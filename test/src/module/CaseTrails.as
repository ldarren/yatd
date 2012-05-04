package module {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.special.LineMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.pica.graphics.cameras.CameraManIso;
	import org.pica.graphics.effects.BillBoard;
	import org.pica.graphics.effects.MotionTrail;
	import org.pica.graphics.Renderer;
	import org.pica.graphics.ui.Button;
	import org.pica.graphics.ui.Picker3D;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class CaseTrails implements ICase {
		
		public static const ID:String = Test.CASE_GFX_TRAILS;
		
		[Embed(source = "../../../res/tex/concrete.jpg")]		private var texClass_:Class;
		[Embed(source = "../../../res/ui/buttons/but_b.png")]	private var NormBitmapClass:Class;
		[Embed(source = "../../../res/ui/buttons/but_f.png")]	private var OverBitmapClass:Class;
		[Embed(source = "../../../res/ui/buttons/but_a.png")]	private var DownBitmapClass:Class;
		[Embed(source = "../../../res/ui/buttons/but_i.png")]	private var InacBitmapClass:Class;
		
		private var plane_:Plane;
		private var cameraman_:CameraManIso;
		
		private var checkPoints_:Lines3D;
		private var blobs_:Array;
		private var trails_:Array;
		private var endPoint_:int = 1;
		private var startPoint_:int = 0;
		private var radius_:Number = 25;
		
		private var btnStart_:Button;
		private var btnStop_:Button;
		private var runMode_:Boolean = false;
		
		public function CaseTrails() {
			var sprite:Sprite = new Sprite();
			
			with (sprite.graphics) {
				beginBitmapFill(Bitmap(new texClass_() ).bitmapData, null, true);
				drawRect(0, 0, 512, 512);
				endFill();
			}
			
			// material's animate param must set to true for decal to work
			var movieMat:MovieMaterial = new MovieMaterial(sprite, false, true);
			
			plane_ = new Plane(movieMat, 512, 512, 10, 10);
			plane_.pitch(90);
			
			cameraman_ = new CameraManIso(200,45);
			
			var redMat:LineMaterial = new LineMaterial(0xff0000);
			checkPoints_ = new Lines3D(redMat);
			
			blobs_ = new Array();
			trails_ = new Array();
			createBlobs();
			
			Button.setDefaultTheme([new NormBitmapClass(), new OverBitmapClass(), new DownBitmapClass(), new InacBitmapClass()], new Rectangle(0, 0, 10, 19), new Rectangle(3, 9, 4, 1));
			btnStart_ = new Button("trailsstart", "Start", null, {up:onButton}, 10, 10);
			btnStop_ = new Button("trailsend", "End", null, {up:onButton}, 10, 50);
		}
		
		public function load(gfx:Renderer):void {
			cameraman_.changeShot(gfx.camera, new Point(0, 0), new Rectangle( -256, -256, 512, 512));

			with (gfx) {
				addObj(plane_);
				addObj(checkPoints_);
				addOverlay(btnStart_);
				addOverlay(btnStop_);
				
				for each (var b:BillBoard in blobs_) {
					addObj(b);
				}
				for each (var t:MotionTrail in trails_) {
					addObj(t);
				}
			}
			
			Picker3D.setPickable(plane_, true);
		}
		
		public function unload(gfx:Renderer):void {
			Picker3D.setPickable(plane_, false);
			
			with (gfx) {
				for each (var t:MotionTrail in trails_) {
					removeObj(t);
				}
				for each (var b:BillBoard in blobs_) {
					removeObj(b);
				}
				
				removeObj(plane_);
				removeObj(checkPoints_);
				removeOverlay(btnStart_);
				removeOverlay(btnStop_);
			}

			cameraman_.resetShot();
		}
		
		public function onEvent(evt:Event):void {
			var ke:KeyboardEvent = evt as KeyboardEvent;
			switch(evt.type) {
			case KeyboardEvent.KEY_DOWN:
				//trace("keycode: "+ke.keyCode);
				switch(ke.keyCode) {
				case 87: //w
					cameraman_.moveForward(5);
					break;
				case 83: //s
					cameraman_.moveForward(-5);
					break;
				case 65: //a
					cameraman_.moveSide(-5);
					break;
				case 68: //d
					cameraman_.moveSide(5);
					break;
				case 81: //q
					cameraman_.rotate(2);
					break;
				case 69: //e
					cameraman_.rotate(-2);
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
			case MouseEvent.MOUSE_UP:
				if (runMode_) break;
				Picker3D.hitTest();
				var pt:Point = Picker3D.getPoint();
				if (pt.x != -1) {
					var x:Number = pt.x - 256;
					var y:Number = -pt.y + 256;
					checkPoints_.addNewLine(1, x, 0, y, x, 50, y);
				}
				break;
			}
		}
		
		public function onUpdate():void {
			cameraman_.update();
			
			if (runMode_) moveBlobs(66.67);
		}
		
		private function onButton(btn:Button):void {
			if (checkPoints_.lines.length > 0 && btn.name == "trailsstart") {
				runMode_ = true;
				var v:Vertex3D = Line3D(checkPoints_.lines[0]).v0;
				var b:BillBoard = blobs_[0] as BillBoard;
				b.position=new Number3D(v.x,40,v.z);
			}
			else {
				runMode_ = false;
				startPoint_ = 0;
				endPoint_ = 1;
				checkPoints_.removeAllLines();
			}
				
			for each (b in blobs_) {
				b.visible = runMode_;
			}
			for each (var t:MotionTrail in trails_) {
				t.visible = runMode_;
			}
		}
		
		private function createBlobs(count:uint=1):void {
			var c:uint = Math.random()*0x444444 | 0x999999;
			var add:BitmapData = new BitmapData(64, 64, true, 0);
			var mat:Matrix = new Matrix();
			mat.createGradientBox(64, 64);
			
			var s:Sprite = new Sprite();
			with (s.graphics) {
				beginGradientFill(GradientType.RADIAL, [c, c & 0x242424], [1, 0], [0x44, 0xFF], mat);
				drawRect(0, 0, 64, 64);
				endFill();
			}
			add.draw(s);
			
			var bill:BillBoard;
			var trail:MotionTrail;
			for (var i:int = 0; i < count;++i) {
				bill = new BillBoard(new BitmapMaterial(add), 64, 64);
				bill.visible = false;
				
				trail = new MotionTrail(MotionTrail.createGradientTexture(64, GradientType.LINEAR, [c, c], [1, 0], [0x66, 0xFF]), bill, 7, 10, 400, 0.01 + (Math.random() * 0.1));

				blobs_.push(bill);
				trails_.push(trail);
			}
		}
		
		private function moveBlobs(elapsed:Number):void {
			var end:Number3D = Line3D(checkPoints_.lines[endPoint_]).v0.getPosition();
			var start:Number3D = Line3D(checkPoints_.lines[startPoint_]).v0.getPosition();
			var curr:Number3D;
			var dx:Number, dz:Number;
			for each (var b:BillBoard in blobs_) {
				curr = b.position;
				dx = end.x - curr.x; dz = end.z - curr.z;
				if (dx * dx + dz * dz < radius_) {
					startPoint_ = endPoint_;
					++endPoint_;
					if (endPoint_ >= checkPoints_.lines.length) endPoint_ = 0;
					end = Line3D(checkPoints_.lines[endPoint_]).v0.getPosition();
					start = Line3D(checkPoints_.lines[startPoint_]).v0.getPosition();
				}
				b.position = new Number3D(curr.x+0.1*(end.x-start.x), 40, curr.z+0.1*(end.z-start.z));
			}
		}
			
	}
	
}