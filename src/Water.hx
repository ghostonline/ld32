package ;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;

class Water extends Entity
{
    inline static var SPEED = 250.0;

    var img:Image;
    var targetHeight:Int;

    public function new(x:Float, y:Float, width:Float)
    {
        super(x, y);
        img = Image.createRect(Math.round(width), 1, 0xAAAAFF, 0.5);
        img.scaleY = 0;
        img.originY = 1;
        graphic = img;
        layer = ZOrder.Water.getIndex();
    }

    public function setHeight(height:Int)
    {
        targetHeight = height;
    }

    override public function update():Void
    {
        super.update();

        if (Math.round(img.scaleY) != targetHeight)
        {
            var max = targetHeight - img.scaleY;
            var dir = HXP.sign(max);
            max = Math.abs(max);
            var rise = Math.min(SPEED * HXP.elapsed, max);
            img.scaleY += rise * dir;
        }
    }

}