package org.pica.graphics.effects {
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import org.papervision3d.core.data.UserData;
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.materials.special.LineMaterial;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Lightning extends Lines3D {
		
		private var isStriking_:Boolean = false;
		private var weight_:uint;
		private var steps_:uint;		// number of steps for a light
		private var freq_:Number;		// 1/segment: segment is number of pixel per segment
		private var minLength_:uint;	// if a line shorter than minLength_, use less steps
		private var minSteps_:uint;		// min steps when len is less than minLenght
		private var branch_:uint;
		
		public function Lightning(color:int, alpha:Number, weight:uint, segments:uint, steps:uint, branch:uint) {
			super(new LineMaterial(color, alpha));
			
			weight_ = weight;
			steps_ = steps;
			freq_ = 1 / segments;
			minLength_ = segments * steps_;
			minLength_ *= minLength_;
			minSteps_ = steps_ * 0.33;
			branch_ = branch;

			// parent already has filter
			this.useOwnContainer = true;
			this.filters = [new GlowFilter(color)];
			
			strike(false);
		}
		
		public function clearBolts():void {
			this.removeAllLines();
		}
		
		public function removeBolt(name:String):void {
			var trash:Array = new Array();
			var l:Line3D;
			for each (l in this.lines) {
				if (l.userData.data as String == name) trash.push(l);
			}
			
			for each (l in trash) this.removeLine(l);
		}
		
		public function addBolts(name:String, bolts:Array):void {
			var from:Vertex3D, to:Vertex3D;
			for (var n:int = 1; n < bolts.length;++n) {
				from = bolts[n - 1] as Vertex3D;
				to = bolts[n] as Vertex3D;
				this.addBolt(name, from.x, from.y, from.z, to.x, to.y, to.z);
			}
			from = bolts[bolts.length-1] as Vertex3D;
			to = bolts[0] as Vertex3D;
			this.addBolt(name, from.x, from.y, from.z, to.x, to.y, to.z);
		}
		
		public function addBolt(name:String, fromX:Number, fromY:Number, fromZ:Number, toX:Number, toY:Number, toZ:Number):void {
			var len:uint, s:uint, x:uint, y:uint, z:uint;
			var unnamed:Array;
			x = fromX - toX; y = fromY - toY; z = fromZ - toZ;
			len = x * x + y * y + z * z;
			s = (minLength_ > len) ? /*Math.sqrt(len) * freq_*/minSteps_ : steps_;
			
			for (var b:int = 0; b < branch_;++b) {
				unnamed = this.addNewSegmentedLine(weight_, s, fromX, fromY, fromZ, toX, toY, toZ);
				for each (var l:Line3D in unnamed) l.userData = new UserData(name);
			}
		}
		
		public function strike(on:Boolean):void {
			isStriking_ = on;// && this.lines.length > 0;
			this.visible = isStriking_;
		}
		
		public function isStriking():Boolean {
			return isStriking_;
		}
		
		public function retarget(name:String, fromX:Number, fromY:Number, fromZ:Number, toX:Number, toY:Number, toZ:Number):void {
			removeBolt(name);
			addBolt(name, fromX, fromY, fromZ, toX, toY, toZ);
		}
		
		public function update():void {
			if (isStriking_) {
				var r1:Number, r2:Number, r3:Number;
				for each (var line:Line3D in this.lines) {
					r1 = Math.random() - 0.5; r2 = Math.random() - 0.5; r3 = Math.random() - 0.5;
					line.v0.x += r1;
					line.v0.y += r2;
					line.v0.x += r3;
					line.v1.x += r2;
					line.v1.y += r3;
					line.v1.x += r1;
				}
			}
		}
		
	}
	
}