package  
{
	import flash.display.Sprite;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import playerio.Connection;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class Ability extends FlxSprite
	{
		[Embed(source = "data/Range_1.png")] public var range1:Class;
		[Embed(source = "data/Range_2.png")] public var range2:Class;
		private var _range:int;
		private var _cost:int;
		private var _effect:String;
		private var _caster:Player;
		private var _fromTile:int;
		private var _toTile:int;
		private var _tileSize:int;
			
		public function Ability(tileSize:int, caster:Player, range:int, cost:int, effect:String, fromTile:int, toTile:int) 
		{
			_tileSize = tileSize
			_range = range;
			_cost = cost;
			_effect = effect;
			_caster = caster;
			
			_fromTile = fromTile;
			_toTile = toTile;
			var img:Class = range1
			if (_range == 1) {
				img = range1;
				
			}else if (_range == 2) {
				img = range2;
			}
			super(_caster.x - (tileSize * range) , _caster.y - (tileSize * range), img); //need to make sure position image on the center of the players tile
			
			trace("Ability X: " + this.x + " Y:" + this.y);
			
		}
		
		override public function update():void 
		{
			this.x = _caster.x - _tileSize
			this.y = _caster.y - _tileSize
			super.update();
		}
		
		//Returns the cost of the ability
		public function getCost():int 
		{
			return _cost;
		}
		
		//Returns the range of the ability
		public function  getRange():int
		{
			return _range;
		}
		
		public function cast(tileX:int, tileY:int, connection:Connection) 
		{
			if (_effect == "Terrain" && PlayState.myMap.getTile(tileX,tileY) == _fromTile) {
				PlayState.myMap.setTile(tileX, tileY, _toTile)
				connection.send("MapTileChanged", tileX, tileY, _toTile);
				connection.send("QuestMapUpdate", PlayState.myMap.toString());
			}
		}
	}

}