package  
{
	import flash.display.SimpleButton;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxG;
	import org.flixel.FlxText;
	import org.flixel.plugin.photonstorm.FlxHealthBar;
	import playerio.*
	import sample.ui.components.*
	import sample.ui.*
	import flash.events.TimerEvent
	import flash.utils.Timer
	
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
		private var _xpGain:int
		private var characterInfo:Label
		private var levelLabel:Label;
		private var classLabel:Label;
		private var coinLabel:Label;
		private var mainMenu:Box
		private var nextLevelButton:TextButton
		private var mainMenuButton:TextButton;
		private var loader:Box
		
		public function QuestCompleteState(gainedXP:int, coin:int, client:Client, nextLevel:String) 
		{
			_client = client;
			_nextLevel = nextLevel;
			_xpGain = gainedXP;
			super();
			add(new Background("Map"));
			characterInfo = new Label("", 12, TextFormatAlign.CENTER);
			client.bigDB.loadMyPlayerObject(loadPlayerSuccess);
			mainMenuButton = new TextButton("Main Menu", continueButton);
			nextLevelButton = new TextButton("Next Level", nextLevelCallback);
			mainMenuButton.visible = false;
			nextLevelButton.visible = false;
			if (nextLevel == "") {
				nextLevelButton.visible = false;
				nextLevelButton.enabled = false;
			}else if (nextLevel == "Class_Choose") {
				nextLevelButton = new TextButton("Choose Class", chooseClassCallback);
				mainMenuButton.visible = false;
				mainMenuButton.enabled = false;
			}
			
			// initialize labels for player info to show at the end
			var playerInfoTextSize:int = 17;
			var levelTextFormat:TextFormat = new TextFormat("Abscissa", playerInfoTextSize, 0xff488921);
			levelLabel = new Label("Level: ", playerInfoTextSize, TextFormatAlign.CENTER, 0xff488921);
			levelLabel.setTextFormat(levelTextFormat);
			
			var classTextFormat:TextFormat = new TextFormat("Abscissa", playerInfoTextSize, 0xff488921);
			classLabel = new Label("Class: ", playerInfoTextSize, TextFormatAlign.CENTER, 0xff488921);
			classLabel.setTextFormat(classTextFormat);
			
			var coinTextFormat:TextFormat = new TextFormat("Abscissa", playerInfoTextSize, 0xff488921);
			coinLabel = new Label("Coins: ", playerInfoTextSize, TextFormatAlign.CENTER, 0xff488921);
			coinLabel.setTextFormat(coinTextFormat);
			
			// labels for other information
			var questTextFormat:TextFormat = new TextFormat("Abscissa", 30, 0xff488921);
			var questLabel:Label = new Label("quest complete!", 30, TextFormatAlign.CENTER, 0xff488921);
			questLabel.setTextFormat(questTextFormat);
			
			var xpGainedTextFormat:TextFormat = new TextFormat("Abscissa", 20, 0xff488921);
			var xpGainedLabel:Label = new Label("Gained " + gainedXP + " XP!", 20, TextFormatAlign.LEFT, 0xff4af266);
			xpGainedLabel.setTextFormat(xpGainedTextFormat);
			
			var coinsGainedTextFormat:TextFormat = new TextFormat("Abscissa", 20, 0xff488921);
			var coinsGainedLabel:Label = new Label("Gained " + coin + " coins!", 20, TextFormatAlign.LEFT, 0xff4af266);
			coinsGainedLabel.setTextFormat(coinsGainedTextFormat);
			
			mainMenu = new Box().fill(0xFFFFFF, 0.8, 0);
			mainMenu.add(new Box().fill(0x00000, 0.3, 15).margin(10, 10, 10, 10).minSize(FlxG.width / 2, FlxG.height).add(
				new Box().fill(0xffffff,1,5).margin(10,10,10,10).minSize(300,0).add(
						new Rows(
							questLabel,
							new Columns(levelLabel, classLabel, coinLabel),
							xpGainedLabel,
							coinsGainedLabel,
							new Columns().spacing(8).margin(10).add(
							mainMenuButton,
							nextLevelButton)
						).spacing(30)
					)));
			FlxG.stage.addChild(mainMenu);
			
			loader = new Box().fill(0xffffff,.8).add(
				new Label("Creating Tutorial Level.", 20)
			).add(
				new Box().margin(20).add(new Label("Please wait while we connect to the server.", 12))
			)
			loader.width = FlxG.stage.stageWidth;
			loader.height = FlxG.stage.stageHeight;
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
			
			
			//XP BAR - have to make a sprite to leverage the FlxHealthBar, his health will reflect the XP
			var xpSprite:FlxSprite = new FlxSprite(0, 0, null);
			xpSprite.health = ob.xp;
			var neededXP:Number = needXP(ob.level + 1);
			var xpBar:FlxHealthBar = new FlxHealthBar(xpSprite, 300, 100, needXP(ob.level), neededXP, true);
			xpBar.x = (FlxG.width / 2) + 20
			xpBar.y = 100
			var xpText:FlxText = new FlxText( xpBar.x + 150, 150, 300, xpSprite.health.toString() + " XP / " + neededXP.toString() + " XP");
			add(xpSprite);
			add(xpBar);
			add(xpText);
			var count:int = 0;
			var myTimer:Timer = new Timer(100);
			myTimer.addEventListener(TimerEvent.TIMER, function (event:TimerEvent):void 
			{
				xpSprite.health++;
				count++;
				
				if (xpSprite.health >= neededXP) {
					FlxG.flash(0xffffff, 1, function() {
						FlxG.stage.addChild(new Alert("You Have Leveled Up!"));
					});
					ob.level = ob.level + 1;
					neededXP = needXP(ob.level + 1);
					xpBar.setRange(needXP(ob.level), neededXP)
					ob.save();
				}else if(count >= _xpGain){
					myTimer.stop();
					levelLabel.text = "Level " + ob.level;
					classLabel.text = "Class: " + ob.role;
					coinLabel.text = "Coins: " + ob.coin;
					mainMenuButton.visible = true;
					nextLevelButton.visible = true;
				}
				xpText.text = xpSprite.health.toString() + " XP / " + neededXP.toString() + " XP";
			});
			myTimer.start();
			// labels for player info
			levelLabel.text = "Level " + ob.level;
			classLabel.text = "Class: " + ob.role;
			coinLabel.text = "Coins: " + ob.coin;
		}
		
		//Callback for when players must choose a class
		private function chooseClassCallback():void {
			FlxG.stage.removeChild(mainMenu);
			this.kill();
			FlxG.switchState(new ClassChooseState(_client));
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
		
		private function needXP(level:int):Number {
			return Math.floor(Math.pow((level - 1), 1.2) * 25)
		}

	}

}