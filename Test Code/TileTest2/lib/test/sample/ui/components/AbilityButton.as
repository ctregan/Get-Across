package sample.ui.components{
	import flash.display.SimpleButton
	import flash.events.Event
	import flash.events.MouseEvent
	import flash.text.TextFormatAlign
	
	public class AbilityButton extends SimpleButton{
		protected var _width:Number
		protected var _height:Number
		protected var _clickHandler:Function
		private var _text:String
		public var text:Label
		private var _rangeShow:Boolean // Toggle Visibility
		
		function AbilityButton(ability:Ability, text:String){
			_rangeShow = false;
			_clickHandler = function() {
				if (_rangeShow) {
					ability.visible = false;
					_rangeShow = false;
				}else{
					ability.visible = true;
					_rangeShow = true;
				}
			}
			if(_clickHandler != null){
				addEventListener(Event.ADDED_TO_STAGE,handleAttach)
				addEventListener(Event.REMOVED_FROM_STAGE,handleDetatch)
			}
			
			_text = text;
			this.text = new Label(_text, 12, TextFormatAlign.CENTER);
			this.upState 		= new Box().margin(0,0,0,0).fill(0xFFFFFF,1,10).border(1,0x558888).add(new Box().add(this.text.Clone()))
			this.downState 		= new Box().margin(0,0,0,0).fill(0x558888,1,10).border(1,0x000000).add(new Box().add(this.text.Clone()))
			this.overState 		= new Box().margin(0,0,0,0).fill(0x55AAAA,1,10).border(1,0x000000).add(new Box().add(this.text.Clone()))
			this.hitTestState 	= new Box().margin(0,0,0,0).fill(0xFFFFFF,1,10).border(1,0x55AAAA).add(new Box().add(this.text.Clone()))
			
			_width = this.text.width + 12
			_height = this.text.height + 10
			
			redraw()
			
			redraw()
		}
		
		public function handleAttach(e:Event){
			addEventListener(MouseEvent.CLICK, _clickHandler)
		}
		
		public function handleDetatch(e:Event){
			removeEventListener(MouseEvent.CLICK, _clickHandler)
		}
		
		public override function set width(w:Number):void{
			_width = w;
			redraw();
		}
		
		public override function set height(h:Number):void{
			_height = h;
			redraw();
		}
		protected function redraw(){
			if(this.upState){
				this.upState.width = _width
				this.upState.height = _height
			}
			
			if(this.downState){
				this.downState.width = _width
				this.downState.height = _height
			}

			if(this.overState){
				this.overState.width = _width
				this.overState.height = _height
			}

			if(this.hitTestState){
				this.hitTestState.width = _width
				this.hitTestState.height = _height		
			}
		}
	}	
}