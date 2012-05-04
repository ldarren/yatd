package scenes.td.ui {
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import org.pica.graphics.ui.Button;
	import org.pica.graphics.ui.Window;
	import scenes.td.events.NetEvent;
	import scenes.td.events.TowerEventDispatcher;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Login {
		
		static public const STATE_NONE:int = 0;
		static public const STATE_LOGIN:int = 1;
		static public const STATE_VERIFY:int = 2;
		
		private var window_:Window;
		private var btn_width_:Number;

		private var btn_fb_:Button;
		private var btn_ko_:Button;
		private var btn_ms_:Button;
		private var btn_of_:Button;
		
		private var btn_login_:Button;
		private var btn_cancel_:Button;
		
		public var hidden:Boolean = true;
		private var mode_:int;
		private var state_:int = Login.STATE_NONE;
		private var stage_:Stage;
		
		public var dispatcher:TowerEventDispatcher;
		
		public function Login(stage:Stage, x:Number, y:Number, w:Number, h:Number, mode:int = NetEvent.MODE_OFFLINE) {
			dispatcher = new TowerEventDispatcher("Connection");
			
			stage_ = stage;
			mode_ = mode;
			window_ = new Window("con_win", x, y, w, h);
			
			btn_width_ = w - 40;
			btn_fb_ = new Button("con_fb", "Facebook", null, { up:onModeButton }, 17, 30, btn_width_ );
			btn_ko_ = new Button("con_ko", "kongregate", null, { up:onModeButton }, 17, 60, btn_width_ );
			btn_ms_ = new Button("con_ms", "Myspace", null, { up:onModeButton }, 17, 90, btn_width_ );
			btn_of_ = new Button("con_of", "Offline", null, { up:onModeButton }, 17, 120, btn_width_ );
			btn_login_ = new Button("con_login", "Verify Login", null, { up:onLoginButton }, 17, 60, btn_width_ );
			btn_cancel_ = new Button("con_cancel", "Cancel", null, { up:onLoginButton }, 17, 120, btn_width_ );
		}
		
		public function onShow(visible:Boolean, state:int=Login.STATE_LOGIN):void {
			hidden = !visible || state == Login.STATE_NONE;
			if (state_ != Login.STATE_NONE && state_ != state) {
				switch(state_) {
				case Login.STATE_LOGIN:
					window_.removeChild(btn_fb_);
					window_.removeChild(btn_ko_);
					window_.removeChild(btn_ms_);
					window_.removeChild(btn_of_);
					break;
				case Login.STATE_VERIFY:
					window_.removeChild(btn_login_);
					window_.removeChild(btn_cancel_);
					break;
				}
			}
			if (hidden) {
				window_.hideModal();
				stage_.removeChild(window_);
			} else {
				switch(state) {
				case Login.STATE_LOGIN:
					window_.addChild(btn_fb_);
					window_.addChild(btn_ko_);
					window_.addChild(btn_ms_);
					window_.addChild(btn_of_);
					break;
				case Login.STATE_VERIFY:
					window_.addChild(btn_login_);
					window_.addChild(btn_cancel_);
					break;
				}
				stage_.addChild(window_);
				window_.showModal();
			}
			state_ = state;
		}
		
		private function onModeButton(btn:Button):void {
			var state:int = Login.STATE_VERIFY;
			switch (btn.name) {
			case "con_fb":
				mode_ = NetEvent.MODE_FACEBOOK;
				dispatcher.dispatchEvent(new NetEvent(NetEvent.SEND, { action:"connect", mode:mode_ } ));
				break;
			case "con_ko":
				mode_ = NetEvent.MODE_KONGREGATE;
				dispatcher.dispatchEvent(new NetEvent(NetEvent.SEND, { action:"connect", mode:mode_ } ));
				break;
			case "con_ms":
				mode_ = NetEvent.MODE_MYSPACE;
				dispatcher.dispatchEvent(new NetEvent(NetEvent.SEND, { action:"connect", mode:mode_ } ));
				break;
			case "con_of":
				mode_ = NetEvent.MODE_OFFLINE;
				state = Login.STATE_NONE;
				break;
			}
			checkMode();
			onShow(true, state);
		}
		
		private function onLoginButton(btn:Button):void {
			switch (btn.name) {
			case "con_login":
				dispatcher.dispatchEvent(new NetEvent(NetEvent.SEND, { action:"login", mode:mode_ } ));
				break;
			case "con_cancel":
				onShow(true, Login.STATE_LOGIN); // reselect mode
				break;
			}
		}
		
		public function checkMode():void {
			if (mode_ != NetEvent.MODE_OFFLINE) dispatcher.dispatchEvent(new NetEvent(NetEvent.CONNECT, { mode:mode_ } ));
		}
		
		public function onLogin(evt:NetEvent):void {
			onShow(false);
		}
		
	}
	
}