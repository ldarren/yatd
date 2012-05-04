package scenes.td.ui {
	import flash.display.Stage;
	import flash.text.TextFormatAlign;
	import org.pica.graphics.ui.Button;
	import org.pica.graphics.ui.Label;
	import scenes.td.events.GameEvent;
	import scenes.td.ui.Dialog;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class MessageBox extends Dialog {
		
		static public const OPTION_OK:int = 0;
		static public const OPTION_YES_NO:int = 1;
		
		private var lbl_msg_:Label;
		private var btn2_1_:Button;
		private var btn2_2_:Button;
		private var btn1_1_:Button;
		
		private var action_:String;
		private var option_:int;
		
		public function MessageBox(stage:Stage, x:Number, y:Number, w:Number, h:Number) {
			super("Message Box", "msgw", stage, x, y, w, h);
			
			lbl_msg_ = new Label("msg", "Message", 10, 30, _window.logicalWidth - 20, 60);
			var btny:int = _window.logicalHeight - 40;
			btn2_1_ = new Button("btn_yes", "Yes", null, { up:onButton }, _window.logicalWidth / 4, btny, 60);
			btn2_2_ = new Button("btn_no", "No", null, { up:onButton }, 3 * _window.logicalWidth / 4 - 60, btny, 60);
			btn1_1_ = new Button("btn_ok", "Ok", null, { up:onButton }, _window.logicalWidth / 2 - 30, btny, 60);
			
			_window.addChild(lbl_msg_);
		}
		
		public function onShow(action:String, msg:String, option:int):void {
			action_ = action;
			lbl_msg_.text = msg;
			
			switch(option) {
			case MessageBox.OPTION_OK:
				if (btn2_1_.parent == _window) _window.removeChild(btn2_1_);
				if (btn2_2_.parent == _window) _window.removeChild(btn2_2_);
				if (btn1_1_.parent != _window) _window.addChild(btn1_1_);
				break;
			case MessageBox.OPTION_YES_NO:
				if (btn2_1_.parent != _window) _window.addChild(btn2_1_);
				if (btn2_2_.parent != _window) _window.addChild(btn2_2_);
				if (btn1_1_.parent == _window) _window.removeChild(btn1_1_);
				break;
			}
			
			super.show(true);
		}
		
		public function onHide():void {
			super.show(false);
		}
		
		public function onButton(btn:Button):void {
			switch(btn.name) {
			case btn2_1_.name:
				dispatcher.dispatchEvent(new GameEvent(action_, { reply:"yes" } ));
				break;
			case btn2_2_.name:
				dispatcher.dispatchEvent(new GameEvent(action_, { reply:"no" } ));
				break;
			case btn1_1_.name:
				dispatcher.dispatchEvent(new GameEvent(action_, { reply:"ok" } ));
				break;
			}
			onHide();
		}
		
	}

}