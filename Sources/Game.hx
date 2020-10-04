package;

import Car.CarStats;
import differ.shapes.Circle;
import kha.network.HttpMethod;
import haxe.Json;
import kha.network.Http;
import differ.sat.SAT2D;
import kha.math.Vector2;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Game {
	var gold = 1000;

	var car:PlayerCar;
	var trackFlags:LapFlags;

	var cars:Array<Car> = [];
	var goldEntities:Array<Gold> = [];
	var raceFlags:Array<LapFlags> = [];

	var camera:Camera;
	var input:Input;
	var lastTime:Float;
	var world:World;

	var raceMode = false;
	var raceTrackId = null;
	var wasOnFlag = false;

	var ui:UIPanel;

	public function new(user) {
		world = new World();

		ui = new UIPanel();
		ui.setGold(gold);
		ui.setUser(user);

		for (flagLocation in world.flagLocations)
			raceFlags.push(new LapFlags(flagLocation, getTrackAt(flagLocation).id));
		
		for (goldLocation in world.goldLocations)
			goldEntities.push(new Gold(goldLocation));

		camera = new Camera();
		input = new Input(camera);
		input.onRightDown = function() {
			if (raceMode) {
				car.movementAngle = car.angle;
			}
		}
		input.onRightUp = function() {
			if (raceMode) {
				car.speed += 300;
			}
		}
		input.onLeftUp = function() {
			if (!raceMode) {
				if (getHoveredTrack() != null) {
					startRace(getHoveredTrack().id);
				}
			}
		}
		input.onMouseMove = function(dx,dy) {
			if (!raceMode && input.middleMouseButtonDown) {
				camera.position.x -= dx;
				camera.position.y -= dy;
			}
		};
		lastTime = Scheduler.realTime();

		Http.request("localhost", "races", null, 3000, false, HttpMethod.Get, [], function (error, response, body){
			if (error == 1 || response == 0 || body == null) {
				trace("Error reaching server! No races loaded.");
				return;
			}
			var races:Array<{
				id:String
			}> = haxe.Json.parse(body);

			for (race in races){
				var req = new haxe.Http("http://localhost:3000/race/"+race.id);
				req.onBytes = function(data) {
					var frames = [];
					var frameSize = 4+4+4+4;
					for (i in 0...Std.int(data.length/frameSize)) {
						frames.push(new CarFrame(data.getInt32(i*frameSize), data.getInt32(i*frameSize+4), data.getInt32(i*frameSize+8), data.getInt32(i*frameSize+12)));
					}
					var meta = new CarStats(1,1,1,1);
					cars.push(new RecordCar(meta, frames));
				};
				req.onError = function(s) trace(s);
				req.onStatus = function(s) {
					trace("Request for race " + race.id + " returned status "+s);
				}

				req.request();

			}
		});
	}
	public function update(): Void {
		var delta = Scheduler.realTime() - lastTime;

		if (raceMode) {
			car.driveTo(input.getMouseWorldPosition());
			car.accelerating = input.leftMouseButtonDown;
			car.sliding = input.rightMouseButtonDown;

			camera.position = car.position.mult(camera.scale).sub(new Vector2(kha.Window.get(0).width/2, kha.Window.get(0).height/2));
		}

		for (piece in goldEntities)
			piece.update(delta);
		for (car in cars)
			car.update(delta);

		for (piece in goldEntities)
			if (piece.active)
				for (car in cars)
					if (piece.getCollider().testPolygon(car.getCollider()) != null){
						piece.collect();
					}

		lastTime = Scheduler.realTime();

		if (raceMode) {
			var touchingFlag = (SAT2D.testPolygonVsPolygon(car.getCollider(), trackFlags.getCollider()) != null);
			if (touchingFlag && !wasOnFlag) {
				finishRace();
			}
			wasOnFlag = touchingFlag;
		}
	}

	public function render(framebuffer: Framebuffer): Void {
		var g = framebuffer.g2;
		g.begin(true,kha.Color.fromBytes(118,207,124));
		camera.transform(g);
		g.color = kha.Color.White;
		g.drawImage(kha.Assets.images.track,0,0);

		for (piece in goldEntities)
			piece.render(g);
		for (car in cars)
			car.render(g);
		for (flag in raceFlags)
			flag.render(g);

		camera.reset(g);
		if (!raceMode) {
			var track = getHoveredTrack();
			if (track != null) {
				// var bubblePosition = new Vector2(track.point.x-kha.Assets.images.trackBubble.width/2, track.point.y-kha.Assets.images.trackBubble.height);
				var bubblePosition = input.getMouseScreenPosition().sub(new Vector2(kha.Assets.images.trackBubble.width/2, kha.Assets.images.trackBubble.height));
				g.font = kha.Assets.fonts.FredokaOne_Regular;
				g.fontSize = 35;
				g.drawImage(kha.Assets.images.trackBubble, bubblePosition.x, bubblePosition.y);

				g.color = kha.Color.Black;
				var string = "Track "+track.id;
				g.drawString(string, bubblePosition.x+kha.Assets.images.trackBubble.width/2-g.font.width(g.fontSize, string)/2, bubblePosition.y+5);
				g.color = kha.Color.White;
			}
		}

		ui.render(g);

		g.end();
	}
	function getHoveredTrack() {
		return getTrackAt(input.getMouseWorldPosition());
	}
	function getTrackAt(point:Vector2) {
		for (lap in world.lapPolygons)
			if (SAT2D.testCircleVsPolygon(new Circle(point.x,point.y,1),lap.polygon) != null){
				return lap;
			}

		return null;
	}
	function startRace(trackId:String) {
		raceMode = true;
		raceTrackId = getHoveredTrack().id;
		var meta = new CarStats(1,1,1,1);
		car = new PlayerCar(meta);
		cars.push(car);
		for (flag in raceFlags) {
			if (flag.trackId == raceTrackId) {
				trackFlags = flag;
				break;
			}
		}
		car.position = trackFlags.position;
		wasOnFlag = true;
	}
	function finishRace() {
		var frames = car.recording.stopRecording();
		var newCar = new RecordCar(car.meta, frames);
		cars.push(newCar);

		var req = new haxe.Http("http://localhost:3000/cars");
		req.setPostBytes(car.recording.asBytes());
		req.onData = function(s) trace(s);
		req.onError = function(s) trace(s);
		req.onStatus = function(s) trace(s);

		req.request(true);

		raceMode = false;
		raceTrackId = null;
		cars.remove(car);
		car = null;
		trackFlags = null;
	}
}
