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
		[Embed(source = "data/bacon.png")] private var bacon:Class;
		public function EffectSprite(xPixel:int, yPixel:int, img:String, range:int, tileSize:int) 
		{
			_tileSize = tileSize
			_range = range
			if(img == "bacon"){
				super(xPixel, yPixel, bacon)
			}
			
			var myTimer:Timer = new Timer(1000);
			myTimer.addEventListener(TimerEvent.TIMER, wait)
			myTimer.start();
			
		}
		
		private function wait(event:TimerEvent):void 
		{
			var sprites:Array = PlayState.lyrMonster.members
			for (var index in sprites) {
					if (calcDistance(x, y, sprites[index].x, sprites[index].y) < (_range * _tileSize)) {
						sprites[index].x = this.x
						sprites[index].y = this.y;
					}
				}	
		}
		
		//Finds the distance between two points (AKA two sprites)
		private function calcDistance(sx:Number, sy:Number, ex:Number, ey:Number):Number {
			if (sx > ex) {
				if (sy > ey) return (sx - ex) + (sy - ey);
				else return (sx - ex) + (ey - sy);
			} else {
				if (sy > ey) return (ex - sx) + (sy - ey);
				else return (ex - sx) + (ey - sy);
			}
		}
	}

}