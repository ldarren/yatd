package org.pica.animators {
	import caurina.transitions.properties.CurveModifiers;
	import caurina.transitions.Tweener;
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.math.Number3D;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Animator {
		
		public function Animator() {
		}
		
		static public function init():void {
			CurveModifiers.init();
		}
		
		static public function followPath(obj:Object, path:Array, height:Number=0, step:Function=null, done:Function=null):void {
			FollowPath.execute(obj, path, height, step, done);
		}
		
		static public function shoot(obj:Object, from:Number3D, to:Number3D, step:Function=null, done:Function=null):void {
			Gunner.shoot(obj, from, to, 1, step, done);
		}
		
		static public function stop(obj:Object):void {
			Tweener.removeTweens(obj);
		}
	}
	
}