package {
	import flash.events.Event;
	import org.pica.graphics.Renderer;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public interface ICase {
		function load(gfx:Renderer):void;
		function unload(gfx:Renderer):void;
		function onEvent(evt:Event):void;
		function onUpdate():void;
	}
	
}