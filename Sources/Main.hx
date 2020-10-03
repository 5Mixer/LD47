package;

import js.html.EffectTiming;
import kha.math.Vector2;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Main {
	var car:Car;
	var flags:LapFlags;
	var camera:Camera;
	var input:Input;
	var lastTime:Float;
	public function new() {
		car = new Car();
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
	}
	function update(): Void {
		var delta = Scheduler.realTime() - lastTime;
		car.update(delta);
		car.driveTo(input.getMouseWorldPosition());
		car.accelerating = input.leftMouseButtonDown;
		car.sliding = input.rightMouseButtonDown;

		camera.position = car.position.mult(camera.scale).sub(new Vector2(kha.Window.get(0).width/2, kha.Window.get(0).height/2));

		lastTime = Scheduler.realTime();
	}

	function render(framebuffer: Framebuffer): Void {
		var g = framebuffer.g2;
		g.begin(kha.Color.fromBytes(84, 214, 118));
		camera.transform(g);
        g.drawImage(kha.Assets.images.track,0,0);
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
