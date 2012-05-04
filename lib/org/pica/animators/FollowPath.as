package org.pica.animators {
	import caurina.transitions.Tweener;
	import org.papervision3d.core.math.Number3D;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class FollowPath	{
		
		public function FollowPath() {
			
		}
		
		static public function execute(obj:Object, path:Array, height:Number, step:Function, done:Function):void {
			var endpos:Number3D = path[0];
			var tweenObj: Object = 
			{
				x: endpos.x, 
				y: height, 
				z: endpos.z, 
				_bezier: path2Bezier(path, height), 
				time: 5, 
				transition: "easeinoutquad",
				onUpdate: step,
				onComplete: done
			};
			Tweener.addTween(obj, tweenObj);
		}
		
		static private function path2Bezier(path:Array, height:Number):Array {
			var bezier:Array = new Array();
			for (var i:uint = path.length - 1; i > 0; --i) {
				bezier.push({x: path[i].x, y: height, z: path[i].z});
			}
			return bezier;
		}
		
	}
	
}