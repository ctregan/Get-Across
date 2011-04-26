package  
{
	import org.flixel.*;
	import org.flixel.data.FlxMouse;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class PlayState extends FlxState
	{
		[Embed(source = "data/map_data.txt", mimeType = "application/octet-stream")] public var data_map:Class;
		[Embed(source = "data/testTileSet.png")] public var data_tiles:Class;
		[Embed(source = "data/Cursor.png")] public var cursor_img:Class;
		private var apInfo:FlxText;
		private var myPlayer:Player;
		private var myMouse:FlxMouse;
		private var errorMessage:FlxText;
		private var secCounter:FlxText;
		private var location:FlxText;
		private var mouseLocation:FlxText;
		private var counter:Number;

		public static var myMap:FlxTilemap;
		
		public static var lyrStage:FlxGroup;
        public static var lyrSprites:FlxGroup;
        public static var lyrHUD:FlxGroup;
		

		public function PlayState():void
		{
			super();
			
			counter = 15; //15 sec/1ap
			
			myMouse = FlxG.mouse;
			FlxG.mouse.show(null, 0, 0);
			
			lyrStage = new FlxGroup; //Map exists here
            lyrSprites = new FlxGroup; //Character Sprites exist here
            lyrHUD = new FlxGroup; //HUD elements exist here
			
			myMap = new FlxTilemap();
			myMap.drawIndex = 0;
			myMap.loadMap(new data_map, data_tiles, 32, 32);
			myMap.collideIndex = 1;
			lyrStage.add(myMap);
			
			myPlayer = new Player(0,0);
			lyrSprites.add(myPlayer);
			
			apInfo = new FlxText(0, (myMap.heightInTiles * 32), 100, "AP:" + myPlayer.AP, true);
			errorMessage = new FlxText(0, ((myMap.heightInTiles - 1) * 32) + 60, 120, "Errors Appear Here", true);
			location = new FlxText(150, ((myMap.heightInTiles - 1) * 32) + 40, 100, "(0,0)", true);
			mouseLocation = new FlxText(150, ((myMap.heightInTiles - 1) * 32) + 60, 200, "(0,0)", true);
			secCounter = new FlxText(200, ((myMap.heightInTiles - 1) * 32) + 40, 100, "15 Sec until AP", true);
			
			lyrHUD.add(secCounter);
			lyrHUD.add(location);
			lyrHUD.add(errorMessage);
			lyrHUD.add(apInfo);
			lyrHUD.add(mouseLocation);
		
			
			this.add(lyrStage);
            this.add(lyrSprites);
            this.add(lyrHUD);


		}
		
		override public function update():void 
		{
			counter -= FlxG.elapsed;
			if (counter <= 0)
			{
				// After 2 seconds has passed, the timer will reset.
				myPlayer.AP++;
				counter = 15;
			}
			secCounter.text = counter.toPrecision(3) + " Sec until AP";
			apInfo.text = "AP:" + myPlayer.AP;
			location.text = "(" + myPlayer.xPos + "," + myPlayer.yPos + ")";
			errorMessage.text = "" + myPlayer.errorMessage;
			mouseLocation.text = tileInformation(myMap.getTile(myMouse.x / 32, myMouse.y / 32));
			super.update();
		}
		
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
		
	}

}