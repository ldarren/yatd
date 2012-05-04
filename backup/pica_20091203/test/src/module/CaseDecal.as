package module {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.pica.graphics.effects.Decal;
	import org.pica.graphics.Renderer;
	import org.pica.graphics.ui.Picker3D;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class CaseDecal implements ICase {
		
		public static const ID:String = Test.CASE_GFX_DECAL;
		
		[Embed (source="../../../res/snakeskin.jpg")]		private var texClass_:Class;
		
		private var plane_:Plane;
		private var decal_:Decal;
		
		public function CaseDecal() {
			var sprite:Sprite = new Sprite();
			var g:Graphics = sprite.graphics;
			
			g.beginBitmapFill(Bitmap(new texClass_() ).bitmapData, null, true);
			g.drawRect(0, 0, 320, 240);
			g.endFill();
			
			// material's animate param must set to true for decal to work
			var movieMat:MovieMaterial = new MovieMaterial(sprite, false, true, false);
			
			plane_ = new Plane(movieMat, 320, 240, 1, 1);
			
			decal_ = new Decal("sqr", plane_, 0.3);
		}
		
		public function load(gfx:Renderer):void {
			gfx.setCameraPos(new Number3D(0, 0, -200));

			gfx.addObj(plane_);
			Picker3D.setPickable(plane_);
		}
		
		public function unload(gfx:Renderer):void {
			Picker3D.setPickable(plane_, false);
			gfx.removeObj(plane_);
		}
		
		public function onEvent(evt:Event):void {
			switch (evt.type) {
			case MouseEvent.MOUSE_MOVE:
				var me:MouseEvent = evt as MouseEvent;
				Picker3D.hitTest();
				var pt:Point = new Point;
				if (Picker3D.getPickedPoint(plane_, pt)) {
					decal_.clear();
					decal_.drawSquare(pt.x, pt.y, 20, 20, 0xff0000);
				}
				break;
			}
		}
		
		public function onUpdate():void {
		}
		
	}
	
}