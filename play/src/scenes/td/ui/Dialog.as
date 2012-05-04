package scenes.td.ui {
	import flash.display.Stage;
	import org.pica.graphics.ui.Button;
	import org.pica.graphics.ui.Window;
	import scenes.td.events.TowerEventDispatcher;
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Dialog	{
		
		public var hidden:Boolean = true;
		protected var _stage:Stage;

		protected var _window:Window;
		private var btn_close_:Button;
		
		public var dispatcher:TowerEventDispatcher;
		
		public function Dialog(title:String, name:String, stage:Stage, x:Number, y:Number, w:Number, h:Number) {
			dispatcher = new TowerEventDispatcher(name);
			
			_stage = stage;
			_window = new Window(name, title, x, y, w, h);
			//_window.setSkin(win_skins, new Rectangle(0, 22, 30, 18), new Rectangle(4, 4, 22, 10));
			//_window.setSkin(win_skins, new Rectangle(0, 0, 46, 32), new Rectangle(22, 22, 2, 2));
			
			btn_close_ = new Button("btn_close", "", null, {up:onClick}, _window.logicalWidth - 15, 5, 10, 10);
		}
		
		public function enableClose(enable:Boolean):void {
			if (enable) {
				_window.addChild(btn_close_);
			} else {
				_window.removeChild(btn_close_);
			}
		}
		
		protected function show(visible:Boolean):void {
			hidden = !visible;
			if (visible) {
				_stage.addChild(_window);
				_window.showModal();
			} else {
				_window.hideModal();
				_stage.removeChild(_window);
			}
		}
		
		private function onClick(btn:Button):void {
			switch (btn.name) {
			case "btn_close":
				show(false);
				break;
			}
		}
		
	}

}