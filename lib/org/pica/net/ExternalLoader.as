// adapted from http://www.dreamincode.net/forums/showtopic126313.htm
package org.pica.net {
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
    
    public class ExternalLoader {
        
		static public const TYPE_DOWNLOAD:int = 0;
		static public const TYPE_SUBMIT:int = 1;
		static public const TYPE_REQUEST:int = 2;
		
		public var dispatcher:EventDispatcher;

        private var xmlLoader_:URLLoader;
        private var imgLoader_:Loader;
        private var request_:URLRequest;
		private var submit_:URLRequest;
		private var download_:URLRequest;
        private var queue_:Array;
        private var isRunning_:Boolean = false;
    
        // Initialization:
        public function ExternalLoader(server:String) {
            xmlLoader_ = new URLLoader();
            xmlLoader_.dataFormat = URLLoaderDataFormat.TEXT;
            xmlLoader_.addEventListener(Event.COMPLETE, onComplete);
			xmlLoader_.addEventListener(IOErrorEvent.IO_ERROR, onError);
			xmlLoader_.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			
            imgLoader_ = new Loader();
            imgLoader_.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			
			download_ = new URLRequest();
			submit_ = new URLRequest(server + "submit.php");
			submit_.method = URLRequestMethod.POST;
			request_ = new URLRequest(server + "request.php");
			request_.method = URLRequestMethod.GET;
			
			queue_ = new Array();
			dispatcher = new EventDispatcher();
        }
        
        public function download(id:String, src:String):void {
			var obj:Object = { type:ExternalLoader.TYPE_DOWNLOAD, id:id, src:src };
			queue_.push(obj);
			
			processQueue();
        }
        
        public function submit(data:Object):void {
			var params:URLVariables = new URLVariables();
			for (var k:String in data) {
				params[k] = data[k];
			}
			var obj:Object = { type:ExternalLoader.TYPE_SUBMIT, data:params};
			queue_.push(obj);
			
			processQueue();
        }
		
		public function request(data:Object):void {
			var params:URLVariables = new URLVariables();
			for (var k:String in data) {
				params[k] = data[k];
			}
			var obj:Object = { type:ExternalLoader.TYPE_REQUEST, data:params};
			queue_.push(obj);
			
			processQueue();
		}
        
        private function processQueue():void {
            if (!isRunning_ && queue_.length > 0) {
                isRunning_ = true;
				var obj:Object = queue_.pop() as Object;
				switch(obj.type) {
				case ExternalLoader.TYPE_DOWNLOAD:
					download_.url = obj.src as String;
                    imgLoader_.load(request_);
					imgLoader_.name = obj.id;
					break;
				case ExternalLoader.TYPE_REQUEST:
					request_.data = obj.data;
                    xmlLoader_.load(request_);
					break;
				case ExternalLoader.TYPE_SUBMIT:
					submit_.data = obj.data;
                    xmlLoader_.load(submit_);
					break;
				}
            }
        }
        
        private function onComplete(evt:Event):void {
trace("onComplete>> "+evt.target.data);
			if (evt.target.data) dispatcher.dispatchEvent(new NetEvent(NetEvent.RECEIVED, new URLVariables(evt.target.data)));
			else dispatcher.dispatchEvent(new NetEvent(NetEvent.DONWNLOADED, { id:evt.target.id, img:evt.target.content.bitmapData }));
            
			isRunning_ = false;
            processQueue();
        }
		
		// report web server level error msg
		private function onError(evt:Event):void {
			var data:Object = evt.target.data;
for (var key:String in data) {
	trace("key: " + key + " val: " + data[key]);
}
			dispatcher.dispatchEvent(new NetEvent(NetEvent.ERROR, { error:data } ));
			
            isRunning_ = false;
            processQueue();
		}
   }
    
}
