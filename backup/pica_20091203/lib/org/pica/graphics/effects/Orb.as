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

		private var matOn_:CellMaterial;
		private var matOff_:CellMaterial;
		private var color_:int;
		
		private var sphere_:Sphere;
		
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
		
	}
	
}