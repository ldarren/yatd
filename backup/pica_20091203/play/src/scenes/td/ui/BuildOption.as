package scenes.td.ui {
	import flash.display.Stage;
	import org.pica.graphics.ui.Button;
	import org.pica.graphics.ui.Window;
	import scenes.td.events.GameEvent;
	import scenes.td.events.TowerEvent;
	import scenes.td.events.TowerEventDispatcher;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class BuildOption {
		
		private var window_:Window;
		private var btn_opt1_:Button;
		private var btn_opt2_:Button;
		private var btn_cancel_:Button;
		private var btn_width_:Number;
		
		public var hidden:Boolean = true;
		private var mode_:int = 0;
		private var stage_:Stage;
		
		public var dispatcher:TowerEventDispatcher;
		
		public function BuildOption(stage:Stage, x:Number, y:Number, w:Number, h:Number) {
			dispatcher = new TowerEventDispatcher("OptionWin");
			
			stage_ = stage;
			window_ = new Window("optwin", x, y, w, h);
			//window_.setSkin(win_skins, new Rectangle(0, 22, 30, 18), new Rectangle(4, 4, 22, 10));
			//window_.setSkin(win_skins, new Rectangle(0, 0, 46, 32), new Rectangle(22, 22, 2, 2));
			
			btn_width_ = w - 40;
			btn_opt1_ = new Button("option1", "Option One", null, { up:onButton }, 17, 30, btn_width_ );
			btn_opt2_ = new Button("option2", "Option Second", null, { up:onButton }, 17, 60, btn_width_ );
			btn_cancel_ = new Button("opt_cancel", "Cancel", null, { up:onButton }, 17, 90, btn_width_ );
		}
		
		public function onShow(visible:Boolean, mode:int):void {
			hidden = !visible;
			if (visible) {
				mode_ = mode;
				if (mode_ == 1) {
					btn_opt1_.setContent("Destroy Tower", null, btn_width_);
					window_.addChild(btn_opt1_);
					window_.addChild(btn_cancel_);
				} else {
					btn_opt1_.setContent("Build Tower", null, btn_width_);
					btn_opt2_.setContent("Destroy Wall", null, btn_width_);
					window_.addChild(btn_opt1_);
					window_.addChild(btn_opt2_);
					window_.addChild(btn_cancel_);
				}
				stage_.addChild(window_);
				window_.showModal();
			} else {
				if (mode_ == 1) {
					window_.removeChild(btn_opt1_);
					window_.removeChild(btn_cancel_);
				} else {
					window_.removeChild(btn_opt1_);
					window_.removeChild(btn_opt2_);
					window_.removeChild(btn_cancel_);
				}
				window_.hideModal();
				stage_.removeChild(window_);
			}
		}
		
		private function onButton(btn:Button):void {
			switch (btn.name) {
			case "option1":
				if (mode_==1) dispatcher.dispatchEvent(new TowerEvent(TowerEvent.LOWER_TOWER));
				else dispatcher.dispatchEvent(new TowerEvent(TowerEvent.RAISE_TOWER));
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