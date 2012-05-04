package module {
	import flash.events.Event;
	import flash.geom.Rectangle;
	import org.papervision3d.core.math.Number3D;
	import org.pica.graphics.Renderer;
	import org.pica.graphics.ui.BaseUI;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class CaseWindow implements ICase {
		
		public static const ID:String = Test.CASE_UI_WINDOW;
		
		[Embed(source = "../../../res/ui/window/graphite.png")]	private var NormWinClass:Class;
		[Embed(source = "../../../res/ui/window/test.png")]		private var TestWinClass:Class;
		
		private var win1_:BaseUI;
		private var win2_:BaseUI;
		private var win3_:BaseUI;
		
		public function CaseWindow() {
			// test window
			win1_ = new BaseUI();
			with(win1_){
				setSkin([new TestWinClass(), ], new Rectangle(3, 3, 10, 10), new Rectangle(3, 3, 4, 4));
				setSize(607, 303);
				x = 55;
				y = 55;
			}
			// full window
			win2_ = new BaseUI();
			with(win2_){
				setSkin([new NormWinClass(), ], new Rectangle(0, 0, 30, 40), new Rectangle(6, 26, 18, 10));
				setSize(557, 293);
				x = 35;
				y = 35;
			}
			// partial window
			win3_ = new BaseUI();
			with(win3_){
				setSkin([new NormWinClass(), ], new Rectangle(0, 22, 30, 18), new Rectangle(4, 4, 22, 10));
				setSize(477, 277);
				x = 15;
				y = 15;
			}
		}
		
		public function load(gfx:Renderer):void {
			gfx.setCameraPos(new Number3D(0, 0, -100));

			gfx.addOverlay(win1_);
			gfx.addOverlay(win2_);
			gfx.addOverlay(win3_);
		}
		
		public function unload(gfx:Renderer):void {
			gfx.removeOverlay(win1_);
			gfx.removeOverlay(win2_);
			gfx.removeOverlay(win3_);
		}
		
		public function onEvent(evt:Event):void {
			
		}
		
		public function onUpdate():void {
			
		}
		
	}
	
}