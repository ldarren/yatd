package org.pica.graphics {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.Papervision3D;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	
	public class Renderer {

		private var viewport_:Viewport3D;
		private var renderer_:BasicRenderEngine;
		private var scene_:Scene3D;
		private var camera_:CameraObject3D;
		private var canvas_:Sprite;
		
		public function Renderer(canvas:Sprite, width:Number = 800, height:Number = 600, camera:CameraObject3D=null) {
			//Papervision3D.useDEGREES = false;
			Papervision3D.usePERCENT = false;

			viewport_ = new Viewport3D(width, height, false, true);
			
			renderer_ = new BasicRenderEngine();
			viewport_.opaqueBackground = 0;
			scene_ = new Scene3D();
			camera_ = camera==null?new Camera3D():camera;

			canvas_ = canvas;
			canvas_.addChild(viewport_);	// IChildList is flex's canvas has to be used
			
			initWorld();
			initOverlays();
		}
		
		protected function initWorld():void {
			camera_.x = 0;
			camera_.y = 0;
			camera_.z = -100;
			
			viewport_.interactive = true;
		}
		
		protected function initOverlays():void {
			
		}
		
		public function onEnterFrame(evt:Event = null):void {
			renderer_.renderScene(scene_, camera_, viewport_);
		}
		
		public function get scene():Scene3D {
			return scene_;
		}
		
		public function get renderer():BasicRenderEngine {
			return renderer_;
		}
		
		public function get camera():CameraObject3D {
			return camera_;
		}
		
		public function get viewport():Viewport3D {
			return viewport_;
		}
		
		public function onEvent(evt:Event):void {
			
		}
		
		public function setCameraPos(pos:Number3D):void {
			camera_.position = pos;
		}
		
		public function moveCamera(dist:Number):void {
			camera_.moveForward(dist);
		}
		
		public function rotCamera(ele:Number, sec:Number):void {
			camera_.orbit(ele, sec, true);
		}
		
		public function addObj(obj:DisplayObject3D, name:String=null):void {
			scene_.addChild(obj,name);
		}
		
		public function removeObj(obj:DisplayObject3D):void {
			scene_.removeChild(obj);
		}
		
		public function addOverlay(ui:DisplayObject):void {
			canvas_.addChild(ui);
		}
		
		public function removeOverlay(ui:DisplayObject):void {
			canvas_.removeChild(ui);
		}
	}
}