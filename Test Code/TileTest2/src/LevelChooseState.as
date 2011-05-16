package  
{
	import org.flixel.FlxState;
	import org.flixel.*;
	import playerio.*;
	import sample.ui.components.*;
	import sample.ui.*;
	import flash.text.TextFormatAlign;
	import sample.ui.components.scroll.ScrollBox
	import flash.events.Event
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
		private var base:Box 
		private var createDialog:Box
		private var loader:Box
		private var roomContainer:Rows
		private var cancel:TextButton
		private var currentLobby:Lobby;
		
		public function LevelChooseState(myClient:Client) 
		{
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
								cancel = new TextButton("Cancel", hide)
							)				
						)
					)
				)
			)
			refresh();
			realign();
			FlxG.stage.addChild(base);
		}
		private function refresh():void 
		{
			_client.bigDB.loadRange("UserMaps", "ByCreator", null, "A", "Z", 20, function(abarr:Array) {
				for (var x in abarr) {
					roomContainer.addChild(new LobbyEntry(abarr[x].Name, abarr[x].key, "user", mapSelectCallback));
				}
			});
		}
		
		private function mapSelectCallback(levelKey:String, mapType:String) {
			currentLobby = new Lobby(_client, "GetAcross", levelKey, mapType, handleJoin, handleError)
			
			FlxG.stage.addChild(currentLobby);
		}
		
		
		public function hide() {
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
			base.width = FlxG.stage.stageWidth
			base.height = FlxG.stage.stageHeight
						
		}
		
	}

}