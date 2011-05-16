package  
{
	import flash.display.Sprite;
	import org.flixel.*
	import org.flixel.plugin.photonstorm.FlxHealthBar;
	import org.flixel.system.input.*;// data.FlxMouse;
	//import org.flixel.data.FlxPanel;
	import playerio.*
	import sample.ui.Alert;
	import sample.ui.components.AbilityButton;
	import sample.ui.components.Box;
	import sample.ui.components.Label;
	import sample.ui.components.Rows;
	import sample.ui.components.TextButton;
	import sample.ui.InGamePrompt;
	import sample.ui.Prompt
	import sample.ui.Chat
	import flash.text.TextFormatAlign
	import flash.utils.*;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class PlayState extends FlxState
	{
		//Tile Value Constants, if tileSet changes, need to update these!!
		private const GRASS_TILE:int = 0;
		private const HILL_TILE:int = 1;
		private const TREE_TILE:int = 2;
		private const CHERRY_TILE:int = 3;
		private const WATER_TILE:int = 4;
		private const WIN_TILE:int = 5;
		
		//[Embed(source = "data/map_data.txt", mimeType = "application/octet-stream")] public var data_map:Class; //Tile Map array
		[Embed(source = "data/testTileSet2_32.png")] public var data_tiles:Class; //Tile Set Image
		[Embed(source = "data/Cursor.png")] public var cursor_img:Class; //Mouse Cursor
		[Embed(source = "data/hoverTileImg.png")] public var hoverTileImg:Class;
		[Embed(source = "data/noTileImg.png")] public var hoverTileImgNo:Class;
		private var apInfo:FlxText; //Text field to reflect the numner of AP left
		private var myPlayer:Player;
		private var playersArray:Array = []; //Array of all players on board
		private var monsterArray:Array = [];
		
		private var myMouse:Mouse; //Mouse
		private var errorMessage:FlxText; //Text Field to reflect any errors
		private var secCounter:FlxText; //Text field to reflect time left until next AP
		private var location:FlxText; //(x,x) graph information of where your player is.
		private var mouseLocation:FlxText; //Text Field to reflect tile information where the mouse is
		private var counter:Number; //Sec/ 1 ap, this will be moved serverside
		private var goals:FlxText; //Simple text field where goals can be written
		private var abilities:FlxText; //Simple text label for abilities
		private var abilitiesBox:Box;
		private var connected:Boolean = false; //Indicates if connection has been established1
		private var lvl:FlxText;
		private var experience:FlxText;
		private var resources:FlxText;
		public static var resourcesText:FlxText;
		private var background:Background;
		private var playerStartX: int = 0;	// starting x position of this player
		private var playerStartY: int = 0;	// starting y position of this player
		private static var alert:Alert;
		
		public static var myMap:FlxTilemap; //The tile map where the tileset is drawn
		public static var lyrStage:FlxGroup;
        public static var lyrSprites:FlxGroup;
        public static var lyrHUD:FlxGroup;
		public static var lyrBackground:FlxGroup;
		public static var lyrBattle:FlxGroup;
		public static var lyrMonster:FlxGroup;
		public static var lyrTop:FlxGroup;
		
		private static var _windowWidth:int = 700;
		private static var _windowHeight:int = 400;
		
		private static var abilitySelected:Boolean = false; //Indicates whether an ability is activated
		private static var activeAbility:Ability; //Which ability is currently chosen
		
		private var imPlayer:int;
		private var myID:String;
		private var infoBox:InfoBox;
		private var client:Client;
		private var connection:Connection; //connection to server
		
		// buttons for side menu
		public static var gatherResourcesButton:FlxButton;
		
		
		private var win:Boolean = false; //This variable will indicate if a user has won or not
		
		// constants/offset numbers
		public static var _mapOffsetX:int = 204; 	// left border of map
		public static var _mapOffsetY:int = 46;	// top border of map
		private var _apBoxOffsetX:int = 265;
		private var _apBoxOffsetY:int = 10;
		private var _timerOffsetX:int = 360;
		private var _timerOffsetY:int = 5;
		private var _positionInfoOffsetX:int = 480;
		private var _positionInfoOffsetY:int = 368;
		private var _terrainMessageBoxOffsetX:int = 210;
		private var _terrainMessageBoxOffsetY:int = 368;
		private var _errorMessageOffsetX: int = 600;
		private var _errorMessageOffsetY: int = 368;
		private var _goalsBoxOffsetX:int = 540;
		private var _goalsBoxOffsetY:int = 70;
		private var _cardBoxOffsetX:int = 31;
		private var _cardBoxOffsetY:int = 75;
		private static var _tileSize:int = 32;
		private var _lvlTextOffsetX:int = 5;
		private var _lvlTextOffsetY:int = 5;
		private var _experienceTextOffsetX:int = 70;
		private var _experienceTextOffsetY:int = 5;
		private var _resourceTextOffsetX:int = 540;
		private var _resourceTextOffsetY:int = 250;
		
		private static var myClient:Client;
		private static var myConnection:Connection;
		private static var playerName:String;
		private static var playerAP:int;
		private var _APcounterMax:int = 10;	// seconds to pass until player gets AP incremented
		private static var resourcesString;
		
		private var camMap:FlxCamera;
		private var camMap2:FlxCamera;
		
		private var _windowHeight:int = 400;
		private var _windowWidth:int = 700;
		
		private var gatherResourceButton:FlxButton;
		
		private var timer;				// object used for delays.
		
		private var tileHover:FlxSprite;
		
		public function PlayState(connection:Connection, client:Client):void
		{

			super();
			trace("Sucessfully connected to the multiplayer server");
			
			infoBox = new InfoBox(resetGame,joinGame);
			//addChild(infoBox);
			
			infoBox.Show("waiting");						

			this.client = client;
			myClient = client;
			this.connection = myConnection = connection;
			
			//Connection successful, load board and player
			connection.addMessageHandler("init", function(m:Message, iAm:int, name:String, level:String, startAP:int, levelKey:String, resources:String) {
				imPlayer = iAm;
				playerAP = startAP;
				trace("init: starting ap: " + playerAP);
				//boardSetup(level);
				resourcesString = resources;
				client.bigDB.load("NewQuests", level, function(ob:DatabaseObject):void {
					//Recieve Tile Array from database to be turned into string with line breaks between each line
					if (ob != null)
					{
						var mapString:String = ob.tileValues;
						connection.send("QuestMapUpdate", mapString);
						mapString = mapString.split("|").join("\n");
						boardSetup(mapString, name, levelKey);
						trace("board made");
						//Load Monster
						try {
							//monsterArray = new Array[ob.MonsterCount];
							var monsters:Array = ob.Monsters
							for (var z in monsters) {
								//Dont add a monster that is dead
								if(monsters[z].AP > 0){
									var myMonsterSprite:Monster = new Monster(monsters[z].Type, monsters[z].AP, z, monsters[z].xTile, monsters[z].yTile,0, _windowHeight, _tileSize);
									monsterArray.push(myMonsterSprite);
									lyrMonster.add(myMonsterSprite);
									lyrHUD.add(myMonsterSprite.healthBar);
									
								}
							}
						}catch (e:Error) {
							trace("Monster Loading Error: " + e);
						}
					}
					
					// if object is null, then player's quest ended before they returned to it...return them to the menu screen
					else 
					{
						//todo: add message explaining maybe what XP/coins were won
						// remove questID associated with this player
						client.bigDB.load("PlayerObjects", name,
							function(thisPlayer:DatabaseObject):void
							{
								thisPlayer.questID = "noQuest";
								thisPlayer.save();
							}
						);
						
						// create new menu for player to navigate back to main screen
						var button:TextButton = new TextButton("Start a new quest!",
							function ():void
							{
								FlxG.switchState(new MenuState(client));
							}
						);
						var menu:Box = new Box().fill(0xFFFFFF, 0.8, 0)
						menu.add(new Box().fill(0x00000, .5, 15).margin(10, 10, 10, 10).minSize(FlxG.width, FlxG.height).add(
							new Box().fill(0xffffff,1,5).margin(10,10,10,10).minSize(300,0).add(
									new Rows(
										new Label("This quest is already finished!", 30, TextFormatAlign.CENTER),
										button
									).spacing(30)
								)
							)
						);
						FlxG.stage.addChild(menu);
					}
					connection.send("PlayerSetUp");
				});
			})
			
			if (myMap == null) {
				trace("map doesn't exist....");
			}
			
			
			//Recieve Info from server about your saved character
			connection.addMessageHandler("playerInfo", function(m:Message, posX:int, posY:int, name:String) {
				if (myPlayer == null) {
					playerName = name;
					// add player to screen --
					trace("create player sprite: " + posX + " " + posY);
					trace("playerInfo: AP to start with: " + playerAP);
					trace("resources to start with: " + playerAP);
					myPlayer = new Player(posX, posY, 0, _windowHeight, _tileSize, playerAP, resourcesString);
					playersArray[imPlayer - 1] = myPlayer;
					
					var playerHealthBar:FlxHealthBar = new FlxHealthBar(myPlayer, 100, 20, 0, 20, true);
					playerHealthBar.x = _apBoxOffsetX - 35
					playerHealthBar.y = _apBoxOffsetY - 5
					lyrHUD.add(playerHealthBar);
					lyrTop.add(apInfo);
					lyrSprites.add(myPlayer);

					//Load Abilities for Player From Database
					client.bigDB.loadMyPlayerObject(function(db:DatabaseObject) {
						try {
							var abilityArray:Array = db.abilities
							if (abilityArray != null || abilityArray.length > 0) {
								client.bigDB.loadKeys("Abilities", db.abilities, function(dbarr:Array) {
									var yButtonPlacementModifier:int = 0;
									for (var z:String in dbarr) {
										var test:DatabaseObject = dbarr[z]
										var myAbility:Ability = new Ability(_tileSize, 0, _windowHeight, myPlayer, test);
										myAbility.visible = false;
										lyrStage.add(myAbility);
										trace("Loaded Ability " + test.Name + "\n");
										lyrHUD.add(new AbilityButton(_cardBoxOffsetX, _cardBoxOffsetY + yButtonPlacementModifier, myAbility))
										lyrHUD.add(new FlxText(_cardBoxOffsetX + 2, _cardBoxOffsetY + yButtonPlacementModifier + 2, 100, test.Name))
										yButtonPlacementModifier += 30
									}
								})
							}
						} catch (e:Error) {
							//Catches Error is no abilities have been set yet
							trace("unable to load abilities");
						}
					});
				}
				timer = setInterval(setCameras, 100);	// set up camera after 0.1 second.... to ensure everything is set

				//FlxG.follow(myPlayer);
				//FlxG.followBounds(0, 0, myMap.width, myMap.height);
				
			})
			
			//New user has joined, make their character
			connection.addMessageHandler("UserJoined", function(m:Message, userID:int, posX:int, posY:int) {
				if (userID != imPlayer) {
					// create other player; AP doesn't matter, so default to 20
					playersArray[userID-1] = new Player(posX, posY, 0,_windowHeight , _tileSize, 20, null);
					if (playersArray[userID-1] != null && lyrSprites != null) lyrSprites.add(playersArray[userID-1]);
				}
			})
			//Player has moved and we hear about it
			connection.addMessageHandler("PlayerMove", function(m:Message, userID:int, posX:int, posY:int) {
				var tileType:int = getTileIdentity(posX, posY);
				if(userID != imPlayer){
					Player(playersArray[userID - 1]).movePlayer(posX, posY, _tileSize, connection);
				}
			})
			//A tile has changed and needs to be updated locally
			connection.addMessageHandler("MapTileChanged", function(m:Message, userID:int, posX:int, posY:int, newTileType:int) {
				myMap.setTile( posX, posY, newTileType);
				//myMap.setTile(posX, posY, newTileType, true);
			})
			//A player has reached the end, victory!
			connection.addMessageHandler("win", cleanup)
			//A monster has been hurt and need their AP updated
			connection.addMessageHandler("MonsterAPChange", function (m:Message, userID:int, newAP:int, monsterIndex:int ):void 
			{
				monsterArray[monsterIndex]._ap = newAP;
			})
			connection.addMessageHandler("AlertMessages", function(m:Message, levelKey:String):void
			{
				client.bigDB.load("StaticMaps", levelKey,
					function(dbo:DatabaseObject) {
						//trace("message object: " + dbo.toString());
						var messages:Array = dbo.Messages
						for (var z in messages) {
							//while (alert.unread) {
							//}
							alert.changeText(messages[z]);
							alert.width = FlxG.stage.stageWidth
							alert.height = FlxG.stage.stageHeight
							FlxG.stage.addChild(alert);
						}
					}
				);
			})
		
		}
		
		private function setCameras():void {
			// Camera will show up at where the map should be
			camMap= new FlxCamera(_mapOffsetX, _mapOffsetY, 320, 320);
			camMap.follow(myPlayer, FlxCamera.STYLE_TOPDOWN);
			camMap.setBounds(0, _windowHeight, myMap.width, myMap.height, true);
			//camMap.color = 0xFFCCCC;
			FlxG.addCamera(camMap);							// camera that shows where the character is on the map
		
			// stop the interval
			clearInterval(timer);
		}
		
		private function cleanup(m:Message, userID:int, xp:int, coin:int):void 
		{
			connection.disconnect();
			this.kill();
			FlxG.switchState(new QuestCompleteState(xp, coin, client));
			
		}
		override public function update():void 
		{
			
			if (connected == true) {
				if (getTileIdentity(myPlayer.xPos, myPlayer.yPos) == CHERRY_TILE)
				{
					gatherResourceButton = new FlxButton(myPlayer.x + 20, myPlayer.y - 20, "Pick Cherry");
					//gatherResourcesButton.x = myPlayer.x + 20;
					//gatherResourcesButton.y = myPlayer.y - 20;
					//gatherResourcesButton.visible = true;
					add(gatherResourceButton);
				}
				else { 
					remove(gatherResourceButton);// gatherResourcesButton.visible = false;
				}
				counter -= FlxG.elapsed;
				if (counter <= 0)
				{
					// After 180 seconds has passed, the timer will reset.
					counter = _APcounterMax;
					// increment player's AP if it's not the max yet
					if (myPlayer.AP < 20)
						myPlayer.AP++;
					myConnection.send("updateStat", "AP", myPlayer.AP);
				}
				//Update HUD Information
				secCounter.text = counter.toPrecision(3) + " seconds until more AP";
				//Player moves only one character, detect keys presses here

				if (myPlayer != null && !win) {
					if (myPlayer.AP <= 20 && FlxG.keys.justPressed("A")) {
						myPlayer.AP++;
						myConnection.send("updateStat", "AP", myPlayer.AP);
					}
					if (FlxG.keys.justPressed("DOWN") && !myPlayer.isMoving && !myPlayer.inBattle) {
						myPlayer.facing = FlxSprite.DOWN;
						win = myPlayer.movePlayer(0, 1, _tileSize, connection);
						connection.send("move", 0, 1);
					}else if (FlxG.keys.justPressed("UP") && !myPlayer.isMoving && !myPlayer.inBattle) {
						myPlayer.facing = FlxSprite.UP;
						win = myPlayer.movePlayer(0, -1, _tileSize, connection);
						connection.send("move", 0, -1);
					}else if (FlxG.keys.justPressed("RIGHT") && !myPlayer.isMoving && !myPlayer.inBattle) {
						myPlayer.facing = FlxSprite.RIGHT;
						win = myPlayer.movePlayer(1, 0, _tileSize, connection);
						connection.send("move", 1, 0);
					}else if (FlxG.keys.justPressed("LEFT") && !myPlayer.isMoving && !myPlayer.inBattle) {
						myPlayer.facing = FlxSprite.LEFT;
						win = myPlayer.movePlayer( -1, 0, _tileSize, connection);
						connection.send("move", -1, 0);
					}else if (myMouse.justPressed() &&  mouseWithinTileMap() && abilitySelected) {
						var selectedXTile:int = (myMouse.x - _mapOffsetX) / _tileSize
						//(myMouse.x - (myMouse.x % 32)) / 32;
						var selectedYTile:int = (myMouse.y - _mapOffsetY) / _tileSize
						//(myMouse.y - (myMouse.y % 32)) / 32
						//TO DO: ADD ALERT MESSAGE!!!
						if (checkActiveAbilityRange(selectedXTile, selectedYTile)) {
							activeAbility.cast(selectedXTile, selectedYTile , connection);
						}
					}else if(!myPlayer.isMoving) {
						myPlayer.play("idle" + myPlayer.facing);
					}
					
					tileHover.visible = mouseWithinTileMap();

					if (tileHover.visible) {
						var xTemp:int = Math.floor((myMouse.x - _mapOffsetX) / _tileSize);
						var xTempCoord:int = xTemp * _tileSize;
						var yTemp:int = Math.floor((myMouse.y - _mapOffsetY) / _tileSize);
						var yTempCoord:int = yTemp * _tileSize + _windowHeight;
						tileHover.x = xTempCoord;
						tileHover.y = yTempCoord;
						
						// if within 1 tile away
						// if okay condition
						// then go
						var absDis:int = Math.abs(myPlayer.xPos - xTemp) + Math.abs(myPlayer.yPos - yTemp);
						// have to check if the move is possible beforehand... 
						var canGo:Boolean = myPlayer.checkMove(xTemp, yTemp);
						
						if (absDis < 2 && absDis > 0 && canGo) {	// one away
							tileHover.loadGraphic(hoverTileImg);
							if (myMouse.justPressed()) {
								trace("okay to move");
								// check for condition....
								
								if (xTemp < myPlayer.xPos) myPlayer.facing = FlxSprite.LEFT;
								else if (xTemp > myPlayer.xPos) myPlayer.facing =FlxSprite.RIGHT;
								else if (yTemp < myPlayer.yPos) myPlayer.facing =FlxSprite.UP;
								else if (yTemp > myPlayer.yPos) myPlayer.facing =FlxSprite.DOWN;
								
								win = myPlayer.movePlayer(xTemp - myPlayer.xPos, yTemp - myPlayer.yPos, _tileSize, connection)
							}
						} else {
							// if not within reach, set color to red
							tileHover.loadGraphic(hoverTileImgNo);
						}
					}
					
					apInfo.text = "AP: " + myPlayer.AP;
					location.text = "(" + myPlayer.xPos + "," + myPlayer.yPos + ")";
					errorMessage.text = "" + myPlayer.errorMessage;
					if (win) {
						connection.send("win")
					}
					if (mouseWithinTileMap()){
						mouseLocation.text = tileInformation(getTileIdentity(myMouse.x, myMouse.y));
					} else {
						mouseLocation.text = "";
					}
					//Only show the battle hud if the player is in combat
					lyrBattle.visible = myPlayer.inBattle;
					 //Detect Monster collision, if a monster is overlapping your player then you are now in a fight
					for (var monster in monsterArray) {
						FlxG.overlap(monsterArray[monster], myPlayer, function() {
							myPlayer.inBattle = true;
							myPlayer.combatant = monsterArray[monster]
							errorMessage.text = "BATTLE!";
							lyrBattle.visible = true;
						})
					}
				}
			}
			super.update();
		}
		
		//Give a tile number and return information String about that Tile
		private function tileInformation(type:Number):String
		{
			if (type == HILL_TILE) {
				return "Hill (Travel Cost = 3AP)";
			}else if (type == TREE_TILE) {
				return "Tree (Travel Cost = 1AP)";
			}else if (type == CHERRY_TILE) {
				return "Cherry Tree (Travel Cost = 1AP)";
			}else if (type == WATER_TILE || type == 6 || type == 7) {
				return "Water (Impassible without help)";
			}else if (type == GRASS_TILE) {
				return "Land (Travel Cost = 1AP)";
			}else if (type == WIN_TILE) {
				return "End Point (Reach here to win!)";
			}else{
				return "Unknown Land Type";
			}
			
		}
		
		//Returns whether the given tile location is within range of the active ability
		private function checkActiveAbilityRange(xTile:int, yTile:int):Boolean
		{
			return (Math.abs((myPlayer.xPos - xTile) + (myPlayer.yPos - yTile)) <= activeAbility.getRange()) 
			
		}
		
		// update AP value for this player in the Quests database
		// input: new value of AP
		public static function updateAP(newAP:int):void
		{
			myClient.bigDB.load("Quests", playerName, function(results:DatabaseObject):void {
				// make sure player exists in Quests
				if (results != null) {
					results.AP = newAP;
					results.save();
				}
			});
		}
		
		// increment AP value for this player in the Quests database
		public static function incrementAP():void
		{
			myClient.bigDB.load("Quests", playerName, function(results:DatabaseObject):void {
				// make sure player exists in Quests
				if (results != null) {
					results.AP += 1;
					results.save();
				}
			});
		}
		
		//Returns whether an ability has been selected to be used by the player
		public static function getAbilitySelected():Boolean 
		{
			return abilitySelected;
		}
		
		// Updates which ability is currently active
		public static function setActiveAbility(toActivate:Ability):void 
		{
			if (toActivate == null) {
				abilitySelected = false;
			}else {
				abilitySelected = true;
				activeAbility = toActivate;
			}
		}
		
		//Add all flixel elements to the board, essentially drawing the game.
		private function boardSetup(map_data:String, playerName:String, levelKey:String):void 
		{

			
			counter = _APcounterMax; // 1ap gained every 3 minutes
			alert = new Alert("");
			//Add chat to game
			//var chat:Chat = new Chat(FlxG.stage, connection);
			//Different Layers
			lyrStage = new FlxGroup; //Map exists here
            lyrSprites = new FlxGroup; //Character Sprites exist here
            lyrHUD = new FlxGroup; //HUD elements exist here
			lyrBackground = new FlxGroup;
			lyrBattle = new FlxGroup;
			lyrMonster = new FlxGroup;
			lyrTop = new FlxGroup;
			myMouse = FlxG.mouse;
			
			//Tile Map
			myMap = new FlxTilemap();
			//myMap.drawIndex = 0;
			myMap.loadMap(map_data, data_tiles, _tileSize, _tileSize,0,0,0,6);
			//myMap.collideIndex = 1;
			//myMap.x = _mapOffsetX;
			//myMap.y = _mapOffsetY;
			myMap.x = 0;			// put the map off sight
			myMap.y = _windowHeight;
			trace("made map below");
			lyrStage.add(myMap);
			
			
			
			
			// Top HUD
			apInfo = new FlxText(_apBoxOffsetX, _apBoxOffsetY, 100, "AP:", true);
			lvl = new FlxText(_lvlTextOffsetX, _lvlTextOffsetY, 100, "Lvl:1", true);
			experience = new FlxText(_experienceTextOffsetX, _experienceTextOffsetY, 100, "Exp:0", true);
			
			//Battle HUD
			//Background
			
			//Weak Attack Button
			lyrBattle.add(new FlxButton(22, 284, "text", function() { 
				if (myPlayer.inBattle) {
					myPlayer.combatant.attack(1,myPlayer, connection);
				}
			}))
			lyrBattle.add(new FlxText(24, 286, 100, "Weak Attack"));
			//Medium Attack Button
			lyrBattle.add(new FlxButton(22, 314, "text", function() { 
				if (myPlayer.inBattle) {
					myPlayer.combatant.attack(2,myPlayer, connection);
				}
			}))
			
			lyrBattle.add(new FlxText(24, 316, 100, "Medium Attack"));
			//Strong Attack Button
			lyrBattle.add(new FlxButton(22, 344, "text", function() { 
				if (myPlayer.inBattle) {
					myPlayer.combatant.attack(3,myPlayer, connection);
				}
			}))
			lyrBattle.add(new FlxText(24, 346, 100, "Strong Attack"));
			//Initially the battle hud is invisible, it will be visible when a user enters combat
			lyrBattle.visible = false;
			
			client.bigDB.load("StaticMaps", levelKey,
				function(dbo:DatabaseObject) {					
					//render game background
					//Right Side HUD
					resources = new FlxText(_resourceTextOffsetX, _resourceTextOffsetY, 150, "Resources:", true);			
					resourcesText = new FlxText(_resourceTextOffsetX, _resourceTextOffsetY + 10,150, "", true);
					gatherResourcesButton = new FlxButton(_resourceTextOffsetX, _resourceTextOffsetY + 15, "Gather lumber!", gatherResource);

					goals = new FlxText(_goalsBoxOffsetX, _goalsBoxOffsetY, 100, "Goals:\nReach the Red Star", true); 
					goals.frameHeight = 75;			
					errorMessage = new FlxText(_errorMessageOffsetX, _errorMessageOffsetY, 120, "Errors Appear Here", true);
					location = new FlxText(_positionInfoOffsetX, _positionInfoOffsetY, 100, "(0,0)", true);
					mouseLocation = new FlxText(_terrainMessageBoxOffsetX, _terrainMessageBoxOffsetY, 260, "(0,0)", true);
					secCounter = new FlxText(_timerOffsetX, _timerOffsetY, 100, "15 Sec until AP", true);			
					abilities = new FlxText(_cardBoxOffsetX, _cardBoxOffsetY, 100, "Abilities:\n", true);
					
					// background
					background = new Background();
					
					lyrHUD.add(resources);
					lyrHUD.add(resourcesText);
					lyrHUD.add(gatherResourcesButton);
					lyrHUD.add(lvl);
					lyrHUD.add(experience);
					lyrHUD.add(abilities);
					lyrHUD.add(goals);
					lyrHUD.add(secCounter);
					lyrHUD.add(location);
					lyrHUD.add(errorMessage);
					lyrHUD.add(mouseLocation);
					lyrBackground.add(background);
					
					connected = true;
					
					// gather resources button is not visible unless you can gather something
					gatherResourcesButton.visible = false;
					
					// ask server for data about this player
					// server will send back data so client can create this player's sprite
					connection.send("playerInfo");
					
					trace("level key: " + levelKey);
					// if map has intro messages, fill them in
					if (dbo.Messages != null)
					{
						trace("message object: " + dbo.toString());
						var messages:Array = dbo.Messages;
						for (var i:int = messages.length - 1; i >= 0; i--) {
							var alert:Alert = new Alert(messages[i]);
							alert.x = -100;
							alert.y = -100;
							alert.width = FlxG.width;
							FlxG.stage.addChild(alert);
						}
					}
				}
			);
			
			lyrSprites.add(lyrMonster);
			this.add(lyrBackground);
			this.add(lyrStage);
			this.add(lyrHUD);
			this.add(lyrBattle);
			this.add(lyrTop);
			this.add(lyrSprites);

			tileHover = new FlxSprite(0, _windowHeight, hoverTileImg);
			add(tileHover);
			trace("done setting up the board");
		}
		
		//Determines whether the mouse is within the game map board, return true if it is or false if it is outside the board
		private function mouseWithinTileMap():Boolean
		{
			return ((myMouse.x > _mapOffsetX )
				&& (myMouse.x < _mapOffsetX + myMap.width)
				&& (myMouse.y > _mapOffsetY)
				&& ( myMouse.y < _mapOffsetY + myMap.height));
		}
		
		// given x and y position of mouse, returns what tile it is hovering over
		public static function getTileIdentity(x:int,y:int):uint {
			//return myMap.getTile((x - _FlxG.width) / _tileSize, (y - FlxG.height) / _tileSize);
			var xInt:Number = (x - _mapOffsetX) / _tileSize;
			var yInt:Number = (y - _mapOffsetY) / _tileSize;
			//trace("getting identity of tile " + xInt + "," + yInt);
			return myMap.getTile(xInt, yInt);
		}
		
		// given x and y position of tile on the map, return what type of tile this is
		private function getTileType(x:int, y:int):uint {
			return 0;
		}
		private function setTileIdentity(x:int, y:int, identity:int):void {
			var xInt:int = (x - _mapOffsetX) / _tileSize;
			var yInt:int = (y - _mapOffsetY) / _tileSize;			
			myMap.setTile(xInt, yInt, identity, true);
		}

		private function getTileIdentity(x:int,y:int):uint {
			return myMap.getTile((x - _mapOffsetX) / _tileSize, (y - _mapOffsetY) / _tileSize);
		}
		
		public function gatherResource():void
		{
			// increase player's amount of lumber
			myPlayer.amountLumber++;
			resourcesText.text = "Lumber: " + myPlayer.amountLumber;
			
			// remove tree from tile, and tell server
			myMap.setTile(myPlayer.xPos, myPlayer.yPos, GRASS_TILE);
			
			// tell server about new map, new values for player
			myConnection.send("MapTileChanged", myPlayer.xPos, myPlayer.yPos, GRASS_TILE);
			myConnection.send("QuestMapUpdate", myMap.getMapData());
			myConnection.send("updateStat", "lumber", myPlayer.amountLumber);
		}
		//***************************************************
		//*****************PLAYERIO Functions****************
		//***************************************************
		private function resetGame():void{
			connection.send("reset");
			infoBox.Show("waiting");
		}
		
		private function joinGame():void{
			trace("send join")
			connection.send("join");
			infoBox.Show("waiting");
		}
		
		private function handleMessages(m:Message){
			trace("Recived the message", m)
		}
		
		private function handleDisconnect():void{
			trace("Disconnected from server")
		}
		

		
	}

}