package  
{
	import flash.display.SimpleButton;
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
		private var _nextLevel:String
		private var characterInfo:Label
		private var mainMenu:Box
		private var nextLevelButton:TextButton
		private var loader:Box
		
		public function QuestCompleteState(xp:int, coin:int, client:Client, nextLevel:String) 
		{
			_client = client
			_nextLevel = nextLevel;
			super()
			characterInfo = new Label("",12, TextFormatAlign.CENTER)
			client.bigDB.loadMyPlayerObject(loadPlayerSuccess)
			
			nextLevelButton = new TextButton("Next Level", nextLevelCallback);
			if (nextLevel == "") {
				nextLevelButton.visible = false;
			}
			mainMenu = new Box().fill(0xFFFFFF, 0.8, 0)
			mainMenu.add(new Box().fill(0x00000, .5, 15).margin(10, 10, 10, 10).minSize(FlxG.width, FlxG.height).add(
				new Box().fill(0xffffff,1,5).margin(10,10,10,10).minSize(300,0).add(
						new Rows(
							new Label("Quest Complete!", 30, TextFormatAlign.CENTER),
							characterInfo,
							new Label("XP Gained: " + xp, 15, TextFormatAlign.LEFT, 0x0000FF),
							new Label ("Coin Gained: " + coin, 15, TextFormatAlign.LEFT, 0x0000FF),
							new Columns().spacing(10).margin(10).add(
							new TextButton("Main Menu", continueButton),
							nextLevelButton)
						).spacing(30)
					)))
			FlxG.stage.addChild(mainMenu);
			
			loader = new Box().fill(0xffffff,.8).add(
				new Label("Creating Tutorial Level.", 20)
			).add(
				new Box().margin(20).add(new Label("Please wait while we connect to the server.", 12))
			)
			loader.width = FlxG.stage.stageWidth
			loader.height = FlxG.stage.stageHeight
		}
		
		//Callback function for the continue button
		private function continueButton():void
		{
			FlxG.switchState(new MenuState(_client));
			FlxG.stage.removeChild(mainMenu);
			this.kill();
		}
		
		//Callback function called when Player data object has been successfully loaded
		private function loadPlayerSuccess(ob:DatabaseObject):void 
		{
			characterInfo.text = "Level: " + ob.level + "	Class: " + ob.role + "	Coin: " + ob.coin;
		}
		
		//Callback function for when the next level button is pressed
		private function nextLevelCallback():void {
			_client.multiplayer.createRoom(
				null,								//Room id, null for auto generted
				"GetAcross",							//RoomType to create, bounce is a simple bounce server
				true,								//Hide room from userlist
				{name:"Tutorial", key:_nextLevel, type:"static"},						//Room Join data, data is returned to lobby list. Variabels can be modifed on the server
				joinRoom,							//Create handler
				handleError					//Error handler										   
			)
		}
		
		//Callback function for LOBBY, once it has connected to a game
		private function handleJoin(connection:Connection):void 
		{
			FlxG.switchState( new PlayState(connection, _client))
			FlxG.stage.removeChild(mainMenu);
			FlxG.stage.removeChild(loader);
		}
		
		//Callback function for LOBBY, if it has encountered an error
		private function handleError(error:PlayerIOError):void{
			trace("Got", error)
			//FlxG.state = new LoginState()
		}
		//Callback for once room is created
		private function joinRoom(id:String):void{
			showLoader()
			_client.multiplayer.joinRoom(
				id,									//Room id
				{},									//User join data.
				handleJoin,							//Join handler
				handleError					//Error handler	
			)
		}
		
		private function showLoader():void{
			FlxG.stage.addChild(loader)
		}

		private function hideLoader():void{
			if(loader.parent)FlxG.stage.removeChild(loader)
		}

	}

}