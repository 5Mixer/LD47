package ;

import kha.math.Vector2;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;

class CarStats {
    public var speed:Int;
    public var acceleration:Int;
    public var boost:Int;
    public var profits:Int;

    public var owner:String;
    public function new(speed, acceleration, boost, profits, owner) {
        this.speed = speed;
        this.acceleration = acceleration;
        this.boost = boost;
        this.profits = profits;
        this.owner = owner;
    }
}

class Car implements Collider {
    public var position:Vector2 = new Vector2();
    var origin:Vector2;
    public var angle:Float;

    var owner:String;

    var maxAngleDelta = 5*Math.PI/180;

    public var meta:CarStats;

    public function new(meta) {
        position = new Vector2(50,50);
        this.meta = meta;
    }
    function getMaxSpeed() {
        return 50 + meta.speed * 25;
    }
    function getAcceleration() {
        return .75 + meta.acceleration * .25;
    }
    function getBoost() {
        return meta.boost;
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