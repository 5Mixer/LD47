package;

import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Main {
	var car:Car;
	var camera:Camera;
	public function new() {
		car = new Car();
		camera = new Camera();
	}
	function update(): Void {

	}

	function render(framebuffer: Framebuffer): Void {
		var g = framebuffer.g2;
		g.begin(kha.Color.fromBytes(84, 214, 118));
		camera.transform(g);
		car.render(g);
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