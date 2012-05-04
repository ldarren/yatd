package scenes.td.ui {
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import org.pica.graphics.ui.Button;
	import org.pica.net.NetEvent;
	import scenes.td.SocialNet;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Login extends Dialog{
		
		static public const STATE_NONE:int = 0;
		static public const STATE_LOGIN:int = 1;
		static public const STATE_VERIFY:int = 2;
		
		private var btn_fb_:Button;
		private var btn_ko_:Button;
		private var btn_ms_:Button;
		private var btn_of_:Button;
		
		private var btn_login_:Button;
		private var btn_cancel_:Button;
		
		private var mode_:int;
		private var state_:int = Login.STATE_NONE;
		
		public function Login(stage:Stage, x:Number, y:Number, w:Number, h:Number, mode:int = 0) {
			super("Login", "conwin", stage, x, y, w, h);
			mode_ = mode;
			
			var btn_width:Number = w - 20;
			var btn_height:Number = 25;
			btn_fb_ = new Button("con_fb", "Facebook", null, { up:onModeButton }, 17, 30, btn_width, btn_height );
			btn_ko_ = new Button("con_ko", "kongregate", null, { up:onModeButton }, 17, 60, btn_width, btn_height );
			btn_ms_ = new Button("con_ms", "Myspace", null, { up:onModeButton }, 17, 90, btn_width, btn_height );
			btn_of_ = new Button("con_of", "Offline", null, { up:onModeButton }, 17, 120, btn_width, btn_height );
			btn_login_ = new Button("con_login", "Verify Login", null, { up:onLoginButton }, 17, 60, btn_width, btn_height );
			btn_cancel_ = new Button("con_cancel", "Cancel", null, { up:onLoginButton }, 17, 120, btn_width, btn_height );
		}
		
		public function onShow(visible:Boolean, state:int=Login.STATE_LOGIN):void {
			super.show(visible && state != Login.STATE_NONE);
			if (state_ != Login.STATE_NONE && state_ != state) {
				switch(state_) {
				case Login.STATE_LOGIN:
					_window.removeChild(btn_fb_);
					_window.removeChild(btn_ko_);
					_window.removeChild(btn_ms_);
					_window.removeChild(btn_of_);
					break;
				case Login.STATE_VERIFY:
					_window.removeChild(btn_login_);
					_window.removeChild(btn_cancel_);
					break;
				}
			}
			if (visible) {
				switch(state) {
				case Login.STATE_LOGIN:
					_window.addChild(btn_fb_);
					_window.addChild(btn_ko_);
					_window.addChild(btn_ms_);
					_window.addChild(btn_of_);
					break;
				case Login.STATE_VERIFY:
					_window.addChild(btn_login_);
					_window.addChild(btn_cancel_);
					break;
				}
			}
			state_ = state;
		}
		
		private function onModeButton(btn:Button):void {
			var state:int = Login.STATE_VERIFY;
			switch (btn.name) {
			case "con_fb":
				mode_ = SocialNet.MODE_FACEBOOK;
				dispatcher.dispatchEvent(new NetEvent(NetEvent.SEND, { action:SocialNet.ACTION_CONNECT, mode:mode_ } ));
				break;
			case "con_ko":
				mode_ = SocialNet.MODE_KONGREGATE;
				dispatcher.dispatchEvent(new NetEvent(NetEvent.SEND, { action:SocialNet.ACTION_CONNECT, mode:mode_ } ));
				break;
			case "con_ms":
				mode_ = SocialNet.MODE_MYSPACE;
				dispatcher.dispatchEvent(new NetEvent(NetEvent.SEND, { action:SocialNet.ACTION_CONNECT, mode:mode_ } ));
				break;
			case "con_of":
				mode_ = SocialNet.MODE_OFFLINE;
				state = Login.STATE_NONE;
				break;
			}
			checkMode();
			onShow(true, state);
		}
		
		private function onLoginButton(btn:Button):void {
			switch (btn.name) {
			case "con_login":
				dispatcher.dispatchEvent(new NetEvent(NetEvent.SEND, { action:SocialNet.ACTION_LOGIN, mode:mode_ } ));
				break;
			case "con_cancel":
				onShow(true, Login.STATE_LOGIN); // reselect mode
				break;
			}
		}
		
		public function checkMode():void {
			if (mode_ != SocialNet.MODE_OFFLINE) dispatcher.dispatchEvent(new NetEvent(NetEvent.CONNECT, { mode:mode_ } ));
		}
		
		public function onLogin(evt:NetEvent):void {
			onShow(false);
		}
		
	}
	
}