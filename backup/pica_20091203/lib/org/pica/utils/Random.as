package org.pica.utils {
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Random {
		
		public function Random() {
			
		}
		
		static public function between(from:Number, to:Number):Number {
			return (to - from) * Math.random() + from;
		}
		
	}
	
}