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
		
		public function MenuState(client:Client) 
		{
			myClient = client
			super()
			characterInfo = new Label("",12, TextFormatAlign.CENTER)
			client.bigDB.loadMyPlayerObject(loadPlayerSuccess)
			mainMenu = new Box().fill(0xFFFFFF, 0.8, 0)
			mainMenu.add(new Box().fill(0x00000, .5, 15).margin(10, 10, 10, 10).minSize(300, FlxG.height).add(
				new Box().fill(0xffffff,1,5).margin(10,10,10,10).minSize(300,0).add(
						new Rows(
							new Label("Main Menu", 30, TextFormatAlign.CENTER),
							characterInfo,
							new TextButton("Start Tutorial", startTutorial),
							new TextButton("New Game", newGame),
							new TextButton("Random Map", randomMap)
						).spacing(30)
					)))
			addChild(mainMenu);
			
			FlxG.mouse.show(null, 0, 0);
		}
		
		//Callback function called when Player data object has been successfully loaded
		private function loadPlayerSuccess(ob:DatabaseObject):void 
		{
			characterInfo.text = "Level: " + ob.level + " Class: " + ob.role;
		}
		
		//Callback function for when Start Tutorial Button is Pressed
		private function startTutorial():void
		{
			var lobby:Lobby = new Lobby(myClient, "GetAcross", handleJoin, handleError)
			
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
			FlxG.state = new PlayState(connection, myClient)
		}
		
		//Callback function for LOBBY, if it has encountered an error
		private function handleError(error:PlayerIOError):void{
			trace("Got", error)
			//FlxG.state = new LoginState()
		}
		
	}

}