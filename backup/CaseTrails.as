package module {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.view.Viewport3D;
	
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.special.ParticleMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.objects.special.ParticleField;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.ViewportLayer;

	import org.pica.graphics.Renderer;
	import org.pica.graphics.effects.MotionTrail;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class CaseTrails implements ICase {
		public static const ID:String = Test.CASE_GFX_TRAILS;

		private var targetSphere : Sphere;
		private var trails : Array = [];
		public var flock : Boolean = true;
		private var p:Plane;
		private var p_list:Array;
		private var trail_list:Array;
		private var parts: ParticleField;
		private var parts2:ParticleField;
		
		private var _currentTarget : Number3D = new Number3D();
		private var _currentControl : Number3D = new Number3D();
		
		private var cam_:Camera3D;
		private var viewport_:Viewport3D;
		private var mouseX_:Number, mouseY_:Number;
		
		[Embed(source="D:/SmartFlex/pica/res/concrete.jpg")]
		public var grassAsset : Class;
		
		public function CaseTrails() {
			trail_list = new Array();
			p_list = new Array();
			
			newTarget();
			newControl();
					
			p = new Plane(new MovieMaterial(new grassAsset() as Bitmap), 1800, 1800, 4, 4);
			p.pitch(90);
			p.y = -500;
			
			parts = new ParticleField(new ParticleMaterial(0xFFe9BA, 0.1), 100, 4, 1500, 1500, 1500);
			parts2 = new ParticleField(new ParticleMaterial(0xFFe9BA, 0.1), 100, 4, 1500, 1500, 1500);
			
			/* var textLayer : ViewportLayer = new ViewportLayer(null, null);
			textLayer.forceDepth = true;
			textLayer.screenDepth = 0;
			var text:TextField = new TextField();
			text.text = "press f";
			text.setTextFormat(new TextFormat("Font", 48, 0x999999));
			
			textLayer.addChild(text);
			
			textLayer.blendMode = "multiply";
			viewport.containerSprite.addLayer(textLayer); */
		}
		
		public function load(gfx:Renderer):void {
			//camera.focus = 100;
			//camera.zoom = 10;
			//camera.z = -1600;
			with (gfx) {
				setCameraPos(new Number3D(0, 0, -160));
				addObj(p);
				addObj(parts);
				addObj(parts2);
				cam_ = camera;
				viewport_ = viewport;
			}
			for(var n:int=0;n<22;++n){
				createTrail();
			}
			for each (var i:Plane in p_list) {
				gfx.addObj(i);
			}
			for each (var m:MotionTrail in trail_list) {
				gfx.addObj(m);
			}
		}
		
		public function unload(gfx:Renderer):void {
			for each (var m:MotionTrail in trail_list) {
				gfx.removeObj(m);
			}
			for each (var i:Plane in p_list) {
				gfx.removeObj(i);
			}
			with (gfx) {
				removeObj(parts2);
				removeObj(parts);
				removeObj(p);
			}
		}
		
		public function onEvent(evt:Event):void {
			var ke:KeyboardEvent = evt as KeyboardEvent;
			var me:MouseEvent = evt as MouseEvent;
			switch(evt.type) {
			case KeyboardEvent.KEY_DOWN:
				//trace("keycode: "+ke.keyCode);
				switch(ke.keyCode) {
				case 70: //f
					flock = !flock;
					break;
				}
				break;
			case MouseEvent.MOUSE_MOVE:
				mouseX_ = me.localX;
				mouseY_ = me.localY;
			if (cam_ == null) return;
			for(var i:int=0;i<trails.length;i++){
				updateObject(trails[i] as DisplayObject3D, i);
			}
			
			cam_.x -= (cam_.x-(800*0.5-mouseX_)/(800*0.5)*160)*0.2;
			cam_.y -= (cam_.y-(650*0.5-mouseY_)/(650*0.5)*80)*0.2;
			
			cam_.y = Math.max(-300, cam_.y);
			
			parts.yaw(0.5);
			parts2.yaw(-0.5);
				break;
			}
		}
		
		public function onUpdate():void {
		}
		
		private function createTrail():void{
			var c:uint = Math.random()*0x444444 | 0x999999;
			var add  :BitmapData = new BitmapData(64, 64, true, 0);
			var mat:Matrix = new Matrix();
			mat.createGradientBox(64, 64);
			
			var s:Sprite = new Sprite();
			s.graphics.beginGradientFill(GradientType.RADIAL, [c, c & 0x242424], [1, 0], [0x44, 0xFF], mat);
			s.graphics.drawRect(0, 0, 64, 64);
			s.graphics.endFill();
			add.draw(s);
			
			
			var pp:Plane = new Plane(new MovieMaterial(s, true));
			
			p_list.push(pp);

			pp.x = Math.random()*500-250;
			pp.y = Math.random()*500-250;
			pp.z = Math.random()*500-250;
			
			var scale : Number = Math.random()*0.5 + 0.5;
			pp.scale = scale+0.4;
			pp.extra = new ControlProps(Math.random()*500-250, Math.random()*500-250, Math.random()*500-250, pp.x, pp.y, pp.z, Math.random(), Math.random()*500-250, Math.random()*500-250, Math.random()*500-250);
			
			var trail:MotionTrail = new MotionTrail(MotionTrail.createGradientMovie(c, c), pp, 17, 20 * scale, 400, 0.14 * scale + (Math.random() * 0.1));
			trail_list.push(trail);
			
			var vpl:ViewportLayer = viewport_.getChildLayer(pp);
			vpl.addDisplayObject3D(trail);
			vpl.blendMode = "add";
			trails.push(pp);
		}
		
		private function updateObject(object:DisplayObject3D, i:Number):void{
			
			var props : ControlProps = object.extra as ControlProps;
			
			props.t += 0.035/(2-(object.scale-0.4));
			
			object.x = bezier(props.sx, props.tx, props.t, props.cx);
			object.y = bezier(props.sy, props.ty, props.t, props.cy);
			object.z = bezier(props.sz, props.tz, props.t, props.cz);
			
			object.lookAt(cam_);
			object.yaw(180);
			
			if(props.t >= 0.5){
				
				//reset
				props.sx = object.x;
				props.sy = object.y;
				props.sz = object.z;
				
				if(flock){
					if(i == 0)
					{
						
						newTarget();
						newControl();
					}
					
					props.cx = (props.tx+_currentControl.x)*0.5+ Math.random()*300-150;
					props.cy = (props.ty+_currentControl.y)*0.5+Math.random()*300-150;
					props.cz = (props.tz+_currentControl.z)*0.5+Math.random()*300-150;
					
					props.tx = _currentTarget.x+ Math.random()*300-150;
					props.ty = _currentTarget.y+Math.random()*300-150;
					props.tz = _currentTarget.z+Math.random()*300-150;
				
				
				}else{
					
					props.cx = Math.random()*1000-500;
					props.cy = Math.random()*1000-500;
					props.cz = Math.random()*1000-500;
					props.tx = Math.random()*1000-500;
					props.ty = Math.random()*1000-500;
					props.tz = Math.random()*1000-500;
				}
							
				
				
				props.t = 0;
				
			}
			
		}
		
		private function newTarget():void{
			_currentTarget.reset(Math.random()*1000-500, Math.random()*1000-500, Math.random()*1000-500);
			
		}
		
		private function newControl():void{
			_currentControl.reset(Math.random()*1000-500, Math.random()*1000-500, Math.random()*1000-500);
		}
		
		private function bezier(start:Number, end:Number, t:Number, p:Number):Number {
		
			return start + t*(2*(1-t)*(p-start) + t*(end - start)); 
		}
		
	}
	
}

internal class ControlProps {
	public var tx : Number;
	public var ty : Number;
	public var tz : Number;
	public var sx : Number;
	public var sy : Number;
	public var sz : Number;
	public var t : Number;
	public var cx : Number;
	public var cy : Number;
	public var cz : Number;
	public function ControlProps(tx : Number, ty :Number, tz :Number, sx :Number, sy:Number, sz:Number, t:Number, cx:Number, cy:Number, cz:Number){
		this.tx = tx;
		this.ty = ty;
		this.tz = tz;
		this.sx = sx;
		this.sy = sy;
		this.sz = sz;
		this.t = t;
		this.cx = cx;
		this.cy = cy;
		this.cz =cz;
	}
}