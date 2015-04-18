package ;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;
import com.haxepunk.HXP;

class Hud extends Entity
{

    public var fat(default, null):Int;

    var maxFat:Int;

    var fatLbl:Text;

    public function new(maxFat:Int)
    {
        super();
        this.maxFat = maxFat;
        fat = maxFat;

        fatLbl = new Text("Fat:");
        addGraphic(fatLbl);
        fatLbl.x = 10;
        fatLbl.y = 70;

        updateGUI();
    }

    function updateGUI()
    {
        fatLbl.text = "Fat: " + fat + "/" + maxFat;
    }

    public function addScore(points:Int)
    {
        fat = Math.round(HXP.clamp(fat - points, 0, maxFat));
        updateGUI();
    }

}