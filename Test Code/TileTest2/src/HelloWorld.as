package  
{
	import org.flixel.*;
	
	[SWF(width="700", height="400", backgroundColor="#FFFFFF")] //Set the size and color of the Flash file

	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class HelloWorld extends FlxGame
	{
		
		public function HelloWorld() 
		{
			// increasing the window size so that we'll have more space for extra stuff (like bigger map... 
			// Max map size is....?
			super(700, 800, LoginState,1);
		}
	}

}