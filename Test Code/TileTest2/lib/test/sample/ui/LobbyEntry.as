package sample.ui{
	import flash.desktop.Clipboard;
	import org.flixel.FlxG
	import sample.ui.components.*
	import playerio.*
	import flash.text.TextFormatAlign
	public class LobbyEntry extends Box {
		function LobbyEntry(labelString:String, levelKey:String, mapType:String, callback:Function){
			super();
			margin(1,1,1,1).minSize(40,35).add(
				new Box().margin(0,0,0,0).fill(0xEEEEEE,.2,10).border(1,0xBBBBBB,1).add(
					new Box().margin(NaN,NaN,NaN,5).add(new Label(labelString))
				).add(
					new Box().margin(3,3,3).add(
						new Box().margin(0,0,0,0).minSize(200,0).add(
								new TextButton("Select This Map", function(){callback(levelKey, mapType)})
						)
					)
				)
			)
		}
		
		
	}
}