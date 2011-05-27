package  
{
	import org.flixel.*;
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.system.Security;
	import playerio.*;
	import sample.ui.components.*;
	import sample.ui.*;
	import sample.ui.InGamePrompt;
	
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class KongregateLoadState extends FlxState
	{
		private var loaderBox:Box
		private var kongregate:*;
		private var words:Label;
				
		public function KongregateLoadState() 
		{
			words = new Label("Loading", 20);
			loaderBox = new Box().fill(0xffffff,.8).add(
				words
			).add(
				new Box().margin(20).add(new Label("Attempting to Log In...", 12))
			)
			loaderBox.width = FlxG.stage.stageWidth;
			loaderBox.height = FlxG.stage.stageHeight;
			showLoader();
			
			var paramObj:Object = LoaderInfo(FlxG.stage.loaderInfo).parameters;
			
			var apiPath:String = paramObj.kongregate_api_path ||
			"http://www.kongregate.com/flash/API_AS3_Local.swf";
			
			Security.allowDomain(apiPath);
			
			var request:URLRequest = new URLRequest(apiPath);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.load(request);
			FlxG.stage.addChild(loader);
		}
		// This function is called when loading is complete
		private function loadComplete(event:Event):void
		{
			// Save Kongregate API reference
			kongregate = event.target.content;
			// Connect to the back-end
			kongregate.services.connect();
			kongregate.services.addEventListener("login", onKongregateInPageLogin);
			var isGuest:Boolean = kongregate.services.isGuest();
			
			if (isGuest) {
				var prompt:InGamePrompt = new InGamePrompt(FlxG.stage,"Would you like to use your Kongregate Login?", function(){
				kongregate.services.showSignInBox();
				}, function() {
					hideLoader();
					FlxG.switchState(new LoginState());
				});
				
				
			}else {
				//Get Kongregate user credentials
				var userid:String = kongregate.services.getUserId();
				var token:String = kongregate.services.getGameAuthToken();
				//Connect to Player.IO
				PlayerIO.quickConnect.kongregateConnect(
					FlxG.stage,
					"get-across-ynrpgn4egdtvzlz3wg8w", 
					userid, 
					token, 
					loginSuccess,
					function(e:PlayerIOError){
						trace("Error: ", e)
					}
				);
			}
		 
		}
		
		private function onKongregateInPageLogin(event:Event){
		  // Get the user's new login credentials
		  var userid:String = kongregate.services.getUserId();
		  var token:String = kongregate.services.getGameAuthToken();
			 
		  // Log in with new credentials here
		  //Connect to Player.IO
			PlayerIO.quickConnect.kongregateConnect(
				FlxG.stage,
				"get-across-ynrpgn4egdtvzlz3wg8w", 
				userid, 
				token, 
				loginSuccess, 
				function(e:PlayerIOError){
					trace("Error: ", e)
				}
			);
		}
		
		private function loginSuccess(client:Client) {
			hideLoader();
			client.bigDB.loadMyPlayerObject(function(myPlayer:DatabaseObject) {
				if (myPlayer.level == null) {
					myPlayer.level = 1;
					myPlayer.role = "Novice";
					myPlayer.tutorial = 1;
					myPlayer.xp = 0;
					myPlayer.coin = 0;
					myPlayer.save(function() {
						
						FlxG.switchState(new MenuState(client));
					});
				}else {
					//hideLoader();
					FlxG.switchState(new MenuState(client));
				}
			});
		}
		private function showLoader():void{
			FlxG.stage.addChild(loaderBox)
		}

		private function hideLoader():void{
			if(loaderBox.parent)FlxG.stage.removeChild(loaderBox)
		}
		
	}

}