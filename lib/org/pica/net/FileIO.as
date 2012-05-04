package org.pica.net {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	public class FileIO extends EventDispatcher {
		
		public function FileIO() {
			
		}
		
		public function read(path:String):void {
			var loader:URLLoader = new URLLoader();
			addListeners(loader);
			loader.load(new URLRequest(path));
		}
		
		private function addListeners(loader:URLLoader):void {
			loader.addEventListener( Event.COMPLETE, onComplete );
			loader.addEventListener( ProgressEvent.PROGRESS, onProgress );
			loader.addEventListener( IOErrorEvent.IO_ERROR, onError );
		}
		
		private function removeListeners(loader:URLLoader):void {
			loader.removeEventListener( Event.COMPLETE, onComplete );
			loader.removeEventListener( ProgressEvent.PROGRESS, onProgress );
			loader.removeEventListener( IOErrorEvent.IO_ERROR, onError );
		}
		
		private function onComplete(evt:Event):void {
			var loader:URLLoader = evt.target as URLLoader;
			removeListeners(loader);
			switch(loader.dataFormat)
			{
			case URLLoaderDataFormat.TEXT:
				parseText(loader.data as String);
				break;
			case URLLoaderDataFormat.BINARY:
				parseBin(loader.data as ByteArray);
				break;
			case URLLoaderDataFormat.VARIABLES:
				parseVar(loader.data as URLVariables);
				break;
			}
		}
		
		private function onProgress(evt:ProgressEvent):void {
			if (hasEventListener(ProgressEvent.PROGRESS)) {
				dispatchEvent(evt);
			}
		}
		
		private function onError(evt:IOErrorEvent):void {
			removeListeners(evt.target as URLLoader);
			dispatchEvent(evt);
		}
		
		private function parseText(data:String):void {
			trace("FileIO parseText: "+data);
		}
		
		private function parseBin(data:ByteArray):void {
			trace("FileIO parseBin");
		}
		
		private function parseVar(data:URLVariables):void {
			trace("FileIO parseVar");
		}
	}
}