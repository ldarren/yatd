package org.pica.animators {
	import caurina.transitions.Tweener;
	import org.papervision3d.core.math.Number3D;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Gunner {
		
		public function Gunner() {
			
		}
		
		static public function shoot(obj:Object, from:Number3D, to:Number3D, speed:Number, step:Function=null, done:Function=null):void {
			var tweenObj: Object = 
			{
				x: to.x, 
				y: to.y, 
				z: to.z, 
				time: 0.5, 
				transition: "easeinquad",
				onUpdate: step,
				onComplete: done,
				onCompleteParams: [obj]
			};
			Tweener.addTween(obj, tweenObj);
		}
		
	}
	
}