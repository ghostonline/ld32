package ;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;
import com.haxepunk.HXP;
import openfl.geom.Rectangle;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Graphiclist;

class Hud extends Entity
{

    public var fat(default, null):Int;

    var maxFat:Int;
    var fatBar:Bar;
    var fatBarWidth:Int;
    var heart:Image;

    public function new(maxFat:Int)
    {
        super();
        this.maxFat = maxFat;
        fat = maxFat;

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

}