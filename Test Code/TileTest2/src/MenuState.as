package  
{
	import playerio.*
	import sample.ui.*
	import org.flixel.*
	import flash.text.*;
	import sample.ui.components.*
	import flash.text.TextFormatAlign
	import Facebook.FB
	import org.flixel.plugin.photonstorm.FlxHealthBar;

	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class MenuState extends FlxState
	{
		private var mainMenu:Box
		private var mapTypeSelection:Box;
		private var myClient:Client;
		private var tutorialButton:TextButton;
		private var continueButton:TextButton;
		private var tutorialLevel:int = 0;
		private var loader:Box
		private var _questID:String;
		private var _roomID:String;
		private var myPlayer:DatabaseObject;
		[Embed(source = "data/Planter2.png")] public var planterImg:Class;
		[Embed(source = "data/Cook2.png")] public var cookImg:Class;
		[Embed(source = "data/Crafter2.png")] public var crafterImg:Class;
		[Embed(source = "data/Novice2.png")] private var noviceImg:Class;
		[Embed(source = "data/Crafter_wrench.png")] public var crafterWrenchImg:Class;
		[Embed(source = "data/Crafter_hammer.png")] public var crafterHammerImg:Class;
		[Embed(source = "data/Cook_chef.png")] public var cookChefImg:Class;
		[Embed(source = "data/Cook_spaghetti.png")] public var cookSpaghettiImg:Class;
		[Embed(source = "data/Planter_tulips.png")] public var planterTulipsImg:Class;
		[Embed(source = "data/Planter_thorns.png")] public var planterThornsImg:Class;
		
		private static var _windowWidth:int = 700;
		private static var _windowHeight:int = 400;
		private static var playerClass:String;
		
		// stuff about the player on the right side of the screen
		private var playerClassImg:FlxSprite = new FlxSprite();
		private static var xpBar:FlxHealthBar;
		private static var xpText:FlxText;
		private static var levelText:FlxText;
		private static var spText:FlxText;
		private static var coinText:FlxText;
		
		public function MenuState(client:Client) 
		{
			myClient = client;
			super();
			add(new Background("Map"));
			client.bigDB.loadMyPlayerObject(loadPlayerSuccess);
			playerClassImg = new FlxSprite(450, 130, noviceImg);
			levelText = new FlxText(360, 10, 300, "Level " ).setFormat(null, 25);
			xpBar = new FlxHealthBar(playerClassImg,200,50);
			xpBar.x = levelText.x;
			xpBar.y = levelText.y + 50;
			xpText = new FlxText(xpBar.x, xpBar.y + 50, 300, "").setFormat(null, 13);
			
			spText = new FlxText(levelText.x, playerClassImg.y + 150, 300, "Skill Points: " ).setFormat(null, 20);
			coinText = new FlxText(levelText.x, spText.y + 50, 300, "Coins: " ).setFormat(null, 20);
			
			add(playerClassImg);
			add(xpBar);
			add(xpText);
			add(levelText);
			add(spText);
			add(coinText);
		}
		
		//Callback function called when Player data object has been successfully loaded
		private function loadPlayerSuccess(ob:DatabaseObject):void 
		{
			myPlayer = ob;
			playerClassImg.health = myPlayer.xp;
			var neededXP:Number = QuestCompleteState.needXP(myPlayer.level + 1);
			xpBar = new FlxHealthBar(playerClassImg, 200, 70, QuestCompleteState.needXP(myPlayer.level), neededXP, true);
			xpText.text = "You have " + playerClassImg.health.toString() + " XP.  " + neededXP.toString() + " XP until level " + (myPlayer.level + 1) + "!";
			levelText.text += myPlayer.level + " " + myPlayer.role;
			spText.text += myPlayer.sp;
			coinText.text += myPlayer.coin;
			
			// image of player avatar
			playerClass = ob.role;
			// image of player avatar
			// if has costume, show; otherwise, just show basic class image
			if (myPlayer.costume != null) {
				switch (myPlayer.costume)
				{
					case "Cook_normal":
						playerClassImg.loadGraphic(cookImg);
						break;
					case "spaghetti":
						playerClassImg.loadGraphic(cookSpaghettiImg);
						break;
					case "chef":
						playerClassImg.loadGraphic(cookChefImg);
						break;
					case "Crafter_normal":
						playerClassImg.loadGraphic(crafterImg);
						break;
					case "wrench":
						playerClassImg.loadGraphic(crafterWrenchImg);
						break;
					case "hammer":
						playerClassImg.loadGraphic(crafterHammerImg);
						break;
					case "Planter_normal":
						playerClassImg.loadGraphic(planterImg);
						break;
					case "tulips":
						playerClassImg.loadGraphic(planterTulipsImg);
						break;
					case "thorns":
						playerClassImg.loadGraphic(planterThornsImg);
						break;
					default:
						playerClassImg.loadGraphic(noviceImg);
						break;
				}
			}
			
			else {
				switch (playerClass)
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
				} else if (tutorialLevel == 6 && playerClass == "Novice") {
					continueButton = new TextButton("You finished all tutorial levels!  Choose your class!", chooseClass);
				} else { // player has finished tutorials
					tutorialButton.visible = tutorialButton.enabled = false;
					continueButton = new TextButton("Continue Your Previous Quest", continueQuest);
					if (_questID == "noQuest") {
						continueButton.visible = continueButton.enabled = false;
					}else {
						continueButton.enabled = continueButton.visible = true;
					}
				}
			}
			catch (e:Error)
			{
				continueButton.visible = continueButton.enabled = false;
			}
			//Try to load questID, if no quest then that button is invisible
			
			var titleTextFormat:TextFormat = new TextFormat("Abscissa", 40, 0xff488921);
			var titleLabel:Label = new Label("Get Across", 40, TextFormatAlign.CENTER, 0xff488921);
			titleLabel.setTextFormat(titleTextFormat);
			mapTypeSelection = new Box().fill(0xFFFFFF, 0.8, 0);
			mapTypeSelection.add(new Box().fill(0x00000, .3, 15).margin(10, 10, 10, 10).minSize(_windowWidth / 2, _windowHeight).add(
				new Box().fill(0xffffff,1,5).margin(10,10,10,10).minSize(300,0).add(
						new Rows(
							new Label("Select a Map Type", 35, TextFormatAlign.CENTER, 0xff488921),
							new TextButton(myPlayer.role + " Maps", classMaps),
							new TextButton("Large Maps (Play with your Friends!)", largeMaps),
							new TextButton("User-Made Maps", userMaps),
							new TextButton("Back to Main Menu", back)
						).spacing(15)
					)))
			mainMenu = new Box().fill(0xFFFFFF, 0.8, 0);
			mainMenu.add(new Box().fill(0x00000, .3, 15).margin(10, 10, 10, 10).minSize(_windowWidth / 2, _windowHeight).add(
				new Box().fill(0xffffff,1,5).margin(10,10,10,10).minSize(300,0).add(
						new Rows(
							titleLabel,
							new TextButton("Character Screen", function():void { FlxG.switchState(new CharacterScreen(myClient)); FlxG.stage.removeChild(mainMenu); } ),
							continueButton,
							tutorialButton,
							new TextButton("Start New Quest", newGame),
							new TextButton("Quest Editor", mapEditor),
							new TextButton("Buy abilities with Skill Points", skillPoints),
							new TextButton("Buy items with Coins", coins)
						).spacing(15)
					)))
			FlxG.stage.addChild(mainMenu);
			
			loader = new Box().fill(0xffffff,.8).add(
				new Label("Creating Level.", 20)
			).add(
				new Box().margin(20).add(new Label("Please wait while we connect to the server.", 12))
			)
			loader.width = FlxG.stage.stageWidth;
			loader.height = FlxG.stage.stageHeight;
		}
		
		// callback function for choosing class
		private function chooseClass():void {
			FlxG.switchState(new ClassChooseState(myClient));
			FlxG.stage.removeChild(mainMenu);
		}
		
		//Callback function for when Continue Button is pressed
		private function continueQuest():void 
		{
			var _levelKey:String = "";
			if (tutorialLevel <= 5) {
				_levelKey = "Tutorial_" + tutorialLevel;
			}
			showLoader();
			myClient.bigDB.load("NewQuests", _questID,
				function(quest:DatabaseObject):void 
				{
					var roomID:String = quest.RoomID
					myClient.multiplayer.createJoinRoom(
						quest.RoomID,								//Room id, null for auto generted
						"GetAcross",							//RoomType to create, bounce is a simple bounce server
						true,								//Hide room from userlist
						{name:"Tutorial", key:_levelKey, type:"static", continueQuest:_questID },						//Room Join data, data is returned to lobby list. Variabels can be modifed on the server
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
				})
	
		}
		//Callback function for when Start Tutorial Button is Pressed
		private function startTutorial():void
		{
			var prompt:InGamePrompt = new InGamePrompt(FlxG.stage, "Would you like to start the tutorial?  Warning: All previous tutorial progress will be lost!", function():void { tutorialLevel = 1;  startNewTutorial() } );
		}

		//Callback when the user wants to start new tutorial
		private function startNewTutorial():void 
		{
			myPlayer.tutorial = tutorialLevel;
			trace("TUTORIAL TO START: " + myPlayer.tutorial);
			myPlayer.questID = "noQuest"
			myPlayer.save(false,false,
			function():void {
				var _levelKey:String = "Tutorial_" + myPlayer.tutorial;
				showLoader();
				myClient.multiplayer.createJoinRoom(
					null,								//Room id, null for auto generted
					"GetAcross",							//RoomType to create, bounce is a simple bounce server
					true,								//Hide room from userlist
					{name:"Tutorial", key:_levelKey, type:"static", continueQuest:"noQuest" },						//Room Join data, data is returned to lobby list. Variabels can be modifed on the server
					{},
					function(connection:Connection):void {
						FlxG.stage.removeChild(mainMenu);
						hideLoader();
						FlxG.switchState( new PlayState(connection,myClient))
					},
					function(error:PlayerIOError):void {
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
			if (playerClass == "Novice") {
				FlxG.stage.addChild(new Alert("To Access This Option You Must Finish All 5 Tutorial Levels"));
			} else if (continueButton.enabled == true) {
				var prompt:InGamePrompt = new InGamePrompt(FlxG.stage, "You will lose your old quest data if you start a new game. You sure?", function():void {
					//startNewGameAccept();
					FlxG.stage.addChild(mapTypeSelection);
					FlxG.stage.removeChild(mainMenu);
				});
			}else {
				//startNewGameAccept();
				FlxG.stage.addChild(mapTypeSelection);
				FlxG.stage.removeChild(mainMenu);
			}
		}
		//Callback function for when class maps are chosen from the menu
		private function classMaps():void {
			startNewGameAccept(myPlayer.role);
		}
		
		//Callback function for when large maps is chosen from map type menu
		private function largeMaps():void {
			startNewGameAccept("Campaign");
		}
		
		//Callback function for when User Maps is selected from map type menu
		private function userMaps():void {
			startNewGameAccept("User");
		}
		
		//If the Start new game prompt is accepted and the users desires to delete their old quest
		private function startNewGameAccept(type:String ):void {
			myPlayer.questID = "noQuest";
			FlxG.stage.removeChild(mapTypeSelection);
			myPlayer.save(false,false,function ():void 
			{
				FlxG.switchState(new LevelChooseState(myClient, type));
			})
			this.kill();
		}
		
		//Callback for when back button is selected from map type selection menu
		private function back():void {
			FlxG.stage.removeChild(mapTypeSelection);
			FlxG.stage.addChild(mainMenu);
		}
		//Callback function for when Spend Coins is pressed
		private function coins():void {
			if (tutorialLevel <= 5) {
				FlxG.stage.addChild(new Alert("To Access This Option You Must Finish All 5 Tutorial Levels"));
			}else{
				this.kill();
				FlxG.stage.removeChild(mainMenu);
				FlxG.switchState(new StoreState(myClient));
			}
		}
		
		// callback function for character screen
		private function character():void {
			if (tutorialLevel <= 5) {
				FlxG.stage.addChild(new Alert("To Access This Option You Must Finish All 5 Tutorial Levels"));
			}else{
				this.kill();
				FlxG.stage.removeChild(mainMenu);
				FlxG.switchState(new CharacterScreen(myClient));
			}
		}
		
		//Callback function for when Spend Skill Points Button is pressed
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