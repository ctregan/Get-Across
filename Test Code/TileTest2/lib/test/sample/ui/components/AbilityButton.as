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
		private var _rangeShow:Boolean;
		
		function AbilityButton(xPixel:int, yPixel:int, ability:Ability) {
			_ability = ability;
			_rangeShow = false;
			//add(new FlxText(xPixel + 2, yPixel + 2, width - 2, text));
			super(xPixel, yPixel, buttonClick,null, "ability");
		}
		
		public function buttonClick():void 
		{
			if(!PlayState.getAbilitySelected()){
				PlayState.setActiveAbility(_ability);
				_ability.visible = true;
				_rangeShow = true;
				this.borderColor = 0xFF0000;
			}
		}
		
		override public function update():void 
		{
			if (_rangeShow) {
				this.buttonHighlight.visible = true;
			}else if (!PlayState.getAbilitySelected) {
				_rangeShow = false;
				this.buttonHighlight.visible = false;
			}
			super.update();
		}
			
	}	
}