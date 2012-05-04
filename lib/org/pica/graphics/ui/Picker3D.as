package org.pica.graphics.ui {
	import flash.geom.Point;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.render.data.RenderHitData;
	//import org.papervision3d.core.utils.Mouse3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.Viewport3D;
	
	/**
	 * ...
	 * @author Darren Liew
	 * @usage Only useful for object with MovieMaterial and flat surface. it is simpler and faster than Mouse3D
	 */
	public class Picker3D {
		
		//private static var mouse_:Mouse3D = null;
		private static var viewport_:Viewport3D = null;
		private static var pickedID_:int = -1;
		private static var x_:Number;
		private static var y_:Number;
		
		public function Picker3D() {
		}
		
		// most likely called in main.as, check it, b4 call it again
		public static function init(viewport:Viewport3D):void {
			//Mouse3D.enabled = true;
			viewport_ = viewport;
			//mouse_ = viewport.interactiveSceneManager.mouse3D;
		}
		
		// most likely called in main.as, check it, b4 call it again
		public static function deinit():void {
			//Mouse3D.enabled = false;
			viewport_ = null;
			//mouse_ = null;
		}
		
		public static function setPickable(obj:DisplayObject3D, pickable:Boolean=true):void {
			if (pickable) obj.material.interactive = true;
			else obj.material.interactive = false;
		}
		
		public static function hitTest():void {
			var rh:RenderHitData = viewport_.hitTestMouse();
			pickedID_ = -1;
			if (rh.hasHit) {
				if (isNaN(rh.u)) { // material not loaded yet, ignore it first
					var do3d:DisplayObject3D = rh.displayObject3D;
					do3d.material.interactive = false;
					rh = viewport_.hitTestMouse();
					do3d.material.interactive = true;
					if (!rh.hasHit) return;
				}
				pickedID_ = rh.hasHit ? rh.displayObject3D.id : -1;
				x_ = rh.u;
				y_ = rh.v;
			}
		}
		
		public static function getPickedPoint(obj:DisplayObject3D, pt:Point):Boolean {
			if (obj.id == pickedID_) {
				pt.x = x_;
				pt.y = y_;
				return true;
			}
			pt.x = -1;
			pt.y = -1;
			return false;
		}
		
		public static function getPickedObjId():int {
			return pickedID_;
		}
		
		public static function getPoint():Point {
			return new Point(x_, y_);
		}
		
		public static function getNumber3D():Number3D {
			return new Number3D(x_, 0, y_);
		}
		
	}
	
}