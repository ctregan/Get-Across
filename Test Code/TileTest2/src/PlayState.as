package  
{
	import org.flixel.*
	import org.flixel.data.FlxMouse;
	import playerio.*
	import sample.ui.Alert;
	import sample.ui.InGamePrompt;
	import sample.ui.Prompt
	import sample.ui.Chat
	import sample.ui.Lobby
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class PlayState extends FlxState
	{
		//[Embed(source = "data/map_data.txt", mimeType = "application/octet-stream")] public var data_map:Class; //Tile Map array
		[Embed(source = "data/testTileSet.png")] public var data_tiles:Class; //Tile Set Image
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
		private var connected:Boolean = false; //Indicates if connection has been established1

		public static var myMap:FlxTilemap; //The tile map where the tileset is drawn
		private var connection:Connection; //connection to server
		public static var lyrStage:FlxGroup;
        public static var lyrSprites:FlxGroup;
        public static var lyrHUD:FlxGroup;
		
		private var lobby:Lobby;
		private var imPlayer:int;
		private var infoBox:InfoBox;
		private var client:Client;
		

		public function PlayState(connection:Connection, client:Client):void
		{
			super();
			trace("Sucessfully connected to the multiplayer server");
			
			infoBox = new InfoBox(resetGame,joinGame);
			//addChild(infoBox);
			
			infoBox.Show("waiting");						
			
			this.client = client;
			this.connection = connection;
			
			//Connection successful, load board and player
			connection.addMessageHandler("init", function(m:Message, iAm:int, name:String, level:String){
				imPlayer = iAm;
				//boardSetup(level);
				client.bigDB.load("StaticMaps", level, function(ob:DatabaseObject):void {
					var values:Array = ob.tileValues; //Recieve Tile Array from database to be turned into string with line breaks between each line
					boardSetup(values.join("\n"));
					
				});
			})
			//Recieve Info from server about your saved character
			connection.addMessageHandler("playerInfo", function(m:Message, posX:int, posY:int) {
				if (myPlayer == null) {
					myPlayer = new Player(posX, posY);
					playersArray[imPlayer - 1] = myPlayer;
					lyrSprites.add(myPlayer);
				}
				
			})
			//New user has joined, make their character
			connection.addMessageHandler("UserJoined", function(m:Message, userID:int, posX:int, posY:int) {
				if(userID != imPlayer){
					playersArray[userID-1] = (new Player(posX, posY));
					lyrSprites.add(playersArray[userID-1]);
				}
			})
			//Player has moved and we hear about it
			connection.addMessageHandler("PlayerMove", function(m:Message, userID:int, posX:int, posY:int) {
				if(userID != imPlayer){
					Player(playersArray[userID - 1]).movePlayer(posX, posY);
				}
			})
			//A tile has changed and needs to be updated locally
			connection.addMessageHandler("MapTileChanged", function(m:Message, userID:int, posX:int, posY:int, newTileType:int) {
				if(userID != imPlayer){
					myMap.setTile(posX, posY, newTileType, true);
				}
			})
			
			
		}
		
		override public function update():void 
		{
			if(connected == true){
				counter -= FlxG.elapsed;
				if (counter <= 0)
				{
					// After 15 seconds has passed, the timer will reset.
					//myPlayer.AP++;
					counter = 15;
				}
				//Update HUD Information
				secCounter.text = counter.toPrecision(3) + " Sec until AP";
				//Player moves only one character, detect keys presses here
				if (myPlayer != null) {
					if (myPlayer.AP <= 0 && FlxG.keys.justPressed("A")) {
						myPlayer.AP += 20;
					}
					if (FlxG.keys.justPressed("DOWN")) {
						myPlayer.movePlayer(0, 1);
						connection.send("move", 0, 1);
					}else if (FlxG.keys.justPressed("UP")) {
						myPlayer.movePlayer(0, -1);
						connection.send("move", 0, -1);
					}else if (FlxG.keys.justPressed("RIGHT")) {
						myPlayer.movePlayer(1, 0);
						connection.send("move", 1, 0);
					}else if (FlxG.keys.justPressed("LEFT")) {
						myPlayer.movePlayer( -1, 0);
						connection.send("move", -1, 0);
					}else if (myMouse.justPressed() &&  mouseWithinTileMap()) {
						//TO DO: ADD ALERT MESSAGE!!!
						//new InGamePrompt(this, "Are you sure?", function(){ 
							myMap.setTile(myMouse.x / 32, myMouse.y / 32, 5, true);
							connection.send("MapTileChanged", (myMouse.x - (myMouse.x % 32)) / 32, (myMouse.y - (myMouse.y % 32)) / 32, 5); //Test Code, will turn any clicked tile into a star
						//})
					}
					apInfo.text = "AP:" + myPlayer.AP;
					location.text = "(" + myPlayer.xPos + "," + myPlayer.yPos + ")";
					errorMessage.text = "" + myPlayer.errorMessage;
					mouseLocation.text = tileInformation(myMap.getTile(myMouse.x / 32, myMouse.y / 32));
				}else {
					//errorMessage.text = "Loading Player Information";
				}
				
				super.update();
			}
		}
		
		//Give a tile number and return information String about that Tile
		private function tileInformation(type:Number):String
		{
			if (type == 1) {
				return "Hill (Travel Cost = 3AP)";
			}else if (type == 2) {
				return "Tree (Travel Cost = 1AP)";
			}else if (type == 3) {
				return "Cherry Tree (Travel Cost = 1AP)";
			}else if (type == 4) {
				return "Water (Impassible without help)";
			}else if (type == 0) {
				return "Land (Travel Cost = 1AP)";
			}else if (type == 5 ) {
				return "End Point (Reach here to win!)";
			}else{
				return "Unkown Land Type";
			}
			
		}
		
		//Add all flixel elements to the board, essentially drawing the game.
		private function boardSetup(map_data:String):void 
		{
			counter = 15; //15 sec/1ap
			//Add chat to game
			//var chat:Chat = new Chat(FlxG.stage, connection);
			//Different Layers
			lyrStage = new FlxGroup; //Map exists here
            lyrSprites = new FlxGroup; //Character Sprites exist here
            lyrHUD = new FlxGroup; //HUD elements exist here
			myMouse = FlxG.mouse;
			
			//Tile Map
			myMap = new FlxTilemap();
			myMap.drawIndex = 0;
			myMap.loadMap(map_data, data_tiles, 32, 32);
			myMap.collideIndex = 1;
			lyrStage.add(myMap);
			
			
			//Bottom HUD
			apInfo = new FlxText(0, (myMap.height), 100, "AP:", true);
			errorMessage = new FlxText(0, myMap.height + 20, 120, "Errors Appear Here", true);
			location = new FlxText(150, myMap.height, 100, "(0,0)", true);
			mouseLocation = new FlxText(150, myMap.height + 20, 200, "(0,0)", true);
			secCounter = new FlxText(200, myMap.height, 100, "15 Sec until AP", true);
			
			//Right Side HUD
			goals = new FlxText(myMap.width, 0, 100, "Goals:\nReach the Red Star", true); 
			goals.frameHeight = 75;
			abilities = new FlxText(myMap.width, 80, 100, "Abilities:", true);
			
			lyrHUD.add(abilities);
			lyrHUD.add(goals);
			lyrHUD.add(secCounter);
			lyrHUD.add(location);
			lyrHUD.add(errorMessage);
			lyrHUD.add(apInfo);
			lyrHUD.add(mouseLocation);
		
			
			this.add(lyrStage);
            this.add(lyrSprites);
            this.add(lyrHUD);
			
			connected = true;
			connection.send("playerInfo");
		}
		
		//Determines whether the mouse is within the game map board, return true if it is or false if it is outside the board
		private function mouseWithinTileMap():Boolean
		{
			if (myMap.x < myMouse.x && myMouse.x < (myMap.x + myMap.width) && myMap.y < myMouse.y && myMouse.y < (myMap.y + myMap.height)) {
				return true;
			}
			return false;
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