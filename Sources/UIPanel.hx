package ;

import Car;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;
import kha.math.Vector2;

class UIPanel {
    public var buyCar:()->Void;

    public var gold:Int = 10000;
    var user:String;
    var cars:Array<Car> = [];
    var garageCars:Array<CarStats> = [];
    var contentsOffset = 0.;
    var contentHeight = 0.;
    var garageUser = null;

    var panelPosition:Vector2;

    var backgroundColor = kha.Color.fromBytes(50,50,50);
    var textColour = kha.Color.fromBytes(240,240,240);

    var margin = 20;
    var input:Input;

    public var carPendingTrackSelection:CarStats = null;

    public static var width:Int = 300;

    var upgradeCosts = [100, 300, 500, 1000, 2000];

    public function new(garageUser, input) {
        this.garageUser = garageUser;
        this.input = input;
    }
    public function setUser(user:String) {
        this.user = user;
    }
    public function setCars(cars:Array<Car>) {
        this.cars = cars;
    }
    public function setGarageCars(cars:Array<CarStats>) {
        this.garageCars = cars;
    }
    public function scroll(delta) {
        var panelSize = new Vector2(width, kha.Window.get(0).height);

        contentsOffset += delta*40;
        contentsOffset = Math.min(contentHeight-panelSize.y, contentsOffset);
        contentsOffset = Math.max(0, contentsOffset);
    }

    var clickPosition:Vector2;
    public function click(position:Vector2) {
        clickPosition = position;
    }

    public function render(g:kha.graphics2.Graphics) {
        var panelSize = new Vector2(width, kha.Window.get(0).height);
        panelPosition = new Vector2(kha.Window.get(0).width-panelSize.x, 0);

        var y = panelPosition.y + margin;
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

        var ownedCars = 0;
        // Draw cars
        var userCars = garageCars.copy();
        for (car in cars){
            if (car.meta.owner != garageUser) // Only show cars belonging to the player
                continue;
            userCars.push(car.meta);
        }
        for (car in userCars) {

            ownedCars++;

            g.color = textColour;
            g.fontSize = 30;
            g.font = kha.Assets.fonts.FredokaOne_Regular;
            g.drawString("Speed", panelPosition.x + margin, y);
            drawStat(g, panelPosition.x + panelSize.x - margin - (8+5)*4, y, car.speed);
            y += g.fontSize + margin;

            g.color = textColour;
            g.fontSize = 30;
            g.font = kha.Assets.fonts.FredokaOne_Regular;
            g.drawString("Acceleration", panelPosition.x + margin, y);
            drawStat(g, panelPosition.x + panelSize.x - margin - (8+5)*4, y, car.acceleration);
            y += g.fontSize + margin;

            g.color = textColour;
            g.fontSize = 30;
            g.font = kha.Assets.fonts.FredokaOne_Regular;
            g.drawString("Boost", panelPosition.x + margin, y);
            drawStat(g, panelPosition.x + panelSize.x - margin - (8+5)*4, y, car.boost);
            y += g.fontSize + margin;
            
            if (car.speed < 5)
                y = drawButton(g, '+Speed [$$${upgradeCosts[car.speed]}]', panelPosition.x+margin, y, gold >= upgradeCosts[car.speed], function() {
                    if (car.speed < 5) {
                        gold -= upgradeCosts[car.speed];
                        car.speed++;
                    }
                });
            
            if (car.acceleration < 5)
                y = drawButton(g, '+Acceleration [$$${upgradeCosts[car.acceleration]}]', panelPosition.x+margin, y, gold >= upgradeCosts[car.acceleration], function() {
                    if (car.acceleration < 5) {
                        gold -= upgradeCosts[car.acceleration];
                        car.acceleration++;
                    }
                });
            
            if (car.boost < 5)
                y = drawButton(g, '+Boost [$$${upgradeCosts[car.boost]}]', panelPosition.x+margin, y, gold >= upgradeCosts[car.boost], function() {
                    if (car.boost < 5) {
                        gold -= upgradeCosts[car.boost];
                        car.boost++;
                    }
                });

            y = drawButton(g, carPendingTrackSelection == car ? "Choose track" : "Race Car", panelPosition.x+margin, y, true, function() {
                if (carPendingTrackSelection == car) {
                    carPendingTrackSelection = null; // Cancel track selection
                }else{
                    carPendingTrackSelection = car;
                }
            });

            y += margin * 3;
        }

        if (ownedCars < 10) {
            y = drawButton(g, "Buy Car [$1000]", panelPosition.x+margin, y, gold>=1000, buyCar);
            y += margin;
        }

        contentHeight = y+10;
        g.popTransformation();

        clickPosition = null;
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
    function drawButton(g:Graphics, string, x, y, valid, onClick:()->Void) {
        var hovering = false;
        var mousePos = input.getMouseScreenPosition();
        if (mousePos.x > panelPosition.x+margin && mousePos.x < panelPosition.x+margin+kha.Assets.images.button.width &&
            mousePos.y +contentsOffset > y && mousePos.y +contentsOffset < y + kha.Assets.images.button.height) {
                hovering = true;
            }

        if (valid)
            g.color = hovering ? kha.Color.fromBytes(241, 172, 107) : kha.Color.fromBytes(218, 124, 100);
        else
            g.color = kha.Color.fromBytes(170,170,170);

        g.drawImage(kha.Assets.images.button, panelPosition.x + margin, y);
        g.color = textColour;
        g.fontSize = 30;
        g.drawString(string, x + kha.Assets.images.button.width/2 - g.font.width(g.fontSize,string)/2, y+5);

        if (clickPosition == null || !valid)
            return y + 50;

        if (clickPosition.x > panelPosition.x+margin && clickPosition.x < panelPosition.x+margin+kha.Assets.images.button.width &&
            clickPosition.y+contentsOffset > y && clickPosition.y+contentsOffset < y + kha.Assets.images.button.height) {

            onClick();
        }

        return y + 50;
    }
}