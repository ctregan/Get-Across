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
	import sample.ui.components.scroll.ScrollBox;	
	import org.flixel.FlxState;
	import org.flixel.*;
	import playerio.*;
	import sample.ui.components.*;
	import sample.ui.*;
	import flash.text.TextFormatAlign;
	import sample.ui.components.scroll.ScrollBox
	import flash.events.Event
 
	
    public class MessageBox extends Sprite {

		//private var _addCopyButton:Sprite;
		private var _paragraph:Sprite;
		private var _paragraphTextField:TextField;
		private var _copy:String;
		private var roomContainer:Rows
		
		private var base:ScrollBox 
		
        function MessageBox(x:int, y:int, textArray:Array):void {
			//base = new ScrollBox().fill(0xffffff,.8).margin(20,20,20,20).add(
			//	new Box().fill(0x000000,.5,10).margin(10,10,10,10).add(
			//		new Box().fill(0xffffff,1,5).margin(10,10,10,10).add(
			//			new Label("Select Map", 20, TextFormatAlign.LEFT)
			//		).add(
			//			new Box().margin(35,0,35,0).add(
			//				new Box().margin(0,0,0,0).fill(0x0,0,10).border(1,0x555555,1).add(
			//					new Box().margin(3,1,3,3)
			//				)
			//			)
			//		).add(
			//			new Box().margin(NaN,0,0,0).add(
			//				new Columns().spacing(10).add(
			//					new TextButton("Cancel", null)
			//				)				
			//			)
			//		)
			//	)
			//)
			//addChild(base);
			
			var msgbox:Sprite = new Sprite();

			// drawing a white rectangle
			msgbox.graphics.beginFill(0xB5A642, 0.8); // white
			msgbox.graphics.drawRect(x,y,400,300); // x, y, width, height
			msgbox.graphics.endFill();

			// drawing a black border
			//msgbox.graphics.lineStyle(1, 0x000000, 100);  // line thickness, line color (black), line alpha or opacity
			//msgbox.graphics.drawRect(x,y,400,300); // x, y, width, height
			addChild(msgbox)   
			var textfield:TextField = new TextField()
			textfield.textColor = 0x000000;
			textfield.width = 400;
			textfield.autoSize = TextFieldAutoSize.LEFT;
			textfield.wordWrap = true;
			textfield.antiAliasType = AntiAliasType.ADVANCED;
			//textfield.embedFonts = true;
			textfield.selectable = false;
			textfield.x = x + 20;
			textfield.y = y + 20;
			//textfield.scrollRect = new Rectangle(0, 0, 400, 300);
			//textfield.scrollH = 1;
			//textfield.scroll
			var i:int;
			for (i = 0; i < textArray.length; i++) {
				textfield.text += textArray[i] + "\n\n";
				trace(textfield.text);
			}

			msgbox.addChild(textfield);
			

		}		
	}

}