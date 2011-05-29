package  
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxTilemap;
	import playerio.Connection;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class ButtonSprite extends FlxSprite
	{
		[Embed(source = "data/Button.png")] private var button:Class;
		private var _myMap:FlxTilemap;
		private var _xOpen:int; //X Tile Location of where the door is to open 
		private var _yOpen:int; //Y Tile Location of where the door is to open
		private var _tileSize:int;
		
		public function ButtonSprite(xTile:int, yTile:int, xOpen:int, yOpen:int, myMap:FlxTilemap, tileSize:int) 
		{	
			_xOpen = xOpen;
			_yOpen = yOpen;
			_tileSize = tileSize;
			
			var xPixel:int = (xTile * tileSize) + myMap.x;
			var yPixel:int = (yTile * tileSize) + myMap.y;
			super(xPixel, yPixel, button);
			
		}
		
		public function clickButton(connection:Connection):void {
			PlayState.myMap.setTile(_xOpen, _yOpen, 0, true);
			kill();
		}
		
	}

}