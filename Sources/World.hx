package ;

import kha.math.Vector2;

class World {
    public var goldLocations:Array<Vector2> = [];
    public var flagLocations:Array<Vector2> = [];
    public function new() {
        var data = haxe.xml.Parser.parse(kha.Assets.blobs.map_tmx.toString());
        var map = data.elementsNamed("map").next();
        for (objectLayer in map.elementsNamed("objectgroup")) {
            if (objectLayer.get("name") == "gold")
                for (object in objectLayer.elements())
                    goldLocations.push(new Vector2(Std.parseInt(object.get("x")), Std.parseInt(object.get("y"))));
            
            if (objectLayer.get("name") == "flag")
                for (object in objectLayer.elements())
                    flagLocations.push(new Vector2(Std.parseInt(object.get("x")), Std.parseInt(object.get("y"))));
        }
    }
}