﻿package {		import flash.display.MovieClip;	import flash.display.SimpleButton;	import flash.events.MouseEvent;	import flash.events.TextEvent;	import flash.text.TextField	public class InfoBox extends MovieClip{		private var startCallback:Function;		private var joinCallback:Function;		private var playAgain:SimpleButton;		private var joinGame:SimpleButton;		private var winner:TextField;		function InfoBox(startCallback:Function, joinCallback:Function){			stop();			winner = new TextField();			playAgain = new SimpleButton();			joinGame = new SimpleButton();			playAgain.visible = false;			playAgain.addEventListener(MouseEvent.CLICK, handleRestart)			joinGame.visible = false			joinGame.addEventListener(MouseEvent.CLICK, handleJoin)			this.startCallback = startCallback			this.joinCallback = joinCallback;			this.addChild(winner)			this.addChild(playAgain);			this.addChild(joinGame);			this.x = 320			this.y = 0		}		public function Hide(){			this.visible = false		}		public function Show(what:String, data:String = "") {			winner.visible = false			playAgain.visible = false;			joinGame.visible = false;			switch(what){				case "showWinner":{					winner.text = data					winner.visible = true				}				case "full":{}				case "waiting":{					if(data == "ok")joinGame.visible = true				}				case "tie":{					if(data == "go")playAgain.visible = true;					break;				}				default:{					playAgain.visible = true;					break;				}			}			this.gotoAndStop(what)			this.visible = true		}		private function handleRestart(e:MouseEvent){			startCallback();		}		private function handleJoin(e:MouseEvent){			joinCallback();		}	}	}