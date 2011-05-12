package sample.ui{
	import flash.display.Sprite
	import flash.display.Stage
	import flash.events.Event
	import flash.text.TextFormatAlign
	import org.flixel.FlxState;
	
	import flash.events.MouseEvent
	import flash.events.KeyboardEvent
	
	import sample.ui.components.*
	import sample.ui.components.scroll.*
	import playerio.*;
	
	import org.flixel.FlxG;
	
	public class Alert extends Box{
		private var base:Box
		private var textLabel:Label;
		public var unread:Boolean = false;
		function Alert(text:String) {

			textLabel = new Label(text, 15);
			textLabel.multiline = true;
			fill(0xffffff,.8).add(
				new Box().minSize(150,110).fill(0x0,.5,10).margin(10,10,10,10).add(
					new Box().minSize(150,110).fill(0xFFFFFF,1,10).margin(0,0,0,0).add(
						new Box().margin(10).add(
							textLabel
						)	
					).add(
						new Box().margin(75).add(
							new TextButton("Continue",accept)
						)
					)
				)
			)
			this.x = FlxG.stage.x / 2
			this.y = FlxG.stage.y / 2
			
			FlxG.stage.addEventListener(Event.RESIZE, handleResize)
			handleResize()
		}
		
		function accept():void {
			unread = false;
			FlxG.stage.removeEventListener(Event.RESIZE, handleResize)
			FlxG.stage.removeChild(this);
		}
		public function changeText(newString:String) {
			unread = true;
			textLabel.text = newString;
		}
		public function show():void {
			FlxG.stage.addChild(this);
			FlxG.stage.addEventListener(Event.RESIZE, handleResize)
		}
		
		private function handleResize(e:Event = null){
			this.width = FlxG.stage.width
			this.height = FlxG.stage.height
		}
	}
}