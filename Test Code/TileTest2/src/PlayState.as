package  
{
	import org.flixel.*
	import org.flixel.data.FlxMouse;
	import playerio.*
	import sample.ui.Prompt
	import sample.ui.Chat
	import sample.ui.Lobby
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class PlayState extends FlxState
	{
		[Embed(source = "data/map_data.txt", mimeType = "application/octet-stream")] public var data_map:Class; //Tile Map array
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
		private var connection:Connection //connection to server
		public static var lyrStage:FlxGroup;
        public static var lyrSprites:FlxGroup;
        public static var lyrHUD:FlxGroup;
		
		private var lobby:Lobby
		private var imPlayer:int;
		private var infoBox:InfoBox;
		

		public function PlayState():void
		{
			super();
			//COnnect to PlayerIO server
			new Prompt(FlxG.stage, "What's your name?", "Guest-" + (Math.random()*9999<<0), function(name:String){
				PlayerIO.connect(
					FlxG.stage,								//Referance to stage
					"getacross-rny1binyakgosozwy0h8wg",			//Game id (Get your own at playerio.com. 1: Create user, 2:Goto admin pannel, 3:Create game, 4: Copy game id inside the "")
					"public",							//Connection id, default is public
					name,								//Username
					"",									//User auth. Can be left blank if authentication is disabled on connection
					null,								//Current PartnerPay partner.
					handleConnect,						//Function executed on successful connect
					handleError							//Function executed if we recive an error
				);   
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
					}
					apInfo.text = "AP:" + myPlayer.AP;
					location.text = "(" + myPlayer.xPos + "," + myPlayer.yPos + ")";
					errorMessage.text = "" + myPlayer.errorMessage;
				}else {
					errorMessage.text = "Loading Player Information";
				}
				mouseLocation.text = tileInformation(myMap.getTile(myMouse.x / 32, myMouse.y / 32));
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
		private function boardSetup():void 
		{
			counter = 15; //15 sec/1ap
			
			//Different Layers
			lyrStage = new FlxGroup; //Map exists here
            lyrSprites = new FlxGroup; //Character Sprites exist here
            lyrHUD = new FlxGroup; //HUD elements exist here
			myMouse = FlxG.mouse;
			
			//Tile Map
			myMap = new FlxTilemap();
			myMap.drawIndex = 0;
			myMap.loadMap(new data_map, data_tiles, 32, 32);
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
		}
		
		//**************************************************************
		//********************PlayIO Functions**************************
		//**************************************************************
		
		private function handleConnect(client:Client):void{
			trace("Sucessfully connected to player.io");
			
			
			//Set developmentsever (Comment out to connect to your server online)
			client.multiplayer.developmentServer = "127.0.0.1:8184";
			
			//Create lobby
			lobby = new Lobby(client, "GetAcross", handleJoin, handleError)
			
			//Show lobby (parsing true hides the cancel button)
			lobby.show(true);
			
			//gotoAndStop(2); //Tbis is pure Flash, need to change this to AS3 (not sure the equivalent
		
			
		}
		
		private function handleJoin(connection:Connection):void{
			trace("Sucessfully connected to the multiplayer server");
		
			
			infoBox = new InfoBox(resetGame,joinGame);
			addChild(infoBox)
			
			infoBox.Show("waiting");						
			
			this.connection = connection;

			//Add chat to game
			var chat:Chat = new Chat(stage, connection);			
			//Connection successful, load board and player
			connection.addMessageHandler("init", function(m:Message, iAm:int, name:String){
				imPlayer = iAm;
				connected = true;
				connection.send("playerInfo");
				boardSetup();
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
			
			
		}
	
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
		
		private function handleError(error:PlayerIOError):void{
			trace("Got", error)
			FlxG.state = new LoginState();

		}
		
	}

}