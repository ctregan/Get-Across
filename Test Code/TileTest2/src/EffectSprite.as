package  
{
	import org.flixel.FlxBasic;
	import org.flixel.FlxEmitter;
	import org.flixel.FlxParticle;
	import org.flixel.FlxRect;
	import org.flixel.FlxSprite; 
	import flash.events.TimerEvent
	import flash.utils.Timer;
	import playerio.Connection;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class EffectSprite extends FlxSprite 
	{
		private var _range:int
		public var _tileSize:int
		public var type:String;
		public var uses:int;
		public var xTile:int;
		public var yTile:int
		private var _index:int;
		private var connection:Connection
		public var dead:Boolean = false;
		[Embed(source = "data/bacon.png")] private var bacon:Class;
		[Embed(source = "data/redflower.png")] private var redflower:Class;
		[Embed(source = "data/wine.png")] private var wine:Class;
		[Embed(source = "data/bomb.png")] private var bomb:Class;
		[Embed(source = "data/thornflower.png")] private var thornflower:Class;
		[Embed(source = "data/snakecandy.png")] private var snakesnack:Class;
		[Embed(source = "data/coin.png")] private var coin:Class;
		
		private var RUBBLE_TILE:int = 17;
		
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
			var xPixel:int = ((xTile * tileSize) + PlayState.myMap.x) - (tileSize * _range);
			var yPixel:int = ((yTile * tileSize) + PlayState.myMap.y) - (tileSize * _range);
			var classToinitialize:Class;
			
			if(type == "bacon"){
				classToinitialize = bacon;
			}
			else if (type == "redflower") {
				classToinitialize = redflower;
				PlayState.fireParticles(xPixel + (_tileSize * 2), yPixel + (_tileSize * 2), "flower");
			}else if (type == "wine") {
				classToinitialize = wine;
			}else if (type == "bomb") {
				classToinitialize = bomb;
			}else if (type == "thornflower") {
				classToinitialize = thornflower;
				PlayState.fireParticles(xPixel + (_tileSize), yPixel + (_tileSize), "thornflower");
			}else if (type == "snakesnack") {
				classToinitialize = snakesnack
			}else if (type == "coin") {
				classToinitialize = coin;
			}
			
			super(xPixel, yPixel , classToinitialize);
			
			if(type == "bacon" && uses < 1){
				var myTimer:Timer = new Timer(1000);
				myTimer.addEventListener(TimerEvent.TIMER, function (event:TimerEvent):void 
				{
					myTimer.stop();
					wait()
					
				});
				myTimer.start();
			}else if (type == "bomb" && uses < 1) {
				var myTimer:Timer = new Timer(1000);
				myTimer.addEventListener(TimerEvent.TIMER, function (event:TimerEvent):void 
				{
					myTimer.stop();
					bombExplode();
				});
				myTimer.start();
			}else if ( type == "thornflower") {
				PlayState.myMap.setTile(xTile, yTile, 0, true);
			}else if (type == "snakesnack") {
				var myTimer:Timer = new Timer(1000);
				myTimer.addEventListener(TimerEvent.TIMER, function (event:TimerEvent):void 
				{
					myTimer.stop();
					feedSnake();
				});
				myTimer.start();
				
			}
		}
		
		private function wait():void 
		{
			var inRangeArray:Array = new Array()
			var bsprite:Array = PlayState.lyrMonster.members;
			var index:int = 0;
			for (var monster in bsprite) {
				var sprite = Monster(bsprite[monster]);
				if (inRange(sprite._xTile, sprite._yTile) && sprite._ap > 0) {
					inRangeArray[index] = sprite;
					index++;
				}
			}
			if (inRangeArray.length < 1) {
				addUse(true);
				return
			}else {
				Monster(inRangeArray[randomNumber(inRange.length - 1, 0)].move(xTile, yTile));
				addUse(true);
				return
			}
		}
		
		function randomNumber(high:Number=1, low:Number=0):Number
		{
		  return Math.floor(Math.random() * (1+high-low)) + low;
		}
		
		// when bomb explodes, set tile to rubble
		// create particle emitter for bomb exploding
		private function bombExplode():void {
			PlayState.fireParticles(this.x, this.y, "bomb");
			PlayState.myMap.setTile(xTile, yTile, RUBBLE_TILE, true);
			addUse(true);
		}
		
		private function feedSnake() {
			PlayState.myMap.setTile(xTile, yTile, 21, true);
			addUse(true);
		}
		
		public function addUse(propogate:Boolean, type:String = ""):void
		{
			if(!dead){
				uses++;
				if (propogate && type == "coin")
				{
					connection.send("CoinUse", _index, uses);
				}else if(propogate){
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
			}else if ((type == "bacon" || type == "wine" || type == "bomb" || type == "snakesnack" || type == "coin")&& uses > 0) {
				kill();
				dead = true;
			}
			super.update();
		}
	}

}