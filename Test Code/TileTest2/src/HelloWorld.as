package  
{
	import org.flixel.*;
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.system.Security;
	
	[SWF(width="700", height="400", backgroundColor="#FFFFFF")] //Set the size and color of the Flash file

	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class HelloWorld extends FlxGame
	{
		private var kongregate:*;
		public function HelloWorld() 
		{
			var paramObj:Object = loaderInfo(root.loaderInfo).parameters;
			
			var apiPath:String = paramObj.Kongregate_api_path ||
			"http://www.kongregate.com/flash/API_AS3_Local.swf";
			
			Security.allowDomain(apiPath);
			
			var request:URLRequest = new URLRequest(apiPath);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.load(request);
			this.addChild(loader);
			
			
			
			// increasing the window size so that we'll have more space for extra stuff (like bigger map... 
			// Max map size is....?
			super(700, 800, LoginState,1);
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
				kongregate.services.showSignInBox();
			}else {
				//Get Kongregate user credentials
				var userid:String = kongregate.services.getUserId();
				var token:String = kongregate.services.getGameAuthToken();

				//Connect to Player.IO
				PlayerIO.quickConnect.kongregateConnect(
					FlxG.stage,
					"GetAcross", 
					userid, 
					token, 
					function(client:Client){
						super(700, 800, MenuState(client), 1);
					}, function(e:PlayerIOError){
						trace("Error: ", e)
					}
				);
			}
		 
			// You can now access the API via:
			// kongregate.services
			// kongregate.user
			// kongregate.scores
			// kongregate.stats
			// etc...
		}
		
		private function onKongregateInPageLogin(event:Event){
		  // Get the user's new login credentials
		  var userid:Number = kongregate.services.getUserId();
		  var token:String = kongregate.services.getGameAuthToken();
			 
		  // Log in with new credentials here
		  //Connect to Player.IO
			PlayerIO.quickConnect.kongregateConnect(
				FlxG.stage,
				"GetAcross", 
				userid, 
				token, 
				function(client:Client){
					super(700, 800, MenuState(client), 1);
				}, function(e:PlayerIOError){
					trace("Error: ", e)
				}
			);
		}
	}

}