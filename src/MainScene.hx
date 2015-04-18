import com.haxepunk.Scene;

class MainScene extends Scene
{
    var player:Player;
    var cat:Cat;

	public override function begin()
	{
        player = new Player(100, 100);
        add(player);

        cat = new Cat(player);
        add(cat);
	}
}