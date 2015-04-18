import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.utils.Input;

class MainScene extends Scene
{
    static inline var ROWS = 10;
    static inline var COLUMNS = 10;
    static inline var TILE_SIZE = 30;

    var board:Array<Tile>;
    var boardX:Float;
    var boardY:Float;

    var selectedTile:Tile;
    var selectedX:Int;
    var selectedY:Int;

	public override function begin()
	{
        board = new Array<Tile>();

        var generator = new TileGenerator();

        boardX = (HXP.width - TILE_SIZE * COLUMNS) / 2;
        boardY = (HXP.height - TILE_SIZE * ROWS) / 2;
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
                add(t);
                board.push(null);
                setTile(col, row, t);
            }
        }
	}

    function getTile(x:Int, y:Int)
    {
        if (x < 0 || x >= COLUMNS || y < 0 || y >= ROWS) { return null; }
        return board[x + y * COLUMNS];
    }

    function setTile(x:Int, y:Int, tile:Tile)
    {
        if (x < 0 || x >= COLUMNS || y < 0 || y >= ROWS) { return; }
        tile.x = boardX + x * TILE_SIZE + TILE_SIZE / 2;
        tile.y = boardY + y * TILE_SIZE + TILE_SIZE / 2;
        board[x + y * COLUMNS] = tile;
    }

    function setSelected(x:Int, y:Int)
    {
        var tile = getTile(x, y);
        tile.setSelected(true);
        selectedTile = tile;
        selectedX = x;
        selectedY = y;
    }

    function swapTiles(aX:Int, aY:Int, bX:Int, bY:Int)
    {
        var a = getTile(aX, aY);
        var b = getTile(bX, bY);
        setTile(aX, aY, b);
        setTile(bX, bY, a);
    }

    override public function update()
    {
        super.update();

        if (Input.mousePressed)
        {
            var tileX = Math.floor((Input.mouseX - boardX) / TILE_SIZE);
            var tileY = Math.floor((Input.mouseY - boardY) / TILE_SIZE);

            var tile = getTile(tileX, tileY);
            if (tile != null)
            {
                if (selectedTile == null)
                {
                    setSelected(tileX, tileY);
                }
                else if (tileX == selectedX || tileY == selectedY)
                {
                    swapTiles(tileX, tileY, selectedX, selectedY);
                    selectedTile.setSelected(false);
                    selectedTile = null;
                }
            }
        }
    }
}