package org.pica.graphics.effects {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import org.papervision3d.core.data.UserData;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.pica.graphics.loader.Object2D;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class SpriteGroup extends DisplayObject3D {
		
		private var spares_:Array;
		private var resource_:Object2D;
		private var radius_:uint;
		
		public function SpriteGroup(name:String) {
			super(name);
		}
		
		public function init( bitmap:Object2D, count:uint):void {
			resource_ = bitmap;
			
			spares_ = new Array();
			
			var i:int = -1;
			var b:BillBoard;
			var asset:BitmapData;
			var bm:BitmapMaterial;
			while (++i < count) {
				resource_.animate(0);
				asset = resource_.bitmapData;
				bm = new BitmapMaterial(asset);
				b = new BillBoard(bm);
				b.frame = resource_.currentFrameIdx;
				spares_.push(b); 
			}
			
			radius_ = (asset.width+asset.height)/2;
		}
		
		public function get radius():Number {
			return radius_;
		}
		
		public function createSprite(x:Number, y:Number, z:Number):BillBoard {
			var b:BillBoard = spares_.pop() as BillBoard;
			b.x = x;
			b.y = y;
			b.z = z;
			this.addChild(b);
			return b;
		}
		
		// each billboard has it's own frame count, but all sharing one bimpmap resource
		public function animate(elapsed:uint):void {
			var a:Object;
			if (resource_ == null || (a = resource_.currAnimation) == null) return;
			//resource_.animate();
			
			var frame:uint;
			var b:BillBoard;
			var s:uint = a.start;
			var e:uint = a.end;
			for each (var key:* in this._children) {
				b = this._childrenByName[key];
			
				b.elapsed += elapsed;
				if (b.elapsed < a.period) continue;
				b.elapsed = 0;

				frame = b.frame;
				if (frame++ >= e)
					frame = s;
				b.frame = frame;
				b.material.bitmap = resource_.getFrame(frame);
			}
		}
		
		private function onDone(p:DisplayObject3D):void {
			this.removeChild(p);
			spares_.push(p);
		}
		
	}
	
}