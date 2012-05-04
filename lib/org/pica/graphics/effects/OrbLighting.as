package org.pica.graphics.effects {
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class OrbLighting extends Orb{

		static public const EFFECT_RADIUS:Number = 4096;
		
		private var lightning_:Lightning;
		
		private var partner_:Number3D;
		
		private var targetObj_:DisplayObject3D;
		private var targetPos_:Number3D;
		private var targets_:Array;
		
		public function OrbLighting(size:Number, targets:Array, light:PointLight3D, color:int, dark:int, step:int = 5) {
			super(size, light, color, dark, step);
			
			targets_ = targets;
			lightning_ = new Lightning(0x5C98EF, 1, 1, 8, 15, 1);
			this.addChild(lightning_);
		}
		
		public function update():DisplayObject3D {
			if (isPoweredOn()) {
				// track existing target, if moved away, stop tracking
				if (targetObj_ != null) {
					if (isTarget(targetObj_.position, OrbLighting.EFFECT_RADIUS)) {
						if (checkDelta(targetObj_.position)){
							setTargetPos(targetObj_.position);
							lightning_.retarget("dyn", 0, 0, 0, targetPos_.x, targetPos_.y, targetPos_.z);
						}
					} else {
						setTargetPos(null);
						targetObj_ = null;
						lightning_.removeBolt("dyn");
					}
				}
				var target:DisplayObject3D;
				// if lost target, look for a new one
				if (targetObj_ == null && targets_ != null) {
					for each (var d:DisplayObject3D in targets_) {
						if (isTarget(d.position, OrbLighting.EFFECT_RADIUS)) {
							targetObj_ = d;
							setTargetPos(targetObj_.position);
							//trace("found new target x:"+targetPos_.x+" z: "+targetPos_.z);
							lightning_.addBolt("dyn", 0, 0, 0, targetPos_.x, targetPos_.y, targetPos_.z);
							target = d;
							break;
						}
					}
				}
				lightning_.update();
				return target;
			}
			return null;
		}
		
		override public function powerOn():void {
			if (partner_ != null) lightning_.addBolt("stt", 0,0,0, partner_.x, partner_.y, partner_.z);
			if (targetPos_ != null) lightning_.addBolt("dyn", 0,0,0, targetPos_.x, targetPos_.y, targetPos_.z);
			lightning_.strike(true);
			
			super.powerOn();
		}
		
		override public function powerOff():void {
			lightning_.strike(false);
			lightning_.clearBolts();
			
			setTargetPos(null);
			targetObj_ = null;
			
			super.powerOff();
		}
		
		public function setPartner(orb:Orb):void {
			if (orb == null) {
				partner_ = null;
				return;
			}
			
			partner_ = new Number3D(orb.x - this.x, orb.y - this.y, orb.z - this.z);
		}
		
		public function setTargetPos(pos:Number3D):void {
			if (pos == null) {
				targetPos_ = null;
				return;
			}
			
			targetPos_ = pos;
			targetPos_.x -= this.x;
			targetPos_.y -= this.y;
			targetPos_.z -= this.z;
		}
		
	}
	
}