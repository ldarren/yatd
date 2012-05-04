package scenes.td {
	import com.facebook.commands.stream.PublishPost;
	import com.facebook.commands.stream.PublishPostFull;
	import com.facebook.commands.users.GetInfo;
	import com.facebook.commands.users.HasAppPermission;
	import com.facebook.data.auth.ExtendedPermissionValues;
	import com.facebook.data.BooleanResultData;
	import com.facebook.data.users.FacebookUser;
	import com.facebook.data.users.GetInfoData;
	import com.facebook.data.users.GetInfoFieldValues;
	import com.facebook.data.users.HasAppPermissionValues;
	import com.facebook.events.FacebookEvent;
	import com.facebook.Facebook;
	import com.facebook.net.FacebookCall;
	import com.facebook.utils.FacebookSessionUtil;
	import flash.display.LoaderInfo;
	import scenes.td.events.NetEvent;
	import scenes.td.events.TowerEventDispatcher;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class SocialNet {
		
		private var fb_:Facebook;
		private var session_:FacebookSessionUtil;
		
		private var user_:FacebookUser;
		private var loaderInfo_:LoaderInfo;
		
		public var dispatcher:TowerEventDispatcher;
		
		public function SocialNet() {
			dispatcher = new TowerEventDispatcher("SocialNet");
		}
		
		public function onSend(evt:NetEvent):void {
			var data:Object = evt.data;
			switch(data.action) {
			case "connect":
				switch (data.mode) {
				case NetEvent.MODE_FACEBOOK:
					login("1","2",null);
					break;
				case NetEvent.MODE_KONGREGATE:
					break;
				case NetEvent.MODE_MYSPACE:
					break;
				}
				break;
			case "login":
				switch (data.mode) {
				case NetEvent.MODE_FACEBOOK:
					validateLogin();
					break;
				case NetEvent.MODE_KONGREGATE:
					break;
				case NetEvent.MODE_MYSPACE:
					break;
				}
				break;
			}
		}
		
		public function login(api_key:String, code:String, info:LoaderInfo):Boolean {
			loaderInfo_ = info;
			var handled:Boolean;

			if (loaderInfo_.parameters.fb_sig_session_key) {
				session_ = new FacebookSessionUtil(null, null, info);
				session_.addEventListener(FacebookEvent.CONNECT, onFacebookConnected);
				session_.verifySession()
				handled = true;
			} else {
				session_ = new FacebookSessionUtil(api_key, code, info);
				session_.addEventListener(FacebookEvent.CONNECT, onFacebookConnected);
				session_.login();
				handled = false;
			}
			return handled;
		}
		
		public function validateLogin():void {
			session_.validateLogin();
		}
		
		public function logout():void {
			session_.logout();
		}
		
		private function onFacebookConnected(evt:FacebookEvent):void {
			fb_ = session_.facebook;
			if (evt.success && fb_) {
				dispatcher.dispatchEvent(new NetEvent(NetEvent.RECEIVED, { ret:"OK", action:"fb_logined" } ));
				// get user permission setting
				var call:FacebookCall;
				call = fb_.post(new HasAppPermission(HasAppPermissionValues.PUBLISH_STREAM));
				call.addEventListener(FacebookEvent.COMPLETE, onPermissionDisclosed, false, 0, true);
				// get player name
				call = fb_.post(new GetInfo([fb_.uid], [GetInfoFieldValues.NAME]));
				call.addEventListener(FacebookEvent.COMPLETE, onUserInfoReturned);
			} else {
				dispatcher.dispatchEvent(new NetEvent(NetEvent.ERROR, { ret:"KO", action:"fb_logined", error:evt.error.errorMsg } ));
			}
		}
		
		private function onPermissionDisclosed(evt:FacebookEvent):void {
			if (!evt.success || !((evt.data as BooleanResultData).value)){
				// extended permission to upload message, skipping approval of upload
				fb_.grantExtendedPermission(ExtendedPermissionValues.PUBLISH_STREAM);
				dispatcher.dispatchEvent(new NetEvent(NetEvent.ERROR, { ret:"KO", action:"permission", error:"No permission" } ));
			} else {
				dispatcher.dispatchEvent(new NetEvent(NetEvent.RECEIVED, { ret:"OK", action:"permission" } ));
			}
		}
		
		private function onUserInfoReturned(evt:FacebookEvent):void {
			if (evt.success) {
				user_ = (evt.data as GetInfoData).userCollection.getItemAt(0) as FacebookUser;
				dispatcher.dispatchEvent(new NetEvent(NetEvent.RECEIVED, { ret:"OK", action:"get_name", name:user_.name } ));
			} else {
				dispatcher.dispatchEvent(new NetEvent(NetEvent.ERROR, { ret:"KO", action:"get_name", error:evt.error.errorMsg } ));
			}
		}
		
		public function postMessage(msg:String):void {
			var attachment:Object = { 'media':[ { 'type':'image', 'src':'http://bit.ly/AJTnf', 'href':'http://bit.ly/hifZk' } ] };
			var call:FacebookCall = fb_.post(new PublishPostFull(msg, attachment, null, null, "Your Comments", null, false, null));
			call.addEventListener(FacebookEvent.COMPLETE, function(e:FacebookEvent):void {
				if (e.success) trace("COMPLETE ");
				else trace("FAILED: "+e.error.errorMsg);
			});

			call.addEventListener(FacebookEvent.ERROR, function(e:FacebookEvent):void {
				trace("ERROR ");
			});

			call.addEventListener(FacebookEvent.CONNECT, function(e:FacebookEvent):void {
				trace("CONNECT ");
			});
		}
		
	}
	
}