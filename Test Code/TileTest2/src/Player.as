package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class Player extends FlxSprite
	{
		[Embed(source = "data/Ship.png")] public var ship_img:Class;
		public var AP:Number;
		public var errorMessage:String;
		public var xPos:Number;
		public var yPos:Number;
		private var _move_speed:int = 400;
		public function Player(startX:Number, startY:Number ) 
		{
			errorMessage = "";
			xPos = startX;
			yPos = startY;
			AP = 20;
			super(0, 0, ship_img);
		}
		override public function update():void 
		{
			if (AP <= 0 && FlxG.keys.justPressed("A")) {
				AP += 20;
			}else if (AP <= 0) {
				super.update();
				return;
			}
			if (FlxG.keys.justPressed("DOWN")) {
				/*if (PlayState.myMap.getTile(xPos, yPos + 1) == 4) {
					errorMessage = "Invalid Move, cant cross water";
				}else if(yPos >= PlayState.myMap.heightInTiles - 1){
					errorMessage = "Invalid Move, reached bottom edge";
				}else {
					yPos++;
					AP = AP - findCost();
					this.y = this.y + 32
				}*/
				if (checkMove(xPos, yPos + 1)) {
					yPos++;
					AP = AP - findCost(xPos, yPos);
					this.y = this.y + 32;
				}
				//velocity.y += _move_speed * FlxG.elapsed;
				
			}else if (FlxG.keys.justPressed("UP")) {
				/*if(yPos >= 1){
					yPos--;
					AP = AP - findCost();
					this.y = this.y - 32
				}else {
					errorMessage = "Invalid Move, reached top edge";
				}*/
				if (checkMove(xPos, yPos - 1)) {
					yPos--;
					AP = AP - findCost(xPos, yPos);
					this.y = this.y - 32;
				}
			}else if (FlxG.keys.justPressed("RIGHT")) {
				/*if(xPos < PlayState.myMap.widthInTiles - 1){
					xPos++;
					AP = AP - findCost();
					this.x = this.x + 32
				}else {
					errorMessage = "Invalid Move, reached right edge";
				}*/
				if (checkMove(xPos+1, yPos)) {
					xPos++;
					AP = AP - findCost(xPos, yPos);
					this.x = this.x + 32;
				}
				//velocity.x -= _move_speed * FlxG.elapsed;
			}else if (FlxG.keys.justPressed("LEFT")) {
				/*if(xPos >= 1){
					xPos--;
					AP = AP - findCost();
					this.x = this.x - 32
				}else {
					errorMessage = "Invalid Move, reached left edge";
				}*/
				if (checkMove(xPos - 1, yPos)) {
					xPos--;
					AP = AP - findCost(xPos, yPos);
					this.x = this.x - 32;
				}
				//velocity.x += _move_speed * FlxG.elapsed;
			}
			
			super.update();
		}
		
		private function findCost(proposedX:Number, proposedY:Number):Number {
			if (PlayState.myMap.getTile(proposedX, proposedY) == 1) {
				return 3;
			}else {
				return 1;
			}
		}
		private function checkMove(proposedX:Number, proposedY:Number):Boolean {
			if (PlayState.myMap.getTile(proposedX, proposedY) == 4) {
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