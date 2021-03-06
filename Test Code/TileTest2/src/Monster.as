package  
{
	import org.flixel.FlxSprite;
	import org.flixel.plugin.photonstorm.FlxHealthBar;
	import playerio.Connection;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class Monster extends FlxSprite
	{
		[Embed(source = "data/monster1.png")] public var monster_weak:Class;
		public var _ap:int
		public var _xTile:int
		public var _yTile:int
		private var _monsterIndex:int //The Index of the Monster within the level's database table.
		public var healthBar:FlxHealthBar;
		private var _tileSize:int;
		private var _connection:Connection
		public var moving:Boolean = false;
		public var dead:Boolean = false;
		
		public function Monster(type:String, ap:int, monsterIndex:int, xTile:int, yTile:int, xOffset:int, yOffset:int, tileSize:int, connection:Connection) 
		{
			_ap = ap;
			_xTile = xTile
			_yTile = yTile
			_tileSize = tileSize
			_monsterIndex = monsterIndex
			_connection = connection
			
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
			healthBar = new FlxHealthBar(this, 20, 5, 0, _ap, true);
			healthBar.trackParent( -5, 0);
			facing = FlxSprite.DOWN;
			play("idle" + DOWN);
		}
		
		override public function update():void 
		{
			
			super.update();
			this.health = _ap
			if (_ap <= 0 && !dead) {
				this.kill();
				healthBar.kill();
				dead = true;
			}
		}
		
		public function move(tileX:int, tileY:int):void 
		{
			moving = true;
			this.y += (tileY - _yTile) * _tileSize
			trace("Monster move y to " + this.y);
			this.x += (tileX - _xTile) * _tileSize
			trace("Monster move x to " + this.x);
			
			_xTile = tileX;
			_yTile = tileY;
			_connection.send("SpriteMove", "Monsters", _xTile, _yTile, _monsterIndex);
			moving = false;
		}
		
		//Attempts to attack monster and does damage based on "type"
		/*
		 * 1 = Weak Attack (1-2 AP)
		 * 2 = Medium Attack  (3-4 AP)
		 * 3 = Strong Attack (5-6 AP)
		 */
		public function attack(type:int, player:Player):void 
		{
			var damage:int;
			if (type == 1) {
				damage = Math.floor(Math.random()*(1+2-1))+1;
			}else if (type == 2) {
				damage = Math.floor(Math.random()*(1+4-3))+3;
			}else if (type == 3) {
				damage = Math.floor(Math.random()*(1+6-5))+5;
			}
			_ap -= damage;
			
			var note:String = "-" + damage + " to monster!";
			if (_ap <= 0) {
				this.kill();
				healthBar.kill();
				dead = true;
				player.inBattle = false;
				note += "\nMonster fell!";
			}
			_connection.send("MonsterAPChange",  _ap, _monsterIndex)
			PlayState.fireNotification(this.x + 20, this.y - 20, note, "loss");
		}
		
	}

}