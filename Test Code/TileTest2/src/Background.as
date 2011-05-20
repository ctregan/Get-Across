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
		[Embed(source = "data/levelChooseBackground.png")] public var lc_img:Class;
		public function Background(type:String = "") 
		{
			var backgroundImage:Class
			if (type == "LevelChoose") {
				backgroundImage = lc_img;
			}else{
				backgroundImage = bg_img
			}
			super(0, 0, backgroundImage);
		}
		
	}

}