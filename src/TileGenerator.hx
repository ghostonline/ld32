package ;
import com.haxepunk.HXP;

/**
 * ...
 * @author Bart Veldstra
 */
class TileGenerator
{

    var bag:Array<Int>;

    public function new()
    {
        bag = new Array<Int>();
    }

    function newBag()
    {
        for (ii in 0...Tile.NUM_TYPES)
        {
            bag.push(ii);
        }
        HXP.shuffle(bag);
    }

    public function createTile()
    {
        if (bag.length < 1) { newBag(); }
        var type = bag.pop();
        return new Tile(type);
    }

}