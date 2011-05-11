package  
{
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	//import org.flixel.data.FlxPanel;
	import org.flixel.FlxButton;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxRect;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	import flash.events.Event
	import org.flixel.FlxU;
	import playerio.*;
	import sample.ui.Login;
	import flash.text.TextFormatAlign;
	import sample.ui.components.*;
	import sample.ui.Registration;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class LoginState extends FlxState
	{
		//private var loginBox:FlxRect;
		//private var mainMenu:FlxObject;
		//private var loginBox:Box;
		//private var mainMenu:Box;
		//private var accountCreateBox:FlxRect;
		//private var accountCreateBox:Box;
		private var loginObj:Login;
		//private var registrationObj:Registration;
		//private var testMouse:Mouse;
		private var title:FlxText;
		private var loginButton:FlxButton;
		private var registrationButton:FlxButton;
		
		
		
		override public function create():void 
		{
			// create buttons
			title = new FlxText(100, 50, 500, "GetAcross", true);
			title.size = 32;
			//title.font = "Arial";
			title.alignment = "center";
			add(title);
			
			loginButton = new FlxButton(300, 200, "Login", onLogin, null, null);
			add(loginButton);
			
			registrationButton = new FlxButton(300, 250, "Registration", onRegistration, null, null);
			add(registrationButton);

			FlxG.mouse.show();
		}
		
		private function onLogin():void {
			FlxG.switchState(new Login(this));
			//loginObj.Show();
		}
		
		private function onRegistration(): void {
			//registrationObj = new Registration(this);
			//registrationObj.Show();
		}
		
		
		
	}

}