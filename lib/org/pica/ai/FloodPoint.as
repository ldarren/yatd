package org.pica.ai {
	import org.papervision3d.core.data.UserData;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class FloodPoint {
		public var id:int;
		public var homeId:int;
		public var searching:Boolean;
		public var userData:UserData;
		
		public function FloodPoint(id:int, homeId:int) {
			this.id = id;
			this.homeId = homeId;
			this.searching = true;
			this.userData = null;
		}
		
	}
	
}