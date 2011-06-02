package  
{
	// from a wiki page

    import flash.display.Sprite;
	import flash.geom.Rectangle;
    import flash.text.TextField;
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import sample.ui.components.*;
	import org.flixel.*;
	import sample.ui.components.scroll.ScrollBar;
	import sample.ui.components.scroll.ScrollBox;	
	import org.flixel.FlxState;
	import org.flixel.*;
	import playerio.*;
	import sample.ui.components.*;
	import sample.ui.*;
	import flash.text.TextFormatAlign;
	import sample.ui.components.scroll.ScrollBox
	import flash.events.Event
	import sample.ui.components.scroll.ScrollButton;
 
	
    public class MessageBox extends Sprite {

		//private var _addCopyButton:Sprite;
		private var _paragraph:Sprite;
		private var _paragraphTextField:TextField;
		private var _copy:String;
		private var roomContainer:Rows
		
		private var base:ScrollBox 
		private var textfield:TextField;
		
        function MessageBox(x:int, y:int, textArray:Array):void {			
			var msgbox:Sprite = new Sprite();
			msgbox.graphics.beginFill(0xB5A642, 0.8); // white
			msgbox.graphics.drawRect(x,y,300,120); // x, y, width, height
			msgbox.graphics.endFill();
			addChild(msgbox)   
			textfield = new TextField()
			textfield.textColor = 0x000000;
			//textfield.width = 300;
			//textfield.autoSize = TextFieldAutoSize.LEFT;
			textfield.wordWrap = true;
			textfield.antiAliasType = AntiAliasType.ADVANCED;
			//textfield.embedFonts = true;
			//textfield.selectable = false;
			textfield.x = x + 20;
			textfield.y = y + 20;
			var i:int;
			for (i = 0; i < textArray.length; i++) {
				textfield.appendText(textArray[i] + "\n");
			}

			textfield.multiline = true;
			textfield.scrollRect = new Rectangle(0, 0, 260, 120);
			//textfield.numLines = 10;
			textfield.mouseEnabled;
			textfield.mouseWheelEnabled;
			trace(textfield.numLines);
			textfield.scrollV = textfield.bottomScrollV;
			msgbox.addChild(textfield);
			
			// add control for moving up and down the textfield object
			
			var upButton:ScrollButton = new ScrollButton(1, 20, scrollUp);
			upButton.x = x + 270;
			upButton.y = y + 10;
			msgbox.addChild(upButton);
			
			var downButton:ScrollButton = new ScrollButton(3, 20, scrollDown);
			downButton.x = x + 270;
			downButton.y = y + 30;
			msgbox.addChild(downButton);
			
			//var scrollBar:ScrollBar = new ScrollBar();
			//scrollBar.x = x + 250;
			//scrollBar.y = y;
			//scrollBar.height = 200;
			//scrollBar.
			//scrollBar.scrollViewable = textfield.height / msgbox.height * 200;
			//msgbox.addChild(scrollBar);
		}	
		
		public function scrollUp():void {
			
			textfield.scrollV -= 1;
			trace("UP: " + textfield.scrollV);
			addChild(textfield);
		}
		
		public function scrollDown():void {
			trace("DOWN: " + textfield.scrollV);
			textfield.scrollV += 1;
			addChild(textfield);
		}
	}

}