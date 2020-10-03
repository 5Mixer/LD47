package ;

import kha.graphics2.Graphics;
import kha.math.Vector2;

class Gold implements Collider {
    public var active = true;
    var position:Vector2;
    var reactivationTimer = 0.;
    public function new(position:Vector2) {
        this.position = position;
    }
    public function update(delta:Float) {
        if (reactivationTimer <= 0) {
            active = true;
            reactivationTimer = 0;
        }else{
            reactivationTimer -= delta;
        }
    }
    public function render(g:Graphics) {
        if (active)
            g.drawImage(kha.Assets.images.gold, position.x, position.y);
    }
    public function getCollider() {
        return differ.shapes.Polygon.rectangle(position.x,position.y, 10,10);
    }
    public function collect() {
        active = false;
        reactivationTimer = 5 + Math.random() * 5;
    }
}