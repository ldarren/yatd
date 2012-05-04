package scenes.td.events {
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class TowerEventDispatcher extends EventDispatcher {
		
		private var name_:String;
		
		public function TowerEventDispatcher(name:String) {
			name_ = name;
		}
		
		public function get name():String {
			return name_;
		}
		
	}
	
}