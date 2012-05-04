package scenes.td {
	import com.facebook.commands.friends.GetFriends;
	import com.facebook.commands.stream.PublishPost;
	import com.facebook.data.friends.GetFriendsData;
	import com.facebook.data.users.FacebookUserCollection;
	import flash.system.Security;
	import org.pica.net.NetEvent;
	//import com.facebook.commands.stream.PublishPostFull;
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
	import scenes.td.events.TowerEventDispatcher;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class SocialNet {
		
		static public const MODE_OFFLINE:int = 0;
		static public const MODE_FACEBOOK:int = 1;
		static public const MODE_KONGREGATE:int = 2;
		static public const MODE_MYSPACE:int = 3;
		
		static public const ACTION_LOGIN:String = "login";
		static public const ACTION_CONNECT:String = "connect";
		static public const ACTION_LOGINED:String = "logined";
		static public const ACTION_PERMISSION:String = "perm";
		static public const ACTION_SELFINFO:String = "selfinf";
		static public const ACTION_BUDDYINFO:String = "buddinf";
		
		static public const RET_OK:String = "OK";
		static public const RET_KO:String = "KO";
		
		private var fb_:Facebook;
		private var session_:FacebookSessionUtil;
		
		private var loaderInfo_:LoaderInfo;
		
		public var dispatcher:TowerEventDispatcher;
		
		public function SocialNet() {
			dispatcher = new TowerEventDispatcher("SocialNet");
			Security.loadPolicyFile("http://profile.ak.fbcdn.net/crossdomain.xml");
		}
		
		public function onSend(evt:NetEvent):void {
			var data:Object = evt.data;
			switch(data.action) {
			case SocialNet.ACTION_CONNECT:
				switch (data.mode) {
				case SocialNet.MODE_FACEBOOK:
					login("1","2",null);
					break;
				case SocialNet.MODE_KONGREGATE:
					break;
				case SocialNet.MODE_MYSPACE:
					break;
				}
				break;
			case SocialNet.ACTION_LOGIN:
				switch (data.mode) {
				case SocialNet.MODE_FACEBOOK:
					validateLogin();
					break;
				case SocialNet.MODE_KONGREGATE:
					break;
				case SocialNet.MODE_MYSPACE:
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
		
		public function getFriends():void {
			var call:FacebookCall = fb_.post(new GetFriends());
			call.addEventListener(FacebookEvent.COMPLETE, onFriendIdReturned);
		}
		
		private function onFacebookConnected(evt:FacebookEvent):void {
			fb_ = session_.facebook;
			if (evt.success && fb_) {
				dispatcher.dispatchEvent(new NetEvent(NetEvent.RECEIVED, { ret:SocialNet.RET_OK, action:SocialNet.ACTION_LOGINED } ));
				// get user permission setting
				var call:FacebookCall;
				call = fb_.post(new HasAppPermission(HasAppPermissionValues.PUBLISH_STREAM));
				call.addEventListener(FacebookEvent.COMPLETE, onPermissionDisclosed, false, 0, true);
				// get player name
				call = fb_.post(new GetInfo([fb_.uid], [GetInfoFieldValues.NAME, GetInfoFieldValues.PIC_SQUARE]));
				call.addEventListener(FacebookEvent.COMPLETE, onUserInfoReturned);
			} else {
				dispatcher.dispatchEvent(new NetEvent(NetEvent.ERROR, { ret:SocialNet.RET_KO, action:SocialNet.ACTION_LOGINED, error:evt.error.errorMsg } ));
			}
		}
		
		private function onPermissionDisclosed(evt:FacebookEvent):void {
			if (!evt.success || !((evt.data as BooleanResultData).value)){
				// extended permission to upload message, skipping approval of upload
				fb_.grantExtendedPermission(ExtendedPermissionValues.PUBLISH_STREAM);
				dispatcher.dispatchEvent(new NetEvent(NetEvent.ERROR, { ret:SocialNet.RET_KO, action:SocialNet.ACTION_PERMISSION, error:"No permission" } ));
			} else {
				dispatcher.dispatchEvent(new NetEvent(NetEvent.RECEIVED, { ret:SocialNet.RET_OK, action:SocialNet.ACTION_PERMISSION } ));
			}
		}
		
		private function onUserInfoReturned(evt:FacebookEvent):void {
			if (evt.success) {
				var user:FacebookUser = (evt.data as GetInfoData).userCollection.getItemAt(0) as FacebookUser;
				dispatcher.dispatchEvent(new NetEvent(NetEvent.RECEIVED, { ret:SocialNet.RET_OK, action:SocialNet.ACTION_SELFINFO, name:user.name, pic:user.pic_square, uid:user.uid } ));
			} else {
				dispatcher.dispatchEvent(new NetEvent(NetEvent.ERROR, { ret:SocialNet.RET_KO, action:SocialNet.ACTION_SELFINFO, error:evt.error.errorMsg } ));
			}
		}
		
		private function onFriendIdReturned(evt:FacebookEvent):void {
			var friends:Array = (evt.data as GetFriendsData).friends.source;

			var uids:Array = new Array();
			for each (var user:FacebookUser in friends) {
				uids.push(user.uid);
			}
			// retrieving informations for all uids contained in the uids array
			var call:FacebookCall = new GetInfo(uids, [GetInfoFieldValues.FIRST_NAME, GetInfoFieldValues.PIC_SQUARE]);
			fb_.post(call);
			// the function on_friend_list_loaded will be called once the post is completed
			call.addEventListener(FacebookEvent.COMPLETE, onFriendInfoReturned);
		}
		// function to be called after GetInfo has finished
		private function onFriendInfoReturned(evt:FacebookEvent):void {
			if (evt.success) {
				var friends_data:Array = ((evt.data as GetInfoData).userCollection.source);
				for each (var user:FacebookUser in friends_data) {
					dispatcher.dispatchEvent(new NetEvent(NetEvent.RECEIVED, { ret:SocialNet.RET_OK, action:SocialNet.ACTION_BUDDYINFO, name:user.first_name, pic:user.pic_square, uid:user.uid } ));
				}
			} else {
				dispatcher.dispatchEvent(new NetEvent(NetEvent.ERROR, { ret:SocialNet.RET_KO, action:SocialNet.ACTION_BUDDYINFO, error:evt.error.errorMsg } ));
			}
			
		}
		
		public function postMessage(msg:String):void {
			var attachment:Object = { 'media':[ { 'type':'image', 'src':'http://bit.ly/AJTnf', 'href':'http://bit.ly/hifZk' } ] };
			var call:FacebookCall = fb_.post(new PublishPost(msg, attachment, null, null)/*new PublishPostFull(msg, attachment, null, null, "Your Comments", null, false, null)*/);
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