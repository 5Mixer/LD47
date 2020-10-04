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
	var car:PlayerCar;
	var trackFlags:LapFlags;

	var cars:Array<Car> = [];
	var garageCars:Array<CarStats> = [];
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
	var user:String;

	var mouseCollider:differ.shapes.Circle;

	public function new(user) {
		world = new World();
		this.user = user;

		camera = new Camera();
		input = new Input(camera);

		mouseCollider = new differ.shapes.Circle(0,0,1);

		ui = new UIPanel(user,input);
		ui.setUser(user);
		ui.setCars(cars);
		ui.setGarageCars(garageCars);
		ui.buyCar = function() {
			ui.gold -= 1000;
			garageCars.push(new CarStats(1,1,1,1,user));
		}

		for (flagLocation in world.flagLocations){
			raceFlags.push(new LapFlags(flagLocation, getTrackAt(flagLocation).id));
			getTrackAt(flagLocation).point = flagLocation;
		}
		
		for (goldLocation in world.goldLocations)
			goldEntities.push(new Gold(goldLocation));

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
		input.onLeftDown = function() {
			if (!raceMode && !mouseInUI()) {
				if (getHoveredTrack() != null) {
					startRace(getHoveredTrack().id);
				}
			}
			if (mouseInUI()) {
				ui.click(input.getMouseScreenPosition());
			}
		}
		input.onMouseMove = function(dx,dy) {
			if (!raceMode && input.middleMouseButtonDown) {
				camera.position.x -= dx;
				camera.position.y -= dy;
			}
		};
		input.onScroll = function(delta) {
			if (mouseInUI()) {
				ui.scroll(delta);
			}else{
				camera.zoomOn(input.getMouseScreenPosition(), delta);
			}
		}
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
					var meta = new CarStats(1,1,1,1, "OTHER");
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

		mouseCollider.x = input.getMouseWorldPosition().x;
		mouseCollider.y = input.getMouseWorldPosition().y;

		var screenSize = new Vector2(kha.Window.get(0).width, kha.Window.get(0).height);

		if (raceMode) {
			car.driveTo(input.getMouseWorldPosition());
			car.accelerating = input.leftMouseButtonDown;
			car.sliding = input.rightMouseButtonDown;
			camera.position = car.position.mult(camera.scale).sub(screenSize.mult(.5));
		}
		
		camera.position.x = Math.max(0, camera.position.x);
		camera.position.y = Math.max(-200, camera.position.y); // Hardcode extra space for upper race bubbles
		camera.position.x = Math.min(kha.Assets.images.track.width*camera.scale-(screenSize.x-UIPanel.width), camera.position.x);
		camera.position.y = Math.min(kha.Assets.images.track.height*camera.scale-screenSize.y, camera.position.y);

		for (piece in goldEntities)
			piece.update(delta);
		for (car in cars)
			car.update(delta);

		for (piece in goldEntities)
			if (piece.active)
				for (car in cars)
					if (Math.abs(car.position.x-piece.position.x)+Math.abs(car.position.y-piece.position.y) < 40) // Quick phase check
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
		for (flag in raceFlags)
			flag.render(g);
		for (car in cars)
			car.render(g);

		camera.reset(g);
		if (!raceMode) {
			var track = getHoveredTrack();
			if (track != null) {
				var bubblePosition = camera.worldToView(track.point).sub(new Vector2(kha.Assets.images.trackBubble.width/2, kha.Assets.images.trackBubble.height));
				// var bubblePosition = input.getMouseScreenPosition().sub(new Vector2(kha.Assets.images.trackBubble.width/2, kha.Assets.images.trackBubble.height));
				g.font = kha.Assets.fonts.FredokaOne_Regular;
				g.fontSize = 35;
				g.drawImage(kha.Assets.images.trackBubble, bubblePosition.x, bubblePosition.y);

				g.color = kha.Color.Black;
				var string = "Track "+track.id;
				g.drawString(string, bubblePosition.x+kha.Assets.images.trackBubble.width/2-g.font.width(g.fontSize, string)/2, bubblePosition.y+5);
				g.color = kha.Color.White;
			}
		}

		if (!raceMode) {
			ui.render(g);
		}

		g.end();
	}
	function getHoveredTrack() {
		for (lap in world.lapPolygons)
			if (mouseCollider.testPolygon(lap.polygon) != null){
				return lap;
			}
		return null;
	}
	function getTrackAt(point:Vector2) {
		for (lap in world.lapPolygons)
			if ((new differ.shapes.Circle(point.x,point.y,1)).testPolygon(lap.polygon) != null){
				return lap;
			}

		return null;
	}
	function startRace(trackId:String) {
		raceMode = true;
		raceTrackId = getHoveredTrack().id;
		var meta = new CarStats(1,1,1,1,user);
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
	function mouseInUI() {
		return !raceMode && input.getMouseScreenPosition().x >= kha.Window.get(0).width-UIPanel.width;
	}
}
