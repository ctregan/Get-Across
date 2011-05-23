package com.Logging 
{
	/**
	 * ...
	 * @author Dmitri/Yun-En
	 * 
	 * Contains action IDs for all user actions in the game. Think of this class as a global enum.
	 * Replace with your own IDs.
	 * 
	 * IMPORTANT NOTES:
	 * 1.) Don't reuse ids.  This will make for really weird server logs, as
	 * old data will get reinterpretated as new data.
	 * Just make new ids and use those instead.
	 * 2.) When you add a new id, make sure to add it to the server as well.
	 * That way when it generates reports it can know which id maps to which actions.
	 */
	public final class ClientActionType 
	{
		
		public static const BRIDGE:int = 1;
		public static const WEAK_ATTACK: int = 2;
		public static const KILL:int = 3;
		public static const CHICKEN_FEAST:int = 4;
		public static const RED_FLOWER:int = 5;
		public static const COLLECT_LUMBER:int = 6;
		public static const COLLECT_CHERRY:int = 7;
		public static const FISH_1:int = 8;
		public static const YELLOW_FLOWER:int = 9;
		public static const MEDIUM_ATTACK:int = 10;
		public static const STRONG_ATTACK:int = 11;
		public static const COLLECT_CHERRY_SEED:int = 12;
		public static const GAME_START:int = 13;
		public static const GAME_END:int = 14;
		public static const AP_GAIN:int = 15;
		public static const MOVE:int = 16;
		public static const WON:int = 17;
	}

}