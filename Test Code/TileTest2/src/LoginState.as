package  
{
	import flash.text.TextField;
	import org.flixel.FlxButton;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class LoginState extends FlxState
	{
		private var loginButton:FlxButton;
		
		
		public function LoginState() 
		{
			
			FlxG.mouse.show(null, 0, 0);
		
			var text1:FlxText = new FlxText(FlxG.width / 6, 30, FlxG.width - 30, "Get Across",true);
			var text2:FlxText = new FlxText(FlxG.width / 3, 100, FlxG.width - 30, "Login", true);
			text1.size = 40;
			text2.size = 30;
			
			var text3:FlxText = new FlxText(25, 200, 75, "Username: ", true);
			text3.size = 10;
			var userName:TextField = new TextField();
			userName.x = 100;
			userName.y = 200;
			userName.height = 20;
			userName.textColor = 0xFFFFFF;
			userName.border = true;
			userName.borderColor = 0xFFFFFF;
			userName.multiline = false;
			userName.type = "input"
			userName.backgroundColor = 0xFFFFFF;
			
			var text4:FlxText = new FlxText(25, 240, 75, "Password: ", true);
			text4.size = 10;
			
			var password:TextField = new TextField();
			password.x = 100;
			password.y = 240;
			password.height = 20;
			password.textColor = 0xFFFFFF;
			password.border = true;
			password.borderColor = 0xFFFFFF;
			password.multiline = false;
			password.type = "input"
			password.backgroundColor = 0xFFFFFF;
			
			loginButton = new FlxButton(FlxG.width / 3, FlxG.height - 30, attemptLogin);
			loginButton.loadText(new FlxText(30, 5, 100, "Log In", true), null);
		
			this.add(text1);
			this.add(text2);
			this.add(text3);
			this.addChild(userName);
			this.add(text4);
			this.addChild(password);
			this.add(loginButton);
			
			
		}
		
		private function attemptLogin():void 
		{
			FlxG.state = new PlayState();
		}
		
	}

}