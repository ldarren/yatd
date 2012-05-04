package module {
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.pica.graphics.cameras.CameraManIso;
	import org.pica.graphics.effects.LightBeam;
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
		
		[Embed (source="../../../res/tex/portal.png")]	private var portalClass_:Class;
		[Embed (source="../../../res/myflag.png")]		private var texClass_:Class;
		[Embed (source="../../../res/mask.png")]		private var maskClass_:Class;
		
		private var plane_:Plane;
		private var beam_:LightBeam;
		private var bg_:Plane;
		private var bmp_:Object2D;
		
		private var cameraman_:CameraManIso;
		
		public function CasePortal() {
			bmp_ = new Object2D("Water");
			//bmp_.load("../../res/portal.png", 64, 64, 0x00ffffff, onLoaded);
			var mats:Array = new Array();
			mats = mats.concat([1, 0, 0, 0, 0]); // red
			mats = mats.concat([0, 0, 0, 0, 0]); // green
			mats = mats.concat([0, 0, 0, 0, 0]); // blue
			mats = mats.concat([0, 0, 1, 0, 0]); // alpha
			bmp_.load("../../res/water.jpg", 64, 64, onLoaded, 0x00aaaaaa, new ColorMatrixFilter(mats), Bitmap(new maskClass_()).bitmapData);
			
			plane_ = new Plane(null, 128, 128, 10, 10);
			plane_.pitch(90);
			plane_.position = new Number3D(128, 10, 64);
			
			beam_ = new LightBeam(new portalClass_,16, 64, 1, 1, 1);
			beam_.position = new Number3D(0, 40, 0);

			bg_ = new Plane(new BitmapMaterial(Bitmap(new texClass_()).bitmapData),0,0,10,10);
			bg_.pitch(90);
			
			cameraman_ = new CameraManIso(200,45);
		}
		
		public function load(gfx:Renderer):void {
			cameraman_.changeShot(gfx.camera, new Point(0, 0), new Rectangle( -256, -128, 512, 256));

			gfx.addObj(bg_);
			gfx.addObj(plane_);
			gfx.addObj(beam_);
		}
		
		public function unload(gfx:Renderer):void {
			gfx.removeObj(beam_);
			gfx.removeObj(plane_);
			gfx.removeObj(bg_);
			
			cameraman_.resetShot();
		}
		
		public function onEvent(evt:Event):void {
		}
		
		public function onUpdate():void {
			cameraman_.update();
			
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
