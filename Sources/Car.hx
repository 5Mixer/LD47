package ;

import kha.math.Vector2;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;

class Car implements Collider {
    public var position:Vector2 = new Vector2();
    var origin:Vector2;
    public var angle:Float;
    var player = false;

    public function new(player=true) {
        position = new Vector2(50,50);
        this.player = player;
    }

    public function getCollider() {
        return differ.shapes.Polygon.rectangle(position.x,position.y, 10,10);
    }
    public function update(delta:Float){}

    public function render(g:Graphics) {
        var sliceSize:Vector2 = new Vector2(9, 6);
        origin = sliceSize.mult(.5);

        g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(position.x , position.y)).multmat(FastMatrix3.rotation(angle-Math.PI)).multmat(FastMatrix3.translation(-position.x - origin.x, -position.y - origin.y)));
        g.drawImage(kha.Assets.images.car, position.x, position.y);
        g.popTransformation();
    }
}