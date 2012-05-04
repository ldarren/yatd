package module {
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import org.papervision3d.core.math.Number3D;
	import org.pica.graphics.Renderer;
	import org.pica.graphics.ui.Button;
	import org.pica.graphics.ui.Input;
	import org.pica.graphics.ui.Label;
	import org.pica.graphics.ui.ListBox;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class CaseList implements ICase {
		
		public static const ID:String = Test.CASE_UI_LIST;

		[Embed(source = "../../../res/ui/buttons/but_b.png")]		private var NormBitmapClass:Class;
		[Embed(source = "../../../res/ui/buttons/but_f.png")]		private var OverBitmapClass:Class;
		[Embed(source = "../../../res/ui/buttons/but_a.png")]		private var DownBitmapClass:Class;
		[Embed(source = "../../../res/ui/buttons/but_i.png")]		private var InacBitmapClass:Class;
		[Embed(source = "../../../res/ui/icons/basic_up.png")]		private var upClass:Class;
		[Embed(source = "../../../res/ui/icons/basic_down.png")]	private var downClass:Class;
		[Embed(source = "../../../res/ui/icons/basic_left.png")]	private var leftClass:Class;
		[Embed(source = "../../../res/ui/icons/basic_right.png")]	private var rightClass:Class;
		[Embed(source = "../../../res/ui/icons/facebook_64.png")]	private var iconClass:Class;

		private var list_:ListBox;
		private var list2_:ListBox;
		
		public function CaseList() {
			ListBox.setTheme([new NormBitmapClass(), new OverBitmapClass(), new DownBitmapClass(), new InacBitmapClass()], new Rectangle(0, 0, 10, 19), new Rectangle(3, 9, 4, 1),
				[new upClass(), new downClass(), new leftClass(), new rightClass()]);
			list_ = new ListBox("testList", 160, 70, 4, onButton, ListBox.ALIGN_VERTICAL);
			
			var icon:Bitmap = new iconClass();
			list_.addItem("item_fb", "Facebook", icon);
			list_.addItem("item_fs", "Friendster", icon);
			list_.addItem("item_ms", "Myspace", icon);
			list_.addItem("item_tw", "Twitter", icon);
			list_.addItem("item_bs", "Blogspot", icon);
			list_.addItem("item_gm", "GMail", icon);

			list2_ = new ListBox("testList2", 70, 160, 4, onButton, ListBox.ALIGN_HORIZONTAL);
			list2_.x = 250;
			
			list2_.addItem("item2_fb", "Facebook", icon);
			list2_.addItem("item2_fs", "Friendster", icon);
			list2_.addItem("item2_ms", "Myspace", icon);
			list2_.addItem("item2_tw", "Twitter", icon);
			list2_.addItem("item2_bs", "Blogspot", icon);
			list2_.addItem("item2_gm", "GMail", icon);
		}
		
		public function load(gfx:Renderer):void {
			gfx.setCameraPos(new Number3D(0, 0, -100));
			
			gfx.addOverlay(list_);
			gfx.addOverlay(list2_);
		}
		
		public function unload(gfx:Renderer):void {
			gfx.removeOverlay(list_);
			gfx.removeOverlay(list2_);
		}
		
		public function onEvent(evt:Event):void {
			
		}
		
		public function onUpdate():void {
			
		}
		
		private function onButton(btn:Button):void {
			trace("name: "+btn.name);
		}
		
	}
	
}