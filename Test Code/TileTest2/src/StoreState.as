package  
{
	import com.Logging.ClientAction;
	import flash.events.MouseEvent;
	import sample.ui.*
	import sample.ui.components.*;
	import sample.ui.components.scroll.ScrollBox;
	import org.flixel.*;
	import playerio.*;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class StoreState extends FlxState
	{
		private var mainMenu:Box
		private var myClient:Client;
		private var cancel:TextButton
		private var roomContainer:Rows;
		private var toolTip:FlxText;
		private var coinCount:FlxText;
		private var toolTipImage:FlxSprite;
		
		public function StoreState(client:Client) 
		{
			add(new Background("Map"));
			myClient = client; 
			roomContainer = new Rows().spacing(2);
			var titleLabel:Label = new Label("General Store", 30, TextFormatAlign.CENTER, 0xff488921);
			
			mainMenu = new Box().fill(0xffffff,.8).margin(20,20,20,20).add(
				new Box().fill(0x000000,.5,10).margin(10,10,10,10).add(
					new Box().fill(0xffffff,1,5).margin(10,10,10,10).add(
						titleLabel
					).add(
						new Box().margin(35,0,35,0).add(
							new Box().margin(0,0,0,0).fill(0x0,0,10).border(1,0x555555,1).add(
								new ScrollBox().margin(3,1,3,3).add(roomContainer)
							)
						)
					).add(
						new Box().margin(NaN,0,0,0).add(
							new Columns().spacing(10).add(
								cancel = new TextButton("Back to Main Menu", hide)
							)				
						)
					)
				)
			)
			
			coinCount = new FlxText(375, 20, 300, "", true).setFormat(null, 20);
			toolTip = new FlxText(375, 70,300, "", true).setFormat(null, 16);
			toolTipImage = new FlxSprite(375, 200, null);
			toolTipImage.visible = false;
			mainMenu.width = FlxG.stage.stageWidth / 2;
			mainMenu.height = FlxG.stage.stageHeight;
			refresh();
			FlxG.stage.addChild(mainMenu);
			add(toolTip);
			add(coinCount);
			add(toolTipImage);
		}
		private function refresh():void 
		{
			roomContainer.removeChildren();
			//TO DO ADD LOADING SCREEN!!!!!!!
			myClient.bigDB.loadMyPlayerObject(function(myPlayer:DatabaseObject):void {
				coinCount.text = "You Have " + myPlayer.coin + " Coins";
				
				if (myPlayer.coin == 0)
					FlxG.stage.addChild(new Alert("You can't buy anything without coins!  Play some games to get more!"))
					var itemArray:Array = myPlayer.items;
					if (itemArray == null) {
						myPlayer.items = new Array();
						itemArray = myPlayer.items;
						myPlayer.save();
					}
					myClient.bigDB.loadRange("StoreItems", "ByClass", null, myPlayer.role, myPlayer.role, 10, function(abarr:Array):void {
					trace("abarr length: " + abarr.length);
					if (abarr.length == 0) {
						roomContainer.addChild(new Label("Sorry, no Items are Currently Available for " + myPlayer.role + "!"));
					}else{
						for (var x in abarr) {
							var contains:Boolean = false;
							for (var y in itemArray) {
								if (itemArray[y] == abarr[x].key) {
									contains = true;
								}
							}
							if (!contains) {
								var itemE:ItemEntry = new ItemEntry(abarr[x], toolTip, toolTipImage, ItemSelectCallback)
								roomContainer.addChild(itemE);
							}else {
								roomContainer.addChild(new ItemEntry(abarr[x], toolTip, toolTipImage, ItemSelectCallback, true));
							}
						}
					}
				});
			});
			
		}
		
		private function ItemSelectCallback(key:String, cost:int, type:String, value:String) {
			myClient.bigDB.loadMyPlayerObject(function(myPlayer:DatabaseObject):void {
				if (myPlayer.coin >= cost) {
					var prompt:InGamePrompt = new InGamePrompt(FlxG.stage, "Are you sure?\n Cost: " + cost + " Coins", function():void{
						myPlayer.coin -= cost;
						var skin:String = myPlayer.skin
						skin = value;
						myPlayer.items.push(key);
						myPlayer.save();
						FlxG.flash(0xffffff, 1, function():void { FlxG.stage.addChild(new Alert("You have bought a new item")); refresh(); } )
					});
				}else {
					FlxG.stage.addChild(new Alert("You do not have enough coins!  You'll need " + (cost - myPlayer.coin) + " more!"));
				}
			});
			
			
		}
		public function hide():void{
 			FlxG.stage.removeChild(mainMenu);
			kill();
			FlxG.switchState(new MenuState(myClient));
		}
		
	}

}