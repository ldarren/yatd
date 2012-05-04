package scenes.td {
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.pica.graphics.effects.OrbLighting;
	
	/**
	 * ...
	 * @author Darren Liew
	 * @todo generalized for different kind of orbs (laser, bullets, lighting, flame, projectile, force field)
	 */
	public class Weapon extends OrbLighting {
		
		public function Weapon(size:Number, targets:Array, light:PointLight3D, color:int, dark:int, step:int = 5) {
			super(size, targets, light, color, dark, step);
			
		}
		
		override public function project(parent:DisplayObject3D, renderSessionData:RenderSessionData):Number {
			var target:Wisp = super.update() as Wisp;
			if (target) target.onHit(10);
			return super.project(parent, renderSessionData);
		}
		
	}
	
}