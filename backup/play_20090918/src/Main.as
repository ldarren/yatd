package {
	import com.facebook.commands.users.GetInfo;
	import com.facebook.data.users.FacebookUser;
	import com.facebook.data.users.GetInfoData;
	import com.facebook.data.users.GetInfoFieldValues;
	import com.facebook.events.FacebookEvent;
	import com.facebook.Facebook;
	import com.facebook.net.FacebookCall;
	import com.facebook.utils.FacebookSessionUtil;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.pica.graphics.Renderer;
	import org.pica.graphics.ui.Button;
	import org.pica.graphics.ui.Label;
	import org.pica.utils.Constant;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Main extends Sprite {
		private var mGfx_:Renderer;
		private var mScene_:Scene;
		
		private var mUserNameLabel_:Label;
		private var mStatusLabel_:Label;
		private var mLoginVerifyButton_:Button;
		private var mSceneLoadButton_:Button;
		private var mNextWaveButton_:Button;
		
		private var nOldMouseX_:Number = 0;
		private var nOldMouseY_:Number = 0;
		private var nCamEle_:Number = 45.0;
		private var nCamSec_:Number = -45.0;
		
		private var mFB_:Facebook;
		private var mSession_:FacebookSessionUtil;
		private var mUser_:FacebookUser;
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			Constant.FPS = stage.frameRate;
			mGfx_ = new Renderer(this, stage.stageWidth, stage.stageHeight);
			mGfx_.rotCamera(nCamEle_, nCamSec_);
			mScene_ = new Scene(mGfx_);
			
			mSession_ = new FacebookSessionUtil("ed31a65e55da33488cb4f758a415ac66", "38db310b7e290030da0791851dec08de", loaderInfo);
			mSession_.addEventListener(FacebookEvent.CONNECT, onFacebookConnected);
			mFB_ = mSession_.facebook;
			
			mStatusLabel_ = new Label("status", "Login in...", 10, 570, 700, 30);
			addChild(mStatusLabel_);

			if (loaderInfo.parameters.fb_sig_session_key) {
				mSession_.verifySession()
			} else {
				//mSession_.login();
			
				mLoginVerifyButton_ = new Button("btn_verify", "Read user info", 10, 10, onButton);
				addChild(mLoginVerifyButton_);
			}
			
			addEventListener(Event.ENTER_FRAME, onUpdate, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onEvent); // sprite empty space doesn't receive event
			addEventListener(MouseEvent.MOUSE_WHEEL, onEvent);
			addEventListener(MouseEvent.CLICK, onEvent);
			addEventListener(MouseEvent.MOUSE_DOWN, onEvent);
		}
		
		public function onUpdate(evt:Event):void {
			mScene_.update();
			
			mGfx_.onEnterFrame(evt);
		}
		
		public function onEvent(evt:Event):void {
			var e:MouseEvent;
			switch(evt.type) {
			case MouseEvent.MOUSE_WHEEL:
				e = evt as MouseEvent;
				var delta:int = e.delta;
				if (e.altKey) delta += delta * 10;
				if (e.ctrlKey) delta += delta * 10;
				if (e.altKey) delta += delta * 10;
				mGfx_.moveCamera(delta);
				break;
			case MouseEvent.MOUSE_DOWN:
				nOldMouseX_ = this.mouseX;
				nOldMouseY_ = this.mouseY;
				break;
			case MouseEvent.MOUSE_UP:
			case MouseEvent.MOUSE_OUT:
				break;
			case MouseEvent.MOUSE_MOVE:
				{
					e = evt as MouseEvent;
					if (e.buttonDown) {
						nCamEle_ += nOldMouseY_ - this.mouseY;
						nCamSec_ += nOldMouseX_ - this.mouseX;
						nOldMouseX_ = this.mouseX;
						nOldMouseY_ = this.mouseY;
						nCamEle_ %= 360;
						nCamSec_ %= 360;

						mGfx_.rotCamera(nCamEle_, nCamSec_);
					}
				}
				break;
			}
			mGfx_.onEvent(evt);
		}
		
		public function onButton(btn:Button):void {
			switch(btn.name) {
			case "btn_verify":
trace("verify");
				removeChild(btn);
				
				mSession_.validateLogin()
				// hacked, should be at onUserInfoReturned
				mSceneLoadButton_ = new Button("btn_load", "Load scene", 10, 10, onButton);
				addChild(mSceneLoadButton_);
				mNextWaveButton_ = new Button("btn_wave", "Next wave", 10, 50, onButton);
				addChild(mNextWaveButton_);
				break;
			case "btn_load":
				mScene_.load();
				break;
			case "btn_wave":
				mScene_.nextWave();
				break;
			}
		}
		
		private function onFacebookConnected(evt:FacebookEvent):void {
			if (evt.success) {
				var call:FacebookCall = mFB_.post(new GetInfo([mFB_.uid], [GetInfoFieldValues.NAME]));
				call.addEventListener(FacebookEvent.COMPLETE, onUserInfoReturned);

				mStatusLabel_.text = "Logined, retrieving user info...";

				mUserNameLabel_ = new Label("lbl_username", "Reading user info...", 10, 10, 150, 30);
				addChild(mUserNameLabel_);
				
			} else {
				mStatusLabel_.text = "onFacebookConnected ko: "+evt.error.errorMsg;
			}
		}
		
		private function onUserInfoReturned(evt:FacebookEvent):void {
			if (evt.success) {
				mUser_ = (evt.data as GetInfoData).userCollection.getItemAt(0) as FacebookUser;
				mUserNameLabel_.text = "User: " + mUser_.name;

				mStatusLabel_.text = "Retrieved user info";
			
//				mSceneLoadButton_ = new Button("btn_load", "Load scene", 10, 10, onButton);
//				addChild(mSceneLoadButton_);
//				mNextWaveButton_ = new Button("btn_wave", "Next wave", 10, 50, onButton);
//				addChild(mNextWaveButton_);
			} else {
				mStatusLabel_.text = "onUserInfoReturned ko: "+evt.error.errorMsg;
			}
		}
		
	}
	
}