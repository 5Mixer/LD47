package ;

import kha.math.Vector2;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;

class LapFlags {
    public var position:Vector2 = new Vector2();
    public var projection:Vector2 = new Vector2();
    var angle = 0;

    public function new() {
        position = new Vector2(50,50);
    }
    public function render(g:Graphics) {
        var sliceSize:Vector2 = new Vector2(15, 2);
        var origin = sliceSize.mult(.5);

        g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(position.x, position.y)).multmat(FastMatrix3.scale(5,5)).multmat(FastMatrix3.rotation(angle-Math.PI)).multmat(FastMatrix3.translation(-position.x - origin.x, -position.y - origin.y)));
        g.drawImage(kha.Assets.images.flags, position.x, position.y);
        g.popTransformation();
    }

}