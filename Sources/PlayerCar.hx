package ;

import kha.Scheduler;
import kha.math.Vector2;

class PlayerCar extends Car {

    public var speed = 1.;
    public var accelerating = false;
    public var sliding = false;

    public var movementAngle = 0.;
    var slidingFactor = 0.;

    var trackColor:kha.Color;

    public var recording:Recording = new Recording();

    override public function update(delta:Float) {
        super.update(delta);
        if (angle > Math.PI) angle -= 2*Math.PI;
        else if (angle < -Math.PI) angle += 2*Math.PI;

        recording.record(new CarFrame(Math.round(position.x*1000),Math.round(position.y*1000), Math.round(angle*180/Math.PI), Math.round(((Scheduler.realTime()-recording.recordingStartTime)*10000))));

        if (accelerating) {
            speed += getAcceleration();
        }else{
            speed -= getAcceleration();
        }
        speed = Math.max(0, speed);
        if (speed > getMaxSpeed()) {
            speed = speed *.95 + getMaxSpeed() * .05;
        }

        maxAngleDelta = (5*Math.PI/180) - (speed/getMaxSpeed()) * (2 * Math.PI/180);

        if (sliding) {
            slidingFactor = 1;
        
            if (angle-movementAngle > Math.PI) movementAngle += 2*Math.PI;
            else if (angle-movementAngle < -Math.PI) movementAngle -= 2*Math.PI;

            movementAngle = movementAngle * .99 + angle * .01;
        }else{
            slidingFactor = slidingFactor*.9;
        }

        // Use a pixel based check to determine whether the player is on the gray tracks
        var col = kha.Assets.images.track.at(Std.int(position.x),Std.int(position.y));
        var lowerValue = 107;
        var upperValue = 115;

        var onTrack = col.Rb >= lowerValue && col.Rb <= upperValue
                   && col.Gb >= lowerValue && col.Gb <= upperValue
                   && col.Bb >= lowerValue && col.Bb <= upperValue;

        // If the player is on a track, determine whether they've entered another track
        if (onTrack) {
            if (trackColor == null) {
                trackColor = col;
            }else if (trackColor != col) {
                // position = new Vector2();
            }
        }else{
            speed *= .98;
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