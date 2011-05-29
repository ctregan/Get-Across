package  
{
	import flash.desktop.Clipboard;
	import flash.display.TriangleCulling;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;
	import playerio.Client;
	import playerio.DatabaseObject;
	import sample.ui.Alert;
	import sample.ui.InGamePrompt;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class ClassChooseState extends FlxState
	{
		private var _client:Client;
		[Embed(source = "data/Planter2.png")] public var planterImg:Class;
		[Embed(source = "data/Cook2.png")] public var cookImg:Class;
		[Embed(source = "data/Crafter2.png")] public var crafterImg:Class;
		public function ClassChooseState(client:Client) 
		{
			_client = client;
			
			add(new Background("LevelChoose"));
			add(new FlxText(0, 0, 400, "You have: 3 SP").setFormat(null, 15, 0x000000)); //Title
			add(new FlxText(185, 15, 500, "Choose Your Class").setFormat(null, 35)); //Title
			/*
			****Cook Panel****
			*/
			add(new FlxText(90, 90, 100, "Cook").setFormat(null, 15, 0x000000));
			add(new FlxText(90, 110, 100, "Cost: 3 SP").setFormat(null, 12, 0x000000));
			add(new FlxSprite(75, 130, cookImg));
			add(new FlxText(45, 255, 155, "Cooks are masters of the culinary arts. A cook can create a wide array of treats to support friends or annoy foes.\n\nStarting Ability:\nMonster Bacon").setFormat(null, 8, 0x000000,"center"));
			add(new FlxButtonPlus(75, 350, chooseClass, [ "Cook" ], "Choose Cook"));
			
			/*
			****Crafter Panel****
			*/
			add(new FlxText(315, 90, 100, "Crafter").setFormat(null, 15, 0x000000));
			add(new FlxText(315, 110, 100, "Cost: 3 SP").setFormat(null, 12, 0x000000));
			add(new FlxSprite(300, 130, crafterImg));
			add(new FlxText(270, 255, 155, "Crafters are the masters of tools. A crafter can construct support structures to help ease any journey.\n\nStarting Ability:\nBuild Bridge").setFormat(null, 8, 0x000000,"center"));
			add(new FlxButtonPlus(300, 350, chooseClass, [ "Crafter" ], "Choose Crafter"));
			
			/*
			****Planter Panel****
			*/
			add(new FlxText(540, 90, 100, "Planter").setFormat(null, 15, 0x000000));
			add(new FlxText(540, 110, 100, "Cost: 3 SP").setFormat(null, 12, 0x000000));
			add(new FlxSprite(525, 130, planterImg));
			add(new FlxText(495, 255, 155, "Planters are attuned to nature. A planter can grow an assortment of flowers that can aid allies or create resources.\n\nStarting Ability:\nRed Flower").setFormat(null, 8, 0x000000,"center"));
			add(new FlxButtonPlus(525, 350, chooseClass, [ "Planter" ], "Choose Planter"));
			
			
			
		}
		
		private function chooseClass(classChoice:String):void 
		{
			var startingAbility:Array = new Array();
			if (classChoice == "Planter") {
				startingAbility[0] = "Planter_RedFlower"
			}else if (classChoice == "Crafter") {
				startingAbility[0] = "Crafter_Bridge"
			}else if (classChoice == "Cook") {
				startingAbility[0] = "Cook_MonsterBacon"
			}
			var prompt:InGamePrompt = new InGamePrompt(FlxG.stage, "You Want to Choose the " + classChoice + "?", function():void {
				_client.bigDB.loadMyPlayerObject(function (myPlayer:DatabaseObject):void 
				{
					myPlayer.role = classChoice;
					myPlayer.level = 1;
					myPlayer.xp = 0;
					myPlayer.sp = 0;
					myPlayer.abilities = startingAbility;
					myPlayer.save();
				});
				FlxG.flash(0xFFFFFF, 1, function():void {
					FlxG.stage.addChild(new Alert("Congratulations!  You are now a " + classChoice));
					FlxG.switchState(new MenuState(_client));
				});
			});
		}
		
	}

}