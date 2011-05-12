package  
{
	import playerio.*
	import sample.ui.*
	import org.flixel.*
	import sample.ui.components.*
	import flash.text.TextFormatAlign

	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class MenuState extends FlxState
	{
		private var characterInfo:Label //Will Hold Player Info Loaded from DB
		private var mainMenu:Box
		private var myClient:Client;
		private var tutorialButton:TextButton;
		private var tutorialLevel:int = 0;
		
		public function MenuState(client:Client) 
		{
			myClient = client
			super()
			client.bigDB.loadMyPlayerObject(loadPlayerSuccess)
		}
		
		//Callback function called when Player data object has been successfully loaded
		private function loadPlayerSuccess(ob:DatabaseObject):void 
		{
			characterInfo = new Label("Level: " + ob.level + "	Class: " + ob.role + "	Coin: " + ob.coin, 12, TextFormatAlign.CENTER);
			tutorialLevel = ob.tutorial;
			if (tutorialLevel == 1) {
				tutorialLevel = 1;
				tutorialButton = new TextButton("Start Tutorial", startTutorial);
			}else if (tutorialLevel > 1 && tutorialLevel < 10) {
				tutorialButton = new TextButton("Continue Tutorial", startTutorial);
			}else {
				tutorialButton = new TextButton("Continue Tutorial", startTutorial);
				tutorialButton.enabled = false;
			}
			mainMenu = new Box().fill(0xFFFFFF, 0.8, 0)
			mainMenu.add(new Box().fill(0x00000, .5, 15).margin(10, 10, 10, 10).minSize(FlxG.width, FlxG.height).add(
				new Box().fill(0xffffff,1,5).margin(10,10,10,10).minSize(300,0).add(
						new Rows(
							new Label("Main Menu", 30, TextFormatAlign.CENTER),
							characterInfo,
							tutorialButton,
							new TextButton("New Game", newGame),
							new TextButton("Random Map", randomMap)
						).spacing(30)
					)))
			FlxG.stage.addChild(mainMenu);
		}
		
		//Callback function for when Start Tutorial Button is Pressed
		private function startTutorial():void
		{
			var lobby:Lobby = new Lobby(myClient, "GetAcross", "Tutorial_" + tutorialLevel, handleJoin, handleError)
			//FlxG.state = new QuestLobby(myClient);
			
			//Show lobby (parsing true hides the cancel button)
			//this.Hide(null);
			lobby.show(true);
		}
		
		//Callback function for when New Game Button is pressed
		private function newGame():void
		{
			var alert:Alert = new Alert(this, "This Feature has not yet been implemented")
		}
		
		//Callback function for when Random Map Button is pressed
		private function randomMap():void
		{
			var alert:Alert = new Alert(this, "This Feature has not yet been implemented")
		}
		
		//Callback function for LOBBY, once it has connected to a game
		private function handleJoin(connection:Connection):void 
		{
			FlxG.switchState( new PlayState(connection, myClient))
			FlxG.stage.removeChild(mainMenu);
		}
		
		//Callback function for LOBBY, if it has encountered an error
		private function handleError(error:PlayerIOError):void{
			trace("Got", error)
			//FlxG.state = new LoginState()
		}
		
	}

}