package org.pica.graphics.effects {
	import flash.display.BitmapData;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.shadematerials.CellMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Sphere;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Orb extends DisplayObject3D {
		
		static public const EFFECT_DELTA:Number = 30;

		private var matOn_:CellMaterial;
		private var matOff_:CellMaterial;
		private var color_:int;
		
		private var sphere_:Sphere;
		private var oldX_:Number;
		private var oldZ_:Number;
		
		public function Orb(size:Number, light:PointLight3D, color:int, dark:int, step:int = 5) {
			color_ = color;
			matOff_ = new CellMaterial(light, color_, dark, step);
			matOn_ = new CellMaterial(light, color_, color_, 3);
			
			sphere_ = new Sphere(matOff_, size);
			this.addChild(sphere_);
			sphere_.useOwnContainer = true;
		}
		
		public function powerOn():void {
			sphere_.material = matOn_;
			sphere_.filters = [new GlowFilter(color_), new BlurFilter()];
		}
		
		public function powerOff():void {
			sphere_.material = matOff_;
			sphere_.filters = [new BlurFilter()];
		}
		
		public function isPoweredOn():Boolean {
			return sphere_.material == matOn_;
		}
		
		protected function isTarget(pos:Number3D, range:Number):Boolean {
			if (pos == null) return false;
			var dx:Number = pos.x - this.x; var dz:Number = pos.z - this.z;
			if ((dx * dx + dz * dz) < range) return true;
			return false;
		}
		
		protected function checkDelta(pos:Number3D):Boolean {
			var dx:Number = pos.x - oldX_; var dz:Number = pos.z - oldZ_;
			if ((dx * dx + dz * dz) < Orb.EFFECT_DELTA) return false;
			oldX_ = pos.x; oldZ_ = pos.z;
			return true;
		}
		
	}
	
}