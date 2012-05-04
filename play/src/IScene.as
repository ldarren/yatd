package {
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import org.pica.graphics.Renderer;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public interface IScene {
		function load(gfx:Renderer):void;
		function unload(gfx:Renderer):void;
		function onKeyboard(evt:KeyboardEvent):void;
		function onMouse(evt:MouseEvent):void;
		function onUpdate():void;
	}
	
}