package  
{
	import flash.accessibility.Accessibility;
	import org.flixel.FlxState;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import org.flixel.system.input.Mouse;
	import playerio.Client;
	import playerio.DatabaseObject;
	import sample.ui.Alert;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class MapEditorState extends FlxState
	{
		[Embed(source = "data/testTileSet3_32.png")] public var data_tiles:Class; //Tile Set Image
		[Embed(source = "data/Selected.png")] public var select:Class; 
		private static var TILE_VALUES:Array = ["Grass", "Hill", "Tree", "Cherry Tree", "River", "Star"];
		private static var _tileSize:int = 32;
	
		private var _name:String
		private var _height:int
		private var _width:int
		private var map:FlxTilemap
		private var tileBrush:int = 0;
		private var myMouse:Mouse
		private var palet:FlxSprite
		private var message:FlxText
		private var selectedTile:FlxSprite
		private var _myClient:Client
		
		public function MapEditorState(name:String, height:String, width:String, myClient:Client) 
		{
			_height = int(height);
			_width = int(width);
			_name = name
			_myClient = myClient
			
			FlxG.stage.addChild(new Alert("Welcome to the Map Editor, Use the palet to chose your tile and click on the map to place. Once you are done hit upload"));
			//Make an all grass map
			var initialMapData:String = "";
			for (var h:int = 0; h < _height; h++) {
				for (var w:int = 0; w < _width; w++) {
					if (w == _width - 1) {
						initialMapData = initialMapData.concat("0\n");
					}else {
						initialMapData = initialMapData.concat("0,");
					}
				}
			}
			
			FlxG.mouse.show();
			myMouse = FlxG.mouse;
			
			message = new FlxText(200, 5, 600, "Map Editor", true).setFormat(null, 20)
			add(message);
			
			palet = new FlxSprite(20, 40, data_tiles)
			add(palet);
			
			selectedTile = new FlxSprite(20, 40, select)
			add(selectedTile);
			
			add(new FlxButtonPlus(10, 80, sendMapData, null, "Upload", 55, 40));
			add(new FlxButtonPlus(10, 130, back, null, "Main Menu", 55, 40));
			
			map = new FlxTilemap();
			map.loadMap(initialMapData, data_tiles, 32, 32,0, 0, 0, 6);
			map.x = 75;
			map.y = 80;
			add(map);
			
		
			
		}
		
		override public function update():void 
		{
			super.update();
			if (myMouse.justPressed() &&  mouseWithinTileMap()) {
				var selectedXTile:int = (myMouse.x - map.x) / _tileSize
				//(myMouse.x - (myMouse.x % 32)) / 32;
				var selectedYTile:int = (myMouse.y - map.y) / _tileSize
				//(myMouse.y - (myMouse.y % 32)) / 32
				//TO DO: ADD ALERT MESSAGE!!!
				map.setTile(selectedXTile, selectedYTile, tileBrush, true)
			}else if (myMouse.justPressed() && mouseWithinPalet()) {
				
				tileBrush = (myMouse.x - palet.x) / _tileSize;
				selectedTile.x = (tileBrush * _tileSize) + palet.x;
			}
		}
		//Changes the brush value to whatever tile value is sent in
		private function switchBrush(tileValue:int) {
			tileBrush = tileValue;
		}
		//Returns true if the mouse is within the tile map
		private function mouseWithinTileMap():Boolean
		{
			if (myMouse.x > map.x 
				&& myMouse.x < (map.x + map.width) 
				&& myMouse.y > map.y
				&& myMouse.y < (map.y + map.height )) {	
				return true;
			}
			return false;
		}
		//Returns true if the mouse is within the palet
		private function mouseWithinPalet():Boolean
		{
			if (myMouse.x > palet.x && myMouse.y > palet.y && myMouse.x < (palet.x + palet.width) && myMouse.y < (palet.y + palet.height)){	
				return true;
			}
			return false;
		}
		
		private function back():void {
			this.kill()
			FlxG.switchState(new MenuState(_myClient));
		}
		
		//Sends the data to the database and saves
		private function sendMapData():void {
			//TO DO - SEND THIS TO DATABASE AND SAVE
			var newMap:DatabaseObject = new DatabaseObject();
			newMap.Name = _name;
			newMap.Creator = _myClient.connectUserId
			newMap.tileValues = map.getMapData();
			newMap.XP = 0
			newMap.Coin = 0
			newMap.MonsterCount = 0
			_myClient.bigDB.createObject("UserMaps", null, newMap, function() {
				FlxG.stage.addChild(new Alert("Map Uploaded"));
			});
		}
	}

}