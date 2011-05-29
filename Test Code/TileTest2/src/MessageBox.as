package  
{
	// from a wiki page

    import flash.display.Sprite;
    import flash.text.TextField;
 
    public class MessageBox extends Sprite {
    
        function MessageBox(x:int, y:int, textArray:Array):void {

         var msgbox:Sprite = new Sprite();

          // drawing a white rectangle
          msgbox.graphics.beginFill(0xFFFFFF); // white
          msgbox.graphics.drawRect(0,0,300,20); // x, y, width, height
          msgbox.graphics.endFill();
 
          // drawing a black border
          msgbox.graphics.lineStyle(2, 0x000000, 100);  // line thickness, line color (black), line alpha or opacity
          msgbox.graphics.drawRect(x,y,400,300); // x, y, width, height
			var i:int;
		  for (i = 0; i < textArray.length; i++){
			  var textfield:TextField = new TextField()
			  textfield.text = textArray[i];

			  addChild(msgbox)   
			  addChild(textfield)
		  }

		}
		
	}

}