package scenes.td.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class TowerEvent extends Event {
		
		static public const RAISE_WALL:String		= "g2w";
		static public const LOWER_WALL:String		= "w2g";
		static public const RAISE_TOWER:String		= "w2t";
		static public const LOWER_TOWER:String		= "t2w";
		static public const WALL_LOWERED:String		= "w2gd";
		static public const TOWER_RAISED:String		= "w2td";
		static public const TOWER_LOWERED:String	= "t2wd";
		public static const TOWER_OPTION:String		= "topt";
		
		private var data_:Object;

		public function TowerEvent(type:String, data:Object=null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			data_ = data;
		}
		
		override public function clone():Event{
			return new TowerEvent(type, data_, bubbles, cancelable);
		}
		
		public function get data():Object {
			return data_;
		}
		
	}
	
}