package  
{
	import org.flixel.FlxSprite;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;
	import org.flixel.FlxG
	import playerio.Connection;
	/**
	 * ...
	 * @author Charlie Regan
	 */
	public class ConsumeButton extends FlxButtonPlus
	{
		private var eSprite:EffectSprite;
		private var parent:Player;
		private var connection:Connection
		private var tileSize:int;
		public function ConsumeButton(sprite:EffectSprite, toFollow:Player, connection:Connection, tileSize:int) 
		{
			this.connection = connection
			this.tileSize = tileSize
			parent = toFollow;
			eSprite = sprite;
			
			super(540, 340, function() { onUse() }, null, "Consume", 70, 20);
		}
		
		override public function update():void 
		{
			if (parent == null) {
				parent = PlayState.myPlayer
			}else{
				if (eSprite.dead) {
					this.kill();
				}else if (FlxG.overlap(eSprite, parent)) {
					visible = true;
					//PlayState.lyrTop.add(this);
				}else {
					visible = false;
				}
				//x = (parent.xPos * tileSize)+ PlayState._mapOffsetX + 10;
				//x = parent.x + 10
				//y = parent.y - 20
				//y =(parent.yPos * tileSize)+ PlayState._mapOffsetY - 20;
				super.update();
			}
		}
		
		private function onUse() {
			this.kill();
			eSprite.addUse(true);
			parent.AP += 10;
			connection.send("updateStat", "AP", parent.AP);
		}
		
	}

}