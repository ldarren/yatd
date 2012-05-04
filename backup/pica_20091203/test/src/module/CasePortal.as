package module {
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.pica.graphics.effects.SpriteGroup;
	import org.pica.graphics.loader.Object2D;
	import org.pica.graphics.Renderer;
	import org.pica.utils.Random;
	import org.papervision3d.core.math.Number3D;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class CasePortal implements ICase {
		
		public static const ID:String = Test.CASE_GFX_PORTAL;
		
		[Embed (source="../../../res/myflag.png")]		private var texClass_:Class;
		[Embed (source="../../../res/mask.png")]		private var maskClass_:Class;
		
		private var plane_:Plane;
		private var bg_:Plane;
		private var bmp_:Object2D;
		
		public function CasePortal() {
			bmp_ = new Object2D("Water");
			//bmp_.load("D:/SmartFlex/pica/res/portal.png", 64, 64, 0x00ffffff, onLoaded);
			var mat:Array = new Array();
			mat = mat.concat([1, 0, 0, 0, 0]); // red
			mat = mat.concat([0, 0, 0, 0, 0]); // green
			mat = mat.concat([0, 0, 0, 0, 0]); // blue
			mat = mat.concat([0, 0, 1, 0, 0]); // alpha
			bmp_.load("../../res/water.jpg", 64, 64, 0x00aaaaaa, onLoaded, new ColorMatrixFilter(mat), Bitmap(new maskClass_()).bitmapData);
			
			plane_ = new Plane(null, 256, 256, 0, 0);
			plane_.position=new Number3D(0, 0, -10);
			bg_ = new Plane(new BitmapMaterial(Bitmap(new texClass_()).bitmapData));
		}
		
		public function load(gfx:Renderer):void {
			gfx.setCameraPos(new Number3D(0, 0, -300));

			gfx.addObj(bg_);
			gfx.addObj(plane_);
		}
		
		public function unload(gfx:Renderer):void {
			gfx.removeObj(plane_);
			gfx.removeObj(bg_);
		}
		
		public function onEvent(evt:Event):void {
		}
		
		public function onUpdate():void {
			bmp_.animate(67);
			plane_.material.bitmap = bmp_.currentFrame;
		}
		
		private function onLoaded(bmp:Object2D):void {
			bmp.addAnimation("all", { start:0, end:15, fps:5 } );
			bmp.play("all");
			plane_.material = new BitmapMaterial(bmp.currentFrame);
		}
		
	}
	
}
