package  
{
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class Monster extends FlxSprite
	{
		private var _ap:int
		private var _xTile:int
		private var _yTile:int
		
		public function Monster(type:String, xTile:int, yTile:int) 
		{
			if (type == "Weak") {
				_ap = 5;
			}else if (type == "Medium") {
				_ap = 10
			}else if (type == "Strong") {
				_ap = 20
			}
			_xTile = xTile
			_yTile = yTile
		}
		
	}

}