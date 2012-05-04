package {
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import mx.core.UIComponent;
	import org.pica.graphics.Renderer;
	import org.pica.graphics.ui.Picker3D;
	import module.*;
	
	public class Test extends UIComponent {
		
		public static const CASE_GFX_DECAL:String			= "Deca";
		public static const CASE_GFX_ANIMATED_SPRITE:String	= "AnSp";
		public static const CASE_GFX_ISO_CAMERA:String		= "IsoC";
		public static const CASE_GFX_LIGHTNING:String		= "LGNI";
		public static const CASE_GFX_PORTAL:String			= "PRTL";
		public static const CASE_GFX_TRAILS:String			= "Tril";
		public static const CASE_AI_PATHFINDING:String		= "Path";
		public static const CASE_AI_SWARM:String			= "Swar";
		public static const CASE_UI_BUTTON:String			= "Btn";
		public static const CASE_UI_LIST:String				= "List";
		public static const CASE_UI_WINDOW:String			= "Win";

		private var mGfx_:Renderer;
		private var cases_:Object;
		private var currCase_:ICase;
		
		private var focusCheck_:Boolean = false;
		
		public function Test() {
			super();
			
			cases_ = new Array();
		}
		
		public function init():void {
			this.graphics.beginFill(0x000000);
			this.graphics.drawRect(0, 0, this.width, this.height);
			this.graphics.endFill();
			
			mGfx_ = new Renderer(this);
			
			cases_[CaseDecal.ID] = new CaseDecal();
			cases_[CasePathFinding.ID] = new CasePathFinding();
			cases_[CaseSwarm.ID] = new CaseSwarm();
			cases_[CaseButton.ID] = new CaseButton();
			cases_[CaseList.ID] = new CaseList();
			cases_[CaseWindow.ID] = new CaseWindow();
			cases_[CaseAnimatedSprite.ID] = new CaseAnimatedSprite();
			cases_[CaseIsoCamera.ID] = new CaseIsoCamera();
			cases_[CaseLightning.ID] = new CaseLightning();
			cases_[CasePortal.ID] = new CasePortal();
			cases_[CaseTrails.ID] = new CaseTrails();
			
			currCase_ = cases_[CaseButton.ID];
			currCase_.load(mGfx_);
			//mGfx_.rotCamera(0, 0);
			
			Picker3D.init(mGfx_.viewport);
			trace("fps "+stage.frameRate);
		}
		
		public function onUpdate(evt:Event):void {
			currCase_.onUpdate();
			mGfx_.onEnterFrame(evt);
		}
		
		public function onEvent(evt:Event):void {
			var data:String;
			var c:ICase = null;

			switch(evt.type) {
			case MouseEvent.MOUSE_WHEEL:
			case MouseEvent.MOUSE_DOWN:
			case MouseEvent.MOUSE_UP:
			case MouseEvent.MOUSE_MOVE:
				if (!focusCheck_) break;
				var obj:InteractiveObject = this.getFocus();
				if (obj == null || !this.contains(obj)) {
					this.setFocus();
					focusCheck_ = false;
				}
				break;
			case MouseEvent.MOUSE_OUT:
				focusCheck_ = true;
				break;
			case Event.CHANGE:
				data = evt.currentTarget.selectedItem.@data;
				if (data != null && data != "") {
					c = cases_[data];
				}
				
				if (c != null && c != currCase_) {
					currCase_.unload(mGfx_);
					currCase_ = c;
					currCase_.load(mGfx_);
				}
				break;
			}
			
			currCase_.onEvent(evt);
			mGfx_.onEvent(evt);
		}
		
		public function onButton(evt:Event):void {
			currCase_.onEvent(evt);
		}
	}
}