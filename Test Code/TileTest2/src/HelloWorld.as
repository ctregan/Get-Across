package  
{
	import org.flixel.*;
	
	[SWF(width="700", height="400", backgroundColor="#000000")] //Set the size and color of the Flash file

	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class HelloWorld extends FlxGame
	{
		
		public function HelloWorld() 
		{
			super(450, 400, LoginState,1);
		}
	}

}