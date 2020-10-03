package;

import kha.network.HttpMethod;
import haxe.Json;
import kha.network.Http;
import differ.sat.SAT2D;
import js.html.EffectTiming;
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

	var wasOnFlag = false;

	public function new() {
		car = new PlayerCar();
		flags = new LapFlags();
		camera = new Camera();
		input = new Input(camera);
		input.onRightDown = function() {
			car.movementAngle = car.angle;
		}
		input.onRightUp = function() {
			car.speed += 300;
		}
		lastTime = Scheduler.realTime();

		Http.request("localhost", "cars", null, 3000, false, HttpMethod.Get, null, function (error, response, body){
			if (error == 1 || response == 0 || body == null) {
				trace("Error reaching server! No cars loaded.");
				return;
			}
		
			var data:Array<Array<CarFrame>> = haxe.Json.parse(body);
			for (car in data){
				cars.push(new RecordCar(car));
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

		for (car in cars)
			car.update(delta);

		lastTime = Scheduler.realTime();

		var touchingFlag = (SAT2D.testPolygonVsPolygon(car.getCollider(), flags.getCollider()) != null);
		if (touchingFlag && !wasOnFlag) {
			var frames = car.recording.stopRecording();
			trace(frames);
			var newCar = new RecordCar(frames);
			cars.push(newCar);

			var req = new haxe.Http("http://localhost:3000/cars");
			req.setPostData(Json.stringify(frames));
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
		for (car in cars)
			car.render(g);
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
