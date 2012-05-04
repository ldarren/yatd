package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import org.pica.graphics.Renderer;
	import org.pica.graphics.ui.Picker3D;
	import org.pica.utils.Constant;
	import scenes.*;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Main extends Sprite {
		private var gfx_:Renderer;
		private var scene_:IScene;
		
		public function Main() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			Constant.FPS = stage.frameRate;
			
			gfx_ = new Renderer(this, stage.stageWidth, stage.stageHeight);
			Picker3D.init(gfx_.viewport);

			scene_ = new SceneTowers(stage);
			scene_.load(gfx_);
			
			addEventListener(Event.ENTER_FRAME, onUpdate, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouse); // sprite empty space doesn't receive event
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouse);
			addEventListener(MouseEvent.CLICK, onMouse);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouse);
			addEventListener(MouseEvent.MOUSE_UP, onMouse);
			addEventListener(MouseEvent.MOUSE_OUT, onMouse);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboard);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyboard);
		}
		
		private function onUpdate(evt:Event):void {
			scene_.onUpdate();
			
			gfx_.onEnterFrame(evt);
		}
		
		private function onMouse(evt:MouseEvent):void {
			scene_.onMouse(evt);
			gfx_.onEvent(evt);
		}
		
		private function onKeyboard(evt:KeyboardEvent):void {
			scene_.onKeyboard(evt);
		}
		
	}
	
}