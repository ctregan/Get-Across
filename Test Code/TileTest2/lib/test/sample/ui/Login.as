﻿package sample.ui{	import flash.display.Sprite	import flash.display.Stage	import flash.events.Event	import flash.text.TextFormatAlign	import org.flixel.FlxState;	import org.flixel.FlxG;	import playerio.*;		import flash.events.MouseEvent		import sample.ui.components.*	public class Login extends Sprite {				private var _stage:FlxState //Stage where UI elements should be placed		private var base:Box //Box that contains all visual elements		private var usernameInput:Input; //Label where username is input		private var passwordInput:Input; //Label where password is input		private var errorMessage:Label;		private var myClient:Client;				function Login(stage:FlxState){			_stage = stage			//Errors			errorMessage = new Label("", 12,TextFormatAlign.RIGHT,  0xff0000)			//Input			usernameInput = new Input("", 12, TextFormatAlign.LEFT)			passwordInput = new Input("", 12, TextFormatAlign.LEFT, true)			usernameInput.height = 20			passwordInput.height = 20						base = new Box().fill(0xFFFFFF,0.8).add(				new Box().fill(0x000000,.5,15).margin(10,10,10,10).minSize(300,0).add(					new Box().fill(0xffffff,1,5).margin(10,10,10,10).minSize(300,0).add(						new Rows(							new Label("Login",20, TextFormatAlign.CENTER),							new Columns().margin(0, 5, 0, 5).spacing(3).add(								new Label("Username",12, TextFormatAlign.RIGHT),								usernameInput							),							new Columns().margin(0,5,0,5).spacing(3).add(								new Label("Password",12, TextFormatAlign.RIGHT),								passwordInput							),							errorMessage,							new Columns().margin(10).spacing(10).add(								new TextButton("Cancel", Hide),								new TextButton("Login", attemptLogin))						).spacing(10)					)				)			)						addChild(base)			realign();		}				public function Show(e:Event = null):void{			FlxG.stage.addChild(this);			FlxG.stage.addEventListener(Event.RESIZE, realign)			realign()		}				public function Hide(e:Event = null):void{ 			FlxG.stage.removeChild(this);			FlxG.stage.removeEventListener(Event.RESIZE, realign)		}				private function realign(e:Event = null){						base.reset();			base.width = FlxG.stage.width			base.height = FlxG.stage.height					}		//Attempt to log user in using playerIO simple connect		private function attemptLogin():void 		{				PlayerIO.quickConnect.simpleConnect(				FlxG.stage,				"get-across-ynrpgn4egdtvzlz3wg8w", //Game ID, taken from PlayerIO website				usernameInput.getRawText(), //Login Name, want to grab this from input				passwordInput.getRawText(), //Password, want to grab this for input				successfulLogin,				failedLogin);		}				//Callback function called when login is successful		private function successfulLogin(client:Client):void 		{			trace("Sucessfully connected to player.io");						myClient = client;			//Set developmentsever (Comment out to connect to your server online)			client.multiplayer.developmentServer = "127.0.0.1:8184";			//Start Menu State			FlxG.switchState(new MenuState(myClient));						//Show lobby (parsing true hides the cancel button)			this.Hide(null);		}				//Callback function called when login has failed		private function failedLogin(error:PlayerIOError):void 		{			errorMessage.text = error.message		}			}	}