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
		private var myPlayer:DatabaseObject;
		private var cancel:TextButton
		private var roomContainer:Rows;
		private var toolTip:FlxText
		
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
								cancel = new TextButton("Main Menu", hide)
							)				
						)
					)
				)
			)
			toolTip = new FlxText(375,50, 200, "", true).setFormat(null, 16)
			mainMenu.width = FlxG.stage.stageWidth / 2
			mainMenu.height = FlxG.stage.stageHeight
			refresh();
			FlxG.stage.addChild(mainMenu);
			add(toolTip);
		}
		private function refresh():void 
		{
			
			//TO DO ADD LOADING SCREEN!!!!!!!
			myClient.bigDB.loadMyPlayerObject(function(myPlayer:DatabaseObject) {
				this.myPlayer = myPlayer;
				var abilityArray:Array = myPlayer.abilities
				myClient.bigDB.loadRange("Abilities", "Class", null, myPlayer.role, myPlayer.role, 10, function(abarr:Array) {
					if (abarr.length == 0) {
						roomContainer.addChild(new Label("No Abilities Currently Available for " + myPlayer.role));
					}else{
						for (var x in abarr) {
							var contains:Boolean = false;
							for (var y in abilityArray) {
								if (abilityArray[y] == abarr[x].key) {
									contains = true;
								}
							}
							if (!contains) {
								var abilityE:AbilityEntry = new AbilityEntry(abarr[x].Name, abarr[x].key, abarr[x].cost, AbilitySelectCallback)
								abilityE.addEventListener(MouseEvent.MOUSE_OVER, function ():void 
								{
									toolTip.text = abarr[x].Name + "\n\n" + "Cost: " + abarr[x].cost + " Skill Points\n\n" + "Description:\n" + abarr[x].Description	
								})
								roomContainer.addChild(abilityE);
							}else {
								roomContainer.addChild(new AbilityEntry(abarr[x].Name, abarr[x].key, abarr[x].cost, AbilitySelectCallback, true));
							}
						}
					}
				});
			});
			
		}
		
		private function AbilitySelectCallback(key:String, cost:int) {
			if (myPlayer.sp >= cost) {
				var prompt:InGamePrompt = new InGamePrompt(FlxG.stage, "Are you sure?\n Cost: " + cost + " SP", function(){
					myPlayer.sp -= cost;
					Array(myPlayer.abilities).push(key);
					FlxG.flash(0xffffff,1,function() { FlxG.stage.addChild(new Alert("You have learned a new ability")) })
				});
			}else {
				FlxG.stage.addChild(new Alert("You do not have enough skill points!"));
			}
			
			
		}
		public function hide():void{
 			FlxG.stage.removeChild(mainMenu);
			kill();
			FlxG.switchState(new MenuState(myClient));
		}
		
	}

}