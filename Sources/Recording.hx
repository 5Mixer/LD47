package ;

import kha.math.Vector2;
import kha.Scheduler;


class Recording {
    public var recordingStartTime = 0.;
    var lastFrame = 0.;
    var frames:Array<CarFrame> = [];
    var active = true;
    public function new() {
        recordingStartTime = kha.Scheduler.realTime();
    }
    public function asBytes () {
        var bytes = haxe.io.Bytes.alloc(frames.length*4*4);
        var i = 0;
        var frameSize = 4 + 4 + 4 + 4;
        for (frame in frames) {
            bytes.setInt32(i*frameSize, frame.x);
            bytes.setInt32(i*frameSize+4, frame.y);
            bytes.setInt32(i*frameSize+8, frame.angle);
            bytes.setInt32(i*frameSize+12, frame.time);
            i++;
        }
        return bytes;
    }

    public function startRecording() {
        frames = [];
        active = true;
    }
    public function stopRecording() {
        active = false;
        return frames;
    }
    public function record(frame:CarFrame){
        if (!active)
            return;
        
        var last = frames[frames.length-1];
        var farFromLast = false;

        if (last != null) {
            if (new Vector2(frame.x-last.x,frame.y-last.y).length > 15)
                farFromLast = true;
        }

        if (Scheduler.realTime() - lastFrame > 1/6 || farFromLast) {
            lastFrame = Scheduler.realTime();
            frames.push(frame);
        }
    }
}