package ;

import kha.math.Vector2;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;

class Car {
    var position:Vector2 = new Vector2();
    var origin:Vector2;
    var angle:Float;

    var speed = 1.;
    var acceleration = 1;
    var deceleration = 1;
    var minSpeed = 10.;
    var maxSpeed = 200.;
    var maxAngleDelta = 5*Math.PI/180;
    public var boosting = false;

    public function new() {
        position = new Vector2(50,50);
    }

    public function update(delta:Float) {
        if (boosting) {
            speed += acceleration;
        }else{
            speed -= deceleration;
        }
        speed = Math.min(maxSpeed, Math.max(minSpeed, speed));

        var movement = new Vector2(Math.cos(angle-Math.PI) * speed * delta, Math.sin(angle-Math.PI) * speed * delta);
        position = position.add(movement);
    }

    public function render(g:Graphics) {
        var sliceSize:Vector2 = new Vector2(9, 6);
        origin = sliceSize.mult(.5);

        g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(position.x + origin.x, position.y + origin.y)).multmat(FastMatrix3.rotation(angle-Math.PI)).multmat(FastMatrix3.translation(-position.x - origin.x, -position.y - origin.y)));
        var slices = Math.floor(kha.Assets.images.car.height/sliceSize.y);
        for (slice in 0...slices) {
            g.drawSubImage(kha.Assets.images.car, position.x, position.y, 0, kha.Assets.images.car.height-slice*sliceSize.y, sliceSize.x, sliceSize.y);
        }
        g.popTransformation();
    }

    public function driveTo(point:Vector2) {
        var delta = position.sub(point);
        var targetAngle = Math.atan2(delta.y, delta.x);
        var angleDelta = targetAngle - angle;

        if (angleDelta > Math.PI) angle += 2*Math.PI;
        else if (angleDelta < -Math.PI) angle -= 2*Math.PI;

        if (Math.abs(angleDelta) > maxAngleDelta) {
            angle += maxAngleDelta * (angleDelta > 0 ? 1 : -1);
        }else{
            angle += angleDelta;
        }
    }
}