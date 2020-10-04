package ;

import kha.math.Vector2;

class UIPanel {
    var gold:Int;
    var user:String;
    var cars:Array<Car> = [];

    public function new() {

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

    public function render(g:kha.graphics2.Graphics) {
        var panelSize = new Vector2(300, kha.Window.get(0).height);
        var panelPosition = new Vector2(kha.Window.get(0).width-panelSize.x, 0);
        var margin = 20;

        var y = panelPosition.y + margin;

        var backgroundColor = kha.Color.fromBytes(240,240,240);
        var textColour = kha.Color.fromBytes(5,5,5);
        g.font = kha.Assets.fonts.FredokaOne_Regular;

        // Fill background
        g.color = backgroundColor;
        g.fillRect(panelPosition.x, panelPosition.y, panelSize.x, panelSize.y);

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
    }
}