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
        for (ii in 1...Tile.NUM_TYPES)
        {
            bag.push(ii);
            bag.push(ii);
        }
        bag.push(0);
        HXP.shuffle(bag);
    }

    public function createTile()
    {
        if (bag.length < 3) { newBag(); }
        var type = bag.pop();
        return new Tile(type);
    }

}