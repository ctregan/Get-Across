package sample.ui{
	import flash.desktop.Clipboard;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import org.flixel.FlxG
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import sample.ui.components.*
	import playerio.*
	import flash.text.TextFormatAlign
	public class InventoryEntry extends Box {
		function InventoryEntry(item:DatabaseObject, tooltip:FlxText, toolTipImage:FlxSprite, callback:Function) {
			super();
			var useButton:TextButton = new TextButton("Use item", function(){callback(item.key, item.coinCost, item.Type, item.Image)})
			useButton.addEventListener(MouseEvent.MOUSE_OVER, function ():void 
			{
				tooltip.text = item.Name + "\n\n" + "Cost: " + item.coinCost + " Coins\n\n" + "Description:\n" + item.Description;
			})
			margin(1,1,1,1).minSize(40,35).add(
				new Box().margin(0,0,0,0).fill(0xEEEEEE,.2,10).border(1,0xBBBBBB,1).add(
					new Box().margin(NaN, NaN, NaN, 5).add(new Label(item.Name))
				).add(
					new Box().margin(3,3,3).add(
						new Box().margin(0,0,0,0).minSize(100,0).add(
							useButton	
						)
					)
				)
			)
		}
		
		
	}
}