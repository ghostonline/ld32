package ;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;

class Cat extends Entity
{
    static inline var MAX_OWNER_DISTANCE = 50;
    static inline var SPEED = 4.0;

    var owner:Player;
    public function new(owner:Player)
    {
        super(owner.x - MAX_OWNER_DISTANCE, owner.y);
        this.owner = owner;
        var g = Image.createRect(30, 20);
        g.originX = g.width / 2;
        g.originY = g.height;
        graphic = g;
        setHitboxTo(g);
    }

    override public function update():Void
    {
        super.update();

        if (HXP.distance(x, y, owner.x, owner.y) > MAX_OWNER_DISTANCE)
        {
            HXP.point.setTo(x, y);
            HXP.point2.setTo(owner.x, owner.y);
            var diff = HXP.point2.subtract(HXP.point);
            diff.normalize(MAX_OWNER_DISTANCE);

            HXP.point2.offset(diff.x, diff.y);
            moveTowards(HXP.point2.x, HXP.point2.y, SPEED);
        }
    }
}