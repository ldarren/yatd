package wisps {
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class WispData {
		
		static public const TYPE_BOSS:uint = 1;
		static public const TYPE_SWARM:uint = 2;
		
		public var speed:Number;	// movement speed
		
		public function WispData(speed:Number=1) {
			this.speed = speed;
		}
		
	}
	
}