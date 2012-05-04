package bots {
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class BotData {
		
		static public const TIMER_TYPE:uint = 0;
		static public const HOMING_TYPE:uint = 1;
		static public const ROUND_TYPE:uint = 2;
		
		public var range:Number;	// firing range and sensor range
		public var speed:Number;	// firing rate
		public var damage:Number;
		public var type:uint;		// turret types
		
		public function BotData(range:Number=1, speed:Number=1, damage:Number=1, type:uint=BotData.HOMING_TYPE) {
			this.range = range;
			this.speed = speed;
			this.damage = damage;
			this.type = type;
		}
		
	}
	
}