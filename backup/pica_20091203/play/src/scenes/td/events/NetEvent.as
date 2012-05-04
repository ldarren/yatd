package scenes.td.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class NetEvent extends Event {
		
		static public const MODE_OFFLINE:int = 0;
		static public const MODE_FACEBOOK:int = 1;
		static public const MODE_KONGREGATE:int = 2;
		static public const MODE_MYSPACE:int = 3;
		
		static public const CONN_GAME:int = 0;
		static public const CONN_SOCIAL:int = 1;
		
		static public const SEND:String		= "send";
		static public const RECEIVED:String	= "recv";
		static public const ERROR:String	= "err";
		static public const CONNECT:String	= "conn";
		
		private var data_:Object;
		
		public function NetEvent(type:String, vars:Object, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			data_ = vars;
		}
		
		override public function clone():Event{
			return new NetEvent(type, data_, bubbles, cancelable);
		}
		
		public function get data():Object {
			return data_;
		}
		
	}
	
}