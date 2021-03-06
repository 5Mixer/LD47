package ;

import kha.math.Vector2;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;

class LapFlags implements Collider {
    public var position:Vector2 = new Vector2();
    public var projection:Vector2 = new Vector2();
    var angle = Math.PI/2;
    public var trackId:String;

    public function new(position:Vector2, trackId:String) {
        this.position = position;
        this.trackId = trackId;
    }
    public function render(g:Graphics) {
        var origin = new Vector2(kha.Assets.images.flags.width/2, kha.Assets.images.flags.height/2);

        g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(position.x, position.y)).multmat(FastMatrix3.scale(5,5)).multmat(FastMatrix3.rotation(angle-Math.PI)).multmat(FastMatrix3.translation(-position.x - origin.x, -position.y - origin.y)));
        g.drawImage(kha.Assets.images.flags, position.x, position.y);
        g.popTransformation();
    }
    public function getCollider() {
        var size = new Vector2(kha.Assets.images.flags.width, kha.Assets.images.flags.height);
        var shape = differ.shapes.Polygon.rectangle(position.x, position.y, size.x*5,size.y*5);
        shape.rotation = angle * 180 / Math.PI;
        return shape;
    }
}