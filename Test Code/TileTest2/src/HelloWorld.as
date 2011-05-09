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
			super(700, 400, LoginState,1);
		}
	}

}