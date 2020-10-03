package ;

import kha.Scheduler;

class RecordCar extends Car {
    var startLapTime = 0.;
    var frameIndex = 0;
    var frames:Array<CarFrame>;
    public function new (frames:Array<CarFrame>) {
        super(false);
        startLapTime = Scheduler.realTime();
        this.frames = frames;
    }
    override public function update(delta){

        if (frames[frameIndex+1].time/10000 < Scheduler.realTime() - startLapTime) {
            frameIndex++;

            if (frameIndex+1 >= frames.length) {
                frameIndex = 0;
                startLapTime = Scheduler.realTime();
            }
        }

        var frame = frames[frameIndex];
        var nextFrame = frames[frameIndex == frames.length-1 ? frameIndex : frameIndex + 1];

        var frameProgress = (Scheduler.realTime()-startLapTime-(frame.time/10000))/((nextFrame.time-frame.time)/10000);

        position.x = nextFrame.x*(frameProgress) + frame.x*(1-frameProgress);
        position.y = nextFrame.y*(frameProgress) + frame.y*(1-frameProgress);
        

        var offset = 0;
        if (nextFrame.angle-frame.angle > 180) offset -= 360;
        else if (nextFrame.angle-frame.angle < -180) offset += 360;

        angle = ((nextFrame.angle+offset)*(frameProgress) + frame.angle*(1-frameProgress))*Math.PI/180;
        
        if (angle > Math.PI) angle -= 2*Math.PI;
        else if (angle < -Math.PI) angle += 2*Math.PI;
    }
}