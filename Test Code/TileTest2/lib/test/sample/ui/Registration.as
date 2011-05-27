package sample.ui{
	import flash.display.Sprite
	import flash.display.Stage
	import flash.events.Event
	import flash.text.TextFormatAlign
	import org.flixel.FlxState
	import playerio.*
	import flash.events.MouseEvent
	
	import sample.ui.components.*
	
	import org.flixel.FlxG;
	
	public class Registration extends Sprite{
		private var _stage:Box
		private var accountCreateBox:Box;
		//Error messages
		private var pwdError:Label
		private var usernameError:Label
		private var emailError:Label
		private var errorMessage:Label //Gerneral Error Message
		//Text inputs to be accessed directly
		private var passwordInput:Input
		private var usernameInput:Input
		private var emailInput:Input
		
	
		
		function Registration(stage:Box){
			_stage = stage
			
			//Error messages
			pwdError = new Label("",12, TextFormatAlign.RIGHT, 0xff0000)
			usernameError = new Label("", 12, TextFormatAlign.RIGHT,  0xff0000)
			emailError = new Label("", 12, TextFormatAlign.RIGHT, 0xff0000)
			//Text inputs to be accessed directly
			passwordInput = new Input("", 12, TextFormatAlign.LEFT,  true)
			usernameInput = new Input("", 12, TextFormatAlign.LEFT)
			emailInput = new Input("", 12, TextFormatAlign.LEFT)
			passwordInput.height = 20;
			usernameInput.height = 20;
			emailInput.height = 20;
			
			//Error
			errorMessage = new Label("", 12, TextFormatAlign.CENTER, 0xFF0000, true);
			errorMessage.width = 100;
		
			accountCreateBox = new Box().fill(0xFFFFFF,0.8).add(
			new Box().fill(0x000000,.5,15).margin(10,10,10,10).minSize(300,0).add(
				new Box().fill(0xffffff,1,5).margin(10,10,10,10).minSize(300,0).add(
					new Rows(
						new Label("Account Creation",20, TextFormatAlign.CENTER),
						new Columns().margin(0, 5, 0, 5).spacing(3).add(
							new Label("Username",12, TextFormatAlign.RIGHT),
							usernameInput
						),
						usernameError,
						new Columns().margin(0,5,0,5).spacing(3).add(
							new Label("Password",12, TextFormatAlign.RIGHT),
							passwordInput
						),
						pwdError,
						new Columns().margin(0,5,0,5).spacing(3).add(
							new Label("Email",12, TextFormatAlign.RIGHT),
							emailInput
						),
						emailError,
						errorMessage,
						new Columns().margin(10).spacing(10).add(
							new TextButton("Cancel", function() {
								removeChild(accountCreateBox);
							} ),
							new TextButton("Create Account", function() {
								if (usernameInput.getRawText() == "") {
									errorMessage.text = "Please Enter a Username";
								}else if (passwordInput.getRawText() == "") {
									errorMessage.text = "Please Enter a Password";
								}else if (emailInput.getRawText() == "") {
									errorMessage.text = "Please Enter an Email Address";
								}else {
									createAccount(passwordInput.getRawText(), usernameInput.getRawText(), emailInput.getRawText());
									realign()
								}
								 
							})
						)
					).spacing(25)
				)
			))
			addChild(accountCreateBox)
			realign();
		}
		
		public function Show(e:Event = null):void{
			FlxG.stage.addChild(this);
			FlxG.stage.addEventListener(Event.RESIZE, realign)
			realign()
		}
		
		public function Hide(e:Event = null):void{
 			FlxG.stage.removeChild(this);
			FlxG.stage.removeEventListener(Event.RESIZE, realign)
		}
		
		private function realign(e:Event = null){
			
			accountCreateBox.reset();
			accountCreateBox.width = FlxG.stage.stageWidth
			accountCreateBox.height = FlxG.stage.stageHeight
			
		}
		
		//Attempt to create a logn account using simple Resistration through playerIO
		private function createAccount(password:String, username:String, email:String):void 
		{
			PlayerIO.quickConnect.simpleRegister(FlxG.stage,
				"get-across-ynrpgn4egdtvzlz3wg8w", // getacross server
				//"get-across-x2cjq5dm3euxur54kxxpq", // nadine's server
				//"getacross-rny1binyakgosozwy0h8wg", //CHARLIE'S SERVER
				username, 
				password, 
				email,
				"", 
				"",
				{role:"Novice", level:1, ap:20, xp:0, coin:0, tutorial:1}, 
				"", 
				registrationComplete, 
				getRegistrationError);
		}
		
		//Handle any error from registration and place errors in correct fields
		private function getRegistrationError(error:PlayerIORegistrationError):void {
			errorMessage.textColor = 0xff0000
			errorMessage.text = error.message
			if(error.usernameError != null){
				usernameError.text = error.usernameError
			}
			if (error.passwordError != null) {
				pwdError.text = error.passwordError
			}
			if(error.emailError != null){
				emailError.text = error.emailError
			}
		}
		
		//Account Creation Successful
		private function registrationComplete(client:Client):void {
			errorMessage.textColor = 0x00FF00
			//SET DEFAULT PLAYER INFORMATION HERE
			client.bigDB.loadMyPlayerObject(function(ob:DatabaseObject):void {
				ob.role = "Novice"
				ob.level = 1
				ob.ap = 20
				ob.xp = 0
				ob.coin = 0
				ob.tutorial = 1
				//Start Menu State
				Hide(null);
				FlxG.stage.removeChild(_stage);
				ob.save(false, false, function() {
					
					
					trace("Sucessfully connected to player.io");
				
					//Set developmentsever (Comment out to connect to your server online)
					//client.multiplayer.developmentServer = "127.0.0.1:8184";

					//Show lobby (parsing true hides the cancel button)
					FlxG.switchState(new MenuState(client));
					});
				
				
				
			})
		}
	}	
}