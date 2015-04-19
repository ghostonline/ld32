package ;

import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import openfl.geom.Rectangle;

class Bar extends Graphiclist
{
    var width:Int;
    var start:Image;
    var startWidth:Int;
    var middle:Image;
    var end:Image;
    var endWidth:Int;

    public function new(image:String, width:Int, slice:Int)
    {
        start = new Image(image);
        var imgWidth = start.width;
        var imgHeight = start.height;
        startWidth = slice;
        endWidth = imgWidth - slice - 1;

        start = new Image(image, new Rectangle(0, 0, startWidth, imgHeight));
        start.x = -startWidth;
        start.y = imgHeight / -2;
        middle = new Image(image, new Rectangle(startWidth, 0, 1, imgHeight));
        middle.y = imgHeight / -2;
        end = new Image(image, new Rectangle(startWidth + 1, 0, endWidth, imgHeight));
        end.y = imgHeight / -2;

        super([start, middle, end]);

        setWidth(width);
    }

    public function setWidth(width:Int)
    {
        middle.scaleX = width;
        end.x = width;
        this.width = width;
    }

}