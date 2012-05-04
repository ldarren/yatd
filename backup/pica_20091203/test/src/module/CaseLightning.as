package module {
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.pica.graphics.effects.Lightning;
	import org.pica.graphics.effects.Orb;
	import org.pica.graphics.Renderer;
	import org.pica.graphics.ui.Button;

	/**
	 * ...
	 * @author Darren Liew
	 */
	public class CaseLightning implements ICase {
		
		public static const ID:String = Test.CASE_GFX_LIGHTNING;
		
		[Embed(source = "../../../res/ui/buttons/but_b.png")]		private var NormBitmapClass:Class;
		[Embed(source = "../../../res/ui/buttons/but_f.png")]		private var OverBitmapClass:Class;
		[Embed(source = "../../../res/ui/buttons/but_a.png")]		private var DownBitmapClass:Class;
		[Embed(source = "../../../res/ui/buttons/but_i.png")]		private var InacBitmapClass:Class;
		
		private var light_:PointLight3D;
		
		private var btnStrike_:Button;
		
		private var sphereR_:Orb;
		private var sphereG_:Orb;
		private var sphereB_:Orb;
		
		private var lightning_:Lightning;
		
		private var timer_:Timer;
		
		public function CaseLightning() {
			Button.setDefaultTheme([new NormBitmapClass(), new OverBitmapClass(), new DownBitmapClass(), new InacBitmapClass()], new Rectangle(0, 0, 10, 19), new Rectangle(3, 9, 4, 1));
			btnStrike_ = new Button("btn_strike", "Strike", null, {up:onButton}, 10, 10);
			
			light_ = new PointLight3D(true);
			light_.position = new Number3D(0, 0, 0);

			sphereR_ = new Orb(10, light_, 0xff5466, 0x330406, 5);
			sphereG_ = new Orb(10, light_, 0x54ff66, 0x043306, 5);
			sphereB_ = new Orb(10, light_, 0x5466ff, 0x040633, 5);

			sphereR_.position = new Number3D(0, -70, 0);
			sphereG_.position = new Number3D(-50, 50, 0);
			sphereB_.position = new Number3D(50, 50, 0);
			
			lightning_ = new Lightning(0x5C98EF, 0.75, 1, 8, 15, 3);
			
			timer_ = new Timer(1000);
			timer_.addEventListener(TimerEvent.TIMER, off);
		}
		
		public function load(gfx:Renderer):void {
			gfx.setCameraPos(new Number3D(0, 0, -100));

			gfx.addOverlay(btnStrike_);
			
			gfx.addObj(light_);
			gfx.addObj(lightning_);
			gfx.addObj(sphereR_);
			gfx.addObj(sphereG_);
			gfx.addObj(sphereB_);
		}
		
		public function unload(gfx:Renderer):void {
			gfx.removeObj(sphereR_);
			gfx.removeObj(sphereG_);
			gfx.removeObj(sphereB_);
			gfx.removeObj(lightning_);
			gfx.removeObj(light_);

			gfx.removeOverlay(btnStrike_);
		}
		
		public function onEvent(evt:Event):void {
			var me:MouseEvent = evt as MouseEvent;
			switch (evt.type) {
			case MouseEvent.MOUSE_MOVE:
				if (!timer_.running) break;
				lightning_.retarget("dyn", 0, -70, 0, (me.localX - 400) * 0.2439, (325 - me.localY) * 0.2439, 0);
				break;
			case MouseEvent.MOUSE_WHEEL:
				break;
			case MouseEvent.MOUSE_UP:
				lightning_.addBolt("dyn", 0, -70, 0, (me.localX - 400) * 0.2439, (325 - me.localY) * 0.2439, 0);
				striko();
				break;
			}
		}
		
		public function onUpdate():void {
			lightning_.update();
		}
		
		private function onButton(btn:Button):void {
			striko();
		}
		
		private function striko():void {
			if (timer_.running) return;

			var path:Array = new Array();
			path.push(new Vertex3D(0, -70, 0));
			path.push(new Vertex3D(-50, 50, 0));
			path.push(new Vertex3D(50, 50, 0));
			lightning_.addBolts("static", path);

			sphereR_.powerOn();
			sphereG_.powerOn();
			sphereB_.powerOn();
			lightning_.strike(true);
			timer_.start();
		}
		
		private function off(evt:TimerEvent):void {
			sphereR_.powerOff();
			sphereG_.powerOff();
			sphereB_.powerOff();
			lightning_.clearBolts();
			lightning_.strike(false);
			timer_.stop();
		}
		 
	}
	
}