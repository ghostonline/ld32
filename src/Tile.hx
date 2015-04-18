package ;

import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.Image;
import com.haxepunk.Mask;

class Tile extends Entity
{
    public static inline var NUM_TYPES = 7;

    static var colors = [
        0xFFB300, //Vivid Yellow
        0x803E75, //Strong Purple
        0xFF6800, //Vivid Orange
        0xA6BDD7, //Very Light Blue
        0xC10020, //Vivid Red
        0xCEA262, //Grayish Yellow
        0x817066, //Medium Gray
    ];

    public var typeIdx(default, null):Int;
    var image:Image;

    public function new(type:Int)
    {
        super(0, 0);
        image = Image.createRect(20, 20, colors[type]);
        image.centerOrigin();
        graphic = image;
        setHitboxTo(image);
        this.typeIdx = type;
    }

    public function setSelected(val:Bool)
    {
        image.angle = val ? 45 : 0;
    }

    public function setMatched(val:Bool)
    {
        image.scale = val ? 0.5 : 1;
    }
}