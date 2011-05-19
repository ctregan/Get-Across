package  
{
	import org.flixel.FlxSprite; 
	import flash.events.TimerEvent
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class EffectSprite extends FlxSprite 
	{
		private var _range:int
		private var _tileSize:int
		public var type:String;
		public var uses:int = 0;
		public var xTile:int;
		public var yTile:int
		[Embed(source = "data/bacon.png")] private var bacon:Class;
		[Embed(source = "data/redflower.png")] private var redflower:Class;
		public function EffectSprite(xTile:int, yTile:int, type:String, range:int, tileSize:int) 
		{
			this.type = type;
			_tileSize = tileSize;
			_range = range;
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
			
			if(type == "bacon"){
				var myTimer:Timer = new Timer(1000);
				myTimer.addEventListener(TimerEvent.TIMER, wait)
				myTimer.start();
			}
		}
		
		private function wait(event:TimerEvent):void 
		{
			var sprites:Array = PlayState.lyrMonster.members
			for (var index in sprites) {
					if (inRange(sprites[index]._xTile, sprites[index]._yTile)) {
						sprites[index].x = this.x;
						sprites[index].y = this.y;
						this.kill();
						return;
					}
				}
				kill();
		}
		
		//Pass in a tile location and return if it is in range
		public function inRange(targetXTile:int, targetYTile:int):Boolean {
			return ((Math.abs(this.xTile - targetXTile) + Math.abs(this.yTile - targetYTile)) <= _range);
		}
		
		override public function update():void 
		{
			if (type == "redflower" && uses >= 5) {
				kill();
			}
			super.update();
		}
	}

}