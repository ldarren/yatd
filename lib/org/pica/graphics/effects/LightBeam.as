package org.pica.graphics.effects {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cylinder;
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class LightBeam extends Cylinder {
		
		private var baseBD_:BitmapData;
		private var normalBD_:BitmapData;
		
		public function LightBeam(bmp:Bitmap, rad:Number, height:Number, red:Number, green:Number, blue:Number ) {
			baseBD_ = bmp.bitmapData as BitmapData;
			normalBD_= tint(red, green, blue);

			var mat:BitmapMaterial = new BitmapMaterial(normalBD_);
			mat.doubleSided = true;
			super(mat, rad, height, 8, 6, rad*1.5, false, false);
		}
		
		public function setColor(red:Number, green:Number, blue:Number):void {
			var bmpmat:BitmapMaterial = this.material as BitmapMaterial;
			bmpmat.bitmap = tint(red, green, blue);
		}
		
		public function resetColor():void {
			var bmpmat:BitmapMaterial = this.material as BitmapMaterial;
			bmpmat.bitmap = normalBD_;
		}
		
		public override function project(parent:DisplayObject3D, renderSessionData:RenderSessionData):Number {
			this.yaw(1);
			return super.project(parent, renderSessionData);
		}
		
		private function tint(red:Number, green:Number, blue:Number):BitmapData {
			var arr:Array = [ red,0,0,0,0, 0,green,0,0,0, 0,0,blue,0,0, 0,0,0,1,0 ];
			var colorMat:ColorMatrixFilter = new ColorMatrixFilter(arr);

			var newDB_:BitmapData = new BitmapData(baseBD_.width, baseBD_.height, true);
			newDB_.applyFilter(baseBD_, new Rectangle(0, 0, baseBD_.width, baseBD_.height), new Point(), colorMat);
			return newDB_;
		}
		
	}

}