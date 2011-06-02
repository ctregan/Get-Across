package  
{
	import com.Logging.CGSClient;
	import Facebook.FB;
	import flash.accessibility.Accessibility;
	import flash.display.Sprite;
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
		[Embed(source = "data/testTileSet5_32.png")] public var data_tiles:Class; //Tile Set Image
		[Embed(source = "data/Selected.png")] public var select:Class; 
		[Embed(source = "data/Button.png")] public var button:Class; 
		[Embed(source = "data/Monster1.png")] public var monster:Class; 
		private static var TILE_VALUES:Array = ["Grass", "Hill", "Tree", "Cherry Tree", "River", "Star"];
		private var STAR_TILE:int = 4;
		private var STARTING_TILE:int = 5;
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
		private var Monsters:Array;
		private var MonsterIcon:FlxSprite
		private var MonsterCount:int = 0
		private var Buttons:Array;
		private var ButtonIcon:FlxSprite
		private var ButtonCount:int = 0;
		private var startY:int = 0;

		private var logClient:CGSClient;
		
		public function MapEditorState(name:String, height:String, width:String, myClient:Client) 
		{
			logClient = new CGSClient(CGSClientConstants.URL, 5, 1, 3);
			_height = int(height);
			_width = int(width);
			_name = name;
			_myClient = myClient;
			Monsters = new Array();
			Buttons = new Array();
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
			
			palet = new FlxSprite(5, 40, data_tiles)
			add(palet);
			
			selectedTile = new FlxSprite(5, 40, select)
			add(selectedTile);
			
			/*MonsterIcon = new FlxSprite(5, 72, monster);
			add(MonsterIcon);
			
			ButtonIcon = new FlxSprite(37, 72, button);
			add(ButtonIcon)*/
			
			add(new FlxButtonPlus(10, 130, sendMapData, null, "Upload", 55, 40));
			add(new FlxButtonPlus(10, 180, back, null, "Main Menu", 55, 40));
			
			map = new FlxTilemap();
			map.loadMap(initialMapData, data_tiles, 32, 32,0, 0, 0, 6);
			map.x = 75;
			map.y = 80;
			add(map);
		}
		
		override public function update():void 
		{
			super.update();
			/*if (myMouse.justPressed() && tileBrush == -3 && !mouseWithinTileMap()) {
				FlxG.stage.addChild(new Alert("You must place a gate for your button now"));
			}else*/
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
				/*else if (tileBrush == -1) {
					add(new FlxSprite((selectedXTile * _tileSize) + map.x, (selectedYTile * _tileSize) + map.y, monster));
					
					Monsters[MonsterCount] = new DatabaseObject();
					Monsters[MonsterCount].Type = "Weak";
					Monsters[MonsterCount].xTile = selectedXTile;
					Monsters[MonsterCount].yTile = selectedYTile;
					Monsters[MonsterCount].AP = 5;
					//Monsters[MonsterCount] = monsterObj;
					MonsterCount++;
					return;
				}else if (tileBrush == -2) {
					add(new FlxSprite((selectedXTile * _tileSize) + map.x, (selectedYTile * _tileSize) + map.y, button));
					var buttonObj:DatabaseObject = new DatabaseObject();
					buttonObj.xTile = selectedXTile;
					buttonObj.yTile = selectedYTile;
					Buttons[ButtonCount] = buttonObj;
					tileBrush = -3;
					return;
				}else if (tileBrush == -3) {
					var buttonObj:DatabaseObject = DatabaseObject(Buttons[ButtonCount]);
					buttonObj.xOpen = selectedXTile;
					buttonObj.yOpen = selectedYTile;
					Buttons[ButtonCount] = buttonObj;
					ButtonCount++;
					tileBrush = 14;
				}*/
				
				map.setTile(selectedXTile, selectedYTile, tileBrush, true)
			}else if (myMouse.justPressed() && mouseWithinPalet()) {
				
				tileBrush = (myMouse.x - palet.x) / _tileSize;
				selectedTile.x = (tileBrush * _tileSize) + palet.x;
				selectedTile.y = palet.y;
			}else if (myMouse.justPressed() && mouseWithinSprite(MonsterIcon)){
				tileBrush = -1;
				selectedTile.x = MonsterIcon.x
				selectedTile.y = MonsterIcon.y
			}else if(myMouse.justPressed() && mouseWithinSprite(ButtonIcon)){
				tileBrush = -2;
				selectedTile.x = ButtonIcon.x
				selectedTile.y = ButtonIcon.y
			}
			// update information about selected til
			switch (tileBrush)
			{
				case -2:
					brushInfo.text = "You currently have the BUTTON selected.\n\n Place the button then place the gate it will open!."
					break;
				case -1:
					brushInfo.text = "You currently have the MONSTER selected.\n\n This monster will have 5 AP."
					break;
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
					brushInfo.text = "You currently have START SQUARE selected.\n\nIt takes no AP to cross.  Player will start here.";
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
				case 15:
					brushInfo.text = "You currently have MOUNTAIN selected.\n\nPlayers can get only get across mountains if they have 15 AP!"
					break;
				case 16:
					brushInfo.text = "You currently have BOULDER selected.\n\nYou need a special ability to get over this heartbreakingly large boulder."
					break;
				case 17:
					brushInfo.text = "You currently have RUBBLE selected.\n\nThere used to be a boulder here.  Oh well."
					break;
				case 18:
					brushInfo.text = "You currently have BRAMBLE selected.\n\nIt's so spiky!  Ouch!  You need a special ability to get through it."
					break;
				case 20:
					brushInfo.text = "You currently have SNAKE selected.\n\nActually, it's a VERY HUNGRY SNAKE.  You need a special ability to make it not eat YOU."
					break;
				case 21:
					brushInfo.text = "You currently have HOLE selected.\n\nSnakes that have eaten their fill go take a nice nap."
					break;
				default:
					brushInfo.text = "You currently have a tile selected to paint with!  Go you, yeah!!"
					break;
			}
		}
		
		//Changes the brush value to whatever tile value is sent in
		private function switchBrush(tileValue:int):void {
			tileBrush = tileValue;
		}
		
		private function mouseWithinSprite(sprite:FlxSprite) {
			if (myMouse.x > sprite.x
				&& myMouse.x < (sprite.x + sprite.width)
				&& myMouse.y > sprite.y
				&& myMouse.y < (sprite.y + sprite.height)) {
					return true;
				}
				else {
					return false
				}
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
			FlxG.switchState(new OptionState(_myClient));
		}
		
		//Sends the data to the database and saves
		private function sendMapData():void {
			if (!mapHasEnd())
				FlxG.stage.addChild(new Alert("No one can complete this map if it doesn't have a goal!\n\nAdd a goal tile (the one with the red star) to the map!"));
			else if (!mapHasStart())
				FlxG.stage.addChild(new Alert("You don't have a start tile!  Why don't you put one down? (It's the tile with the yellow square.)"));
			else {
				var newMap:DatabaseObject = new DatabaseObject();
				newMap.Name = _name;
				newMap.Creator = _myClient.connectUserId;
				newMap.tileValues = map.getMapData();
				newMap.XP = 0;
				newMap.Coin = 0;
				newMap.MonsterCount = MonsterCount;
				//newMap.Monsters = new DatabaseObject();
				//newMap.Buttons = Buttons;
				newMap.startX = startX;
				newMap.startY = startY;
				_myClient.bigDB.createObject("UserMaps", null, newMap, function(o:DatabaseObject):void {
					FlxG.stage.addChild(new Alert("Map Uploaded", function():void{ back() }));
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
		
		private function mapHasStart():Boolean {
			var startTile:Array = map.getTileInstances(STARTING_TILE);
			return (startTile != null);
		}
	}

}