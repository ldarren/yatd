package {
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Preloader extends MovieClip {
		
		[Embed (source = "../../res/harvester.jpg")]			static private var logoTexClass_:Class;
		static public const WIDTH:Number = 760;
		static public const HEIGHT:Number = 600;
		private var logo_:Bitmap;
		private var progress_:TextField;
		
		public function Preloader() {
			addEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);

			// show loader
			logo_ = new logoTexClass_;
			logo_.x = (Preloader.WIDTH - logo_.width) / 2;
			logo_.y = Preloader.HEIGHT / 2 - logo_.height;
			addChild(logo_);
			
			progress_ = new TextField();
			progress_.defaultTextFormat = new TextFormat("Arial", 24, 0xeeeeee, null, null, null, null, null, TextFormatAlign.CENTER);
			progress_.selectable = false;
			progress_.antiAliasType = AntiAliasType.NORMAL;
			progress_.x = 0;
			progress_.y = logo_.y + 100;
			progress_.width = Preloader.WIDTH;
			progress_.text = "0 %";
			addChild(progress_);
		}

		private function progress(e:ProgressEvent):void {
			trace("Loading... " + e.bytesLoaded + "/" + e.bytesTotal);
			// update loader
			progress_.text = Number(100 * e.bytesLoaded / e.bytesTotal).toFixed(0) + " %";
		}
		
		private function checkFrame(e:Event):void {
			if (currentFrame == totalFrames) {
				removeEventListener(Event.ENTER_FRAME, checkFrame);
				startup();
			}
		}
		
		private function startup():void {
			// hide loader
			removeChild(logo_);
			removeChild(progress_);
			logo_ = null;
			progress_ = null;
			
			stop();
			trace("Done");
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			var mainClass:Class = getDefinitionByName("Main") as Class;
			addChild(new mainClass() as DisplayObject);
		}
		
	}
	
}