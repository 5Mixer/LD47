package ;

import kha.math.FastMatrix3;
import kha.graphics2.Graphics;
import kha.math.Vector2;

class UIPanel {
    var gold:Int;
    var user:String;
    var cars:Array<Car> = [];
    var contentsOffset = 0.;
    var contentHeight = 0.;
    var garageUser = null;
    public static var width:Int = 300;

    public function new(garageUser) {
        this.garageUser = garageUser;
    }
    public function setGold(gold:Int) {
        this.gold = gold;
    }
    public function setUser(user:String) {
        this.user = user;
    }
    public function setCars(cars:Array<Car>) {
        this.cars = cars;
    }
    public function scroll(delta) {
        var panelSize = new Vector2(width, kha.Window.get(0).height);

        contentsOffset += delta*40;
        contentsOffset = Math.max(0, contentsOffset);
        contentsOffset = Math.min(contentHeight-panelSize.y, contentsOffset);
    }

    public function render(g:kha.graphics2.Graphics) {
        var panelSize = new Vector2(width, kha.Window.get(0).height);
        var panelPosition = new Vector2(kha.Window.get(0).width-panelSize.x, 0);
        var margin = 20;

        var y = panelPosition.y + margin;

        var backgroundColor = kha.Color.fromBytes(50,50,50);
        var textColour = kha.Color.fromBytes(240,240,240);
        g.font = kha.Assets.fonts.FredokaOne_Regular;

        // Fill background
        g.color = backgroundColor;
        g.fillRect(panelPosition.x, panelPosition.y, panelSize.x, panelSize.y);

        g.pushTransformation(FastMatrix3.translation(0,-contentsOffset));
        // Draw username
        g.color = textColour;
        g.fontSize = 40;
        g.drawString(user, panelPosition.x + margin, y);
        y += g.fontSize + margin;

        // Draw gold display
        g.color = kha.Color.White;
        g.drawScaledImage(kha.Assets.images.gold, panelPosition.x + margin, y, kha.Assets.images.gold.width*3,kha.Assets.images.gold.height*3);
        g.color = textColour;
        g.fontSize = 40;
        g.font = kha.Assets.fonts.FredokaOne_Regular;
        g.drawString("$"+gold, panelPosition.x + margin + kha.Assets.images.gold.width*3 + margin, y);
        y += g.fontSize + margin;

        // Draw cars
        for (car in cars) {
            if (car.meta.owner != garageUser) // Only show cars belonging to the player
                continue;

            g.color = textColour;
            g.fontSize = 30;
            g.font = kha.Assets.fonts.FredokaOne_Regular;
            g.drawString("Speed", panelPosition.x + margin, y);
            drawStat(g, panelPosition.x + panelSize.x - margin - (8+5)*4, y, car.meta.speed);
            y += g.fontSize + margin;

            g.color = textColour;
            g.fontSize = 30;
            g.font = kha.Assets.fonts.FredokaOne_Regular;
            g.drawString("Acceleration", panelPosition.x + margin, y);
            drawStat(g, panelPosition.x + panelSize.x - margin - (8+5)*4, y, car.meta.acceleration);
            y += g.fontSize + margin;

            g.color = textColour;
            g.fontSize = 30;
            g.font = kha.Assets.fonts.FredokaOne_Regular;
            g.drawString("Boost", panelPosition.x + margin, y);
            drawStat(g, panelPosition.x + panelSize.x - margin - (8+5)*4, y, car.meta.boost);
            y += g.fontSize + margin;

            y += margin;
        }
        contentHeight = y;
        g.popTransformation();
    }
    function drawStat(g:Graphics, x,y,filledBars,bars=5){
        var barSize = new Vector2(8,15);
        var spacing = 5;
        for (i in 0...bars) {
            var filled = (i + 1) <= filledBars;
            g.drawSubImage(kha.Assets.images.bar,Math.floor(x+i*(barSize.x+spacing)), Math.floor(y+barSize.y/2), filled ? barSize.x : 0, 0, barSize.x, barSize.y);
        }
        g.color = kha.Color.White;
    }
}