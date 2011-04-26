package  
{
	import org.flixel.*;
	[SWF(width="320", height="400", backgroundColor="#000000")] //Set the size and color of the Flash file

	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class HelloWorld extends FlxGame
	{
		
		public function HelloWorld() 
		{
			super(320,400,PlayState,1); //Create a new FlxGame object at 320x240 with 2x pixels, then load PlayState
		}
		
	}

}