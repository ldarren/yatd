package scenes.td {

	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.text.TextField;
	import org.papervision3d.objects.DisplayObject3D;
	import org.pica.graphics.effects.BillBoard;
	import org.pica.graphics.effects.MotionTrail;
	import org.papervision3d.materials.BitmapMaterial;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Wisp extends BillBoard {

		public var trail:MotionTrail;
		public var endPt:int = 1;
		public var startPt:int = 0;
		public var life:int;
		private var maxLife_:int;
		private var sectionLife_:int;
		private var size_:Number;
		static private var blobBDs_:Array;
		static private var trailBDs_:Array;
		static private var maxSet_:int;
		private var currentSet_:int = 0;
		
		public function Wisp(life:int, size:Number, x:Number, y:Number, z:Number) {
			this.life = maxLife_ = life;
			sectionLife_ = maxLife_ / Wisp.maxSet_;
			size_ = size;
			super(new BitmapMaterial(blobBDs_[0]), size, size);
			this.x = x; this.y = y; this.z = z;
			trail = new MotionTrail(trailBDs_[0], this, 7, size_*0.16, 400, 0.0105); // 0.16 is a magic num, the size of the solid portion
		}
		
		public function resetTo(x:Number, y:Number, z:Number):void {
			this.x = x; this.y = y; this.z = z;
			if (trail) trail.resetTo(x, y, z);
			endPt = 1;
			startPt = 0;
			life = maxLife_;
			currentSet_ = 0;
			changeColor();
		}
		
		static public function generateColorSet(colors:Array, size:Number, count:int):void {
			blobBDs_ = new Array();
			trailBDs_ = new Array();
			maxSet_ = count;
			var percent:Number = 1 / count;
			var r1:int = colors[0] >> 16 & 0xff, g1:int = colors[0] >> 8 & 0xff, b1:int = colors[0] & 0xff;
			var r2:int = colors[1] >> 16 & 0xff, g2:int = colors[1] >> 8 & 0xff, b2:int = colors[1] & 0xff;
			var r:int, g:int, b:int;
			var color:uint;
			while (count+1) {
				r = r2 - (r2 - r1) * percent * count;
				g = g2 - (g2 - g1) * percent * count;
				b = b2 - (b2 - b1) * percent * count;
				color = (r << 16) + (g << 8) + b;
				blobBDs_.push(MotionTrail.createGradientTexture(size, GradientType.RADIAL, [color, color], [1, 0], [0x44, 0xFF]));
				trailBDs_.push(MotionTrail.createGradientTexture(size, GradientType.LINEAR, [color, color], [1, 0], [0x66, 0xFF]));
				count--;
			}
		}
		
		public function onHit(damage:int):void {
			life -= damage;
			if (life <= 0) return;
			var s:int = sectionLife_ - life / sectionLife_;
			if (s != currentSet_) {
				currentSet_ = s;
				changeColor();
			}
		}
		
		private function changeColor():void {
			this.material.bitmap = blobBDs_[currentSet_];
			trail.material.bitmap = trailBDs_[currentSet_];
		}
		
	}
	
}
