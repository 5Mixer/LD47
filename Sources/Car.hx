package ;

import kha.math.Vector2;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;

class Car {
    public var position:Vector2 = new Vector2();
    var origin:Vector2;
    public var angle:Float;

    var speed = 1.;
    var acceleration = 1;
    var deceleration = 1;
    var minSpeed = 10.;
    var maxSpeed = 140.;
    var maxAngleDelta = 5*Math.PI/180;
    public var boosting = false;
    public var sliding = false;

    public var movementAngle = 0.;
    var slidingFactor = 0.;

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

        maxAngleDelta = (5*Math.PI/180) - (speed/maxSpeed) * (2 * Math.PI/180);

        // slidingFactor = slidingFactor * .9 + (sliding ? 1 : 0) * .1;
        // if (!sliding) {
        //     movementAngle = angle;
        // }
        if (sliding) {
            slidingFactor = 1;
        
            if (angle-movementAngle > Math.PI) movementAngle += 2*Math.PI;
            else if (angle-movementAngle < -Math.PI) movementAngle -= 2*Math.PI;

            movementAngle = movementAngle * .99 + angle * .01;
        }else{
            slidingFactor = slidingFactor*.9;
        }


        var movement = new Vector2(Math.cos(movementAngle-Math.PI) * speed * delta, Math.sin(movementAngle-Math.PI) * speed * delta);
        var directMovement = new Vector2(Math.cos(angle-Math.PI) * speed * delta, Math.sin(angle-Math.PI) * speed * delta);
        position = position.add(movement.mult(slidingFactor).add(directMovement.mult(1-slidingFactor)));
    }

    public function render(g:Graphics) {
        var sliceSize:Vector2 = new Vector2(9, 6);
        origin = sliceSize.mult(.5);

        g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(position.x , position.y)).multmat(FastMatrix3.rotation(angle-Math.PI)).multmat(FastMatrix3.translation(-position.x - origin.x, -position.y - origin.y)));
        g.drawImage(kha.Assets.images.car, position.x, position.y);
        g.popTransformation();
    }

    public function driveTo(point:Vector2) {
        var delta = position.sub(point);
        var targetAngle = Math.atan2(delta.y, delta.x);
        var angleDelta = targetAngle - angle;

        if (angleDelta > Math.PI) angle += 2*Math.PI;
        else if (angleDelta < -Math.PI) angle -= 2*Math.PI;

        // if (Math.abs(angleDelta) > maxAngleDelta) {
            // angle += maxAngleDelta * (angleDelta > 0 ? 1 : -1);
            angle = (angle*.9 + targetAngle*.1);
        // }else{
        //     angle += angleDelta;
        // }
    }
}