package  
{
	import flash.display.Sprite;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import playerio.Connection;
	import playerio.DatabaseObject;
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
		private var _tileSize:int;
		private var _xOffset:int;
		private var _yOffset:int;
		private var _object:DatabaseObject;
			
		public function Ability(tileSize:int, xOffset:int, yOffset:int, caster:Player, object:DatabaseObject) 
		{
			_tileSize = tileSize;
			_xOffset = xOffset;
			_yOffset = yOffset;
			_range = object.Range;
			_cost = object.cost;
			_object = object
			_caster = caster;
			
			var img:Class = range1
			if (_range == 1) {
				img = range1;
				
			}else if (_range == 2) {
				img = range2;
			}
			super(_caster.x - (tileSize * _range) , _caster.y - (tileSize * _range), img); //need to make sure position image on the center of the players tile
			
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
			if (_object.Effect.Type == "Terrain" && PlayState.myMap.getTile(tileX,tileY) == _object.Effect.From) {
				PlayState.myMap.setTile(tileX, tileY, _object.Effect.To)
				connection.send("MapTileChanged", tileX, tileY, _object.Effect.To);
				//connection.send("QuestMapUpdate", PlayState.myMap.getMapData())
				connection.send("QuestMapUpdate", PlayState.myMap.getMapData());
			}else if (_object.Effect.Type == "Sprite" && PlayState.myMap.getTile(tileX,tileY) == _object.Effect.From) {
				PlayState.lyrSprites.add(new EffectSprite((tileX * _tileSize ) + _xOffset, (tileY * _tileSize) + _yOffset, _object.Effect.Image, _object.Effect.Range, _tileSize));
			}
		}
	}

}