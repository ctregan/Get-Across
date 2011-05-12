package  
{
	import org.flixel.FlxState;
	import org.flixel.FlxG;
	import playerio.*
	import sample.ui.components.*
	import sample.ui.*
	import flash.text.TextFormatAlign
	import flash.text.TextFormat
	
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class QuestCompleteState extends FlxState
	{
		private var _client:Client
		private var characterInfo:Label
		private var mainMenu:Box
		
		public function QuestCompleteState(xp:int, coin:int, client:Client) 
		{
			_client = client
			super()
			characterInfo = new Label("",12, TextFormatAlign.CENTER)
			client.bigDB.loadMyPlayerObject(loadPlayerSuccess)
			mainMenu = new Box().fill(0xFFFFFF, 0.8, 0)
			mainMenu.add(new Box().fill(0x00000, .5, 15).margin(10, 10, 10, 10).minSize(FlxG.width, FlxG.height).add(
				new Box().fill(0xffffff,1,5).margin(10,10,10,10).minSize(300,0).add(
						new Rows(
							new Label("Quest Complete!", 30, TextFormatAlign.CENTER),
							characterInfo,
							new Label("XP Gained: " + xp, 15, TextFormatAlign.LEFT, 0x0000FF),
							new Label ("Coin Gained: " + coin, 15, TextFormatAlign.LEFT, 0x0000FF),
							new TextButton("Continue", continueButton)
						).spacing(30)
					)))
			FlxG.stage.addChild(mainMenu);
		}
		
		//Callback function for the continue button
		private function continueButton():void
		{
			FlxG.switchState(new MenuState(_client));
		}
		
		//Callback function called when Player data object has been successfully loaded
		private function loadPlayerSuccess(ob:DatabaseObject):void 
		{
			characterInfo.text = "Level: " + ob.level + "	Class: " + ob.role + "	Coin: " + ob.coin;
		}

	}

}