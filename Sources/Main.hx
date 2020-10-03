package;

import kha.math.Vector2;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Main {
	var car:Car;
	var camera:Camera;
	var input:Input;
	var lastTime:Float;
	public function new() {
		car = new Car();
		camera = new Camera();
		input = new Input(camera);
		lastTime = Scheduler.realTime();
	}
	function update(): Void {
		var delta = Scheduler.realTime() - lastTime;
		car.update(delta);
		car.driveTo(input.getMouseWorldPosition());
		car.boosting = input.leftMouseButtonDown;

		camera.position = car.position.mult(camera.scale).sub(new Vector2(kha.Window.get(0).width/2, kha.Window.get(0).height/2));

		lastTime = Scheduler.realTime();
	}

	function render(framebuffer: Framebuffer): Void {
		var g = framebuffer.g2;
		g.begin(kha.Color.fromBytes(84, 214, 118));
		camera.transform(g);
        g.drawImage(kha.Assets.images.track,0,0);
		car.render(g);
		g.drawLine(car.position.x,car.position.y,input.getMouseWorldPosition().x,input.getMouseWorldPosition().y);
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
