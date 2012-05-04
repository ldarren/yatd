// http://www.heaveninteractive.com/weblog/2008/03/17/using-actionscript-30-with-php-part-1/
// http://www.actionscript.org/forums/showthread.php3?t=148593
package scenes.td {
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLVariables;
	import scenes.td.events.NetEvent;
	import scenes.td.events.TowerEventDispatcher;
	
	public class InnerNet {
		
		private var witeRequest_:URLRequest;
		private var readRequest_:URLRequest;
		private var loader_:URLLoader;
		
		public var dispatcher:TowerEventDispatcher;
		
		public function InnerNet(server:String) {
			loader_ = new URLLoader();
			loader_.addEventListener(Event.COMPLETE, onComplete);
			loader_.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader_.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);

			witeRequest_ = new URLRequest(server + "submit.php");
			readRequest_ = new URLRequest(server + "request.php");
			
			dispatcher = new TowerEventDispatcher("InnerNet");
		}
		
		public function submit(data:Object):void {
			var params:URLVariables = new URLVariables();
			for (var k:String in data) {
				params[k] = data[k];
			}
			
			witeRequest_.data = params;
			witeRequest_.method = URLRequestMethod.POST;
			
			loader_.dataFormat = URLLoaderDataFormat.TEXT;
			loader_.load(witeRequest_);
		}
		
		public function request(args:Object):void {
			var params:URLVariables = new URLVariables();
			for (var k:String in args) {
				params[k] = args[k];
			}

			readRequest_.data = params;
			readRequest_.method = URLRequestMethod.GET;
			
			loader_.dataFormat = URLLoaderDataFormat.TEXT;
			loader_.load(readRequest_);
		}
		
		private function onComplete(evt:Event):void {
			dispatcher.dispatchEvent(new NetEvent(NetEvent.RECEIVED, new URLVariables(evt.target.data)));
		}
		
		private function onError(evt:Event):void {
			dispatcher.dispatchEvent(new NetEvent(NetEvent.ERROR, {error:evt.target.data}));
		}
	}
}