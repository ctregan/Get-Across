package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import caurina.transitions.Tweener;
	import gs.TweenMax;
	/**
	 * ...
	 * @author Ji Mun
	 */
	public class FriendsBar extends MovieClip
	{
		private var bounds:Rectangle;
		private var startX:Number;
		private var contentX:Number;		
		
		public function FriendsBar() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function tween(e:MouseEvent):void
		{
			var mousePos:Number = mouseX;
			if(mousePos > (scrollBar.x + scrollBar.width) - (scrollHandle.width + 4)){
				mousePos = (scrollBar.x + scrollBar.width) - (scrollHandle.width + 4);
			}
			Tweener.addTween(scrollHandle, {x: mousePos, time: 1});
		}
		private function drag(e:MouseEvent):void
		{
			scrollHandle.startDrag(false, bounds);
			scrollHandle.gotoAndStop(2);
			scrollHandle.removeEventListener(MouseEvent.MOUSE_DOWN, drag);
			addEventListener(MouseEvent.MOUSE_UP, stopdrag);
						
		}
		private function stopdrag(e:MouseEvent):void
		{
			scrollHandle.stopDrag();
			scrollHandle.gotoAndStop(1);
			scrollHandle.addEventListener(MouseEvent.MOUSE_DOWN, drag);
			removeEventListener(MouseEvent.MOUSE_UP, stopdrag);
		}
		private function moveBox(e:Event):void
		{
			TweenMax.to(scrollingContent, 2, {x: -((contentX - startX) + scrollHandle.x) * ((scrollingContent.width - masker.width) / (scrollBar.width - scrollHandle.width))});
			//scrollingContent.x = -((contentX - startX) + scrollHandle.x) * ((scrollingContent.width - masker.width) / (scrollBar.width - scrollHandle.width));
		}
		
	}

}