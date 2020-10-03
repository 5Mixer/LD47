package ;

import kha.math.Vector2;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;

class Car {
    var position:Vector2 = new Vector2();
    var origin:Vector2;
    var angle:Float;

    public function new() {
        position = new Vector2(50,50);
    }

    public function render(g:Graphics) {
        var sliceSize:Vector2 = new Vector2(9, 6);
        origin = sliceSize.mult(.5);

        g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(position.x + origin.x, position.y + origin.y)).multmat(FastMatrix3.rotation(angle)).multmat(FastMatrix3.translation(-position.x - origin.x, -position.y - origin.y)));
        var slices = Math.floor(kha.Assets.images.car.height/sliceSize.y);
        for (slice in 0...slices) {
            g.drawSubImage(kha.Assets.images.car, position.x, position.y, 0, kha.Assets.images.car.height-slice*sliceSize.y, sliceSize.x, sliceSize.y);
        }
        g.popTransformation();
    }
}