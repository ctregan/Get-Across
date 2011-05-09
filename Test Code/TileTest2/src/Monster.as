package  
{
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class Monster extends FlxSprite
	{
		[Embed(source = "data/Monster_Weak.png")] public var monster_weak:Class;
		private var _ap:int
		private var _xTile:int
		private var _yTile:int
		
		public function Monster(type:String, xTile:int, yTile:int, xOffset:int, yOffset:int, tileSize:int) 
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
			
			super(((xTile) * tileSize) + xOffset, ((yTile) * tileSize) + yOffset);
			loadGraphic(monster_weak, true, false, 32 , 32);
			addAnimation("idle" + UP, [0], 0, false);
			addAnimation("idle" + DOWN, [3], 0, false);
			addAnimation("idle" + LEFT, [6], 0, false);
			addAnimation("idle" + RIGHT, [9], 0, false);
			addAnimation("walk" + UP, [0, 1, 2], 15, true);
            addAnimation("walk" + DOWN, [3,4,5], 15, true);
            addAnimation("walk" + LEFT, [6, 7, 8], 15, true);
			addAnimation("walk" + RIGHT, [9, 10, 11], 15, true);
			facing = FlxSprite.DOWN;
			play("idle" + DOWN);
		}
		
	}

}