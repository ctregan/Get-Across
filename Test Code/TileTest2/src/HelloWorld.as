package  
{
	import org.flixel.*;
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.system.Security;
	
	[SWF(width="700", height="500", backgroundColor="#FFFFFF")] //Set the size and color of the Flash file

	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class HelloWorld extends FlxGame
	{

		public function HelloWorld() 
		{
			super(700, 1000, LoginState,1);
			//super(700, 800, KongregateLoadState, 1);
			//super(700, 800, FacebookLoadState, 1);
		}
	}

}