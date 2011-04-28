package  
{
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import org.flixel.FlxButton;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	import flash.events.Event
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
		private var loginBox:Box;
		private var mainMenu:Box;
		private var accountCreateBox:Box;
		private var loginObj:Login;
		private var registrationObj:Registration;
			
		public function LoginState() 
		{
			super();
			FlxG.mouse.show(null, 0, 0);
			
			
			
			mainMenu = new Box().fill(0xFFFFFF, 0.8, 0)
			mainMenu.add(new Box().fill(0x00000, .5, 15).margin(10, 10, 10, 10).minSize(300, FlxG.height).add(
				new Box().fill(0xffffff,1,5).margin(10,10,10,10).minSize(300,0).add(
						new Rows(
							new Label("Get Across", 30, TextFormatAlign.CENTER),
							new TextButton("Login", openLogin),
							new TextButton("Create Account", openAccountCreate)
						).spacing(10)
					)))
			addChild(mainMenu);

			
			
		}
		//Create a login box over the main menu
		private function openLogin():void 
		{
			loginObj = new Login(this);
			loginObj.Show();
		}
		//Creates an account create box over the main menu
		private function openAccountCreate():void {
			registrationObj = new Registration(this);
			registrationObj.Show();
		}
		
		
		
	}

}