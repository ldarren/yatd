package org.pica.graphics.cameras {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class CameraManIso {
		
		private var camera_:CameraObject3D;
		private var area_:Rectangle;
		private var target_:DisplayObject3D;
		private var dz_:Number;
		private var dy_:Number;
		private var ele_:Number;
		private var dFwd_:int;
		private var dSwd_:int;
		private var dRot_:int;
		
		private var dirty_:Boolean;
		
		public function CameraManIso(dist:Number, elevation:Number) {
			target_ = new DisplayObject3D("cam_target");
			ele_ = elevation;
			var ang:Number = ele_ * 0.017453;
			dz_ = dist * Math.cos(ang);
			dy_ = dist * Math.sin(ang);
		}
		
		public function changeShot(camera:CameraObject3D, ctr:Point, rect:Rectangle):void {
			camera_ = camera;
			target_.position = new Number3D( ctr.x, 0, ctr.y);
			area_ = rect;
			
			dirty_ = true;
		}
		
		public function resetShot():void {
			with(target_){
				position = new Number3D();
				rotationX = 0;
				rotationY = 0;
				rotationZ = 0;
			}
			with(camera_){
				position = new Number3D();
				rotationX = 0;
				rotationY = 0;
				rotationZ = 0;
			}
			
			dirty_ = false;
		}
		
		public function moveForward(dist:int):void {
			dFwd_ = dist;
		}
		
		public function moveSide(dist:int):void {
			dSwd_ = dist;
		}
		
		public function rotate(angle:int):void {
			dRot_ = angle;
		}
		
		public function update():void {
			if (dFwd_ || dSwd_ || dRot_) {
				if (dFwd_) target_.moveForward(dFwd_);
				if (dSwd_) target_.moveRight(dSwd_);
				dirty_ = true;
				var pos:Number3D = target_.position;
				if (pos.z < area_.top || pos.z > area_.bottom || pos.x < area_.left || pos.x > area_.right) {
					target_.moveBackward(dFwd_);
					target_.moveLeft(dSwd_);
					dirty_ = false;
				}

				if (dRot_) { target_.yaw(dRot_); dirty_ = true; }
			}

			if (dirty_) {
				with (camera_){
					copyTransform(target_);
					moveBackward(dz_);
					moveUp(dy_);
					pitch(ele_);
				}
				dirty_ = false;
			}
		}
		
	}
	
}
/*
		
		public function moveForward(dist:Number):void {
			var pos:Number3D;
			pos = camera_.position;
			if (pos.y + dist < area_.top || pos.y + dist > area_.bottom) return;
			pos.y += dist;
			camera_.position = pos;
			pos = camera_.target.position;
			pos.y += dist;
			camera_.target.position = pos;
		}
		
		public function moveSide(dist:Number):void {
			var pos:Number3D;
			pos = camera_.position;
			if (pos.x + dist < area_.left || pos.x + dist > area_.right) return;
			pos.x += dist;
			camera_.position = pos;
			pos = camera_.target.position;
			pos.x += dist;
			camera_.target.position = pos;
		}
*/