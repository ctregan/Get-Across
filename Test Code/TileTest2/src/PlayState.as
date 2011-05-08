package  
{
	import org.flixel.*
	import org.flixel.data.FlxMouse;
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
		private var apInfo:FlxText; //Text field to reflect the numner of AP left
		private var myPlayer:Player;
		private var playersArray:Array = []; //Array of all players on board
		private var myMouse:FlxMouse; //Mouse
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
		private var background:Background;
		private var playerStartX: int = 0;	// starting x position of this player
		private var playerStartY: int = 0;	// starting y position of this player
		
		public static var myMap:FlxTilemap; //The tile map where the tileset is drawn
		public static var lyrStage:FlxGroup;
        public static var lyrSprites:FlxGroup;
        public static var lyrHUD:FlxGroup;
		public static var lyrBackground:FlxGroup;
		
		private static var abilitySelected:Boolean = false; //Indicates whether an ability is activated
		private static var activeAbility:Ability; //Which ability is currently chosen
		
		private var imPlayer:int;
		private var myID:String;
		private var infoBox:InfoBox;
		private var client:Client;
		private var connection:Connection; //connection to server
		
		private var win:Boolean = false; //This variable will indicate if a user has won or not
		
		// constants/offset numbers
		private var _mapOffsetX:int = 100; 	// left border of map
		private var _mapOffsetY:int = 40;	// top border of map
		private var _apBoxOffsetX:int = 290;
		private var _apBoxOffsetY:int = 5;
		private var _timerOffsetX:int = 330;
		private var _timerOffsetY:int = 5;
		private var _positionInfoOffsetX:int = 450;
		private var _positionInfoOffsetY:int = 330;
		private var _terrainMessageBoxOffsetX:int = 450;
		private var _terrainMessageBoxOffsetY:int = 300;
		private var _errorMessageOffsetX: int = 450;
		private var _errorMessageOffsetY: int = 370;
		private var _goalsBoxOffsetX:int = 450;
		private var _goalsBoxOffsetY:int = 15;
		private var _cardBoxOffsetX:int = 450;
		private var _cardBoxOffsetY:int = 100;
		private var _tileSize:int = 32;
		private var _lvlTextOffsetX:int = 5;
		private var _lvlTextOffsetY:int = 5;
		private var _experienceTextOffsetX:int = 70;
		private var _experienceTextOffsetY:int = 5;
		private var _resoruceTextOffsetX:int = 450;
		private var _resourceTextOffsetY:int = 300;
		
		private static var myClient:Client;
		private static var playerName:String;
		
		public function PlayState(connection:Connection, client:Client):void
		{
			super();
			trace("Sucessfully connected to the multiplayer server");
			
			infoBox = new InfoBox(resetGame,joinGame);
			//addChild(infoBox);
			
			infoBox.Show("waiting");						
			
			this.client = client;
			myClient = client;
			this.connection = connection;
			
			//Connection successful, load board and player
			connection.addMessageHandler("init", function(m:Message, iAm:int, name:String, level:String) {
				imPlayer = iAm;
				//boardSetup(level);
				client.bigDB.load("StaticMaps", level, function(ob:DatabaseObject):void {
					var values:Array = ob.tileValues; //Recieve Tile Array from database to be turned into string with line breaks between each line
					boardSetup(values.join("\n"));
				});
			})
			//Recieve Info from server about your saved character
			connection.addMessageHandler("playerInfo", function(m:Message, posX:int, posY:int, name:String, startAP:int) {
				if (myPlayer == null) {
					trace("playerInfo!  given AP? " + startAP);
					playerName = name;
					// add player to screen --
					// if player has previous position saved in database, place player there
					client.bigDB.load("Quests", name, function(results:DatabaseObject):void {
						// player has previous position on this map
						if (results != null) {
							playerStartX = results.positionX;
							playerStartY = results.positionY;
							myPlayer = new Player(playerStartX, playerStartY, _mapOffsetX, _mapOffsetY, _tileSize, startAP);
							playersArray[imPlayer - 1] = myPlayer;
							lyrSprites.add(myPlayer);
						}
						else
						{
							myPlayer = new Player(playerStartX, playerStartY, _mapOffsetX, _mapOffsetY, _tileSize, startAP);
							playersArray[imPlayer - 1] = myPlayer;
							lyrSprites.add(myPlayer);
						}
					});
					
					//Load Abilities for Player From Database
					client.bigDB.loadMyPlayerObject(function(db:DatabaseObject) {
						try {
							var abilityArray:Array = db.abilities
							if (abilityArray != null || abilityArray.length > 0) {
								client.bigDB.loadKeys("Abilities", db.abilities, function(dbarr:Array) {
									var abilityButtonBox:Box = new Box().fill(0xffffff, 1, 5).margin(10, 10, 10, 10);
									abilityButtonBox.add(new Label("Abilities", 15, TextFormatAlign.CENTER));
									for (var z:String in dbarr) {
										var test:DatabaseObject = dbarr[z]
										var myAbility:Ability = new Ability(_tileSize, myPlayer, test.Range, test.Cost, test.Effect.Type, test.Effect.From, test.Effect.To);
										myAbility.visible = false;
										lyrStage.add(myAbility);
										trace("Loaded Ability " + test.Name + "\n");
										abilityButtonBox.add(new AbilityButton(myAbility, test.Name))
										abilities.text = abilities.text + test.Name + "\n"
									}
									abilitiesBox.add(new Box().fill(0x00000, .5, 15).margin(10, 10, 10, 10).minSize(130, 130).add(abilityButtonBox))
								})
							}
						} catch (e:Error) {
							//Catches Error is no abilities have been set yet
							trace("unable to load abilities");
						}
					});
				}
				//FlxG.follow(myPlayer);
				//FlxG.followBounds(0, 0, myMap.width, myMap.height);
			})
			//New user has joined, make their character
			connection.addMessageHandler("UserJoined", function(m:Message, userID:int, posX:int, posY:int) {
				if (userID != imPlayer) {
					// create other player; AP doesn't matter, so default to 20
					playersArray[userID-1] = (new Player(posX, posY, _mapOffsetX, _mapOffsetY, _tileSize, 20));
					lyrSprites.add(playersArray[userID-1]);
				}
			})
			//Player has moved and we hear about it
			connection.addMessageHandler("PlayerMove", function(m:Message, userID:int, posX:int, posY:int) {
				if(userID != imPlayer){
					Player(playersArray[userID - 1]).movePlayer(posX, posY, _tileSize, connection);
				}
			})
			//A tile has changed and needs to be updated locally
			connection.addMessageHandler("MapTileChanged", function(m:Message, userID:int, posX:int, posY:int, newTileType:int) {
				setTileIdentity(posX, posY, newTileType);
				//myMap.setTile(posX, posY, newTileType, true);
			})
			//A player has reached the end, victory!
			connection.addMessageHandler("win", function(m:Message, userID:int, xp:int, coin:int) {
				connection.disconnect();
				FlxG.state = new QuestCompleteState(xp, coin, client);
			})
			
			
		}
		
		override public function update():void 
		{
			if(connected == true){
				counter -= FlxG.elapsed;
				if (counter <= 0)
				{
					// After 180 seconds has passed, the timer will reset.
					//myPlayer.AP++;
					counter = 180;
					incrementAP();
					myPlayer.AP++;
				}
				//Update HUD Information
				secCounter.text = counter.toPrecision(3) + " seconds until more AP";
				//Player moves only one character, detect keys presses here
				if (myPlayer != null && !win) {
					if (myPlayer.AP <= 0 && FlxG.keys.justPressed("A")) {
						incrementAP();
						myPlayer.AP++;
					}
					if (FlxG.keys.justPressed("DOWN")) {
						win = myPlayer.movePlayer(0, 1, _tileSize, connection);
					}else if (FlxG.keys.justPressed("UP")) {
						win = myPlayer.movePlayer(0, -1, _tileSize, connection);
					}else if (FlxG.keys.justPressed("RIGHT")) {
						win = myPlayer.movePlayer(1, 0, _tileSize, connection);
					}else if (FlxG.keys.justPressed("LEFT")) {
						win = myPlayer.movePlayer( -1, 0, _tileSize, connection);
					}else if (myMouse.justPressed() &&  mouseWithinTileMap() && abilitySelected) {
						var selectedXTile:int = (myMouse.x - _mapOffsetX) / _tileSize
						//(myMouse.x - (myMouse.x % 32)) / 32;
						var selectedYTile:int = (myMouse.y - _mapOffsetY) / _tileSize
						//(myMouse.y - (myMouse.y % 32)) / 32
						//TO DO: ADD ALERT MESSAGE!!!
						if (checkActiveAbilityRange(selectedXTile, selectedYTile)) {
							activeAbility.cast(selectedXTile, selectedYTile , connection);
						}
						//new InGamePrompt(this, "Are you sure?", function(){ 
						//	myMap.setTile(myMouse.x / 32, myMouse.y / 32, 5, true);
						//	connection.send("MapTileChanged", (myMouse.x - (myMouse.x % 32)) / 32, (myMouse.y - (myMouse.y % 32)) / 32, 5); //Test Code, will turn any clicked tile into a star
						//})
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
				}
				
				super.update();
			}
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
				return "Unkown Land Type";
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
		private function boardSetup(map_data:String):void 
		{
			counter = 180; // 1ap gained every 3 minutes
			//Add chat to game
			//var chat:Chat = new Chat(FlxG.stage, connection);
			//Different Layers
			lyrStage = new FlxGroup; //Map exists here
            lyrSprites = new FlxGroup; //Character Sprites exist here
            lyrHUD = new FlxGroup; //HUD elements exist here
			lyrBackground = new FlxGroup;
			myMouse = FlxG.mouse;
			
			//Tile Map
			myMap = new FlxTilemap();
			myMap.drawIndex = 0;
			myMap.loadMap(map_data, data_tiles, _tileSize, _tileSize);
			myMap.collideIndex = 1;
			myMap.x = _mapOffsetX;
			myMap.y = _mapOffsetY;			
			lyrStage.add(myMap);
			
			// Top HUD
			apInfo = new FlxText(_apBoxOffsetX, _apBoxOffsetY, 100, "AP:", true);
			lvl = new FlxText(_lvlTextOffsetX, _lvlTextOffsetY, 100, "Lvl:1", true);
			experience = new FlxText(_experienceTextOffsetX, _experienceTextOffsetY, 100, "Exp:0", true);
			
			//Bottom HUD
			
			
			//Right Side HUD
			resources = new FlxText(_resoruceTextOffsetX, _resourceTextOffsetY, 150, "Resources:", true);			
			goals = new FlxText(_goalsBoxOffsetX, _goalsBoxOffsetY, 100, "Goals:\nReach the Red Star", true); 
			goals.frameHeight = 75;			
			errorMessage = new FlxText(_errorMessageOffsetX, _errorMessageOffsetY, 120, "Errors Appear Here", true);
			location = new FlxText(_positionInfoOffsetX, _positionInfoOffsetY, 100, "(0,0)", true);
			mouseLocation = new FlxText(_terrainMessageBoxOffsetX, _terrainMessageBoxOffsetY, 150, "(0,0)", true);
			secCounter = new FlxText(_timerOffsetX, _timerOffsetY, 100, "15 Sec until AP", true);			
			abilities = new FlxText(_cardBoxOffsetX, _cardBoxOffsetY, 100, "Abilities:\n", true);
			abilitiesBox = new Box().fill(0xFFFFFF, 0.8, 0)
			abilitiesBox.x = _cardBoxOffsetX;
			abilitiesBox.y = _cardBoxOffsetY;
			abilitiesBox.minSize(150, 150);
			

			// background
			background = new Background();
			
			lyrHUD.add(resources);
			lyrHUD.add(lvl);
			lyrHUD.add(experience);
			lyrHUD.add(abilities);
			lyrHUD.add(goals);
			lyrHUD.add(secCounter);
			lyrHUD.add(location);
			lyrHUD.add(errorMessage);
			lyrHUD.add(apInfo);
			lyrHUD.add(mouseLocation);
			lyrBackground.add(background);
		
			this.add(lyrBackground);
			this.add(lyrStage);
            this.add(lyrSprites);
            this.add(lyrHUD);
			this.addChild(abilitiesBox);
			
			connected = true;
			connection.send("playerInfo");
		}
		
		//Determines whether the mouse is within the game map board, return true if it is or false if it is outside the board
		private function mouseWithinTileMap():Boolean
		{
			if (myMap.x < myMouse.x + _mapOffsetX 
				&& myMouse.x < (myMap.x + myMap.width + _mapOffsetX) 
				&& myMap.y < myMouse.y +_mapOffsetY
				&& myMouse.y < (myMap.y + myMap.height + _mapOffsetY)) {
				errorMessage.text = "In the Box"	
				return true;
			}
			errorMessage.text = "Out of the box"
			return false;
		}
		
		private function getTileIdentity(x:int,y:int):uint {
			return myMap.getTile((x - _mapOffsetX) / _tileSize, (y - _mapOffsetY) / _tileSize);
		}
		
		private function setTileIdentity(x:int,y:int,identity:int):void {
			myMap.setTile((x - _mapOffsetX) / _tileSize, (y - _mapOffsetY) / _tileSize, identity, true);
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