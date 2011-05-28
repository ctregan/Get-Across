package  
{
	import com.Logging.CGSClient;
	import flash.accessibility.Accessibility;
	import org.flixel.FlxState;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import org.flixel.system.input.Mouse;
	import playerio.Client;
	import playerio.DatabaseObject;
	import sample.ui.Alert;
	import sample.ui.components.*
	import com.Logging.*
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class MapEditorState extends FlxState
	{
		[Embed(source = "data/testTileSet4_32.png")] public var data_tiles:Class; //Tile Set Image
		[Embed(source = "data/Selected.png")] public var select:Class; 
		private static var TILE_VALUES:Array = ["Grass", "Hill", "Tree", "Cherry Tree", "River", "Star"];
		private var STAR_TILE:int = 4;
		private static var _tileSize:int = 32;
	
		private var _name:String
		private var _height:int
		private var _width:int
		private var map:FlxTilemap
		private var tileBrush:int = 0;
		private var myMouse:Mouse
		private var palet:FlxSprite
		private var title:FlxText
		private var selectedTile:FlxSprite
		private var _myClient:Client
		private var mainMenu:Box;
		private var instructions:FlxText;
		private var brushInfo:FlxText;
		private var startX:int = 0;
		private var startY:int = 0;
		private var logClient:CGSClient;
		
		public function MapEditorState(name:String, height:String, width:String, myClient:Client) 
		{
			logClient = new CGSClient(CGSClientConstants.URL, 5, 1, -2);
			_height = int(height);
			_width = int(width);
			_name = name;
			_myClient = myClient;
			
			FlxG.stage.addChild(new Alert("Welcome to the Map Editor! Use the palette to choose your tile, then click on the map to place.\n\nOnce you are done, hit upload!"));
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
			
			add(new Background("Faded"));
			
			FlxG.mouse.show();
			myMouse = FlxG.mouse;
			
			title = new FlxText(200, 5, 600, "Map Editor", true).setFormat(null, 25,0xff488921);
			add(title);
			
			instructions = new FlxText(400, 75, 300, "^^ Use this palette to choose your tile, then click on the map to place.\n\nOnce you are done, hit upload to save the map!", true).setFormat(null, 15, 0x33591d);
			add(instructions);
			
			brushInfo = new FlxText(400, 230, 300, "", true).setFormat(null, 15,0xff33591d);
			add(brushInfo);
			
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
				
				//Replace old start point with new one
				if (tileBrush == 5) {
					var mapArray:Array = map.getTileInstances(5);
					for (var x in mapArray) {
						map.setTileByIndex(mapArray[x], 0, true);
					}
					startX = selectedXTile;
					startY = selectedYTile;
				}
				
				map.setTile(selectedXTile, selectedYTile, tileBrush, true)
			}else if (myMouse.justPressed() && mouseWithinPalet()) {
				
				tileBrush = (myMouse.x - palet.x) / _tileSize;
				selectedTile.x = (tileBrush * _tileSize) + palet.x;
			}
			
			// update information about selected til
			switch (tileBrush)
			{
				case 0:
					brushInfo.text = "You currently have GRASS selected.\n\nGrass takes no AP to cross."
					break;
				case 1:
					brushInfo.text = "You currently have HILL selected.\n\nHills take 3 AP to cross."
					break;
				case 2:
					brushInfo.text = "You currently have TREE selected.\n\nTree takes no AP to cross.  It looks pretty cool, though."
					break;
				case 3:
					brushInfo.text = "You currently have CHERRY TREE selected.\n\nHarvest lumber or cherries from cherry tree for 1 AP.  Make sure players can access cherry trees to make bridges or food!"
					break;
				case 4:
					brushInfo.text = "You currently have STAR selected.\n\nPlayers need to reach this to win the level.  Make sure your map has one!"
					break;
				case 5:
					brushInfo.text = "You currently have Start SQUARE selected.\n\nIt takes no AP to cross.  Player will start here.";
					break;
				case 6:
					brushInfo.text = "You currently have VERTICAL BRIDGE selected.\n\nBridge allow players to cross over water for 1 AP."
					break;
				case 7:
					brushInfo.text = "You currently have HORIZONTAL BRIDGE selected.\n\nBridge allow players to cross over water for 1 AP."
					break;
				case 8:
					brushInfo.text = "You currently have WATER selected.\n\nPlayers can't cross water unless they build a bridge."
					break;
				case 9:
					brushInfo.text = "You currently have WATER selected.\n\nPlayers can't cross water unless they build a bridge."
					break;
				case 10:
					brushInfo.text = "You currently have WATER selected.\n\nPlayers can't cross water unless they build a bridge."
					break;
				case 11:
					brushInfo.text = "You currently have WATER selected.\n\nPlayers can't cross water unless they build a bridge."
					break;
				case 12:
					brushInfo.text = "You currently have WATER selected.\n\nPlayers can't cross water unless they build a bridge."
					break;
				case 13:
					brushInfo.text = "You currently have WATER selected.\n\nPlayers can't cross water unless they build a bridge."
					break;
				case 14:
					brushInfo.text = "You currently have WALL selected.\n\nPlayers can't get across walls."
					break;
				default:
					brushInfo.text = "You currently have a tile selected to paint with!  Go you, yeah!!"
					break;
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
			if (!mapHasEnd())
				FlxG.stage.addChild(new Alert("No one can complete this map if it doesn't have a goal!\n\nAdd a goal tile (the one with the red star) to the map!"));
			else {
				var newMap:DatabaseObject = new DatabaseObject();
				newMap.Name = _name;
				newMap.Creator = _myClient.connectUserId;
				newMap.tileValues = map.getMapData();
				newMap.XP = 0;
				newMap.Coin = 0;
				newMap.MonsterCount = 0;
				newMap.startX = startX;
				newMap.startY = startY;
				_myClient.bigDB.createObject("UserMaps", null, newMap, function() {
					FlxG.stage.addChild(new Alert("Map Uploaded"));
				});
				
				//
				var action:ClientAction = new ClientAction;
				action.uid = logClient.message.uid;	// what is this?
				logClient.SetUid(function f(d:String):void {
					//Starting level 1!
					//First we need a new dqid to associate with this play of the level.
					logClient.SetDqid(function f(d:String):void {				
						// report that this user has made this map! 
						logClient.ReportLevel(logClient.message.dqid, 0, function g(d:String):void {}, 3, newMap.Creator, newMap.Name);
					});
				});
			}
		}
		
		// returns true if map contains a star/end tile
		private function mapHasEnd():Boolean {
			var starTiles:Array = map.getTileInstances(STAR_TILE);
			return (starTiles != null);
		}
	}

}