package  
{
	import org.flixel.FlxState;
	import org.flixel.*;
	import playerio.Client;
	import sample.ui.*;
	import sample.ui.components.*;
	import flash.text.TextFormatAlign
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class OptionState extends FlxState
	{
		private var heightInput:Input
		private var widthInput:Input
		private var nameInput:Input
		private var base:Box;
		private var error:Label;
		private var _myClient:Client;
		public function OptionState(myClient:Client) 
		{
			_myClient = myClient;
			//Input
			nameInput = new Input("",12)
			heightInput = new Input("", 12, TextFormatAlign.LEFT)
			widthInput = new Input("", 12, TextFormatAlign.LEFT)
			error = new Label("", 12, "left", 0xFF0000, false);
			nameInput.height = 20
			heightInput.height = 20
			widthInput.height = 20
			
			base = new Box().fill(0xFFFFFF,0.8).add(
				new Box().fill(0x000000,.5,15).margin(10,10,10,10).minSize(300,0).add(
					new Box().fill(0xffffff,1,5).margin(10,10,10,10).minSize(300,0).add(
						new Rows(
							new Label("Options",20, TextFormatAlign.CENTER),
							new Columns().margin(0, 5, 0, 5).spacing(3).add(
								new Label("Map Name",12, TextFormatAlign.RIGHT),
								nameInput
							),
							new Columns().margin(0,5,0,5).spacing(3).add(
								new Label("Tile Height",12, TextFormatAlign.RIGHT),
								heightInput
							),
							new Columns().margin(0,5,0,5).spacing(3).add(
								new Label("Tile Width",12, TextFormatAlign.RIGHT),
								widthInput
							),
							error,
							new Columns().margin(10).spacing(10).add(
								new TextButton("Continue", continueCallback)
						).spacing(10)
					)
				)
			))
			
			FlxG.stage.addChild(base);
		}
		
		private function continueCallback():void {
			if (int(heightInput.text) > 10 || int(widthInput.text) > 10) {
				error.text = "Max Width and Height is 10 tile"
			}else{
				FlxG.stage.removeChild(base);
				this.kill();
				FlxG.switchState(new MapEditorState(nameInput.text, heightInput.text, widthInput.text, _myClient));
			}
		}
		
	}

}