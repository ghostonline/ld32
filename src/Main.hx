import com.haxepunk.Engine;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;

class Main extends Engine
{

	override public function init()
	{
#if debug
		HXP.console.enable();

        trace ("Seed " + HXP.randomSeed);

        Input.define("debug_a", [Key.DIGIT_1]);
        Input.define("debug_b", [Key.DIGIT_2]);
        Input.define("debug_c", [Key.DIGIT_3]);
        Input.define("debug_d", [Key.DIGIT_4]);
        Input.define("debug_e", [Key.DIGIT_5]);
        Input.define("debug_f", [Key.DIGIT_6]);
#end
        Input.define("mute", [Key.M]);

		HXP.scene = new MainScene();
	}

	public static function main() { new Main(); }

}