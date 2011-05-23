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
			
			add(new FlxText(185, 10, 300, "Choose Your Class").setFormat(null, 25)); //Title
			/*
			****Cook Panel****
			*/
			add(new FlxText(90, 90, 100, "Cook").setFormat(null, 15, 0x000000));
			add(new FlxSprite(75, 150, cookImg));
			add(new FlxText(75, 275, 100, "Explanation Text"));
			add(new FlxButtonPlus(75, 350, chooseClass, [ "Cook" ], "Choose Cook"));
			
			/*
			****Crafter Panel****
			*/
			add(new FlxText(315, 90, 100, "Crafter").setFormat(null, 15, 0x000000));
			add(new FlxSprite(300, 150, crafterImg));
			add(new FlxText(300, 275, 100, "Explanation Text"));
			add(new FlxButtonPlus(300, 350, chooseClass, [ "Crafter" ], "Choose Crafter"));
			
			/*
			****Planter Panel****
			*/
			add(new FlxText(540, 90, 100, "Planter").setFormat(null, 15, 0x000000));
			add(new FlxSprite(525, 150, planterImg));
			add(new FlxText(525, 275, 100, "Explanation Text"));
			add(new FlxButtonPlus(525, 350, chooseClass, [ "Planter" ], "Choose Planter"));
			
			
			
		}
		
		private function chooseClass(classChoice:String):void 
		{
			var prompt:InGamePrompt = new InGamePrompt(FlxG.stage, "You Want to Choose the " + classChoice + "?", function() {
				_client.bigDB.loadMyPlayerObject(function (myPlayer:DatabaseObject):void 
				{
					myPlayer.role = classChoice;
					myPlayer.save();
				});
				FlxG.flash(0xFFFFFF, 1, function() {
					FlxG.switchState(new MenuState(_client));
					FlxG.stage.addChild(new Alert("You have chosen " + classChoice));
				});
				//TO-DO Update Database
			});
		}
		
	}

}