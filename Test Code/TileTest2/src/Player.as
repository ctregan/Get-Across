package  
{
	import flash.errors.ScriptTimeoutError;
	import flash.events.TimerEvent;
	import org.flixel.*;
	import playerio.BigDB;
	import playerio.Connection; 
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class Player extends FlxSprite
	{
		//Tile Value Constants, if tileSet changes, need to update these!!
		public static const GRASS_TILE:int = 0;
		public static const HILL_TILE:int = 1;
		public static const TREE_TILE:int = 2;
		public static const CHERRY_TILE:int = 3;
		public static const WIN_TILE:int = 4;
		public static const YELLOW_TILE:int = 5;
		public static const BRIDGE_TILE_UP:int = 6;
		public static const BRIDGE_TILE_LEFT:int = 7;
		public static const WATER_TILE:int = 8;
		public static const WATER_TILE3:int = 9;
		public static const WATER_TILE4:int = 10;
		public static const WATER_TILE5:int = 11;
		public static const WATER_TILE6:int = 12;
		public static const WATER_TILE2:int = 13;
		public static const GATE_TILE:int = 14;
		public static const MOUNTAIN_TILE:int = 15;
		public static const ROCK_TILE:int = 16;
		public static const RUBBLE_TILE:int = 17;
		public static const BRAMBLE_TILE:int = 18;
		public static const SNAKE_TILE:int = 20;
		public static const SNAKE_GONE_TILE:int = 21;
		
		[Embed(source = "data/character3.png")] public var player_avatar:Class;
		[Embed(source = "data/character3_cook.png")] public var cook_avatar:Class;
		[Embed(source = "data/character3_crafter.png")] public var crafter_avatar:Class;
		[Embed(source = "data/character3_planter.png")] public var planter_avatar:Class;
		public var AP:Number; //Amount of AP
		public var level:Number;
		public var coin:Number;
		public var exp:Number;
		public var errorMessage:String;
		public var xPos:Number; //X Tile Position
		public var yPos:Number; //Y Tile Position
		public var inBattle:Boolean = false;
		public var combatant:Monster;
		private var _move_speed:int = 400;
		public var isMoving:Boolean = false;
		private var isMyPlayer:Boolean; //Indicates if this player object is the one local to the client
		
		// player's resources
		public var amountLumber:int;
		public var amountCherry:int;
		
		public function Player(startX:Number, startY:Number, xOffset:int, yOffset:int, tileSize:int, startAP:int, resourcesString:String, playerClass:String, myPlayer:Boolean = true) 
		{
			isMyPlayer = myPlayer;
			errorMessage = "";
			xPos = startX;
			yPos = startY;
			AP = startAP;
			
			trace("player constructed: " + xPos + "," + yPos);
			// load amount of resources player has saved			
			// split list of resources from
			// "Lumber:0/Cherry:3/Seed:2"
			// to ["Lumber:0", "Cherry:3", "Seed:2"]
			if (resourcesString != null)
			{
				trace("resourcesString from server: " + resourcesString);
				var resourcesArray:Array = resourcesString.split("/");
				var resource:Array;
				for (var i:int = 0; i < resourcesArray.length; i++)
				{
					resource = (resourcesArray[i]).split(":");
					
					// change player's variables
					switch (resource[0])
					{
						case "Lumber":
							amountLumber = resource[1];
							PlayState.amountLumberText.text = "Lumber: " + amountLumber + "\n";
							break;
						case "Cherry":
							amountCherry = resource[1];
							PlayState.amountCherryText.text = "Cherries: " + amountCherry + "\n";
							break;
					}
					
				}
			}
			
			super(((startX) * tileSize) + xOffset, ((startY) * tileSize) + yOffset);
			
			switch (playerClass)
			{
				case "Cook":
					loadGraphic(cook_avatar, true, false, 32 , 32);
					break;
				case "Planter":
					loadGraphic(planter_avatar, true, false, 32 , 32);
					break;
				case "Crafter":
					loadGraphic(crafter_avatar, true, false, 32 , 32);
					break;
				default:
					loadGraphic(player_avatar, true, false, 32 , 32);
					break;
			}
			facing = FlxSprite.DOWN;
			
			addAnimation("idle" + UP, [5], 0, false);
			addAnimation("idle" + DOWN, [0], 0, false);
			addAnimation("idle" + LEFT, [4], 0, false);
			addAnimation("idle" + RIGHT, [3], 0, false);
			addAnimation("walk" + UP, [0, 1, 2], 5, true);
            addAnimation("walk" + DOWN, [0,1,2], 5, true);
            addAnimation("walk" + LEFT, [0, 1, 2], 5, true);
			addAnimation("walk" + RIGHT, [0, 1, 2], 5, true);
		}
		
		
		//Public function that can be called to move the position of the player based on a tile change
		//thus to move one tile to the right send (1,0) as arugments, one to left is (-1,0)
		//returns true if the move has caused the user to reach the end, False if not
		public function movePlayer(xChange:Number, yChange:Number, tileSize:int, connection:Connection):Boolean {
			// see if player has enough AP to move; if not, fire notification
			if (AP < findCost(xPos + xChange, yPos + yChange, tileSize, false))
				PlayState.fireNotification(this.x + 20, this.y - 20, "Not enough AP to move here!", "loss");
			else if (checkMove(xPos + xChange, yPos + yChange, tileSize)) {
				isMoving = true;
				xPos = xPos + xChange;
				yPos = yPos + yChange;
				var cost:int = findCost(xPos, yPos, tileSize, true);
				AP = AP - cost;
				play("walk" + facing);
				var desiredX:int = this.x + (tileSize * xChange);
				var desiredY:int = this.y + (tileSize * yChange);

				this.x = desiredX;
				this.y = desiredY;
				if (isMyPlayer) {
					connection.send("move", xChange, yChange);
				}
				
				//trace("x:" + xPos + " y:" + yPos + " change_x:" + xChange + " change_y:" + yChange + " tile_size:" + tileSize + " type:" + PlayState.myMap.getTile(xPos, yPos));
				if (PlayState.myMap.getTile(xPos, yPos) == WIN_TILE) {
					trace("at win!");
					return true;
				}
				var myTimer:Timer = new Timer(500);
				myTimer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {
					isMoving = false;
				})
				myTimer.start();
			}
			
			// sends AP this player has to the server
			if(isMyPlayer){
				connection.send("updateStat", "AP", AP);
			}
			if (cost > 0) PlayState.fireNotification(this.x + 20, this.y - 20, "-" + cost + " AP", "loss");
			return false;
		}
		
		//Find AP Cost of the tile at the given location. If tureMove flag is high, then the player will actually move when results are passed
		private function findCost(proposedX:Number, proposedY:Number, tileSize:int, trueMove:Boolean):Number {
			var sprites:Array = PlayState.lyrEffects.members
			for (var x in sprites) {
				try {
					var eSprite:EffectSprite = EffectSprite(sprites[x]);
					if (eSprite.type == "redflower" && eSprite.inRange(proposedX, proposedY) && !eSprite.dead)  {
						if(trueMove){
							eSprite.addUse(true);
						}
						return 0;
					}
				}catch (e:Error) {
					
				}
			}
			
			// return cost of tile
			switch (PlayState.myMap.getTile(proposedX, proposedY))
			{
				case HILL_TILE:
					return 3;
					break;
				case MOUNTAIN_TILE:
					return 15;
					break;
				default:
					return 0;
			}
		}
		
		override public function update():void 
		{
			health = AP;
			super.update();
		}
		
		//Sees if the desired move for the player is valid.
		public function checkMove(proposedX:Number, proposedY:Number, tileSize:int):Boolean {
			var proposedTileType:int = PlayState.myMap.getTile(proposedX, proposedY)
			if ( proposedTileType >= WATER_TILE && proposedTileType <= WATER_TILE2) {
				errorMessage = "Invalid Move, can't cross water";
				//PlayState.fireNotification(this.x + 20, this.y - 20, "You can't cross water!", "loss");
				return false;
			}else if (proposedTileType == GATE_TILE) {
				PlayState.fireNotification(this.x + 20, this.y - 20, "You have to open the gate first!", "loss");
				errorMessage = "Invalid Move, Must First Open the Gate";
				return false;
			}else if (proposedX >= PlayState.myMap.widthInTiles || proposedX < 0 || proposedY < 0 || proposedY >= PlayState.myMap.heightInTiles) {
				errorMessage = "Invalid Move, edge reached";
				//PlayState.fireNotification(this.x + 20, this.y - 20, "You can't go beyond the map's edge!", "loss");
				return false;
			}else if (proposedTileType == 16) {
				PlayState.fireNotification(this.x + 20, this.y - 20, "Invalid Move, Cannot pass boulder", "loss");
				errorMessage = "Invalid Move, Cannot pass boulder";
				return false;
			}else if (proposedTileType == 18) {
				PlayState.fireNotification(this.x + 20, this.y - 20, "Invalid Move, Cannot pass thorns", "loss");
				errorMessage = "Invalid Move, Cannot pass thorns";
				return false;
			}else if (proposedTileType == 20) {
				PlayState.fireNotification(this.x + 20, this.y - 20, "Invalid Move, Cannot pass hungry snake", "loss");
				errorMessage = "Invalid Move, Cannot pass hungry snake";
				return false;
			}
			return true;
		}
	}
}