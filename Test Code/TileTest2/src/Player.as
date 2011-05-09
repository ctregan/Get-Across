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
		private const GRASS_TILE:int = 0;
		private const HILL_TILE:int = 1;
		private const TREE_TILE:int = 2;
		private const CHERRY_TILE:int = 3;
		private const WATER_TILE:int = 4;
		private const WIN_TILE:int = 5;
		
		[Embed(source = "data/character1.png")] public var player_avatar:Class;
		public var AP:Number; //Amount of AP
		public var level:Number;
		public var coin:Number;
		public var exp:Number;
		public var errorMessage:String;
		public var xPos:Number; //X Tile Position
		public var yPos:Number; //Y Tile Position
		public var xTilePixel:Number; //The X tile location in pixels for the player's current tile
		public var yTilePixel:Number; //The Y tile location in pixels for the player's current tile
		private var _move_speed:int = 400;
		public var isMoving:Boolean = false;
		
		public function Player(startX:Number, startY:Number, xOffset:int, yOffset:int, tileSize:int, startAP:int) 
		{
			errorMessage = "";
			xPos = startX;
			yPos = startY;
			AP = startAP;
			super(((startX) * tileSize) + xOffset, ((startY) * tileSize) + yOffset);
			loadGraphic(player_avatar, true, false, 32 , 32);
			addAnimation("idle" + UP, [0], 0, false);
			addAnimation("idle" + DOWN, [3], 0, false);
			addAnimation("idle" + LEFT, [6], 0, false);
			addAnimation("idle" + RIGHT, [9], 0, false);
			addAnimation("walk" + UP, [0, 1, 2], 15, true);
            addAnimation("walk" + DOWN, [3,4,5], 15, true);
            addAnimation("walk" + LEFT, [6, 7, 8], 15, true);
			addAnimation("walk" + RIGHT, [9, 10, 11], 15, true);
			facing = FlxSprite.DOWN;
		}
		
		//Public function that can be called to move the position of the player based on a tile change
		//thus to move one tile to the right send (1,0) as arugments, one to left is (-1,0)
		//NOW RETURNS A BOOLEAN, True if the move has caused the user to reach the end, False if not
		public function movePlayer(xChange:Number, yChange:Number, tileSize:int, connection:Connection):Boolean {
			trace("x:" + xPos + " y:" + yPos + " change_x:" + xChange + " change_y:" + yChange + " tile_size:" + tileSize);
			if (checkMove(xPos + xChange, yPos + yChange)) {
				isMoving = true;
				xPos = xPos + xChange;
				yPos = yPos + yChange;
				AP = AP - findCost(xPos, yPos);
				play("walk" + facing);
				var desiredX:int = this.x + (tileSize * xChange);
				var desiredY:int = this.y + (tileSize * yChange);
				/*while (this.x > desiredX + 1 || this.x < desiredX - 1) {
					velocity.x = .5 * xChange;
					super.update();
				}
				while (this.y > desiredY + 1 || this.y < desiredY - 1) {
					velocity.y = .5 * yChange;
					super.update();
				}
				velocity.y = 0;
				velocity.x = 0;*/
				this.x = desiredX;
				this.y = desiredY;
				connection.send("move", xChange, yChange);
				if (PlayState.myMap.getTile(xPos, yPos) == WIN_TILE) {
					return true;
				}
				var myTimer:Timer = new Timer(1000);
				myTimer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {
					isMoving = false;
				})
				myTimer.start();
			}
			
			// update AP count in Quests database
			PlayState.updateAP(AP);
			
			return false;
		}
		//Find AP Cost of the tile at the given location.
		private function findCost(proposedX:Number, proposedY:Number):Number {
			if (PlayState.myMap.getTile(proposedX, proposedY) == 1) {
				return 3;
			}else {
				return 1;
			}
		}
		//Sees if the desired move for the player is valid.
		private function checkMove(proposedX:Number, proposedY:Number):Boolean {
			if (PlayState.myMap.getTile(proposedX, proposedY) == WATER_TILE ) {
				errorMessage = "Invalid Move, cant cross water";
				return false;
			}else if (AP < findCost(proposedX, proposedY)) {
				errorMessage = "Invalid Move, insufficient AP";
				return false;
			}else if (proposedX >= PlayState.myMap.widthInTiles || proposedX < 0 || proposedY < 0 || proposedY >= PlayState.myMap.heightInTiles) {
				errorMessage = "Invalid Move, edge reached";
				return false;
			}
			return true;
		}
	}
}