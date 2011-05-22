package  
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import org.flixel.plugin.photonstorm.PNGEncoder;
	//import org.flixel.data.FlxPanel;
	import org.flixel.FlxButton;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
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
		private var loginBox:Box;
		private var mainMenu:Box;
		private var accountCreateBox:Box;
		private var loginObj:Login;
		private var registrationObj:Registration;
		private var testMouse:Mouse;
		
		private var _windowHeight:int = 400;
		private var _windowWidth:int = 700;
			
		public function LoginState() 
		{
			super();
			var titleTextFormat:TextFormat = new TextFormat("Abscissa", 60, 0xff488921);
			var titleLabel:Label = new Label("get across", 50, TextFormatAlign.CENTER, 0xff488921);
			titleLabel.setTextFormat(titleTextFormat);
			
			var loginButton: TextButton = new TextButton("Login", openLogin);
			var createAccountButton:TextButton = new TextButton("Create Account", openAccountCreate);
			loginButton.useHandCursor = createAccountButton.useHandCursor = true;
			mainMenu = new Box().fill(0xFFFFFF, 1, 0)
			mainMenu.add(new Box().fill(0xffffff, 0.5, 15).margin(5, 5, 5, 5).minSize(_windowWidth/2, _windowHeight).add(
				new Box().fill(0xffffff,1,5).margin(10,10,10,10).minSize(300,0).add(
						new Rows(
							titleLabel,
							loginButton,
							createAccountButton
						).spacing(30)
				)));
			add(new Background("Map"));
			FlxG.stage.addChild(mainMenu);
		}
		//Create a login box over the main menu
		private function openLogin():void 
		{
			loginObj = new Login(mainMenu);
			//loginObj.height = FlxG.height
			loginObj.Show();
		}
		//Creates an account create box over the main menu
		private function openAccountCreate():void {
			registrationObj = new Registration(mainMenu);
			//registrationObj.height = FlxG.height
			registrationObj.Show();
		}
		
		
		
	}

}