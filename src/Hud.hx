package ;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;
import com.haxepunk.HXP;
import openfl.geom.Rectangle;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Graphiclist;

class Hud extends Entity
{
    inline static var BEATSPEED = 0.5;

    public var fat(default, null):Int;

    var maxFat:Int;
    var fatBar:Bar;
    var fatBarWidth:Int;
    var heart:Image;
    var beat:Float;

    public function new(maxFat:Int)
    {
        super();
        this.maxFat = maxFat;
        fat = maxFat;
        beat = 0;

        var barX = 50;
        var barY = 60;
        fatBarWidth = HXP.width - barX * 2;
        graphic = new Graphiclist();

        {
            var bar = new Bar("graphics/bar_outline.png", fatBarWidth, 36);
            bar.x = barX;
            bar.y = barY;
            addGraphic(bar);
        }

        {
            fatBar = new Bar("graphics/bar_inner.png", fatBarWidth, 23);
            fatBar.x = barX;
            fatBar.y = barY;
            addGraphic(fatBar);
        }

        heart = new Image("graphics/heart.png");
        heart.centerOrigin();
        heart.x = barX;
        heart.y = barY + 1;
        addGraphic(heart);


        updateGUI();
    }

    function beatFunc(x:Float)
    {
        return Math.max(-Math.pow(2 * x - 1, 2) + 1, 0);
    }

    function updateGUI()
    {
        var factor = 1 - (fat / maxFat);
        fatBar.setWidth(Math.round(factor * fatBarWidth));
    }

    public function addScore(points:Int)
    {
        fat = Math.round(HXP.clamp(fat - points, 0, maxFat));
        updateGUI();
    }

    override public function update():Void
    {
        super.update();

        beat += BEATSPEED * HXP.elapsed;
        while (beat > 1) { beat -= 1; }
        var hScale = 1 - 0.1 * beatFunc(beat * 3);
        heart.scale = hScale;
    }
}