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
		private var continueButton:TextButton;
		private var tutorialLevel:int = 0;
		private var loader:Box
		private var _questID:String;
		private var myPlayer:DatabaseObject;
		
		private static var _windowWidth:int = 700;
		private static var _windowHeight:int = 400;
		
		public function MenuState(client:Client) 
		{
			myClient = client
			super()
			client.bigDB.loadMyPlayerObject(loadPlayerSuccess)
		}
		
		//Callback function called when Player data object has been successfully loaded
		private function loadPlayerSuccess(ob:DatabaseObject):void 
		{
			myPlayer = ob;
			characterInfo = new Label("Level: " + ob.level + "	Class: " + ob.role + "	Coin: " + ob.coin, 12, TextFormatAlign.CENTER);
			tutorialButton = new TextButton("Start Tutorial", startTutorial);
			tutorialLevel = ob.tutorial;
			try {
				_questID = ob.questID;
				if (tutorialLevel <= 1  && (_questID == "noQuest" || _questID == null)) {
					continueButton = new TextButton("Continue Tutorial", continueQuest);
					continueButton.visible = false;
				}else if(tutorialLevel <= 5) {
					continueButton = new TextButton("Continue Tutorial", continueQuest);
				}else {
					continueButton = new TextButton("Continue Last Quest", continueQuest);
					tutorialButton.visible = false;
					tutorialButton.enabled = false;
					if (_questID == "noQuest") {
						continueButton.visible = false;
						continueButton.enabled = false;
					}else {
						continueButton.enabled = true;
						continueButton.visible = true;
					}
				}
			}
			catch (e:Error)
			{
					continueButton.visible = false;
					continueButton.enabled = false;
			}
			//Try to load questID, if no quest then that button is invisible
			
			
			mainMenu = new Box().fill(0xFFFFFF, 0.8, 0)
			mainMenu.add(new Box().fill(0x00000, .5, 15).margin(10, 10, 10, 10).minSize(_windowWidth, _windowHeight).add(
				new Box().fill(0xffffff,1,5).margin(10,10,10,10).minSize(300,0).add(
						new Rows(
							new Label("Main Menu", 30, TextFormatAlign.CENTER),
							characterInfo,
							continueButton,
							tutorialButton,
							new TextButton("New Game", newGame),
							new TextButton("Map Editor", mapEditor)
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
		
		//Callback function for when Continue Button is pressed
		private function continueQuest():void 
		{
			if (tutorialLevel <= 5) {
				var _levelKey:String = "Tutorial_" + tutorialLevel;
			}else{
				var _levelKey:String = "";
			}
			myClient.multiplayer.createRoom(
				null,								//Room id, null for auto generted
				"GetAcross",							//RoomType to create, bounce is a simple bounce server
				true,								//Hide room from userlist
				{name:"Tutorial", key:_levelKey, type:"static"},						//Room Join data, data is returned to lobby list. Variabels can be modifed on the server
				joinRoom,							//Create handler
				handleError					//Error handler										   
			)
		}
		//Callback function for when Start Tutorial Button is Pressed
		private function startTutorial():void
		{
			var prompt:InGamePrompt = new InGamePrompt(FlxG.stage, "Would you like to start the tutorial? All previous tutorial progress will be lost", function() { startNewTutorialAccept() } );
		}
		//Callback when the user wants to start new tutorial
		private function startNewTutorialAccept():void 
		{
			myPlayer.tutorial = 1;
			myPlayer.questID = "noQuest"
			myPlayer.save();
			var _levelKey:String = "Tutorial_1"
			myClient.multiplayer.createRoom(
				null,								//Room id, null for auto generted
				"GetAcross",							//RoomType to create, bounce is a simple bounce server
				true,								//Hide room from userlist
				{name:"Tutorial", key:_levelKey, type:"static"},						//Room Join data, data is returned to lobby list. Variabels can be modifed on the server
				joinRoom,							//Create handler
				handleError					//Error handler										   
			)
		}
		//Callback function for when New Game Button is pressed
		private function newGame():void
		{
			if (tutorialLevel <= 5) {
				FlxG.stage.addChild(new Alert("To Acess This Option You Must Finish All 5 Tutorial Levels"));
			}else if (continueButton.enabled == true) {
				var prompt:InGamePrompt = new InGamePrompt(FlxG.stage, "You will lose your old quest data if you start a new game. You sure?", function() {
					startNewGameAccept();
				});
			}else {
				startNewGameAccept();
			}
		}
		
		//If the Start new game prompt is accepted and the users desires to delete their old quest
		private function startNewGameAccept():void {
			myPlayer.questID = "noQuest";
			myPlayer.save(false,false,function ():void 
			{
				FlxG.switchState(new LevelChooseState(myClient));
			})
			FlxG.stage.removeChild(mainMenu);
			this.kill();
		}
		//Callback function for when Random Map Button is pressed
		private function randomMap():void
		{
			FlxG.stage.addChild(new Alert("This Feature has not yet been implemented"));
		}
		//Callback function for Map Editor Button
		private function mapEditor():void 
		{
			FlxG.switchState(new OptionState(myClient));
			//FlxG.switchState(new ClassChooseState(myClient));
			FlxG.stage.removeChild(mainMenu);
			this.kill();
		}
		
		/*
		 * PLAYERIO ROOM JOIN
		 */
		//Callback function for LOBBY, once it has connected to a game
		private function handleJoin(connection:Connection):void 
		{
			FlxG.switchState( new PlayState(connection, myClient))
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
			myClient.multiplayer.joinRoom(
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