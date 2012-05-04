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
			sectionLife_ = maxLife_ / maxSet_;
			size_ = size;
			super(new BitmapMaterial(blobBDs_[0]), size, size);
			this.x = x; this.y = y; this.z = z;
			trail = new MotionTrail(trailBDs_[0], this, 7, 10, 400, 0.0105);
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
			var percent:Number;
			var color:uint;
			while (count) {
				percent = count / maxSet_;
				color = colors[0] * percent + colors[1] * (1 - percent);
				blobBDs_.push(MotionTrail.createGradientTexture(size, GradientType.RADIAL, [color, color], [1, 0], [0x44, 0xFF]));
				trailBDs_.push(MotionTrail.createGradientTexture(size, GradientType.LINEAR, [color, color], [1, 0], [0x66, 0xFF]));
				count--;
			}
		}
		
		public function onHit(damage:int):void {
			life -= damage;
			if (life <= 0) return;
			if ((life % sectionLife_) == 0) changeColor();
		}
		
		private function changeColor():void {
			/*if (currentSet_ >= maxSet_) {
				return;
			}*/
			this.material.bitmap = blobBDs_[currentSet_];
			trail.material.bitmap = trailBDs_[currentSet_];
			currentSet_++;
		}
		
	}
	
}
