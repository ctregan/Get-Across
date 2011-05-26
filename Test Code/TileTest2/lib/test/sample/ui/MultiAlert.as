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
	
	public class MultiAlert extends Box{
		private var base:Box
		private var textLabel:Label;
		public var unread:Boolean = false;
		private var textArray:Array
		private var index:int = 0;
		function MultiAlert(text:Array) {
			
			textArray = text;
			
			textLabel = new Label(textArray[0], 12, "center", 0x000000, true);
			textLabel.width = 300;
			index++;
			
			fill(0xffffff,.8).add(
				new Box().minSize(300,110).fill(0x0,.5,10).margin(10,10,10,10).add(
					new Box().minSize(300, 110).fill(0xFFFFFF, 1, 10).margin(0, 0, 0, 0).add(
						new Rows(
							new Box().margin(20).add(
								textLabel
							),	
							new Box().margin(20).add(
								new TextButton("Continue",accept)
							)
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
			if (index < textArray.length) {
				textLabel.text = textArray[index];
				index++;
			}else{
				FlxG.stage.removeEventListener(Event.RESIZE, handleResize)
				FlxG.stage.removeChild(this);
			}
		}
		public function show():void {
			FlxG.stage.addChild(this);
			FlxG.stage.addEventListener(Event.RESIZE, handleResize)
		}
		
		private function handleResize(e:Event = null){
			this.width = FlxG.stage.stageWidth
			this.height = FlxG.stage.stageHeight
		}
	}
}