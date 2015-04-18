import com.haxepunk.Scene;

class MainScene extends Scene
{
    var player:Player;

	public override function begin()
	{
        player = new Player(100, 100);
        add(player);
	}
}