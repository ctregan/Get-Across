package  
{
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author Ji Mun
	 */
	public class Background extends FlxSprite
	{
		[Embed(source = "data/gui.png")] public var bg_img:Class;
		public function Background() 
		{
			super(0, 0, bg_img);
		}
		
	}

}