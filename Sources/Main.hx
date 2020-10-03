package;

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

class Main {
	var car:PlayerCar;
	var cars:Array<Car> = [];
	var flags:LapFlags;
	var camera:Camera;
	var input:Input;
	var lastTime:Float;
	var world:World;
	var gold:Array<Gold> = [];
	var raceFlags:Array<LapFlags> = [];

	var wasOnFlag = false;

	public function new() {
		car = new PlayerCar();
		world = new World();
		flags = new LapFlags(new Vector2());

		for (flagLocation in world.flagLocations)
			raceFlags.push(new LapFlags(flagLocation));
		
		for (goldLocation in world.goldLocations)
			gold.push(new Gold(goldLocation));

		camera = new Camera();
		input = new Input(camera);
		input.onRightDown = function() {
			car.movementAngle = car.angle;
		}
		input.onRightUp = function() {
			car.speed += 300;
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
					cars.push(new RecordCar(frames));
				};
				req.onError = function(s) trace(s);
				req.onStatus = function(s) {
					trace("Request for race " + race.id + " returned status "+s);
				}

				req.request();

			}
		});
	}
	function update(): Void {
		var delta = Scheduler.realTime() - lastTime;
		car.update(delta);
		car.driveTo(input.getMouseWorldPosition());
		car.accelerating = input.leftMouseButtonDown;
		car.sliding = input.rightMouseButtonDown;

		camera.position = car.position.mult(camera.scale).sub(new Vector2(kha.Window.get(0).width/2, kha.Window.get(0).height/2));

		for (piece in gold)
			piece.update(delta);
		for (car in cars)
			car.update(delta);

		for (piece in gold)
			if (piece.active)
				if (piece.getCollider().testPolygon(car.getCollider()) != null){
					piece.collect();
				}

		for (piece in gold)
			if (piece.active)
				for (car in cars)
					if (piece.getCollider().testPolygon(car.getCollider()) != null){
						piece.collect();
					}

		lastTime = Scheduler.realTime();

		var touchingFlag = (SAT2D.testPolygonVsPolygon(car.getCollider(), flags.getCollider()) != null);
		if (touchingFlag && !wasOnFlag) {
			var frames = car.recording.stopRecording();
			var newCar = new RecordCar(frames);
			cars.push(newCar);

			var req = new haxe.Http("http://localhost:3000/cars");
			req.setPostBytes(car.recording.asBytes());
			req.onData = function(s) trace(s);
			req.onError = function(s) trace(s);
			req.onStatus = function(s) trace(s);

			req.request(true);
		}
		wasOnFlag = touchingFlag;
	}

	function render(framebuffer: Framebuffer): Void {
		var g = framebuffer.g2;
		g.begin(kha.Color.fromBytes(84, 214, 118));
		camera.transform(g);
        g.drawImage(kha.Assets.images.track,0,0);
		car.render(g);

		for (piece in gold)
			piece.render(g);
		for (car in cars)
			car.render(g);
		for (flag in raceFlags)
			flag.render(g);


		for (lap in world.lapPolygons)
			if (SAT2D.testCircleVsPolygon(new Circle(input.getMouseWorldPosition().x, input.getMouseWorldPosition().y,1),lap.polygon) != null){
				g.drawImage(kha.Assets.images.lap, lap.point.x-kha.Assets.images.lap.width/2, lap.point.y-kha.Assets.images.lap.height);
			}


		flags.render(g);
		camera.reset(g);

		g.end();
	}

	public static function main() {
		System.start({title: "Car Game", width: 800, height: 600}, function (_) {
			// Just loading everything is ok for small projects
			Assets.loadEverything(function () {
				var game = new Main();
				// Avoid passing update/render directly,
				// so replacing them via code injection works
				Scheduler.addTimeTask(function () { game.update(); }, 0, 1 / 60);
				System.notifyOnFrames(function (framebuffers) { game.render(framebuffers[0]); });
			});
		});
	}
}
