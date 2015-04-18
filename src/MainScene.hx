import com.haxepunk.HXP;
import com.haxepunk.Scene;

class MainScene extends Scene
{
    static inline var ROWS = 10;
    static inline var COLUMNS = 10;
    static inline var TILE_SIZE = 30;

    var board:Array<Tile>;

	public override function begin()
	{
        board = new Array<Tile>();

        var generator = new TileGenerator();

        var boardX = (HXP.width - TILE_SIZE * COLUMNS) / 2;
        var boardY = (HXP.height - TILE_SIZE * ROWS) / 2;
        for (row in 0...ROWS)
        {
            for (col in 0...COLUMNS)
            {
                var top = [getTile(col, row - 1), getTile(col, row - 2)];
                var prev = [getTile(col - 1, row), getTile(col - 2, row)];
                var t = generator.createTile();
                while (
                        (row > 1 && col > 1) &&
                        ((prev[0].typeIdx == t.typeIdx && prev[1].typeIdx == t.typeIdx) ||
                        (top[0].typeIdx == t.typeIdx && top[1].typeIdx == t.typeIdx))
                        )
                       {
                           t = generator.createTile();
                       }

                t.x = boardX + row * TILE_SIZE;
                t.y = boardY + col * TILE_SIZE;
                add(t);
                board.push(t);
            }
        }
	}

    function getTile(x:Int, y:Int)
    {
        return board[x + y * COLUMNS];
    }
}