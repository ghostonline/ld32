import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.utils.Input;

typedef Pos = { x:Int, y:Int };

enum State
{
    Falling;
    Swapping;
    Reacting;
    Reverting;
    Idle;
}

class MainScene extends Scene
{
    static inline var ROWS = 10;
    static inline var COLUMNS = 10;
    static inline var TILE_SIZE = 30;
    static inline var SWAP_DURATION = 0.25;
    static inline var FALL_DURATION = 0.5;

    var generator:TileGenerator;

    var board:Array<Tile>;
    var boardX:Float;
    var boardY:Float;

    var selectedTile:Tile;
    var selectedX:Int;
    var selectedY:Int;

    var dirtyBoard:Bool;

    var state:State;
    var animationTimeout:Float;

    var swapA:Pos;
    var swapB:Pos;

    var hud:Hud;

    var water:Water;
    var waterLevel:Int;
    var fatPoints:Int;

    var combo:Int;

	public override function begin()
	{
        hud = new Hud(30);
        add(hud);

        board = new Array<Tile>();

        generator = new TileGenerator();

        boardX = (HXP.width - TILE_SIZE * COLUMNS) / 2;
        boardY = (HXP.height - TILE_SIZE * ROWS) / 2;
        for (row in 0...ROWS)
        {
            for (col in 0...COLUMNS)
            {
                var top = [getTile(col, row - 1), getTile(col, row - 2)];
                var prev = [getTile(col - 1, row), getTile(col - 2, row)];
                var t = generator.createTile();
                while ((row > 1 && (top[0].typeIdx == t.typeIdx && top[1].typeIdx == t.typeIdx)) ||
                      (col > 1 && (prev[0].typeIdx == t.typeIdx && prev[1].typeIdx == t.typeIdx)))
                       {
                           t = generator.createTile();
                       }
                add(t);
                board.push(null);
                setTile(col, row, t);
            }
        }

        water = new Water(boardX, boardY + ROWS * TILE_SIZE, COLUMNS * TILE_SIZE);
        add(water);
        waterLevel = 0;

        state = State.Idle;
	}

    function setWaterLevel(level:Int)
    {
        waterLevel = level;
        water.setHeight(level * TILE_SIZE);
    }

    function getTile(x:Int, y:Int)
    {
        if (x < 0 || x >= COLUMNS || y < 0 || y >= ROWS) { return null; }
        return board[x + y * COLUMNS];
    }

    function setTile(col:Int, row:Int, tile:Tile)
    {
        if (col < 0 || col >= COLUMNS || row < 0 || row >= ROWS) { return; }
        if (tile != null)
        {
            tile.x = getTileX(col);
            tile.y = getTileY(row);
        }
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
        swapA = { x:aX, y:aY };
        swapB = { x:bX, y:bY };
        animationTimeout = SWAP_DURATION;

        var a = getTile(aX, aY);
        var b = getTile(bX, bY);

        setTile(aX, aY, b);
        moveTileSmoothly(b, swapB, swapA, animationTimeout);

        setTile(bX, bY, a);
        moveTileSmoothly(a, swapA, swapB, animationTimeout);

        state = State.Swapping;
    }

    function fallTile(tile:Tile, fromX, fromY, toX, toY)
    {
        animationTimeout = FALL_DURATION;
        var startX = getTileX(fromX);
        var startY = getTileY(fromY);
        var stopX = getTileX(toX);
        var stopY = getTileY(toY);
        if (fromX > -1)
        {
            setTile(fromX, fromY, null);
        }
        else
        {
            startX = stopX;
            startY = (startY - boardY) - TILE_SIZE;
        }

        setTile(toX, toY, tile);
        tile.x = startX;
        tile.y = startY;
        tile.moveAnimated(stopX, stopY, animationTimeout);
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

            if (sequence.length >= 3)
            {
                sequences.push(sequence);
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

            if (sequence.length >= 3)
            {
                sequences.push(sequence);
            }

        }

        var grandTotal = 0;

        // Calculate combo multiplier
        for (sequence in sequences)
        {
            var tile = getTile(sequence[0].x, sequence[1].y);
            if (tile != null && tile.typeIdx > 0) { ++combo; }
        }

        for (sequence in sequences)
        {
            var points = 0;
            for (pos in sequence)
            {
                var tile = getTile(pos.x, pos.y);
                if (tile != null)
                {
                    if (tile.typeIdx > 0) { points += 1; }
                    else { points -= 1; }
                    setTile(pos.x, pos.y, null);
                    remove(tile);
                }
            }

            if (points > 0) { points -= 2; points *= combo; }
            else if (points < 0) { fatPoints += points * -1; }

            grandTotal += points;

        }

        trace("Points earned: " + grandTotal + ", multiplier " + combo);

        hud.addScore(grandTotal);
        setWaterLevel(Math.floor(fatPoints / 10));

        if (sequences.length > 0)
        {
            for (col in 0...COLUMNS)
            {
                var emptyY = ROWS - 1;

                while (emptyY >= 0 && getTile(col, emptyY) != null) { --emptyY; }

                if (emptyY >= 0)
                {
                    var lastEmpty = emptyY;

                    for (upwards in 0...emptyY)
                    {
                        var fullY = emptyY - upwards - 1;
                        var tile = getTile(col, fullY);
                        if (tile != null)
                        {
                            fallTile(tile, col, fullY, col, lastEmpty);
                            --lastEmpty;
                        }
                    }

                    for (row in 0...(lastEmpty + 1))
                    {
                        var tile = generator.createTile();
                        add(tile);
                        setTile(col, row, tile);
                        fallTile(tile, -1, -1, col, row);
                    }
                }
            }

            state = State.Falling;
        }
        else
        {
            state = State.Idle;
        }

        return sequences.length > 0;
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
        case State.Reverting:
            updateSwapping();
        case State.Falling:
            updateFalling();
        default:
            // Do nothing
        }


        if (Input.pressed("debug_a"))
        {
            trace("State: " + state);
            dumpBoard();
        }

        if (Input.pressed("debug_b"))
        {
            ++waterLevel;
            water.setHeight(TILE_SIZE * waterLevel);
        }

        if (Input.pressed("debug_c"))
        {
            --waterLevel;
            water.setHeight(TILE_SIZE * waterLevel);
        }
    }

    function updateIdle()
    {
        combo = 0;

        if (Input.mousePressed || (Input.mouseDown && selectedTile != null))
        {
            var tileX = Math.floor((Input.mouseX - boardX) / TILE_SIZE);
            var tileY = Math.floor((Input.mouseY - boardY) / TILE_SIZE);
            var dragAction = Input.mouseDown && selectedTile != null && !(tileX == selectedX && tileY == selectedY);

            var swapRangeX = Math.abs(tileX - selectedX);
            var swapRangeY = Math.abs(tileY - selectedY);

            var tile = getTile(tileX, tileY);
            if (tile != null)
            {
                if (selectedTile == null && tileY < ROWS - waterLevel)
                {
                    setSelected(tileX, tileY);
                }
                else if (swapRangeX <= 1 && swapRangeY <= 1 && swapRangeX != swapRangeY && dragAction && tileY < ROWS - waterLevel)
                {
                    swapTiles(tileX, tileY, selectedX, selectedY);
                    selectedTile.setSelected(false);
                    selectedTile = null;

                    dirtyBoard = !(tileX == selectedX && tileY == selectedY);
                }
                else if (swapRangeX == 0 && swapRangeY == 0 && Input.mousePressed)
                {
                    selectedTile.setSelected(false);
                    selectedTile = null;
                }
            }
        }
    }

    function updateSwapping()
    {
        animationTimeout -= HXP.elapsed;

        if (animationTimeout > 0) { return; }

        var swapBack = false;

        if (dirtyBoard)
        {
            dirtyBoard = false;
            var hasMatches = processMatches();
            if (!hasMatches)
            {
                swapTiles(swapA.x, swapA.y, swapB.x, swapB.y);
                state = State.Reverting;
            }
        }
        else
        {
            state = State.Idle;
        }
    }

    function updateFalling()
    {
        animationTimeout -= HXP.elapsed;

        if (animationTimeout > 0) { return; }

        processMatches(); // Keep processing matches until done
    }

    function dumpBoard()
    {
        trace("==== board dump ====");
        for (row in 0...ROWS)
        {
            var indices = new Array<String>();
            for (col in 0...COLUMNS)
            {
                var tile = getTile(col, row);
                var symbol = "-";
                if (tile != null)
                {
                    symbol = "" + tile.typeIdx;
                }
                indices.push(symbol);
            }
            trace(indices.join(""));
        }
        trace("====================");
    }
}