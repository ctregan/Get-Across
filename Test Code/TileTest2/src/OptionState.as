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
			add(new Background("Map"));
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
								new Label("Tile Height (1 to 10)",12, TextFormatAlign.RIGHT),
								heightInput
							),
							new Columns().margin(0,5,0,5).spacing(3).add(
								new Label("Tile Width (1 to 10)",12, TextFormatAlign.RIGHT),
								widthInput
							),
							error,
							new Columns().margin(10).spacing(10).add(
								new TextButton("Cancel", function():void { FlxG.switchState(new MenuState(_myClient)); FlxG.stage.removeChild(base)} ),
								new TextButton("Continue", continueCallback)
						).spacing(10)
					)
				)
			))
			base.width = FlxG.stage.stageWidth
			base.height = FlxG.stage.stageHeight
			FlxG.stage.addChild(base);
		}
		
		private function continueCallback():void {
			if (nameInput.text == "")
				error.text = "Error: Please fill in a name for your map!"
			else if (heightInput.text == "" || isNaN(int(heightInput.text)))
				error.text = "Error: Please fill in a numerical height for your map!"
			else if (widthInput.text == "" || isNaN(int(widthInput.text)))
				error.text = "Error: Please fill in a width for your map!"
			else if (int(heightInput.text) == 1 && int(widthInput.text) == 1)
				error.text = "Error: You can't have a 1x1 map!"
			else if (int(heightInput.text) > 20 || int(widthInput.text) > 20)
				error.text = "Error: Max Width and Height is 10 tiles"
			else{
				FlxG.stage.removeChild(base);
				this.kill();
				FlxG.switchState(new MapEditorState(nameInput.text, heightInput.text, widthInput.text, _myClient));
			}
		}
		
	}

}