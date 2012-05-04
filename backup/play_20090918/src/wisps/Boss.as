package wisps {
	import bots.Bullets;
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Sphere;
	import org.pica.ai.Grid2D;
	import org.pica.animators.Animator;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Boss extends DisplayObject3D implements IWisp {
		
		private var radius_:Number;
		private var hp_:Number = 100;
		private var onGoal_:Function;
		
		public function Boss(grid:Grid2D) {
			var sphere:Sphere = new Sphere(new ColorMaterial(0xff0ff), 5);
			sphere.position = new Number3D(0, 5, 0);
			addChild(sphere);
			
			radius_ = 10 * 10;
		}
		
		public function start(path:Array, onGoal:Function):void {
			onGoal_ = onGoal;
			this.position = path[path.length-1];
			Animator.followPath(this, path, 0, null, this.onExit);
		}
		
		public function changePath(path:Array):void {
			Animator.followPath(this, path, 0, null, this.onExit);
		}
		
		public function update(bullet_type:Bullets, bullets:Array):void {
			var rad:Number = bullet_type.radius;
			for each (var bullet:Particle in bullets) {
				if (hitTest(bullet.x, bullet.z, rad)) {
					bullet_type.hit(bullet, this);
trace("hp "+hp_);
				}
				if (hp_ <= 0) {
					Animator.stop(this);
					break;
				}
			}
		}
		
		public function damage(d:Number, s:Particle):void {
			hp_ -= d;
			if (hp_ < 0) hp_ = 0;
		}
		
		public function isAlive():Boolean {
			return hp_ > 0;
		}
		
		public function hitTest(x:Number, y:Number, rad:Number):Boolean {
			var dx:Number = x - this.x;
			var dz:Number = z - this.z;
			if (dx * dx + dz * dz <= rad)
				return true;
			return false;
		}
		
		private function onExit():void {
			onGoal_(this);
		}
	}
	
}