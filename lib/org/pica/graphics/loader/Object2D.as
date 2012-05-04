// TODO: move URLLoader to a network component?
package org.pica.graphics.loader {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.filters.BitmapFilter;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Object2D extends Bitmap {
		
		private var frames_:Object;
		private var curr_animation_:Object;
		private var curr_frame_:uint = 0;
		private var elapsed_:uint = 0;
		private var is_playing_:Boolean = false;

		private var data_:Array;
		private var key_color_:int;
		private var filter_:BitmapFilter;
		private var mask_:BitmapData;
		private var dice_rect_:Rectangle;
		private var onloaded_:Function;
		
		public function Object2D(name:String) {
			this.name = name;
		}
		
		public function load(src:*, dw:uint, dh:uint, onloaded:Function, key_color:int=-1, filter:BitmapFilter=null, mask:BitmapData=null):void {
			data_ = new Array();
			dice_rect_ = new Rectangle(0, 0, dw, dh);
			key_color_ = key_color;
			filter_ = filter;
			mask_ = mask;
			onloaded_ = onloaded;
			
			frames_ = new Object();

			if (src is String) {
				var loader:Loader = new Loader();
				loader.load(new URLRequest(src));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR , onLoadError);
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			} else if (src is BitmapData) {
				postprocessing(src);
			} else if (src is Bitmap) {
				postprocessing(Bitmap(src).bitmapData);
			}
		}
		
		public function addAnimation(name:String, info:Object):Boolean {
			if (info != null && info.start != null && info.end != null && info.fps != null) {
				info.period = 1000/info.fps;
				frames_[name] = info;
				return true;
			}
			
			return false;
		}
		
		public function play(name:String):Boolean {
			if (frames_[name] != null) {
				curr_animation_ = frames_[name];
				is_playing_ = true;
				curr_frame_ = curr_animation_.start;
				elapsed_ = 0;
				return true;
			}

			return false;
		}
		
		public function get currentFrameIdx():uint { return curr_frame_; }
		public function get currentFrame():BitmapData {	return data_[curr_frame_];	}
		public function getAnimation(name:String):Object { return frames_[name]; }
		public function get currAnimation():Object { return curr_animation_; }
		public function getFrame(idx:uint):BitmapData {	return data_[idx];	}
		
		public function animate(elapsed:uint):Boolean {
			if (!is_playing_ || curr_animation_ == null || data_ == null || data_.length == 0) return false;
			
			elapsed_ += elapsed;
			if (elapsed_ < curr_animation_.period) return false;
			elapsed_ = 0;
			
			++curr_frame_;
			if (curr_frame_ > curr_animation_.end) {
				curr_frame_ = curr_animation_.start;
			}
			
			this.bitmapData = currentFrame;
			return true;
		}
		
		private function postprocessing(bd:BitmapData):void {

			var trans_data:BitmapData = new BitmapData(bd.width, bd.height, true);
			var rec:Rectangle = new Rectangle(0, 0, bd.width, bd.height);
			var tl:Point = new Point(0, 0);
			if (key_color_ == -1) trans_data = bd.clone();
			else trans_data.threshold(bd, rec, tl, "==", key_color_, 0x00000000, 0xFFFFFFFF, true);
			
			if (filter_) trans_data.applyFilter(trans_data, rec, tl, filter_);
			
			var dice:BitmapData;
			var row:uint = trans_data.height / dice_rect_.height;
			var col:uint = trans_data.width / dice_rect_.width;
			
			// hack
			for (var i:int = 0; i < row; ++i) {
				for (var j:int = 0; j < col; ++j) {
					dice = new BitmapData(dice_rect_.width, dice_rect_.height);
					dice.copyPixels(trans_data, new Rectangle(j * dice_rect_.width, i * dice_rect_.width, dice_rect_.width, dice_rect_.height), tl, mask_, tl, false);
					data_.push(dice);
				}
			}
			
			this.bitmapData = currentFrame;
			
			onloaded_(this);
		}

		// Event Handlers
		
		private function onLoadComplete(evt:Event):void {
			postprocessing(evt.target.content.bitmapData);
		}		

		private function onLoadError(evt:Event):void {
		}

		private function onLoadProgress(evt:Event):void {
			// Needed for progressbar
		}
	}
	
}
