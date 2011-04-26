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
				if (checkMove(xPos, yPos + 1)) {
					yPos++;
					AP = AP - findCost(xPos, yPos);
					this.y = this.y + 32;
				}
			}else if (FlxG.keys.justPressed("UP")) {
				if (checkMove(xPos, yPos - 1)) {
					yPos--;
					AP = AP - findCost(xPos, yPos);
					this.y = this.y - 32;
				}
			}else if (FlxG.keys.justPressed("RIGHT")) {
				if (checkMove(xPos+1, yPos)) {
					xPos++;
					AP = AP - findCost(xPos, yPos);
					this.x = this.x + 32;
				}
			}else if (FlxG.keys.justPressed("LEFT")) {
				if (checkMove(xPos - 1, yPos)) {
					xPos--;
					AP = AP - findCost(xPos, yPos);
					this.x = this.x - 32;
				}
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