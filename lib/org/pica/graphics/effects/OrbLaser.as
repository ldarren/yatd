package org.pica.graphics.effects {
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class OrbLaser extends Orb{

		static public const EFFECT_RADIUS:int = 4096;
		
		private var laser_:Laser;
		
		private var partner_:Number3D;
		
		private var targetObj_:DisplayObject3D;
		private var targetPos_:Number3D;
		private var targets_:Array;
		
		public function OrbLaser(size:Number, targets:Array, light:PointLight3D, color:int, dark:int, step:int = 5) {
			super(size, light, color, dark, step);
			
			targets_ = targets;
			laser_ = new Laser(color, 0.8, 2); //0x5C98EF
			this.addChild(laser_);
		}
		
		public function update():DisplayObject3D {
			if (isPoweredOn()) {
				// track existing target, if moved away, stop tracking
				if (targetObj_ != null) {
					if (isTarget(targetObj_.position, OrbLaser.EFFECT_RADIUS)) {
						if (checkDelta(targetObj_.position)){
							setTargetPos(targetObj_.position);
							laser_.retarget("dyn", 0, 0, 0, targetPos_.x, targetPos_.y, targetPos_.z);
						}
					} else {
						setTargetPos(null);
						targetObj_ = null;
						laser_.removeStream("dyn");
					}
				}
				var target:DisplayObject3D;
				// if lost target, look for a new one
				if (targetObj_ == null && targets_ != null) {
					for each (var d:DisplayObject3D in targets_) {
						if (isTarget(d.position, OrbLaser.EFFECT_RADIUS)) {
							targetObj_ = d;
							setTargetPos(targetObj_.position);
							//trace("found new target x:"+targetPos_.x+" z: "+targetPos_.z);
							laser_.addStream("dyn", 0, 0, 0, targetPos_.x, targetPos_.y, targetPos_.z);
							target = d;
							break;
						}
					}
				}
				laser_.update();
				return target;
			}
			return null;
		}
		
		override public function powerOn():void {
			if (partner_ != null) laser_.retarget("stt", 0,0,0, partner_.x, partner_.y, partner_.z);
			if (targetPos_ != null) laser_.retarget("dyn", 0,0,0, targetPos_.x, targetPos_.y, targetPos_.z);
			laser_.strike(true);
			
			super.powerOn();
		}
		
		override public function powerOff():void {
			laser_.strike(false);
			laser_.clearStreams();
			
			setTargetPos(null);
			targetObj_ = null;
			
			super.powerOff();
		}
		
		public function setPartner(orb:Orb):void {
			if (orb == null) {
				partner_ = null;
				laser_.removeStream("stt");
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

import org.papervision3d.core.geom.Lines3D;
import org.papervision3d.core.geom.renderables.Line3D;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.materials.special.LineMaterial;

class Laser extends Lines3D {
	
	private var streams_:Object;
	private var weight_:Number;
	private var isStriking_:Boolean;

	public function Laser(color:int, alpha:Number, weight:Number) {
		super(new LineMaterial(color, alpha));
		
		streams_ = new Object();
		weight_ = weight;
		strike(false);
	}

	public function addStream(name:String, sx:Number, sy:Number, sz:Number, tx:Number, ty:Number, tz:Number):void {
		var l:Line3D = this.addNewLine(weight_, sx, sy, sz, tx, ty, tz);
		streams_[name] = l;
	}
	public function removeStream(name:String):void {
		var l:Line3D = streams_[name];
		if (l != null) {
			this.removeLine(l);
			streams_[name] = null;
		}
	}
	public function clearStreams():void {
		this.removeAllLines();
	}
	
	public function retarget(name:String, sx:Number, sy:Number, sz:Number, tx:Number, ty:Number, tz:Number):void {
		removeStream(name);
		addStream(name, sx, sy, sz, tx, ty, tz);
	}
	public function strike(on:Boolean):void {
		isStriking_ = on;// && this.lines.length > 0;
		this.visible = isStriking_;
	}
	public function isStriking():Boolean {
		return isStriking_;
	}
	public function update():void {
		
	}
}