package ;

import kha.System;
import kha.Assets;
import kha.Scheduler;

class Main {
	public static function main() {
		System.start({title: "LD47 - Car Game", width: 800, height: 600}, function (_) {
			// Just loading everything is ok for small projects
			Assets.loadEverything(function () {
                var user = "@5mixer";
                var game = new Game(user);
                var menu = new Menu();
                menu.onPlay = function(username) {
                    user = username;
                };

				Scheduler.addTimeTask(function () {
                    if (user == null) {
                        menu.update();
                    }else{
                        game.update();
                    }
                }, 0, 1 / 60);
                System.notifyOnFrames(function (framebuffers) {
                    if (user == null) {
                        menu.render(framebuffers[0]);
                    }else{
                        game.render(framebuffers[0]);
                    }
                });
			});
		});
    }
}