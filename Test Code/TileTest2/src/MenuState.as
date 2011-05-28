package  
{
	import playerio.*
	import sample.ui.*
	import org.flixel.*
	import flash.text.*;
	import sample.ui.components.*
	import flash.text.TextFormatAlign

	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class MenuState extends FlxState
	{
		private var mainMenu:Box
		private var myClient:Client;
		private var tutorialButton:TextButton;
		private var continueButton:TextButton;
		private var tutorialLevel:int = 0;
		private var loader:Box
		private var _questID:String;
		private var myPlayer:DatabaseObject;
		[Embed(source = "data/Planter2.png")] private var planterImg:Class;
		[Embed(source = "data/Cook2.png")] private var cookImg:Class;
		[Embed(source = "data/Crafter2.png")] private var crafterImg:Class;
		[Embed(source = "data/Novice2.png")] private var noviceImg:Class;
		private var playerClassImg:FlxSprite = new FlxSprite();
		
		private static var _windowWidth:int = 700;
		private static var _windowHeight:int = 400;
		
		public function MenuState(client:Client) 
		{
			myClient = client;
			super();
			add(new Background("Map"));
			client.bigDB.loadMyPlayerObject(loadPlayerSuccess);
			playerClassImg = new FlxSprite(450, 130, noviceImg);
			add(playerClassImg);
		}
		
		//Callback function called when Player data object has been successfully loaded
		private function loadPlayerSuccess(ob:DatabaseObject):void 
		{
			myPlayer = ob;
			
			// labels for level, class, coins
			var playerInfoTextSize:int = 15;
			var levelTextFormat:TextFormat = new TextFormat("Abscissa", playerInfoTextSize, 0xff488921);
			var levelLabel:Label = new Label("Level: " + ob.level, playerInfoTextSize, TextFormatAlign.CENTER, 0xff488921);
			levelLabel.setTextFormat(levelTextFormat);
			
			var classTextFormat:TextFormat = new TextFormat("Abscissa", playerInfoTextSize, 0xff488921);
			var classLabel:Label = new Label("Class: " + ob.role, playerInfoTextSize, TextFormatAlign.CENTER, 0xff488921);
			classLabel.setTextFormat(classTextFormat);
			
			var coinTextFormat:TextFormat = new TextFormat("Abscissa", playerInfoTextSize, 0xff488921);
			var coinLabel:Label = new Label("Skill Points: " + ob.sp, playerInfoTextSize, TextFormatAlign.CENTER, 0xff488921);
			coinLabel.setTextFormat(coinTextFormat);
			
			// image of player avatar
			switch (ob.role)
			{
				case "Planter":
					playerClassImg.loadGraphic(planterImg);
					break;
				case "Cook":
					playerClassImg.loadGraphic(cookImg);
					break;
				case "Crafter":
					playerClassImg.loadGraphic(crafterImg);
					break;
				default:
					playerClassImg.loadGraphic(noviceImg);
					break;
			}
			
			tutorialButton = new TextButton("Start Tutorial", startTutorial);
			tutorialLevel = ob.tutorial;
			try {
				_questID = ob.questID;
				if (tutorialLevel <= 1  && (_questID == "noQuest" || _questID == null)) {
					continueButton = new TextButton("Continue Tutorial " + ob.tutorial + " of 5", startNewTutorial);
					continueButton.visible = false;
				}else if(tutorialLevel <= 5) {
					continueButton = new TextButton("Continue Tutorial " + ob.tutorial + " of 5", startNewTutorial);
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
			
			var titleTextFormat:TextFormat = new TextFormat("Abscissa", 40, 0xff488921);
			var titleLabel:Label = new Label("welcome!", 40, TextFormatAlign.CENTER, 0xff488921);
			titleLabel.setTextFormat(titleTextFormat);
			
			mainMenu = new Box().fill(0xFFFFFF, 0.8, 0);
			mainMenu.add(new Box().fill(0x00000, .3, 15).margin(10, 10, 10, 10).minSize(_windowWidth / 2, _windowHeight).add(
				new Box().fill(0xffffff,1,5).margin(10,10,10,10).minSize(300,0).add(
						new Rows(
							titleLabel,
							new Columns(levelLabel, classLabel, coinLabel),
							continueButton,
							tutorialButton,
							new TextButton("New Game", newGame),
							new TextButton("Map Editor", mapEditor),
							new TextButton("Spend Skill Points", skillPoints)
						).spacing(15)
					)))
			FlxG.stage.addChild(mainMenu);
			
			loader = new Box().fill(0xffffff,.8).add(
				new Label("Creating Tutorial Level.", 20)
			).add(
				new Box().margin(20).add(new Label("Please wait while we connect to the server.", 12))
			)
			loader.width = FlxG.stage.stageWidth;
			loader.height = FlxG.stage.stageHeight;
		}
		
		//Callback function for when Continue Button is pressed
		private function continueQuest():void 
		{
			var _levelKey:String = "";
			if (tutorialLevel <= 5) {
				_levelKey = "Tutorial_" + tutorialLevel;
			}
			showLoader();
			myClient.multiplayer.createJoinRoom(
				null,								//Room id, null for auto generted
				"GetAcross",							//RoomType to create, bounce is a simple bounce server
				true,								//Hide room from userlist
				{name:"Tutorial", key:_levelKey, type:"static" },						//Room Join data, data is returned to lobby list. Variabels can be modifed on the server
				{},
				function(connection:Connection):void  {
					FlxG.stage.removeChild(mainMenu);
					hideLoader();
					FlxG.switchState( new PlayState(connection,myClient))
				},
				function(error:PlayerIOError):void {
					hideLoader();
					FlxG.stage.addChild(new Alert("Error finding level data in server!"));
				}										   
			)
		}
		//Callback function for when Start Tutorial Button is Pressed
		private function startTutorial():void
		{
			var prompt:InGamePrompt = new InGamePrompt(FlxG.stage, "Would you like to start the tutorial?  Warning: All previous tutorial progress will be lost!", function() { tutorialLevel = 1;  startNewTutorial() } );
		}

		//Callback when the user wants to start new tutorial
		private function startNewTutorial():void 
		{
			myPlayer.tutorial = tutorialLevel;
			trace("TUTORIAL TO START: " + myPlayer.tutorial);
			myPlayer.questID = "noQuest"
			myPlayer.save(false,false,
			function() {
				var _levelKey:String = "Tutorial_" + myPlayer.tutorial;
				showLoader();
				myClient.multiplayer.createJoinRoom(
					null,								//Room id, null for auto generted
					"GetAcross",							//RoomType to create, bounce is a simple bounce server
					true,								//Hide room from userlist
					{name:"Tutorial", key:_levelKey, type:"static" },						//Room Join data, data is returned to lobby list. Variabels can be modifed on the server
					{},
					function(connection:Connection) {
						FlxG.stage.removeChild(mainMenu);
						hideLoader();
						FlxG.switchState( new PlayState(connection,myClient))
					},
					function(error:PlayerIOError) {
						hideLoader();
						FlxG.stage.addChild(new Alert("Error: No connection to server!"));
					}
				);
			});
			
				//handleError					//Error handler										   
		}
		//Callback function for when New Game Button is pressed
		private function newGame():void
		{
			if (tutorialLevel <= 5) {
				FlxG.stage.addChild(new Alert("To Access This Option You Must Finish All 5 Tutorial Levels"));
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
		private function skillPoints():void
		{
			if (tutorialLevel <= 5) {
				FlxG.stage.addChild(new Alert("To Access This Option You Must Finish All 5 Tutorial Levels"));
			}else{
				this.kill();
				FlxG.stage.removeChild(mainMenu);
				FlxG.switchState(new AbilitySelectState(myClient));
			}
		}
		//Callback function for Map Editor Button
		private function mapEditor():void 
		{
			FlxG.switchState(new OptionState(myClient));
			//FlxG.switchState(new MapEditorState("n", "10", "10", myClient));
			FlxG.stage.removeChild(mainMenu);
			this.kill();
		}
		//Callback for once room is created
		private function joinRoom(id:String):void {
			if(id != null){
				showLoader()
				myClient.multiplayer.joinRoom(
					id,									//Room id
					{},									//User join data.
					handleJoin,							//Join handler
					handleError					//Error handler	
				)
			}
		}
		/*
		 * PLAYERIO ROOM JOIN
		 */
		//Callback function for LOBBY, once it has connected to a game
		private function handleJoin(connection:Connection):void 
		{
			if(connection != null){
				FlxG.switchState( new PlayState(connection, myClient))
				FlxG.stage.removeChild(mainMenu);
				FlxG.stage.removeChild(loader);
			}
		}
		
		//Callback function for LOBBY, if it has encountered an error
		private function handleError(error:PlayerIOError):void{
			hideLoader();
			FlxG.stage.addChild(new Alert("Error happened when connecting to lobby "));
			//FlxG.state = new LoginState()
		}
		
		
		
		private function showLoader():void{
			FlxG.stage.addChild(loader)
		}

		private function hideLoader():void{
			if(loader.parent)FlxG.stage.removeChild(loader)
		}
	}

}