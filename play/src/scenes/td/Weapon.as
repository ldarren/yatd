package scenes.td {
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.pica.graphics.effects.OrbLaser;
	import scenes.td.ui.Inventory;
	
	/**
	 * ...
	 * @author Darren Liew
	 * @todo generalized for different kind of orbs (laser, bullets, lighting, flame, projectile, force field)
	 */
	public class Weapon extends OrbLaser {
		public static const ORB_COLORS:Array = [
		[0x5466ff, 0x040666],	//blue
		[0x444444, 0x000000],	// black
		[0xffbf00, 0x664600],	// amber
		[0xffffff, 0x666666],	// clear
		[0x54ff66, 0x046606],	// green
		[0xff6654, 0x660604],	// red	
		[0xff54ff, 0x060006]];	// purple
		
		public var type:int = TowerFarm.ORB_BLUE_CODE;
		
		public function Weapon(type:int, size:Number, targets:Array, light:PointLight3D, step:int = 5) {
			var colorid:int = type + Inventory.ORB_BLUE - TowerFarm.ORB_BLUE_CODE;
			super(size, targets, light, ORB_COLORS[colorid][0], ORB_COLORS[colorid][1], step);
trace("Weapon type: "+type);
			this.type = type;
		}
		
		override public function project(parent:DisplayObject3D, renderSessionData:RenderSessionData):Number {
			var target:Wisp = super.update() as Wisp;
			if (target) target.onHit(10);
			return super.project(parent, renderSessionData);
		}
		
	}
	
}