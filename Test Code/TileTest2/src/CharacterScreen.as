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
	import org.flixel.plugin.photonstorm.FlxHealthBar;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class CharacterScreen extends FlxState
	{
		private var mainMenu:Box
		private var myClient:Client;
		private var cancel:TextButton;
		private var save:TextButton;
		private var roomContainer:Rows;
		private var toolTip:FlxText;
		private var toolTipImage:FlxSprite;
		
		[Embed(source = "data/Planter2.png")] public var planterImg:Class;
		[Embed(source = "data/Cook2.png")] public var cookImg:Class;
		[Embed(source = "data/Crafter2.png")] public var crafterImg:Class;
		[Embed(source = "data/Novice2.png")] private var noviceImg:Class;
		[Embed(source = "data/Crafter_wrench.png")] public var crafterWrenchImg:Class;
		[Embed(source = "data/Crafter_hammer.png")] public var crafterHammerImg:Class;
		[Embed(source = "data/Cook_chef.png")] public var cookChefImg:Class;
		[Embed(source = "data/Cook_spaghetti.png")] public var cookSpaghettiImg:Class;
		[Embed(source = "data/Planter_tulips.png")] public var planterTulipsImg:Class;
		[Embed(source = "data/Planter_thorns.png")] public var planterThornsImg:Class;
		private static var currentItem:String;
		
		private static var titleLabel:Label;
		
		// stuff about the player on the right side of the screen
		private var playerClassImg:FlxSprite = new FlxSprite();
		private static var xpBar:FlxHealthBar;
		private static var xpText:FlxText;
		
		public function CharacterScreen(client:Client) 
		{
			add(new Background("Map"));
			myClient = client; 
			
			// info about character on right side of screen
			playerClassImg = new FlxSprite(450, 30, noviceImg);
			
			add(playerClassImg);
			
			roomContainer = new Rows().spacing(2);
			titleLabel = new Label("inventory", 30, TextFormatAlign.CENTER, 0xff488921);
			
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
								cancel = new TextButton("Cancel Changes", hide),
								save = new TextButton("Save Changes", saveChanges)
							)				
						)
					)
				)
			)
			
			toolTip = new FlxText(360, playerClassImg.y + 140,340, "", true).setFormat(null, 16);
			toolTipImage = new FlxSprite(375, 200, null);
			toolTipImage.visible = false;
			mainMenu.width = FlxG.stage.stageWidth / 2;
			mainMenu.height = FlxG.stage.stageHeight;
			refresh();
			FlxG.stage.addChild(mainMenu);
			add(toolTip);
			add(toolTipImage);
		}
		private function refresh():void 
		{
			roomContainer.removeChildren();
			//TO DO ADD LOADING SCREEN!!!!!!!
			myClient.bigDB.loadMyPlayerObject(function(myPlayer:DatabaseObject):void {
				
				// image of player avatar
				// if has costume, show; otherwise, just show basic class image
				if (myPlayer.costume != null) {
					switch (myPlayer.costume)
					{
						case "cook_normal":
							playerClassImg.loadGraphic(cookImg);
							break;
						case "spaghetti":
							playerClassImg.loadGraphic(cookSpaghettiImg);
							break;
						case "chef":
							playerClassImg.loadGraphic(cookChefImg);
							break;
						case "crafter_normal":
							playerClassImg.loadGraphic(crafterImg);
							break;
						case "wrench":
							playerClassImg.loadGraphic(crafterWrenchImg);
							break;
						case "hammer":
							playerClassImg.loadGraphic(crafterHammerImg);
							break;
						case "planter_normal":
							playerClassImg.loadGraphic(planterImg);
							break;
						case "tulips":
							playerClassImg.loadGraphic(planterTulipsImg);
							break;
						case "thorns":
							playerClassImg.loadGraphic(planterThornsImg);
							break;
						default:
							playerClassImg.loadGraphic(noviceImg);
							break;
					}
				}
				
				else {
					switch (myPlayer.role)
					{
						case "Planter":
							playerClassImg.loadGraphic(planterImg);
							break;
						case "Cook":
							playerClassImg.loadGraphic(cookImg);
							break;
						case "Crafter":
							playerClassImg.loadGraphic(crafterImg);
							break;
						default:
							playerClassImg.loadGraphic(noviceImg);
							break;
					}
				}
				
				var itemArray:Array = myPlayer.items;
				// make items array if player doesn't have one
				if (itemArray == null) {
					myPlayer.items = new Array();
					itemArray = myPlayer.items;
					myPlayer.save();
				}
				
				// show player's items
				if (itemArray.length == 0)
					roomContainer.addChild(new Label("You currently have no items!"));
					
				// show items player has
				else {
					// add inventory costumes
					for (var item in itemArray)
					{
						myClient.bigDB.load("StoreItems", itemArray[item], function (thisItem:DatabaseObject):void
						{
							roomContainer.addChild(new InventoryEntry(thisItem, toolTip, toolTipImage,useItem));
						}
						);
					}
				}
			});
		}
		
		// called when player wants to change into this item
		private function useItem(key:String, cost:int, type:String, value:String):void {
			if (value == currentItem)
				FlxG.stage.addChild(new Alert("You are already wearing this item!"));
			else {
				currentItem = value;
				// change user's image
				switch (value)
				{
					case "cook_normal":
						playerClassImg.loadGraphic(cookImg);
						break;
					case "spaghetti":
						playerClassImg.loadGraphic(cookSpaghettiImg);
						break;
					case "chef":
						playerClassImg.loadGraphic(cookChefImg);
						break;
					case "crafter_normal":
						playerClassImg.loadGraphic(crafterImg);
						break;
					case "wrench":
						playerClassImg.loadGraphic(crafterWrenchImg);
						break;
					case "hammer":
						playerClassImg.loadGraphic(crafterHammerImg);
						break;
					case "planter_normal":
						playerClassImg.loadGraphic(planterImg);
						break;
					case "tulips":
						playerClassImg.loadGraphic(planterTulipsImg);
						break;
					case "thorns":
						playerClassImg.loadGraphic(planterThornsImg);
						break;
					default:
						playerClassImg.loadGraphic(noviceImg);
						break;
				}
			}
		}
		
		// go back to main page without saving
		public function hide():void{
 			FlxG.stage.removeChild(mainMenu);
			kill();
			FlxG.switchState(new MenuState(myClient));
		}
		
		private function saveChanges():void {
			myClient.bigDB.loadMyPlayerObject(function(myPlayer:DatabaseObject):void {
				// set the player costume to the last set costume
				myPlayer.costume = currentItem;
				FlxG.stage.removeChild(mainMenu);
				kill();
				myPlayer.save();
				FlxG.stage.addChild(new Alert("Your changes were saved.",function():void{ FlxG.switchState(new MenuState(myClient));}));
			});
		}
		
		
	}

}