package  
{
	import org.flixel.*;
	/**
	 * @author nadine
	 */
	public class Notification extends FlxText
	{
		var timer:int;// = new FlxTimer();
		var duration:int = 50;	// how long notification will stay on screen
		
		public function Notification(startX:int, startY:int, messageString:String, messageType:String) 
		{
			timer = duration;
			super(startX, startY, 150, messageString, false);
			
			// change color of notification
			switch (messageType)
			{
				case "loss": // red
					this.setFormat(null, 8, 0x22ff0000, "left", 1);
					break;
				case "gain": // green
					this.setFormat(null, 8, 0x2200ff00, "left", 1);
					break;
				default: // white
					this.setFormat(null, 8, 0x00000000, "left", 1);
			}
		}
		
		override public function update():void
		{
			this.velocity.y = -10;
			if (timer <= 0)
				this.kill();
			else timer -= FlxG.elapsed;
		}
	}

}