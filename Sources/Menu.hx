package ;

import kha.input.KeyCode;
import kha.input.Keyboard;
import kha.Scheduler;
import kha.math.Vector2;
import kha.Window;
import kha.Framebuffer;

class Menu {
    var username = "";
    public var onPlay:(String)->Void;
    var keyGroup = Scheduler.generateGroupId();
    static inline var maxUsernameLength = 15;

    public function new() {
        Keyboard.get(0).notify(onDown,onUp,onChar);
    }
    function onDown(key:KeyCode) {
        if (key == KeyCode.Backspace) {
            username = username.substring(0, username.length-1);
            Scheduler.removeTimeTasks(keyGroup);
            Scheduler.addTimeTaskToGroup(keyGroup, function() {
                username = username.substring(0, username.length-1);
            }, .3, .05);
        }
        if (key == KeyCode.Return) {
            onPlay(username);
        }
    }
    function onUp(key:KeyCode) {
        Scheduler.removeTimeTasks(keyGroup);
    }
    function onChar(char:String) {
        if (username.length < maxUsernameLength && char != " ")
            username += char;
    }
    public function render(framebuffer:Framebuffer) {
        var g = framebuffer.g2;
        g.begin(kha.Color.White);

        var screenSize = new Vector2(Window.get(0).width, Window.get(0).height);

        g.font = kha.Assets.fonts.FredokaOne_Regular;
        g.fontSize = 65;
        g.color = kha.Color.Black;
        var title = "LD47 - Car Game";
        g.drawString(title, screenSize.x/2 - g.font.width(g.fontSize, title)/2, 100);
        
        g.fontSize = 45;
        var prompt = "Enter Username:";
        g.drawString(prompt, Math.round(screenSize.x/2 - g.font.width(g.fontSize, prompt)/2), 250);
        
        var userString = username + ((Math.round(Scheduler.realTime()) %2 == 0) ? "|" : " ");
        g.drawString(userString, screenSize.x/2 - g.font.width(g.fontSize, username)/2, 300);

        var title = "<Enter> to join";
        g.color = kha.Color.fromFloats(0,0,0,0.5);
        g.fontSize = 30;
        g.drawString(title, screenSize.x/2 - g.font.width(g.fontSize, title)/2, 400);
        
        var title = "By @5mixer";
        g.drawString(title, screenSize.x/2 - g.font.width(g.fontSize, title)/2, 170);

        g.color = kha.Color.White;

        g.end();
    }
    public function update() {

    }
}