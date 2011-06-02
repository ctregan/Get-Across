package  
{
	import flash.display.SimpleButton;
	import flash.geom.Rectangle;
	import flash.sampler.Sample;
	import flash.utils.SetIntervalTimer;
	import org.flixel.FlxState;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;
	import playerio.*;
	import sample.ui.components.*;
	import sample.ui.*;
	import flash.text.TextFormatAlign;
	import sample.ui.components.scroll.ScrollBox
	import flash.events.Event
	import sample.ui.components.scroll.ScrollButton;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class LevelChooseState extends FlxState
	{
		private var _roomType:String
		private var _handleJoin:Function
		private var _handleJoinError:Function
		private var _client:Client
		private var _levelKey:String
		private var _type:String
		private var base:Box 
		private var createDialog:Box
		private var loader:Box
		private var roomContainer:Rows
		private var cancel:TextButton
		private var currentLobby:Lobby;
		
		
		private var up_button:ScrollButton;
		private var down_button:ScrollButton;
		
		//[Embed(source = "data/up_button.png")] private static var upButtonImg:Class;
		//[Embed(source = "data/down_button.png")] private static var downButtonImg:Class;
		//[Embed(source = "data/up_button_down.png")] private static var upButtonHoverImg:Class;
		//[Embed(source = "data/down_button_hover.png")] private static var downButtonHoverImg:Class;		
		public function LevelChooseState(myClient:Client, type:String ) 
		{
			_type = type;
			roomContainer = new Rows().spacing(2);
			_client = myClient;
			
			base = new Box().fill(0xffffff,.8).margin(20,20,20,20).add(
				new Box().fill(0x000000,.5,10).margin(10,10,10,10).add(
					new Box().fill(0xffffff,1,5).margin(10,10,10,10).add(
						new Label("Select Map", 20, TextFormatAlign.LEFT)
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
							//).add(
							//	new TextButton("down", scrollDown)
							//).add(
							//	new TextButton("up", scrollUp)
							)
						)
					)
				)
			)
			//sb.scrollRect = new Rectangle(0, 0, 100, 200);
			//roomContainer.y = 40;
			// add up/down buttons
			
			up_button = new ScrollButton(1, 25, scrollUp);
			up_button.x = 600;
			up_button.y = 42;
			down_button = new ScrollButton(3, 25, scrollDown);
			down_button.x = 630;
			down_button.y = 42;

			//add(down_button);
			refresh();
			realign();
			base.addChild(up_button);
			base.addChild(down_button);
			FlxG.stage.addChild(base);		
		}
		private function scrollUp():void {
			// the first 200y of the container, or 40+ than before
			//roomContainer.y = Math.max(roomContainer.height - 200, roomContainer.y + 40);	
			if (roomContainer.y < roomContainer.height - 540) 
				roomContainer.y += 40;
			//else roomContainer.y = 0;
		}
		
		private function scrollDown():void {
			if (roomContainer.y > -1 * roomContainer.height + 350) 
				roomContainer.y -= 40;
			//roomContainer.y = Math.min(-1 * roomContainer.height + 200, roomContainer.y - 40);						
		}
		
		private function refresh():void 
		{
			if(_type == "User"){
				_client.bigDB.loadRange("UserMaps", "ByCreator", null, "A", "Z", 20, function(abarr:Array):void {
					for (var x in abarr) {
						roomContainer.addChild(new LobbyEntry(abarr[x].Name, abarr[x].key, "user", mapSelectCallback));
					}
				});
			}else {
				_client.bigDB.loadRange("StaticMaps", "ByType",null, _type, _type, 20, function(abarr:Array):void {
					for (var x in abarr) {
						roomContainer.addChild(new LobbyEntry(abarr[x].Name, abarr[x].key, "Static", mapSelectCallback));
					}
				});
			}
		}
		
		private function mapSelectCallback(levelKey:String, mapType:String):void {
			currentLobby = new Lobby(_client, "GetAcross", levelKey, mapType, handleJoin, handleError)
			
			FlxG.stage.addChild(currentLobby);
		}
		
		
		public function hide():void {
			FlxG.stage.removeChild(base);
			if(currentLobby != null){
				currentLobby.hide();
			}
			//if(this.parent) _stage.removeChild(this);
			kill();
			FlxG.switchState(new MenuState(_client));
		}
		
		//Callback function for LOBBY, once it has connected to a game
		private function handleJoin(connection:Connection):void 
		{
			FlxG.stage.removeChild(base);
			currentLobby.hide();
			FlxG.switchState( new PlayState(connection, _client))
			//FlxG.stage.removeChild(this);
			
			//FlxG.stage.removeChild(loader);
		}
		
		//Callback function for LOBBY, if it has encountered an error
		private function handleError(error:PlayerIOError):void{
			trace("Got", error)
			//FlxG.state = new LoginState()
		}
		
		private function realign(e:Event = null):void{
			
			//base.reset();
			base.width = 700;// FlxG.stage.stageWidth
			base.height = 400;// FlxG.stage.stageHeight
						
		}
		
	}

}