package module {
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import org.papervision3d.core.math.Number3D;
	import org.pica.graphics.Renderer;
	import org.pica.graphics.ui.Button;
	import org.pica.graphics.ui.Input;
	import org.pica.graphics.ui.Label;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class CaseButton implements ICase {
		
		public static const ID:String = Test.CASE_UI_BUTTON;
		
		[Embed(source = "../../../res/ui/buttons/but_b.png")]		private var NormBitmapClass:Class;
		[Embed(source = "../../../res/ui/buttons/but_f.png")]		private var OverBitmapClass:Class;
		[Embed(source = "../../../res/ui/buttons/but_a.png")]		private var DownBitmapClass:Class;
		[Embed(source = "../../../res/ui/buttons/but_i.png")]		private var InacBitmapClass:Class;
		[Embed(source = "../../../res/ui/icons/facebook_32.png")]	private var iconClass:Class;
		
		private var btnIconTextLeft:Button;
		private var btnIconTextUp:Button;
		private var btnIconTextRight:Button;
		private var btnIconTextDown:Button;
		private var btnIcon:Button;
		private var btnText:Button;
		
		private var btnTrigger:Button;
		private var txtSource_:Input;
		private var lblTarget_:Label

		private var btnRadio:Button;
		
		public function CaseButton() {
			var bmpNorm:Bitmap = new NormBitmapClass(), bmpOver:Bitmap = new OverBitmapClass(), bmpDown:Bitmap = new DownBitmapClass(), bmpInac:Bitmap = new InacBitmapClass();
			var outer:Rectangle = new Rectangle(0, 0, 10, 19), inner:Rectangle = new Rectangle(3, 9, 4, 1);
			Input.setTheme([bmpDown, bmpDown, bmpDown, bmpInac], outer, inner);
			Button.setDefaultTheme([bmpNorm, bmpOver, bmpDown, bmpInac], outer, inner);
			
			txtSource_ = new Input("txt_src", "Type something here", 10, 20, 180, 20, { multiline:false, wordWrap:true } );
			btnTrigger = new Button("btn_trigger", "Copy ->", null, {up:onButton}, 10, 120);
			lblTarget_ = new Label("lbl_src", "Result: ", 10, 220, 200, 20);

			var icon:Bitmap = new iconClass();
			btnRadio = new Button("btn_radio", "Radio", [icon], { up:onButton }, 10, 320);
			btnRadio.toggle = true;
			
			btnIconTextLeft = new Button("btn_icontextleft", "Facebook", [icon], { up:onButton }, 200, 10, -1, -1, Button.ICON_LEFT);
			btnIconTextUp = new Button("btn_icontexttop", "Facebook", [icon], {up:onButton}, 200, 110, -1, -1, Button.ICON_UP);
			btnIconTextRight = new Button("btn_icontextright", "Facebook", [icon], {up:onButton}, 200, 210, -1, -1, Button.ICON_RIGHT);
			btnIconTextDown = new Button("btn_icontextdown", "Facebook", [icon], {up:onButton}, 200, 310, -1, -1, Button.ICON_DOWN);
			btnIcon = new Button("btn_icon", "", [icon], {up:onButton}, 200, 410, -1, -1, Button.ICON_DOWN);
			btnText = new Button("btn_text", "Facebook", null, {up:onButton}, 200, 510, -1, -1, Button.ICON_DOWN);
		}
		
		public function load(gfx:Renderer):void {
			gfx.setCameraPos(new Number3D(0, 0, -100));

			gfx.addOverlay(btnTrigger);
			gfx.addOverlay(txtSource_);
			gfx.addOverlay(lblTarget_);

			gfx.addOverlay(btnRadio);

			gfx.addOverlay(btnIconTextLeft);
			gfx.addOverlay(btnIconTextUp);
			gfx.addOverlay(btnIconTextRight);
			gfx.addOverlay(btnIconTextDown);
			gfx.addOverlay(btnIcon);
			gfx.addOverlay(btnText);
		}
		
		public function unload(gfx:Renderer):void {
			gfx.removeOverlay(btnTrigger);
			gfx.removeOverlay(txtSource_);
			gfx.removeOverlay(lblTarget_);

			gfx.removeOverlay(btnRadio);
			
			gfx.removeOverlay(btnIconTextLeft);
			gfx.removeOverlay(btnIconTextUp);
			gfx.removeOverlay(btnIconTextRight);
			gfx.removeOverlay(btnIconTextDown);
			gfx.removeOverlay(btnIcon);
			gfx.removeOverlay(btnText);
		}
		
		public function onEvent(evt:Event):void {
			
		}
		
		public function onUpdate():void {
			
		}
		
		private function onButton(btn:Button):void {
			lblTarget_.text = txtSource_.text;
		}
		
	}
	
}