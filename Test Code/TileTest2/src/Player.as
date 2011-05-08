package  
{
	import org.flixel.*;
	import playerio.BigDB;
	import playerio.Connection;
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
		public var errorMessage:String;
		public var xPos:Number; //X Tile Position
		public var yPos:Number; //Y Tile Position
		public var xTilePixel:Number; //The X tile location in pixels for the player's current tile
		public var yTilePixel:Number; //The Y tile location in pixels for the player's current tile
		private var _move_speed:int = 400;
		
		public function Player(startX:Number, startY:Number, xOffset:int, yOffset:int, tileSize:int, startAP:int) 
		{
			errorMessage = "";
			xPos = startX;
			yPos = startY;
			AP = startAP;
			super(((startX + .25) * tileSize) + xOffset, ((startY + .25) * tileSize) + yOffset, player_avatar);
		}
		
		//Public function that can be called to move the position of the player based on a tile change
		//thus to move one tile to the right send (1,0) as arugments, one to left is (-1,0)
		//NOW RETURNS A BOOLEAN, True if the move has caused the user to reach the end, False if not
		public function movePlayer(xChange:Number, yChange:Number, tileSize:int, connection:Connection):Boolean {
			trace("x:" + xPos + " y:" + yPos + " change_x:" + xChange + " change_y:" + yChange + " tile_size:" + tileSize);
			if (checkMove(xPos + xChange, yPos + yChange)) {
				xPos = xPos + xChange;
				yPos = yPos + yChange;
				AP = AP - findCost(xPos, yPos);
				this.x = this.x + (tileSize * xChange);
				this.y = this.y + (tileSize * yChange);
				connection.send("move", xChange, yChange);
				if (PlayState.myMap.getTile(xPos, yPos) == WIN_TILE) {
					return true;
				}
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
			if (PlayState.myMap.getTile(proposedX, proposedY) == WATER_TILE) {
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