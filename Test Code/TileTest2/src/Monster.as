package  
{
	import org.flixel.FlxSprite;
	import playerio.Connection;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class Monster extends FlxSprite
	{
		[Embed(source = "data/Monster_Weak.png")] public var monster_weak:Class;
		public var _ap:int
		private var _xTile:int
		private var _yTile:int
		private var _monsterIndex:int //The Index of the Monster within the level's database table.
		
		public function Monster(type:String, ap:int, monsterIndex:int, xTile:int, yTile:int, xOffset:int, yOffset:int, tileSize:int) 
		{
			_ap = ap;
			_xTile = xTile
			_yTile = yTile
			_monsterIndex = monsterIndex
			
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
		
		override public function update():void 
		{
			super.update();
			if (_ap <= 0) {
				this.kill();
			}
		}
		
		//Attempts to attack monster and does damage based on "type"
		/*
		 * 1 = Weak Attack (1-2 AP)
		 * 2 = Medium Attack  (3-4 AP)
		 * 3 = Strong Attack (5-6 AP)
		 */
		public function attack(type:int, player:Player, connection:Connection):void 
		{
			if (type == 1) {
				_ap -= Math.floor(Math.random()*(1+2-1))+1;
			}else if (type == 2) {
				_ap -= Math.floor(Math.random()*(1+4-3))+3;
			}else if (type == 3) {
				_ap -= Math.floor(Math.random()*(1+6-5))+5;
			}
			
			if (_ap <= 0) {
				this.kill();
				player.inBattle = false;
			}
			connection.send("MonsterAPChange",  _ap, _monsterIndex)
		}
		
	}

}