package  
{
	import org.flixel.FlxSprite; 
	import flash.events.TimerEvent
	import flash.utils.Timer;
	import playerio.Connection;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class EffectSprite extends FlxSprite 
	{
		private var _range:int
		private var _tileSize:int
		public var type:String;
		private var uses:int;
		public var xTile:int;
		public var yTile:int
		private var _index:int;
		private var connection:Connection
		public var dead:Boolean = false;
		[Embed(source = "data/bacon.png")] private var bacon:Class;
		[Embed(source = "data/redflower.png")] private var redflower:Class;
		public function EffectSprite(xTile:int, yTile:int, type:String, range:int, tileSize:int, uses:int, connection:Connection, index:int) 
		{
			this.type = type;
			_tileSize = tileSize;
			_range = range;
			_index = index;
			this.connection = connection;
			this.uses = uses;
			this.xTile = xTile;
			this.yTile = yTile;
			var classToinitialize:Class;
			
			if(type == "bacon"){
				classToinitialize = bacon;
			}
			else if (type == "redflower") {
				classToinitialize = redflower;
			}
			
			super((xTile * tileSize) + PlayState.myMap.x, (yTile * tileSize) + PlayState.myMap.y, classToinitialize);
			
			if(type == "bacon" && uses < 1){
				var myTimer:Timer = new Timer(1000);
				myTimer.addEventListener(TimerEvent.TIMER, function (event:TimerEvent):void 
				{
					wait()
					myTimer.stop();
				});
				myTimer.start();
			}
		}
		
		private function wait():void 
		{
			var sprites:Array = PlayState.lyrMonster.members;
			for (var index in sprites) {
					if (inRange(sprites[index]._xTile, sprites[index]._yTile) && sprites[index]._ap > 0) {
						Monster(sprites[index]).move(xTile, yTile);
						addUse(true);
						return;
					}
				}
				kill();
		}
		
		public function addUse(propogate:Boolean):void
		{
			if(!dead){
				uses++;
				if (propogate)
				{
					connection.send("SpriteUse", _index, uses);
				}
			}
		}
		
		//Pass in a tile location and return if it is in range
		public function inRange(targetXTile:int, targetYTile:int):Boolean {
			return ((Math.abs(this.xTile - targetXTile) + Math.abs(this.yTile - targetYTile)) <= _range);
		}
		
		override public function update():void 
		{
			if (type == "redflower" && uses >= 5) {
				kill();
				dead = true;
			}else if (type == "bacon" && uses > 0) {
				kill();
				dead = true;
			}
			super.update();
		}
	}

}