package ;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;

class Player extends Entity
{
    inline static var SPEED = 5.0;

    public function new(x:Float=0, y:Float=0)
    {
        super(x, y);
        var g = Image.createRect(40, 50);
        graphic = g;
        setHitboxTo(g);
    }

    override public function update():Void
    {
        super.update();

        HXP.point.x = 0;
        HXP.point.y = 0;
        var movement = [
            { name:"up", x:0, y:-1 },
            { name:"down", x:0, y:1 },
            { name:"left", x:-1, y:0 },
            { name:"right", x:1, y:0 },
        ];
        for (m in movement)
        {
            if (Input.check(m.name))
            {
                HXP.point.x += m.x;
                HXP.point.y += m.y;
            }
        }

        HXP.point.normalize(SPEED);

        moveBy(HXP.point.x, HXP.point.y);
    }

}