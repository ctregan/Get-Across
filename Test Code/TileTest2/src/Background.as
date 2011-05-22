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
		[Embed(source = "data/menubg.png")] public var menubg_img:Class;
		
		public function Background(type:String = "") 
		{
			var backgroundImage:Class;
			
			switch (type)
			{
				case "LevelChoose":
					backgroundImage = lc_img;
					break;
				case "Map":
					backgroundImage = menubg_img;
					break;
				default:
					backgroundImage = bg_img;
					break;
			}
			
			super(0, 0, backgroundImage);
		}
		
	}

}