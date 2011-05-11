package sample.ui.components{
	import flash.display.SimpleButton
	import flash.events.Event
	import flash.events.MouseEvent
	import flash.text.TextFormatAlign
	import org.flixel.FlxButton;
	import org.flixel.FlxText;
	
	public class AbilityButton extends FlxButton{
		protected var _width:Number
		protected var _height:Number
		protected var _clickHandler:Function
		private var _text:String
		private var _ability:Ability;
		public var text:Label
		private var _rangeShow:Boolean // Toggle Visibility
		
		function AbilityButton(xPixel:int, yPixel:int, ability:Ability) {
			_ability = ability;
			_rangeShow = false;
			//add(new FlxText(xPixel + 2, yPixel + 2, width - 2, text));
			super(xPixel, yPixel, buttonClick );
		}
		
		private function buttonClick():void 
		{
			if (_rangeShow && PlayState.getAbilitySelected()) {
					_ability.visible = false;
					_rangeShow = false;
					PlayState.setActiveAbility(null);
				}else if(!_rangeShow && !PlayState.getAbilitySelected()){
					PlayState.setActiveAbility(_ability);
					_ability.visible = true;
					_rangeShow = true;
				}
		}
			
	}	
}