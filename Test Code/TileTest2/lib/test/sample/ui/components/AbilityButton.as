package sample.ui.components{
	import flash.display.SimpleButton
	import flash.events.Event
	import flash.events.MouseEvent
	import flash.text.TextFormatAlign
	import org.flixel.FlxButton;
	import org.flixel.FlxText;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;
	
	public class AbilityButton extends FlxButtonPlus{
		protected var _width:Number
		protected var _height:Number
		private var _ability:Ability;
		public var _rangeShow:Boolean;
		
		function AbilityButton(xPixel:int, yPixel:int, ability:Ability, abilityName:String) {
			_ability = ability;
			_rangeShow = false;
			super(xPixel, yPixel, buttonClick,null,abilityName);
		}
		
		public function buttonClick():void 
		{
			if(!PlayState.getAbilitySelected()){
				PlayState.setActiveAbility(_ability);
				_ability.visible = true;
				_rangeShow = true;
			}else {
				_ability.visible = false;
				_rangeShow = false;
				PlayState.setActiveAbility(null);
			}
		}
		
		override public function update():void 
		{
			if (_rangeShow) {
				this.buttonHighlight.visible = true;
			}
			super.update();
		}
			
	}	
}