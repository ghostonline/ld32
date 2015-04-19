package ;

import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.Image;
import com.haxepunk.Mask;
import com.haxepunk.tweens.motion.LinearMotion;
import com.haxepunk.utils.Ease;

class Tile extends Entity
{
    public static inline var NUM_TYPES = 5;

    static var images = [
        "burger",
        "apple",
        "banana",
        "carrot",
        "pear",
    ];

    public var typeIdx(default, null):Int;
    var image:Image;
    var motion:LinearMotion;

    public function new(type:Int)
    {
        super(0, 0);
        image = new Image("graphics/" + images[type] + ".png");
        image.centerOrigin();
        image.originY = image.height - 3;
        var shadow = new Image("graphics/shadow.png");
        shadow.centerOrigin();
        shadow.alpha = 0.5;
        shadow.originY -= 4;
        image.y = shadow.y = 16;

        addGraphic(shadow);
        addGraphic(image);

        setHitboxTo(image);
        layer = ZOrder.Tiles.getIndex();
        this.typeIdx = type;
    }

    public function moveAnimated(x:Float, y:Float, duration:Float)
    {
        if (motion != null) { removeTween(motion); }
        motion = new LinearMotion();
        motion.setMotion(this.x, this.y, x, y, duration, Ease.cubeInOut);
        addTween(motion);
        layer = ZOrder.MovingTiles.getIndex();
    }

    public function setSelected(val:Bool)
    {
        image.angle = val ? 45 : 0;
    }

    override public function update():Void
    {
        super.update();
        if (motion != null)
        {
            x = motion.x;
            y = motion.y;

            if (!motion.active)
            {
                removeTween(motion);
                motion = null;
                layer = ZOrder.Board.getIndex();
            }
        }
    }
}