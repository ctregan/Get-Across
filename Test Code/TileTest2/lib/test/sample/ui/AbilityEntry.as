package sample.ui{
	import flash.desktop.Clipboard;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import org.flixel.FlxG
	import org.flixel.FlxText;
	import sample.ui.components.*
	import playerio.*
	import flash.text.TextFormatAlign
	public class AbilityEntry extends Box {
		function AbilityEntry(ability:DatabaseObject, tooltip:FlxText, callback:Function, bought:Boolean = false) {
			super();
			var buyButton:TextButton;
			if (bought) {
				buyButton = new TextButton("Purchased", null);
				buyButton.enabled = false;
			}else {
				buyButton = new TextButton("Cost: " + ability.SPcost + " SP", function(){callback(ability.key, ability.SPcost)})
			}
			buyButton.addEventListener(MouseEvent.MOUSE_OVER, function ():void 
			{
				tooltip.text = ability.Name + "\n\n" + "Cost: " + ability.SPcost + " Skill Points\n\n" + "Description:\n" + ability.Description;
			})
			margin(1,1,1,1).minSize(40,35).add(
				new Box().margin(0,0,0,0).fill(0xEEEEEE,.2,10).border(1,0xBBBBBB,1).add(
					new Box().margin(NaN, NaN, NaN, 5).add(new Label(ability.Name))
				).add(
					new Box().margin(3,3,3).add(
						new Box().margin(0,0,0,0).minSize(100,0).add(
							buyButton	
						)
					)
				)
			)
		}
		
		
	}
}