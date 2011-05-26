package  
{
	import flash.display.Sprite;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;
	import playerio.Connection;
	import playerio.DatabaseObject;
	import sample.ui.components.AbilityButton;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class Ability extends FlxSprite
	{
		[Embed(source = "data/Range_1.png")] public var range1:Class;
		[Embed(source = "data/Range_2.png")] public var range2:Class;
		private var _range:int;
		public var _cost:int;
		private var _effect:String;
		private var _caster:Player;
		private var _tileSize:int;
		private var _object:DatabaseObject;
		private var _parentButton:AbilityButton;
		
		// resources this ability costs
		public var _neededLumber:int;
		public var _neededCherry:int
			
		public function Ability(tileSize:int, caster:Player, object:DatabaseObject) 
		{
			_tileSize = tileSize;
			_range = object.Range;
			_cost = object.Cost;
			_object = object;
			_caster = caster;
			_neededLumber = object.Lumber;
			_neededCherry = object.Cherry;
			
			var img:Class = range1;
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
			this.x = _caster.x - (_tileSize * _range)
			this.y = _caster.y - (_tileSize * _range)
			super.update();
		}
		
		//Sets the abilities button so that it can be deactivated once this ability has been cast
		public function setButton(btn:AbilityButton):void 
		{
			_parentButton = btn;
		}
		//Returns the cost of the ability
		public function getCost():int 
		{
			return _cost;
		}
		
		//Returns the range of the ability
		public function getRange():int
		{
			return _range;
		}
		
		// returns true if player has enough AP & resources to cast this ability
		// input: player, x & y of tile to cast to, x & y of pixels the player clicked
		public function canCast(player:Player, castToXTile:int,castToYTile:int):Boolean
		{
			var canCast:Boolean = true;
			if ((_object.Effect.Type == "Terrain" || _object.Effect.Type == "Sprite") && (PlayState.myMap.getTile(castToXTile,castToYTile) != _object.Effect.From && (_object.Effect.From2 == null || PlayState.myMap.getTile(castToXTile,castToYTile) != _object.Effect.From2))) {
				canCast = false;
				PlayState.fireNotification(player.x + 20, player.y + 20, "Can't cast ability here!", "loss");
			}
			else if (player.AP < this._cost) {
				canCast = false;
				PlayState.fireNotification(player.x + 20, player.y + 20, "Not enough AP!", "loss");
			}
			else if (player.amountLumber < _neededLumber) {
				canCast = false;
				PlayState.fireNotification(player.x + 20, player.y + 20, "Not enough lumber!", "loss");
			}else if (player.amountCherry < _neededCherry) {
				canCast = false;
				PlayState.fireNotification(player.x + 20, player.y + 20, "Not enough Cherries!", "loss");
			}
			
			return canCast;
		}
		
		public function cast(tileX:int, tileY:int, connection:Connection):void
		{
			var tileType:int = PlayState.myMap.getTile(tileX,tileY)
			if (_object.Effect.Type == "Terrain" &&  tileType == _object.Effect.From) {
				PlayState.myMap.setTile(tileX, tileY, _object.Effect.To)
				connection.send("MapTileChanged", tileX, tileY, _object.Effect.To);
				connection.send("QuestMapUpdate", PlayState.myMap.getMapData());
			}else if (_object.Effect.Type == "Terrain" && _object.Effect.From2 != null && tileType == _object.Effect.From2) {
				PlayState.myMap.setTile(tileX, tileY, _object.Effect.To2)
				connection.send("MapTileChanged", tileX, tileY, _object.Effect.To2);
				connection.send("QuestMapUpdate", PlayState.myMap.getMapData());
			}
			else if (_object.Effect.Type == "Sprite" && PlayState.myMap.getTile(tileX,tileY) == _object.Effect.From) {
				//PlayState.lyrEffects.add(new EffectSprite(tileX, tileY, _object.Effect.Image, _object.Effect.Range, _tileSize));
				connection.send("AddSprite", "Effects", tileX, tileY, _object.Effect.Image, _object.Effect.Range);
			}
			
			_parentButton._rangeShow = false;
			_parentButton.buttonHighlight.visible = false;
		}
	}

}