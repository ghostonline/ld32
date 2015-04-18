import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.utils.Input;

typedef Pos = { x:Int, y:Int };

enum State
{
    Falling;
    Swapping;
    Reacting;
    Idle;
}

class MainScene extends Scene
{
    static inline var ROWS = 10;
    static inline var COLUMNS = 10;
    static inline var TILE_SIZE = 30;
    static inline var SWAP_DURATION = 0.5;

    var board:Array<Tile>;
    var boardX:Float;
    var boardY:Float;

    var selectedTile:Tile;
    var selectedX:Int;
    var selectedY:Int;

    var dirtyBoard:Bool;

    var state:State;
    var animationTimeout:Float;

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

        state = State.Idle;
	}

    function getTile(x:Int, y:Int)
    {
        if (x < 0 || x >= COLUMNS || y < 0 || y >= ROWS) { return null; }
        return board[x + y * COLUMNS];
    }

    function setTile(col:Int, row:Int, tile:Tile)
    {
        if (col < 0 || col >= COLUMNS || row < 0 || row >= ROWS) { return; }
        tile.x = getTileX(col);
        tile.y = getTileY(row);
        board[col + row * COLUMNS] = tile;
    }

    function getTileX(col:Int)
    {
        return boardX + col * TILE_SIZE + TILE_SIZE / 2;
    }

    function getTileY(row:Int)
    {
        return boardY + row * TILE_SIZE + TILE_SIZE / 2;
    }

    function setSelected(x:Int, y:Int)
    {
        var tile = getTile(x, y);
        tile.setSelected(true);
        selectedTile = tile;
        selectedX = x;
        selectedY = y;
    }

    function moveTileSmoothly(tile:Tile, from:Pos, to:Pos, duration:Float)
    {
        tile.x = getTileX(from.x);
        tile.y = getTileY(from.y);
        tile.moveAnimated(getTileX(to.x), getTileY(to.y), duration);
    }

    function swapTiles(aX:Int, aY:Int, bX:Int, bY:Int)
    {
        animationTimeout = SWAP_DURATION;

        var a = getTile(aX, aY);
        var b = getTile(bX, bY);

        setTile(aX, aY, b);
        moveTileSmoothly(b, {x:bX, y:bY}, {x:aX, y:aY}, animationTimeout);

        setTile(bX, bY, a);
        moveTileSmoothly(a, {x:aX, y:aY}, {x:bX, y:bY}, animationTimeout);

        state = State.Swapping;
    }

    function processMatches()
    {
        var sequences = new Array<Array<Pos>>();

        // Horizontal matches
        for (row in 0...ROWS)
        {
            var type = -1;
            var sequence = new Array<Pos>();
            for (col in 0...COLUMNS)
            {
                var tile = getTile(col, row);
                if (tile.typeIdx != type)
                {
                    if (sequence.length >= 3)
                    {
                        sequences.push(sequence);
                    }
                    type = tile.typeIdx;
                    sequence = new Array<Pos>();
                }

                sequence.push( { x:col, y:row } );
            }
        }

        // Vertical matches
        for (col in 0...COLUMNS)
        {
            var type = -1;
            var sequence = new Array<Pos>();
            for (row in 0...ROWS)
            {
                var tile = getTile(col, row);
                if (tile.typeIdx != type)
                {
                    if (sequence.length >= 3)
                    {
                        sequences.push(sequence);
                    }
                    type = tile.typeIdx;
                    sequence = new Array<Pos>();
                }

                sequence.push( { x:col, y:row } );
            }
        }

        for (sequence in sequences)
        {
            for (pos in sequence)
            {
                var tile = getTile(pos.x, pos.y);
                tile.setMatched(true);
            }
        }
    }

    override public function update()
    {
        super.update();
        switch (state)
        {
        case State.Idle:
            updateIdle();
        case State.Swapping:
            updateSwapping();
        default:
            // Do nothing
        }
    }

    function updateIdle()
    {

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

                    dirtyBoard = !(tileX == selectedX && tileY == selectedY);
                }
            }
        }
    }

    function updateSwapping()
    {
        animationTimeout -= HXP.elapsed;

        if (animationTimeout > 0) { return; }

        if (dirtyBoard)
        {
            dirtyBoard = false;
            processMatches();
        }

        state = State.Idle;
    }
}