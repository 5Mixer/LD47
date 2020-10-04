package ;

import differ.shapes.Polygon;
import kha.math.Vector2;

class World {
    public var goldLocations:Array<Vector2> = [];
    public var flagLocations:Array<Vector2> = [];
    public var lapPolygons:Array<{id:String,point:Vector2, polygon:differ.shapes.Polygon}> = [];
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
            
            if (objectLayer.get("name") == "laps")
                for (object in objectLayer.elements()) {
                    var offset = new Vector2(Std.parseInt(object.get("x")), Std.parseInt(object.get("y")));
                    var vertices = [];
                    var midpoint = new Vector2();
                    for (point in object.elementsNamed("polygon").next().get("points").split(" ")) {
                        var localPoint = new Vector2(Std.parseInt(point.split(",")[0]), Std.parseInt(point.split(",")[1]));
                        vertices.push(new differ.math.Vector(localPoint.x + offset.x, localPoint.y + offset.y));
                        midpoint = midpoint.add(new Vector2(localPoint.x + offset.x, localPoint.y + offset.y));
                    }
                    midpoint = midpoint.div(vertices.length);
                    lapPolygons.push({
                        id: object.elementsNamed("properties").next().elements().next().get("value"),
                        point: midpoint,
                        polygon: new Polygon(0, 0, vertices)
                    });
                }
        }
    }
}