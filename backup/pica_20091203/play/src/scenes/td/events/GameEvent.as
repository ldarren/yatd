﻿package scenes.td.events {
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class GameEvent extends Event {
		
		static public const GAME_START:String	= "gsta";
		static public const GAME_END:String		= "gsto";
		static public const GAME_PAUSE:String	= "gpus";
		static public const GAME_PATH:String	= "gpth";
		static public const GAME_SCORE:String	= "scor";
		
		private var data_:Object;
		
		public function GameEvent(type:String, data:Object=null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			data_ = data;
		}
		
		override public function clone():Event{
			return new GameEvent(type, data_, bubbles, cancelable);
		}
		
		public function get data():Object {
			return data_;
		}
		
	}
	
}