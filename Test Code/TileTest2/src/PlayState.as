package  
{
	import flash.display.Sprite;
	import flash.sampler.NewObjectSample;
	import org.flixel.*
	import org.flixel.plugin.photonstorm.FlxButtonPlus;
	import org.flixel.plugin.photonstorm.FlxHealthBar;
	import org.flixel.system.input.*;// data.FlxMouse;
	import sample.ui.MultiAlert;
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
	
	import com.Logging.*;
	
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class PlayState extends FlxState
	{
		//Tile Value Constants, if tileSet changes, need to update these!!
		public static const GRASS_TILE:int = 0;
		public static const HILL_TILE:int = 1;
		public static const TREE_TILE:int = 2;
		public static const CHERRY_TILE:int = 3;
		public static const WATER_TILE:int = 8;
		public static const WIN_TILE:int = 4;
		public static const WATER_TILE2:int = 13;
		public static const WATER_TILE3:int = 9;
		public static const BRIDGE_TILE_UP:int = 6;
		public static const BRIDGE_TILE_LEFT:int = 7;
		public static const GATE_TILE:int = 14;
		
		//[Embed(source = "data/map_data.txt", mimeType = "application/octet-stream")] public var data_map:Class; //Tile Map array
		[Embed(source = "data/testTileSet3_32.png")] public var data_tiles:Class; //Tile Set Image
		[Embed(source = "data/Cursor.png")] public var cursor_img:Class; //Mouse Cursor
		[Embed(source = "data/arrows_32.png")] public var hoverTileImg:Class;
		[Embed(source = "data/noTileImg.png")] public var hoverTileImgNo:Class;
		private var apInfo:FlxText; //Text field to reflect the numner of AP left
		private var myPlayer:Player;
		private var playersArray:Array = []; //Array of all players on board
		private var monsterArray:Array = [];
		private var buttonArray:Array = []; //Array of all buttons on the board
		private var effectArray:Array = []; //Array of all effect sprites currently on the board
		
		private var myMouse:Mouse; //Mouse
		private var errorMessage:FlxText; //Text Field to reflect any errors
		private var secCounter:FlxText; //Text field to reflect time left until next AP
		private var location:FlxText; //(x,x) graph information of where your player is.
		private var mouseLocation:FlxText; //Text Field to reflect tile information where the mouse is
		private var counter:Number; //Sec/ 1 ap, this will be moved serverside
		private var goalsLabel:FlxText; // text for the goals/instructions for this label
		private var abilities:FlxText; //Simple text label for abilities
		private var abilitiesBox:Box;
		private var connected:Boolean = false; //Indicates if connection has been established1
		private var lvl:FlxText;
		private var experience:FlxText;
		private var resources:FlxText;
		
		private var level_name:String;
		
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
		public static var lyrEffects:FlxGroup;
		
		private static var abilitySelected:Boolean = false; //Indicates whether an ability is activated
		private static var activeAbility:Ability; //Which ability is currently chosen
		
		private var imPlayer:int;
		private var myID:String;
		private var infoBox:InfoBox;
		private var client:Client;
		private var connection:Connection; //connection to server
		
		// buttons for side menu
		public static var gatherLumberButton:FlxButtonPlus;
		public static var gatherCherryButton:FlxButtonPlus;
		
		
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
		private static var _viewSize:int = 32;
		private static var _zoomedIn:Boolean = false;
		private var _lvlTextOffsetX:int = 5;
		private var _lvlTextOffsetY:int = 5;
		private var _experienceTextOffsetX:int = 5;
		private var _experienceTextOffsetY:int = 30;
		private static var _resourceTextOffsetX:int = 540;
		private static var _resourceTextOffsetY:int = 250;
		
		private static var myClient:Client;
		private static var playerName:String;
		private static var playerAP:int;
		private var _APcounterMax:int = 10;	// seconds to pass until player gets AP incremented
		private static var resourcesString;
		
		private var camMap:FlxCamera;
		
		private var _windowHeight:int = 400;
		private var _windowWidth:int = 700
		
		var camOffsetX:int = 0;
		var camOffsetY:int = 0;
		var currentZoomView:int = 1;
		public static var amountLumberText:FlxText; //= new FlxText(_resourceTextOffsetX, _resourceTextOffsetY, 150, "Lumber: 0", true);
		public static var amountCherryText:FlxText; //= new FlxText(_resourceTextOffsetX, _resourceTextOffsetY + 20, 150, "Cherry: 0", true);
		
		private var timer;				// object used for delays.
		private var tileHover:FlxSprite;
		private var thingsSet:Number = 0;
		
		private var logClient:CGSClient;
		private var action:ClientAction;
		
		public function PlayState(connection:Connection, client:Client):void
		{

			super();
			trace("Sucessfully connected to the multiplayer server");
			
			this.client = client;
			myClient = client;
			this.connection = connection;

			// Connect to the logging database
			action = new ClientAction();
			// vid = 1, first release
			logClient = new CGSClient(CGSClientConstants.URL, 5, 1, 1);
			
			//Connection successful, load board and player
			connection.addMessageHandler("init", function(m:Message, iAm:int, name:String, xStartTile:int, yStartTile:int, level:String, startAP:int, levelKey:String, resources:String) {
				imPlayer = iAm;
				playerAP = startAP;
				level_name = levelKey;
				trace("init: starting ap: " + playerAP);
				//boardSetup(level);
				resourcesString = resources;
				trace("level to search in newquest: " + level);
				client.bigDB.load("NewQuests", level, function(ob:DatabaseObject):void {
					//Recieve Tile Array from database to be turned into string with line breaks between each line
					if (ob != null)
					{

						var mapString:String = ob.tileValues;
						connection.send("QuestMapUpdate", mapString);
						mapString = mapString.split("|").join("\n");
						trace("Board MapString: " + mapString);
						boardSetup(mapString, name, levelKey);
						trace("board made");
						//Load Monster
						try {
							var monsters:Array = ob.Monsters;
							if(monsters != null){
								for (var z in monsters) {
									//Dont add a monster that is dead
									if(monsters[z].AP > 0){
										var myMonsterSprite:Monster = new Monster(monsters[z].Type, monsters[z].AP, z, monsters[z].xTile, monsters[z].yTile,0, _windowHeight, _tileSize, connection);
										monsterArray.push(myMonsterSprite);
										lyrMonster.add(myMonsterSprite);
										lyrHUD.add(myMonsterSprite.healthBar);
										
									}
								}
								
								// print monster array
								trace("filled monster array: " );
								for (var m:int = 0; m < monsterArray.length; m++ )
									trace("index " + m + ":" + monsterArray[m]._xTile + "," + monsterArray[m]._yTile);
							}
							
						}catch (e:Error) {
							trace("Monster Loading Error: " + e);
						}
						
						//Load Buttons
						try {
							var buttons:Array = ob.Buttons
							if (buttons != null) {
								for (var z in buttons) {
									var myButtonSprite:ButtonSprite = new ButtonSprite(buttons[z].xTile, buttons[z].yTile, buttons[z].xOpen , buttons[z].yOpen, myMap, _tileSize);
									buttonArray.push(myButtonSprite);
									lyrSprites.add(myButtonSprite);
								}
							}
						}catch (e:Error) {
							trace("Button Loading Error: " + e);
						}
						
						//Load Effect Sprites
						try {
							var effectSprites:Array = ob.Effects
							if (effectSprites != null) {
								for (var z in effectSprites) {
									var myEffectSprite:EffectSprite = new EffectSprite(effectSprites[z].xTile, effectSprites[z].yTile, effectSprites[z].Type, effectSprites[z].Range, _tileSize, effectSprites[z].Uses, connection, z);
									effectArray.push(myEffectSprite);
									lyrEffects.add(myEffectSprite);
								}
							}
						}catch (e:Error) {
							trace("Effect Sprite Loading Error: " + e);
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
						var menu:Box = new Box().fill(0xFFFFFF, 0.8, 0);
						// create new menu for player to navigate back to main screen
						var button:TextButton = new TextButton("Start a new quest!",
							function ():void
							{
								FlxG.stage.removeChild(menu);
								FlxG.switchState(new MenuState(client));
							}
						);
						menu.add(new Box().fill(0x00000, .5, 15).margin(10, 10, 10, 10).minSize(FlxG.width/2, FlxG.height).add(
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
					playerSetup(xStartTile, yStartTile, name);
					//connection.send("PlayerSetUp");
				});
			})
			
			if (myMap == null) {
				trace("map doesn't exist....");
			}
			
			//New user has joined, make their character
			connection.addMessageHandler("UserJoined", function(m:Message, userID:int, posX:int, posY:int) {
				if (userID != imPlayer) {
					// create other player; AP doesn't matter, so default to 20
					playersArray[userID-1] = new Player(posX, posY, 0,_windowHeight , _tileSize, 20, null, "Novice");
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
			//Load and alert the player of all messages associated with that level
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
			//A new effect sprite has been added to the field
			connection.addMessageHandler("AddSprite", function (m:Message, xTile:int, yTile:int, type:String, range:int):void 
			{
				var newEffectSprite:EffectSprite = new EffectSprite(xTile, yTile, type, range, _tileSize, 0, connection, effectArray.length);
				lyrEffects.add(newEffectSprite);
				effectArray.push(newEffectSprite);
			})
			//Updates the use for a certain item
			connection.addMessageHandler("SpriteUse", function (m:Message,userID:int, index:int):void 
			{
				if (userID != imPlayer) {
					EffectSprite(effectArray[index]).addUse(false);
				}
			});
		
		}
		
		private function setCameras():void {
			thingsSet++;
			if (thingsSet > 1) {
				trace("make camera");
				// Camera will show up at where the map should be
				camMap= new FlxCamera(_mapOffsetX, _mapOffsetY, 320, 320);
				camMap.follow(myPlayer, FlxCamera.STYLE_TOPDOWN);
				camMap.setBounds(0, _windowHeight, myMap.width, myMap.height, true);
				camMap.deadzone = new FlxRect(_viewSize * 2, _viewSize * 2, 320 - _viewSize * 4, 320 - _viewSize * 4);
				//camMap.color = 0xFFCCCC;
				FlxG.addCamera(camMap);							// camera that shows where the character is on the map
			}
			logClient.SetUid(function f(d:String):void {
				//Starting level 1!
				//First we need a new dqid to associate with this play of the level.
				logClient.SetDqid(function f(d:String):void {
					var lvl:int = -1;
					if (level_name.slice(0, 8)  == "Tutorial") lvl = int(level_name.slice(9, 10));
					else lvl =  lvl = int(level_name.slice(9, 10)) + 20;
						
					logClient.ReportLevel(d, lvl, function g(d:String):void {
						//Now that server has responded, let's send some actions.
						
					});
				});
			});
				
		}
		
		private function cleanup(m:Message, xpGain:int, coinGain:int, nextLevel:String):void 
		{
			connection.disconnect();
			this.kill();
			FlxG.switchState(new QuestCompleteState(xpGain, coinGain, client, nextLevel));
			
		}
		override public function update():void 
		{
			
			if (connected == true) {
				if (myPlayer != null) {
					if (myMap.getTile(myPlayer.xPos, myPlayer.yPos) == CHERRY_TILE)
					{
						gatherLumberButton.x = gatherCherryButton.x = 540;
						gatherLumberButton.y = 340;
						gatherCherryButton.y = 310;
						gatherLumberButton.visible = gatherCherryButton.visible = true;						
					}
					else { 
						gatherLumberButton.visible = gatherCherryButton.visible = false;
					}
				}
				
				counter -= FlxG.elapsed;
				if (counter <= 0)
				{
					// After 180 seconds has passed, the timer will reset.
					counter = _APcounterMax;
					// increment player's AP if it's not the max yet
					if (myPlayer.AP < 20) {
						myPlayer.AP++;
						action = new ClientAction();
						connection.send("updateStat", "AP", myPlayer.AP);
						fireNotification(myPlayer.x + 20, myPlayer.y - 20, "+1 AP", "gain");
						action = new ClientAction();					 
						action.detail = new Object();
						action.detail["x1"] = myPlayer.xPos;
						action.detail["y1"] = myPlayer.yPos;
						action.aid = ClientActionType.AP_GAIN;
						action.ts = new Date().getTime();
						logClient.LogAction(action);
					}
				}
				
				//Update HUD Information
				secCounter.text = counter.toPrecision(3) + " seconds until more AP";
				//Player moves only one character, detect keys presses here

				if (myPlayer != null && !win) {
					/*** DEBUG CHEATS ***/
					if (myPlayer.AP <= 20 && FlxG.keys.justPressed("A")) {
						myPlayer.AP++;
						connection.send("updateStat", "AP", myPlayer.AP);
					}
					
					if (FlxG.keys.justPressed("L") && amountLumberText != null) {
						myPlayer.amountLumber++;
						connection.send("updateStat", "lumber", myPlayer.amountLumber);
						amountLumberText.text = "Lumber: " + myPlayer.amountLumber;
					}
					if (FlxG.keys.justPressed("C") && amountCherryText != null) {
						myPlayer.amountCherry++;
						connection.send("updateStat", "cherry", myPlayer.amountCherry);
						amountCherryText.text = "Cherry: " + myPlayer.amountCherry;
					}
					/*** END DEBUG CHEATS ***/
					
					lyrBattle.visible = myPlayer.inBattle; //Only show the battle hud if the player is in combat
					 //Detect Monster collision, if a monster is overlapping your player then you are now in a fight
					if (!myPlayer.inBattle) {
						/*trace("the monster array i'm looking at: " );
						for (var m:int = 0; m < monsterArray.length; m++ )
							trace("index " + m + ":" + monsterArray[m]._xTile + "," + monsterArray[m]._yTile);*/
						
						var monster:int = 0;
						while (monster < monsterArray.length && !myPlayer.inBattle) {
							FlxG.overlap(monsterArray[monster], myPlayer, function() {
								trace("is overlapping monster!");
								// show notification if player is not already in battle
								FlxG.flash(0xFFFFFF, 1,function ():void 
								{
									FlxG.stage.addChild(new Alert("YOU HAVE ENTERED BATTLE"));
								});
								myPlayer.inBattle = true;
								trace("checking...player in battle!  with monster " + monster + "at "+ monsterArray[monster]._xTile + "," + monsterArray[monster]._yTile);
								myPlayer.combatant = monsterArray[monster];
								errorMessage.text = "BATTLE!";
								lyrBattle.visible = true;
							});
							
							monster++;
						}
					 }
					action = new ClientAction();					 
					action.detail = new Object();
					action.detail["x1"] = myPlayer.xPos;
					action.detail["y1"] = myPlayer.yPos;		
					var moved:Boolean = false;					
					 
					// handle player movement with arrow keys
					if (FlxG.keys.justPressed("DOWN") && !myPlayer.isMoving && !myPlayer.inBattle) {
						myPlayer.facing = FlxSprite.DOWN;	
						win = myPlayer.movePlayer(0, 1, _tileSize, connection);	
						moved = true;
						moved = true;
					}else if (FlxG.keys.justPressed("UP") && !myPlayer.isMoving && !myPlayer.inBattle) {
						myPlayer.facing = FlxSprite.UP;						
						win = myPlayer.movePlayer(0, -1, _tileSize, connection);
						moved = true;
					}else if (FlxG.keys.justPressed("RIGHT") && !myPlayer.isMoving && !myPlayer.inBattle) {
						myPlayer.facing = FlxSprite.RIGHT;
						win = myPlayer.movePlayer(1, 0, _tileSize, connection);
						moved = true;
					}else if (FlxG.keys.justPressed("LEFT") && !myPlayer.isMoving && !myPlayer.inBattle) {
						myPlayer.facing = FlxSprite.LEFT;
						win = myPlayer.movePlayer( -1, 0, _tileSize, connection);
						moved = true;
					}
					

					// handle ability usage
					else if (myMouse.justPressed() &&  mouseWithinTileMap() && abilitySelected) {
						var selectedXTile:int = getTileX();// (myMouse.x - _mapOffsetX) / _tileSize
						var selectedYTile:int = getTileY();// (myMouse.y - _mapOffsetY) / _tileSize
						//TO DO: ADD ALERT MESSAGE!!!
						if (checkActiveAbilityRange(selectedXTile, selectedYTile) && activeAbility.canCast(myPlayer, selectedXTile,selectedYTile)) {
							// if could cast ability
							activeAbility.cast(selectedXTile, selectedYTile , connection);
							// pay for ability
							var cost:int = activeAbility._cost;
							myPlayer.AP -= cost;
							myPlayer.amountLumber -= activeAbility._neededLumber;
							var resourceNote:String = "";
							if (cost > 0) resourceNote += "-" + cost + " AP";
							if (activeAbility._neededLumber > 0) resourceNote += "\n-" + activeAbility._neededLumber + " lumber";
							PlayState.fireNotification(myPlayer.x + 20, myPlayer.y - 20, resourceNote, "loss");
							// depending on what ability... 
							action = new ClientAction();
							action.aid = ClientActionType.UNKNOWN_ABILITY;
							action.detail = new Object();			
							action.detail["ap_cost"] = cost;
							action.detail["lumber_needed"] = activeAbility._neededLumber;
							action.ts = new Date().getTime();
							logClient.LogAction(action);	
							/*trace("just cast ability");
							// if player was in battle, see if they still are
							if (myPlayer.inBattle) {
								trace("player was in battle and is at " + myPlayer.xPos + "," + myPlayer.yPos);
								myPlayer.inBattle = false;
								for (var monster:int in monsterArray) {
									//if (monsterArray[monster]._xTile == myPlayer.xPos && monsterArray[monster]._yTile == myPlayer.yPos) {
									//	myPlayer.inBattle = true;
									FlxG.overlap(monsterArray[monster], myPlayer, function() {
										if (!monsterArray[monster]._isEating) {
											myPlayer.inBattle = true;
											trace("monster is not eating");
										} else trace ("monster " + monster + " is eating!");
										myPlayer.combatant = monsterArray[monster];
										errorMessage.text = "BATTLE!";
										trace("player still in battle!  still overlapping with monster " + monster + "at "+ monsterArray[monster]._xTile + "," + monsterArray[monster]._yTile);
										lyrBattle.visible = true;
									});
									
								}
							 }*/
							
							connection.send("updateStat", "AP", myPlayer.AP);
							connection.send("updateStat", "lumber", myPlayer.amountLumber);
							activeAbility.visible = false;
							setActiveAbility(null);
							abilitySelected = false;
							amountLumberText.text = "Lumber: " + myPlayer.amountLumber;
							amountLumberText.text = "Cherry: " + myPlayer.amountCherry;
						}
					} 
					//CLICK MOVING
					else if (mouseWithinTileMap() && abilitySelected == false) {
						tileHover.visible = mouseWithinTileMap();
						if (camMap && camMap.scroll) camOffsetX = camMap.scroll.x;
						if (camMap && camMap.scroll) camOffsetY = camMap.scroll.y;
						if (_zoomedIn) currentZoomView = 2;	
						else  currentZoomView = 1;	
						var xTemp:int = getTileX();// Math.floor((myMouse.x - _mapOffsetX) / _viewSize / currentZoomView + camOffsetX / _viewSize);						
						//var xTemp:int = Math.floor((myMouse.x - _mapOffsetX + camOffsetX + 0) / _viewSize / currentZoomView);		// the tile number
						var xTempCoord:int = xTemp * _tileSize + 0;
						//var yTemp:int = Math.floor((myMouse.y - _mapOffsetY + camOffsetY - _windowHeight) / _viewSize / currentZoomView);	
						var yTemp:int = getTileY();// Math.floor((myMouse.y - _mapOffsetY) / _viewSize / currentZoomView + (camOffsetY - _windowHeight) / _viewSize );// the tile number
						var yTempCoord:int = yTemp * _tileSize + _windowHeight;									// the coordinate of that tile
						//trace("camera offset:" + camOffsetX + "," + camOffsetY + " actualcoord:" + xTemp + "," + yTemp + " coord:" + xTempCoord + "," + yTempCoord);
						tileHover.x = xTempCoord;
						tileHover.y = yTempCoord;
						
						// if within 1 tile away
						// if okay condition
						// then go
						var absDis:int = Math.abs(myPlayer.xPos - xTemp) + Math.abs(myPlayer.yPos - yTemp);
						// have to check if the move is possible beforehand... 
						var canGo:Boolean = myPlayer.checkMove(xTemp, yTemp, _tileSize);
						
						if (absDis < 2 && absDis > 0 && canGo) {	// one away
							//tileHover.loadGraphic(hoverTileImg);
							tileHover.visible = true;
							if (xTemp < myPlayer.xPos) {
								tileHover.frame = 2;
							}
							else if (xTemp > myPlayer.xPos) {
								tileHover.frame = 0;
							}
							else if (yTemp < myPlayer.yPos) {
								tileHover.frame = 3;
							}
							else if (yTemp > myPlayer.yPos) {
								tileHover.frame = 1;
							}							
							
							// if player wants to move and is in battle, let them try to escape
							/*if (myMouse.justPressed() && abilitySelected == false && myPlayer.inBattle) {
								if (myPlayer.AP == 0)
									fireNotification(myPlayer.x - 5, myPlayer.y - 10, "Not enough AP!", "loss");
								else {
									// if player escaped
									if ((Math.random() * 5) == 4) {
										fireNotification(myPlayer.x + 5, myPlayer.y - 10, "-10 AP to escape!", "loss");
										myPlayer.AP -= 10;
										if (myPlayer.AP < 0) myPlayer.AP = 0;
										connection.send("updateStat", "AP", myPlayer.AP);
										
										if (xTemp < myPlayer.xPos)
											myPlayer.facing = FlxSprite.LEFT; 
										else if (xTemp > myPlayer.xPos)
											myPlayer.facing = FlxSprite.RIGHT; 
										else if (yTemp < myPlayer.yPos)
											myPlayer.facing = FlxSprite.UP; 
										else if (yTemp > myPlayer.yPos)
											myPlayer.facing = FlxSprite.DOWN; 
											
										myPlayer.inBattle = false;
										win = myPlayer.movePlayer(xTemp - myPlayer.xPos, yTemp - myPlayer.yPos, _tileSize, connection)
									}
									else {
										fireNotification(myPlayer.x + 5, myPlayer.y - 10, "-1 AP\nCouldn't escape monster!", "loss");
										myPlayer.AP--;
										connection.send("updateStat", "AP", myPlayer.AP);
									}
								}
							}*/
							
							// if player wants to move and is not in battle
							if (myMouse.justPressed() && abilitySelected == false && !myPlayer.isMoving && myPlayer.inBattle)
								fireNotification(myPlayer.x + 20, myPlayer.y - 20, "Can't escape monster!", "loss");
							else if (myMouse.justPressed() && abilitySelected == false && !myPlayer.isMoving && !myPlayer.inBattle) {
								//trace("okay to move");
								// check for condition....
								moved = true;
								if (xTemp < myPlayer.xPos)
									myPlayer.facing = FlxSprite.LEFT; 
								else if (xTemp > myPlayer.xPos)
									myPlayer.facing = FlxSprite.RIGHT; 
								else if (yTemp < myPlayer.yPos)
									myPlayer.facing = FlxSprite.UP; 
								else if (yTemp > myPlayer.yPos)
									myPlayer.facing = FlxSprite.DOWN; 
								
								win = myPlayer.movePlayer(xTemp - myPlayer.xPos, yTemp - myPlayer.yPos, _tileSize, connection)
							} else {
								fireNotification(myPlayer.xPos + 20, myPlayer.yPos - 20, "Invalid move!", "loss");
							}
						} else {
							// if not within reach, set color to red
							//tileHover.loadGraphic(hoverTileImgNo);
							tileHover.visible = false;
						}
					}else if(!myPlayer.isMoving) {
						myPlayer.play("idle" + myPlayer.facing);
					}
					if (moved) {
						trace("sending moved");
						action.aid = ClientActionType.MOVE;
						action.detail = new Object();			
						action.detail["x2"] = myPlayer.xPos;
						action.detail["y2"] = myPlayer.yPos;
						action.ts = new Date().getTime();
						logClient.LogAction(action);	
						moved = false;						
					}
					apInfo.text = "AP: " + myPlayer.AP;
					location.text = "(" + myPlayer.xPos + "," + myPlayer.yPos + ")";
					errorMessage.text = "" + myPlayer.errorMessage;
					
					if (win) {
						action = new ClientAction();
						action.aid = ClientActionType.WON;
						action.detail = new Object();			
						action.detail["x1"] = myPlayer.xPos;
						action.detail["y1"] = myPlayer.yPos;
						action.ts = new Date().getTime();
						trace("won");
						logClient.LogAction(action);	
						connection.send("win")
						connected = false;
					}
					if (mouseWithinTileMap()){
						mouseLocation.text = tileInformation(getTileIdentity(myMouse.x, myMouse.y));
					} else {
						mouseLocation.text = "";
					}
					/*
					//Only show the battle hud if the player is in combat
					lyrBattle.visible = myPlayer.inBattle;
					 //Detect Monster collision, if a monster is overlapping your player then you are now in a fight
					if(myPlayer.inBattle == false){
						for (var monster in monsterArray) {
							
								FlxG.overlap(monsterArray[monster], myPlayer, function() {
									if(Monster(monsterArray[monster]).moving == false){
										myPlayer.inBattle = true;
										trace("Monster at " + monsterArray[monster].x + "," + monsterArray[monster].y + "   Player at " + myPlayer.x + "," + myPlayer.y);
										FlxG.flash(0xFFFFFF, 1,function ():void 
										{
											FlxG.stage.addChild(new Alert("YOU HAVE ENTERED BATTLE"));
										});
										myPlayer.combatant = monsterArray[monster]
										errorMessage.text = "BATTLE!";
										lyrBattle.visible = true;
									}
								});
						}
					 }*/
					//Detect Button Collision
					for (var button in buttonArray) {
						FlxG.overlap(buttonArray[button], myPlayer, function ():void 
						{
							ButtonSprite(buttonArray[button]).clickButton(connection);
						});
					}
				}
			}
			super.update();
		}
		
		//Give a tile number and return information String about that Tile
		private function tileInformation(type:Number):String
		{
			if (type == HILL_TILE) {
				return "Hill (Travel Cost = 3 AP)";
			}else if (type == TREE_TILE) {
				return "Tree (Travel Cost = 1 AP)";
			}else if (type == CHERRY_TILE) {
				return "Cherry Tree (Travel Cost = 1 AP)";
			}else if (type == WATER_TILE || type == 6 || type == 7) {
				return "Water (Impassible without help)";
			}else if (type == GRASS_TILE) {
				return "Land (Travel Cost = 0 AP)";
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
		
		private function getTileX():int {
			return Math.floor((myMouse.x - _mapOffsetX) / _viewSize / currentZoomView + camOffsetX / _viewSize);						
		}
		
		private function getTileY():int {
			return Math.floor((myMouse.y - _mapOffsetY) / _viewSize / currentZoomView + (camOffsetY - _windowHeight) / _viewSize );
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
		//Set Up the Player
		private function playerSetup(posX:int, posY:int, name:String) {
			if (myPlayer == null) {
					

					//Load Abilities for Player From Database
					var abilityObject:DatabaseObject;
					var abilityTextWidth:int = 210;
					var abilityTextLeftOffset:int = -25;
					var abilityTextUpperOffset:int = 20;
					var tempButton:AbilityButton;
					var abilityText:FlxText;
					var spaceBetweenAbilities:int = 90;
					client.bigDB.loadMyPlayerObject(function(db:DatabaseObject):void {
						try {
							playerName = name;
							if (posX < 0) posX = 0;
							if (posY < 0) posY = 0;
							myPlayer = new Player(posX, posY, 0, _windowHeight, _tileSize, playerAP, resourcesString, db.role);
							playersArray[imPlayer - 1] = myPlayer;
							
							var playerHealthBar:FlxHealthBar = new FlxHealthBar(myPlayer, 100, 20, 0, 20, true);
							playerHealthBar.x = _apBoxOffsetX - 35
							playerHealthBar.y = _apBoxOffsetY - 5
							lyrHUD.add(playerHealthBar);
							lyrTop.add(apInfo);
							lyrSprites.add(myPlayer);
							lvl.text = "Level: " + db.level;
							var abilityArray:Array = db.abilities;
							if (abilityArray != null || abilityArray.length > 0) {
								client.bigDB.loadKeys("Abilities", db.abilities, function(dbarr:Array):void {
									var yButtonPlacementModifier:int = 0;
									for (var z:String in dbarr) {
										abilityObject = dbarr[z];
										var myAbility:Ability = new Ability(_tileSize, myPlayer, abilityObject);
										myAbility.visible = false;
										lyrStage.add(myAbility);
										//trace("Loaded Ability " + abilityObject.Name + "\n");
										tempButton = new AbilityButton(_cardBoxOffsetX, _cardBoxOffsetY + yButtonPlacementModifier, myAbility, abilityObject.Name)
										abilityText = new FlxText(_cardBoxOffsetX + abilityTextLeftOffset, _cardBoxOffsetY + yButtonPlacementModifier + abilityTextUpperOffset, abilityTextWidth, abilityObject.Description);
										abilityText.text += "\n\tAP cost: " + abilityObject.Cost;
										if (abilityObject.Lumber != null) abilityText.text += "\n\tLumber needed: " + abilityObject.Lumber;
										if (abilityObject.Cherry != null) abilityText.text += "\n\tCherries needed: " + abilityObject.Cherry;
										abilityText.setFormat(null, 10);
										lyrHUD.add(tempButton);
										lyrHUD.add(abilityText);
										myAbility.setButton(tempButton);
										yButtonPlacementModifier += spaceBetweenAbilities;
									}
								});
								abilities.text = "Abilities:\n";
							}
						} catch (e:Error) {
							//Catches Error is no abilities have been set yet
							trace("unable to load abilities");
							abilities.text = "No Abilities\n";
						}
					});
				}
				//timer = setInterval(setCameras, 100);	// set up camera after 0.1 second.... to ensure everything is set
				trace("done with character, setting camera ***");
				setCameras();
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
			lyrEffects = new FlxGroup;
			lyrTop = new FlxGroup;
			myMouse = FlxG.mouse;
			
			//Tile Map
			myMap = new FlxTilemap();
			myMap.loadMap(map_data, data_tiles, _tileSize, _tileSize,0,0,0,6);
			myMap.x = 0;			// put the map off sight
			myMap.y = _windowHeight;
			trace("made map below");
			lyrStage.add(myMap);
		
			// Top HUD
			apInfo = new FlxText(_apBoxOffsetX, _apBoxOffsetY, 100, "AP:", true);
			lvl = new FlxText(_lvlTextOffsetX, _lvlTextOffsetY, 100, "Level 1", true);
			lvl.setFormat(null, 15);
			experience = new FlxText(_experienceTextOffsetX, _experienceTextOffsetY, 200, "Experience: 0", true);
			experience.setFormat(null, 10);
			var zoomInButton:FlxButton = new FlxButton(100, 340, "+", zoomInAction);
			var zoomOutButton:FlxButton = new FlxButton(100, 370, "-", zoomOutAction);
			var zoomInLabel:FlxText = new FlxText(50, 340, 100, "Zoom in");
			var zoomOutLabel:FlxText = new FlxText(50, 370, 100, "Zoom out");
			//Battle HUD
			//Background
			
			//Weak Attack Button
			lyrBattle.add(new FlxButtonPlus(540, 290,  function():void { 
				if (myPlayer.inBattle) {
					myPlayer.combatant.attack(1, myPlayer);
					myPlayer.AP--;
					connection.send("updateStat", "AP", myPlayer.AP);				
				}
			}, null, "Weak Attack: 1 AP", 120));
			//lyrBattle.add(new FlxText(24, 286, 100, "Weak Attack"));
			//Medium Attack Button
			lyrBattle.add(new FlxButtonPlus(540, 320, function() { 
				if (myPlayer.inBattle) {
					myPlayer.combatant.attack(2, myPlayer);
					myPlayer.AP -= 3;
					connection.send("updateStat", "AP", myPlayer.AP);
				}
			}, null, "Medium Attack: 3 AP", 120));
			
			//lyrBattle.add(new FlxText(24, 316, 100, "Medium Attack"));
			//Strong Attack Button
			//lyrBattle.add(new FlxButton(22, 344, "text", function() { 
			lyrBattle.add(new FlxButtonPlus(540, 350, function() { 
				if (myPlayer.inBattle) {
					myPlayer.combatant.attack(3, myPlayer);
					myPlayer.AP -= 5;
					connection.send("updateStat", "AP", myPlayer.AP);
				}
			},null, "Strong Attack: 5 AP", 120));
			//lyrBattle.add(new FlxText(24, 346, 100, "Strong Attack"));
			//Initially the battle hud is invisible, it will be visible when a user enters combat
			lyrBattle.visible = false;
			
			//render game background
			//Right Side HUD
			//resources = new FlxText(_resourceTextOffsetX, _resourceTextOffsetY, 150, "Resources:", true);			
			gatherLumberButton = new FlxButtonPlus(0,0, function():void { gatherResource("lumber"); }, null, "Gather lumber!");
			gatherCherryButton = new FlxButtonPlus(0, 0, function():void { gatherResource("cherry"); }, null, "Gather cherry!");
			amountLumberText = new FlxText(_resourceTextOffsetX, _resourceTextOffsetY, 150, "Lumber: 0", true);
			amountCherryText = new FlxText(_resourceTextOffsetX, _resourceTextOffsetY + 20, 150, "Cherry: 0", true);
			amountLumberText.setFormat(null, 12);
			amountCherryText.setFormat(null, 12);
			goalsLabel = new FlxText(_goalsBoxOffsetX, _goalsBoxOffsetY, 100, "Reach the red star", true); 
			goalsLabel.frameHeight = 75;	
			errorMessage = new FlxText(_errorMessageOffsetX, _errorMessageOffsetY, 120, "Errors Appear Here", true);
			location = new FlxText(_positionInfoOffsetX, _positionInfoOffsetY, 100, "(0,0)", true);
			mouseLocation = new FlxText(_terrainMessageBoxOffsetX, _terrainMessageBoxOffsetY, 260, "(0,0)", true);
			secCounter = new FlxText(_timerOffsetX, _timerOffsetY, 100, "15 Sec until AP", true);			
			abilities = new FlxText(_cardBoxOffsetX, _cardBoxOffsetY, 100, "", true);
			
			// background
			background = new Background();
			
			lyrHUD.add(resources);
			lyrHUD.add(amountLumberText);
			lyrHUD.add(amountCherryText);
			lyrHUD.add(lvl);
			lyrHUD.add(experience);
			lyrHUD.add(abilities);
			lyrHUD.add(goalsLabel);
			lyrHUD.add(secCounter);
			lyrHUD.add(location);
			lyrHUD.add(errorMessage);
			lyrHUD.add(mouseLocation);

			lyrHUD.add(new FlxButtonPlus(540, 15, mainMenu, null, "Main Menu"));
			lyrHUD.add(zoomInButton);
			lyrHUD.add(zoomOutButton);
			lyrHUD.add(zoomInLabel);
			lyrHUD.add(zoomOutLabel);
			lyrBackground.add(background);

			tileHover = new FlxSprite(0, _windowHeight);
			tileHover.loadGraphic(hoverTileImg, true, false, 32, 32);
			tileHover.addAnimation("LEFT", [2], 0, false);
			tileHover.addAnimation("DOWN", [1], 0, false);
			tileHover.addAnimation("RIGHT", [0], 0, false);
			tileHover.addAnimation("UP", [3], 0, false);
			lyrHUD.add(tileHover);
			lyrSprites.add(lyrMonster);
			lyrSprites.add(lyrEffects);
			lyrHUD.add(gatherLumberButton);
			lyrHUD.add(gatherCherryButton);
			
			this.add(lyrBackground);
			this.add(lyrStage);
			this.add(lyrHUD);
			this.add(lyrBattle);
			this.add(lyrSprites);
			this.add(lyrTop);
			


			// gather resources button is not visible unless you can gather something
			gatherLumberButton.visible = gatherCherryButton.visible = false;
			// ask server for data about this player
			// server will send back data so client can create this player's sprite
			connection.send("playerInfo");
			client.bigDB.load("StaticMaps", levelKey,
				function(dbo:DatabaseObject) {					
					trace("level key: " + levelKey);
					// if map has intro messages, fill them in
					if (dbo != null && dbo.Messages != null)
					{
						trace("message object: " + dbo.toString());
						FlxG.stage.addChild(new MultiAlert(dbo.Messages));
					}
				}
			);
			
			action.uid = logClient.message.uid;	// what is this?
			var levelID:int = levelToInt(levelKey);
			logClient.SetUid(function f(d:String):void {
				logClient.SetDqid(function f(d:String):void {
					logClient.ReportLevel(d, levelID, function g(d:String):void {
						action.ts = new Date().getTime();
						action.aid = ClientActionType.GAME_START;
						logClient.LogAction(action);
						//action.detail = null;
					});
				});
			});
			
			setCameras();
			connected = true;
			
			trace("done setting up the board, camera set up *** ");
		}
		
		private function zoomInAction():void
		{
			_zoomedIn = true;
			camMap= new FlxCamera(_mapOffsetX, _mapOffsetY, 320/2, 320/2, 2);
			camMap.follow(myPlayer, FlxCamera.STYLE_TOPDOWN);
			camMap.setBounds(0, _windowHeight, myMap.width, myMap.height, true);
			camMap.deadzone = new FlxRect(32, 32, 48, 48);///new FlxRect(_viewSize * 2, _viewSize * 2, 320 - _viewSize * 4, 320 - _viewSize * 4);
			FlxG.resetCameras(new FlxCamera(0, 0, _windowWidth, _windowHeight));
			FlxG.addCamera(camMap);
			action = new ClientAction();
			action.aid = ClientActionType.ZOOMED_IN;
			action.detail = new Object();			
			action.detail["x1"] = myPlayer.xPos;
			action.detail["y1"] = myPlayer.yPos;
			action.ts = new Date().getTime();
			trace("+");
			logClient.LogAction(action);				
		}
		
		private function zoomOutAction():void 
		{
			_zoomedIn = false;
			camMap= new FlxCamera(_mapOffsetX, _mapOffsetY, 320, 320);
			camMap.follow(myPlayer, FlxCamera.STYLE_TOPDOWN);
			camMap.setBounds(0, _windowHeight, myMap.width, myMap.height, true);
			camMap.deadzone = new FlxRect(_viewSize * 2, _viewSize * 2, 320 - _viewSize * 4, 320 - _viewSize * 4);
			FlxG.resetCameras(new FlxCamera(0, 0, _windowWidth, _windowHeight));
			FlxG.addCamera(camMap);
			action = new ClientAction();
			action.ts = new Date().getTime();
			action.aid = ClientActionType.ZOOMED_OUT;
			action.detail = new Object();			
			action.detail["x1"] = myPlayer.xPos;
			action.detail["y1"] = myPlayer.yPos;
			action.ts = new Date().getTime();
			trace("+");
			logClient.LogAction(action);				
		}
		
		private function levelToInt(s:String):int 
		{
			if (s =="Tutorial_1") {
				return 1;
			} else if (s =="Tutorial_2") {
				return 2;
			} else if (s == "Tutorial_3") {
				return 3;
			} else if (s=="Tutorial_4") {
				return 4;
			} else if (s=="Tutorial_5") {
				return 5;
			}
			return -1;
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
		//Callback function for the mainMenu Button
		private function mainMenu():void {
			connection.disconnect();
			this.kill();
			FlxG.switchState(new MenuState(myClient));
		}
		public function gatherResource(resourceType:String):void
		{
			// increase player's amount of given resource
			switch (resourceType)
			{
				case "lumber":
					myPlayer.amountLumber++;
					connection.send("updateStat", "lumber", myPlayer.amountLumber);
					fireNotification(myPlayer.x + 30, myPlayer.y + 20, "+1 Lumber", "gain");
					amountLumberText.text = "Lumber: " + myPlayer.amountLumber;
					action = new ClientAction();
					action.ts = new Date().getTime();
					action.detail = new Object();
					action.detail["x1"] = myPlayer.xPos;
					action.detail["y1"] = myPlayer.yPos;					
					action.aid = ClientActionType.COLLECT_LUMBER;
					trace("lumber");
					logClient.LogAction(action);						
					break;
				case "cherry":
					myPlayer.amountCherry++;
					connection.send("updateStat", "cherry", myPlayer.amountCherry);
					fireNotification(myPlayer.x + 30, myPlayer.y + 20, "+1 Cherry", "gain");
					amountCherryText.text = "Cherry: " + myPlayer.amountCherry;
					action = new ClientAction();
					action.ts = new Date().getTime();
					action.detail = new Object();
					action.detail["x1"] = myPlayer.xPos;
					action.detail["y1"] = myPlayer.yPos;					
					action.aid = ClientActionType.COLLECT_CHERRY;
					trace("cherry");
					logClient.LogAction(action);					
					break;
			}
			
			myPlayer.AP--;
			connection.send("updateStat", "AP", myPlayer.AP);
			fireNotification(myPlayer.x + 30, myPlayer.y, "-1 AP", "loss");
			
			// remove tree from tile, and tell server
			myMap.setTile(myPlayer.xPos, myPlayer.yPos, GRASS_TILE);
			
			// tell server about new map, new values for player
			connection.send("MapTileChanged", myPlayer.xPos, myPlayer.yPos, GRASS_TILE);
			connection.send("QuestMapUpdate", myMap.getMapData());
		}
		
		public static function fireNotification(xPos:int, yPos:int, message:String, messageType:String):void
		{
			// send notificatioin that AP was lost
			var note:Notification = new Notification(xPos, yPos, message, messageType);
			lyrHUD.add(note);
		}
		
		//***************************************************
		//*****************PLAYERIO Functions****************
		//***************************************************
		private function resetGame():void{
			connection.send("reset");
			infoBox.Show("waiting");
			action.ts = new Date().getTime();
			action.detail = new Object();
			action.detail["x1"] = myPlayer.xPos;
			action.detail["y1"] = myPlayer.yPos;					
			action.aid = ClientActionType.RESET;
			trace("reset");
			logClient.LogAction(action);			
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