package scenes.td.ui {
	import flash.display.Stage;
	import org.pica.graphics.ui.Button;
	import scenes.td.events.GameEvent;
	import scenes.td.events.TowerEvent;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class BuildOption extends Dialog {
		
		private var btn_opt1_:Button;
		private var btn_opt2_:Button;
		private var btn_cancel_:Button;
		private var btn_width_:Number;
		private var btn_height_:Number;
		
		private var mode_:int = 0;
		
		public function BuildOption(stage:Stage, x:Number, y:Number, w:Number, h:Number) {
			super("Build Option", "optwin", stage, x, y, w, h);
			//_window.setSkin(win_skins, new Rectangle(0, 22, 30, 18), new Rectangle(4, 4, 22, 10));
			//_window.setSkin(win_skins, new Rectangle(0, 0, 46, 32), new Rectangle(22, 22, 2, 2));
			
			btn_width_ = w - 20;
			btn_height_ = 30;
			btn_opt1_ = new Button("option1", "Option One", null, { up:onButton }, 17, 30, btn_width_, btn_height_ );
			btn_opt2_ = new Button("option2", "Option Second", null, { up:onButton }, 17, 60, btn_width_, btn_height_ );
			btn_cancel_ = new Button("opt_cancel", "Cancel", null, { up:onButton }, 17, 90, btn_width_, btn_height_ );
		}
		
		public function onShow(visible:Boolean, mode:int):void {
			super.show(visible);
			if (visible) {
				mode_ = mode;
				if (mode_ == 1) {
					btn_opt1_.setContent("Destroy Tower", null, btn_width_, btn_height_);
					_window.addChild(btn_opt1_);
					_window.addChild(btn_cancel_);
				} else {
					btn_opt1_.setContent("Build Tower", null, btn_width_, btn_height_);
					btn_opt2_.setContent("Destroy Wall", null, btn_width_, btn_height_);
					_window.addChild(btn_opt1_);
					_window.addChild(btn_opt2_);
					_window.addChild(btn_cancel_);
				}
			} else {
				if (mode_ == 1) {
					_window.removeChild(btn_opt1_);
					_window.removeChild(btn_cancel_);
				} else {
					_window.removeChild(btn_opt1_);
					_window.removeChild(btn_opt2_);
					_window.removeChild(btn_cancel_);
				}
			}
		}
		
		private function onButton(btn:Button):void {
			switch (btn.name) {
			case "option1":
				if (mode_==1) dispatcher.dispatchEvent(new TowerEvent(TowerEvent.LOWER_TOWER));
				else dispatcher.dispatchEvent(new TowerEvent(TowerEvent.TOWER_GEM, {viewonly:false}));
				break;
			case "option2":
				dispatcher.dispatchEvent(new TowerEvent(TowerEvent.LOWER_WALL));
				break;
			case "opt_cancel":
				break;
			}
			onShow(false, 0);
		}
		
	}
	
}