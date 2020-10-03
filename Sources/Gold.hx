package ;

import kha.graphics2.Graphics;
import kha.math.Vector2;

class Gold implements Collider {
    var position:Vector2;
    public function new(position:Vector2) {
        this.position = position;
    }
    public function update(delta:Float) {

    }
    public function render(g:Graphics) {
        g.drawImage(kha.Assets.images.gold, position.x, position.y);
    }
    public function getCollider() {
        return differ.shapes.Polygon.rectangle(position.x,position.y, 10,10);
    }
}