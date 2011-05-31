package  
{
	// from a wiki page

	import com.warmforestflash.ui.FullScreenScrollBar;
    import flash.display.Sprite;
	import flash.geom.Rectangle;
    import flash.text.TextField;
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import gs.TweenLite;
	import org.libspark.ui.SWFWheel;	
 
    public class MessageBox extends Sprite {

		//private var _addCopyButton:Sprite;
		private var _paragraph:Sprite;
		private var _paragraphTextField:TextField;
		private var _copy:String;
		private var _scrollBar:FullScreenScrollBar;		
		
        function MessageBox(x:int, y:int, textArray:Array):void {
			SWFWheel.initialize(stage);				
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
			
			_scrollBar = new FullScreenScrollBar(msgbox, 0x000000, 0xff4400, 0x05b59a, 0xffffff, 15, 15, 4, true);
			addChild(_scrollBar);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}
		//============================================================================================================================
		private function onAddedToStage(e:Event):void
		//============================================================================================================================
		{
			init();
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
	}

}