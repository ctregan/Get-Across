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
	public class AbilitySelectState extends FlxState
	{
		private var mainMenu:Box
		private var myClient:Client;
		private var cancel:TextButton
		private var roomContainer:Rows;
		private var toolTip:FlxText;
		private var spCount:FlxText;
		
		public function AbilitySelectState(client:Client) 
		{
			add(new Background("Map"));
			myClient = client; 
			roomContainer = new Rows().spacing(2);
			var titleLabel:Label = new Label("Ability Store", 40, TextFormatAlign.CENTER, 0xff488921);
			
			mainMenu = new Box().fill(0xffffff,.8).margin(20,20,20,20).add(
				new Box().fill(0x000000,.5,10).margin(10,10,10,10).add(
					new Box().fill(0xffffff,1,5).margin(10,10,10,10).add(
						new Label("Ability Store", 30, TextFormatAlign.LEFT)
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
			spCount = new FlxText(375, 20, 200, "", true).setFormat(null, 20);
			toolTip = new FlxText(375, 70, 200, "", true).setFormat(null, 16);
			mainMenu.width = FlxG.stage.stageWidth / 2;
			mainMenu.height = FlxG.stage.stageHeight;
			refresh();
			FlxG.stage.addChild(mainMenu);
			add(toolTip);
			add(spCount);
		}
		private function refresh():void 
		{
			//TO DO ADD LOADING SCREEN!!!!!!!
			myClient.bigDB.loadMyPlayerObject(function(myPlayer:DatabaseObject):void {
				spCount.text = "You Have " + myPlayer.sp + " SP";
				
				if (myPlayer.sp == 0)
					FlxG.stage.addChild(new Alert("You can't gain new abilities with only 0 SP!  Play some games to get more!"))
				var abilityArray:Array = myPlayer.abilities;
				myClient.bigDB.loadRange("Abilities", "Class", null, myPlayer.role, myPlayer.role, 10, function(abarr:Array):void {
					trace("abarr length: " + abarr.length);
					if (abarr.length == 0) {
						roomContainer.addChild(new Label("Sorry, no Abilities Currently Available for " + myPlayer.role + "!"));
					}else{
						for (var x in abarr) {
							var contains:Boolean = false;
							for (var y in abilityArray) {
								if (abilityArray[y] == abarr[x].key) {
									contains = true;
								}
							}
							if (!contains) {
								var abilityE:AbilityEntry = new AbilityEntry(abarr[x].Name, abarr[x].key, abarr[x].SPcost, AbilitySelectCallback)
								abilityE.addEventListener(MouseEvent.MOUSE_OVER, function ():void 
								{
									trace("hovering over ability " + x + ", " + abarr[x].Name);
									toolTip.text = abarr[x].Name + "\n\n" + "Cost: " + abarr[x].SPcost + " Skill Points\n\n" + "Description:\n" + abarr[x].Description;
								})
								roomContainer.addChild(abilityE);
							}else {
								trace("not adding event listener for " + x);
								roomContainer.addChild(new AbilityEntry(abarr[x].Name, abarr[x].key, abarr[x].SPcost, AbilitySelectCallback, true));
							}
						}
					}
				});
			});
			
		}
		
		private function AbilitySelectCallback(key:String, cost:int) {
			myClient.bigDB.loadMyPlayerObject(function(myPlayer:DatabaseObject):void {
				if (myPlayer.sp >= cost) {
					var prompt:InGamePrompt = new InGamePrompt(FlxG.stage, "Are you sure?\n Cost: " + cost + " SP", function():void{
						myPlayer.sp -= cost;
						var abilities:Array = myPlayer.abilities
						abilities.push(key);
						myPlayer.save();
						FlxG.flash(0xffffff,1,function():void { FlxG.stage.addChild(new Alert("You have learned a new ability")) })
					});
				}else {
					FlxG.stage.addChild(new Alert("You do not have enough skill points!  You'll need " + (cost - myPlayer.sp) + " more!"));
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