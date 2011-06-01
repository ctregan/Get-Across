package  
{
	import flash.display.LoaderInfo;
	import flash.utils.setTimeout;
	import flash.utils.clearInterval;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.external.ExternalInterface;
	import org.flixel.FlxState;
	import playerio.*;
	import org.flixel.FlxG
	import Facebook.FB
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class FacebookLoadState extends FlxState
	{
		//Type in your information here for debugging and playing the game outside Facebook
		private var gameid:String = "get-across-ynrpgn4egdtvzlz3wg8w"
		private var app_id:String = "186539088062045"
		private var show_id:String = "" //Insert a facebook id here if you wish to emulate viewing a player
		private var parameters:Object = null

		
		public function FacebookLoadState() 
		{
			//Get flashvars
			parameters = LoaderInfo(FlxG.stage.loaderInfo).parameters;
			
			//Set default arguments if no parameters is parsed to the game
			gameid = parameters.sitebox_gameid || gameid
			app_id = parameters.fb_application_id || app_id
			show_id = parameters.querystring_id || show_id
			
			//isshow = show_id != ""
			
			//If played on facebook
			if(parameters.fb_access_token){
				//Connect in the background
				PlayerIO.quickConnect.facebookOAuthConnect(
					FlxG.stage,
					gameid,
					parameters.fb_access_token,
					null,
					function(c:Client, id:String=""):void{
						handleConnect(c, parameters.fb_access_token, id)
					},
					handleError);
			}else{
				//Else we are in development, connect with a facebook popup
				PlayerIO.quickConnect.facebookOAuthConnectPopup(
					FlxG.stage,
					gameid,
					"_blank",
					[],
					null,						//Current PartnerPay partner.
					handleConnect, 
					handleError
				);
			}
		}
		
		private function handleConnect(client:Client,access_token:String, id:String = ""):void{
			trace(">> Connected to Player.IO Webservices")
			
			//Init the AS3 Facebook Graph API
			FB.init( { access_token:access_token, app_id:app_id, debug:true } )
			client.bigDB.loadMyPlayerObject(function(myPlayer:DatabaseObject) {
				if (myPlayer.level == null) {
					myPlayer.level = 1;
					myPlayer.role = "Novice";
					myPlayer.tutorial = 1;
					myPlayer.xp = 0;
					myPlayer.coin = 0;
					myPlayer.sp = 0;
					myPlayer.save(function() {
						FlxG.switchState(new MenuState(client));
					});
				}else {
					//hideLoader();
					FlxG.switchState(new MenuState(client));
				}
			});
			
		}
		
		//Handle errors
		private function handleError(e:Error):void{
			trace("got", e)
		}
		
	}

}