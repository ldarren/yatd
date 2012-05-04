package module {
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.pica.graphics.cameras.CameraManIso;
	import org.pica.graphics.Renderer;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class CaseIsoCamera implements ICase {
		
		public static const ID:String = Test.CASE_GFX_ISO_CAMERA;
		
		[Embed (source="../../../res/myflag.png")]		private var texClass_:Class;
		
		private var plane_:Plane;
		private var cameraman_:CameraManIso;
		
		public function CaseIsoCamera() {
			var sprite:Sprite = new Sprite();
			var g:Graphics = sprite.graphics;
			
			g.beginBitmapFill(Bitmap(new texClass_() ).bitmapData, null, false);
			g.drawRect(0, 0, 512, 256);
			g.endFill();
			
			// material's animate param must set to true for decal to work
			var movieMat:MovieMaterial = new MovieMaterial(sprite, false, true);
			
			plane_ = new Plane(movieMat, 512, 256, 10, 10);
			plane_.pitch(90);
			
			cameraman_ = new CameraManIso(100,45);
		}
		
		public function load(gfx:Renderer):void {
//			gfx.setCameraPos(new Number3D(-256, -128, -100));
			cameraman_.changeShot(gfx.camera, new Point(0, 0), new Rectangle( -256, -128, 512, 256));

			gfx.addObj(plane_);
		}
		
		public function unload(gfx:Renderer):void {
			gfx.removeObj(plane_);

			cameraman_.resetShot();
		}
		
		public function onEvent(evt:Event):void {
			var ke:KeyboardEvent = evt as KeyboardEvent;
			switch(evt.type) {
			case KeyboardEvent.KEY_DOWN:
				//trace("keycode: "+ke.keyCode);
				switch(ke.keyCode) {
				case 87: //w
					cameraman_.moveForward(2);
					break;
				case 83: //s
					cameraman_.moveForward(-2);
					break;
				case 65: //a
					cameraman_.moveSide(-2);
					break;
				case 68: //d
					cameraman_.moveSide(2);
					break;
				case 81: //q
					cameraman_.rotate(1);
					break;
				case 69: //e
					cameraman_.rotate(-1);
					break;
				}
				break;
			case KeyboardEvent.KEY_UP:
				//trace("keycode: "+ke.keyCode);
				switch(ke.keyCode) {
				case 87: //w
					cameraman_.moveForward(0);
					break;
				case 83: //s
					cameraman_.moveForward(0);
					break;
				case 65: //a
					cameraman_.moveSide(0);
					break;
				case 68: //d
					cameraman_.moveSide(0);
					break;
				case 81: //q
					cameraman_.rotate(0);
					break;
				case 69: //e
					cameraman_.rotate(0);
					break;
				}
				break;
			}
		}
		
		public function onUpdate():void {
			cameraman_.update();
		}
			
	}
	
}