package ;

import kha.Scheduler;
import kha.math.Vector2;
import kha.math.FastMatrix3;

class PlayerCar extends Car {

    public var speed = 1.;
    var acceleration = 1;
    var deceleration = 1;
    var minSpeed = 10.;
    var maxSpeed = 140.;
    var maxAngleDelta = 5*Math.PI/180;
    public var accelerating = false;
    public var sliding = false;

    public var movementAngle = 0.;
    var slidingFactor = 0.;

    public var recording:Recording = new Recording();

    override public function update(delta:Float) {
        if (player) {
            if (angle > Math.PI) angle -= 2*Math.PI;
            else if (angle < -Math.PI) angle += 2*Math.PI;

            recording.record(new CarFrame(Math.round(position.x*1000),Math.round(position.y*1000), Math.round(angle*180/Math.PI), Math.round(((Scheduler.realTime()-recording.recordingStartTime)*10000))));
        }

        if (accelerating) {
            speed += acceleration;
        }else{
            speed -= deceleration;
        }
        speed = Math.max(minSpeed, speed);
        if (speed > maxSpeed) {
            speed = speed *.95 + maxSpeed * .05;
        }

        maxAngleDelta = (5*Math.PI/180) - (speed/maxSpeed) * (2 * Math.PI/180);

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

    public function driveTo(point:Vector2) {
        var delta = position.sub(point);
        var targetAngle = Math.atan2(delta.y, delta.x);
        var angleDelta = targetAngle - angle;

        if (angleDelta > Math.PI) angle += 2*Math.PI;
        else if (angleDelta < -Math.PI) angle -= 2*Math.PI;

        angle = (angle*.9 + targetAngle*.1);
        
        if (angle > Math.PI) angle -= 2*Math.PI;
        else if (angle < -Math.PI) angle += 2*Math.PI;
    }

}