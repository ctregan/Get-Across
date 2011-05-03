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
	
	public class Alert extends Box{
		private var base:Box 
		private var _stage:FlxState
		function Alert(stage:FlxState, text:String) {
			_stage = stage
			fill(0xffffff,.8).add(
				new Box().minSize(150,110).fill(0x0,.5,10).margin(10,10,10,10).add(
					new Box().minSize(150,110).fill(0xFFFFFF,1,10).margin(0,0,0,0).add(
						new Box().margin(10).add(
							new Label(text, 15)
						)	
					).add(
						new Box().margin(75).add(
							new TextButton("Continue",accept)
						)
					)
				)
			)
			
			stage.addChild(this);
			
			stage.addEventListener(Event.RESIZE, handleResize)
			handleResize()
		}
		
		function accept():void{
			_stage.removeEventListener(Event.RESIZE, handleResize)
			_stage.removeChild(this);
		}
		
		private function handleResize(e:Event = null){
			this.width = _stage.width
			this.height = _stage.height
		}
	}
}