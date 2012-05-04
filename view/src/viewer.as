package {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import mx.managers.PopUpManager;
	import mx.containers.ApplicationControlBar;
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.core.UIComponent;
	import org.papervision3d.objects.DisplayObject3D;
	import org.pica.graphics.loader.Object3D;
	import org.pica.graphics.Renderer;
	
	public class viewer extends UIComponent {
		
		[Embed(source = "../../res/tex/concrete.jpg")] private var ConcreteBitmapClass:Class;
		
		private var mToolBar_:ApplicationControlBar;
		private var mGfx_:Renderer;
		
		private var mMainFile_:FileReference;
		private var mAttachFile_:FileReference;
		private var mImageFile_:FileReference;
		private var mModelFileFilters_:Array;
		private var mImageFileFilters_:Array;
		
		private var mAvatar_:Object3D;
		private var mEquipment_:Object3D;
		
		private var mSelWin_:windowSelection;
		
		private var nOldMouseX:Number;
		private var nOldMouseY:Number;
		private var nCamEle_:Number;
		private var nCamSec_:Number;
		
		public function viewer() {
			super();
			
			mModelFileFilters_ = new Array(new FileFilter("Model files (*.dae, *.kmz, *.md2)", "*.dae;*.kmz;*.md2;"));
			mImageFileFilters_ = new Array(new FileFilter("Image files (*.jpg, *.png, *.swf)", "*.jpg;*.png;*.swf;"));
			
			mMainFile_ = new FileReference();
			mMainFile_.addEventListener(Event.SELECT, openFile);
			
			mAttachFile_ = new FileReference();
			mAttachFile_.addEventListener(Event.SELECT, attachFile);
			
			mImageFile_ = new FileReference();
			mImageFile_.addEventListener(Event.SELECT, reskinFile);
			
			nCamEle_ = 0;
			nCamSec_ = 0;
			
			mAvatar_ = new Object3D("ava");
			mEquipment_ = new Object3D("equ");
		}
		
		public function init(toolbar:ApplicationControlBar):void {
			this.graphics.beginFill(0xaaaaaa);
			this.graphics.drawRect(0, 0, this.width, this.height);
			this.graphics.endFill();

			mToolBar_ = toolbar;

			mGfx_ = new Renderer(this);
		}
		
		public function onUpdate(evt:Event):void {
			mGfx_.onEnterFrame(evt);
		}
		
		public function onEvent(evt:Event):void {
			var e:MouseEvent;
			switch(evt.type) {
			case MouseEvent.MOUSE_WHEEL:
					e = evt as MouseEvent;
					var delta:int = e.delta;
					if (e.altKey) delta += delta * 10;
					if (e.ctrlKey) delta += delta * 10;
					if (e.altKey) delta += delta * 10;
					mGfx_.moveCamera(delta);
				break;
			case MouseEvent.MOUSE_DOWN:
				nOldMouseX = this.mouseX;
				nOldMouseY = this.mouseY;
				break;
			case MouseEvent.MOUSE_UP:
			case MouseEvent.MOUSE_OUT:
				break;
			case MouseEvent.MOUSE_MOVE:
				{
					e = evt as MouseEvent;
					if (e.buttonDown) {
						nCamEle_ += nOldMouseY - this.mouseY;
						nCamSec_ += nOldMouseX - this.mouseX;
						nOldMouseX = this.mouseX;
						nOldMouseY = this.mouseY;
						nCamEle_ %= 360;
						nCamSec_ %= 360;

						mGfx_.rotCamera(nCamEle_, nCamSec_);
					}
				}
				break;
			}
			mGfx_.onEvent(evt);
		}
		
		public function onButton(evt:Event):void {
			var btn:Button = evt.currentTarget as Button;
			switch(btn.id)
			{
			case "btnopen":
				mMainFile_.browse(mModelFileFilters_);
				break;
			case "btnadd":
				mAttachFile_.browse(mModelFileFilters_);
				break;
			case "btnskin":
				mImageFile_.browse(mImageFileFilters_);
				break;
			}
		}
		
		private function openFile(evt:Event):void {
            var file:FileReference = evt.target as FileReference;
			mAvatar_.openModel("main", "../../res/", file.name, new ConcreteBitmapClass(), onAvatarLoaded);
		}
		
		private function attachFile(evt:Event):void {
            var file:FileReference = evt.target as FileReference;
			displaySelectionList(mAvatar_.getNodeNameList("main"), file.name, "node");
		}
		
		private function reskinFile(evt:Event):void {
            var file:FileReference = evt.target as FileReference;
			displaySelectionList(mAvatar_.getMaterialNameList("main"), file.name, "mat");
		}
		
		public function displaySelectionList(list:Array, target:String, type:String):void {
			mSelWin_ = PopUpManager.createPopUp(this, windowSelection, true) as windowSelection;
			if (type=="node")
				mSelWin_["idWinFindView"].addEventListener(MouseEvent.CLICK, selectedNode)
			else
				mSelWin_["idWinFindView"].addEventListener(MouseEvent.CLICK, selectedMat)
			mSelWin_.start(list, target);
		}
		
		private function selectedNode(evt:Event):void {
			mEquipment_.openModel("main", "../../res/", mSelWin_.targetID, new ConcreteBitmapClass(), onEquipmentLoaded);
			mSelWin_.removeMe();
		}
		
		private function selectedMat(evt:Event):void {
			mAvatar_.reskinModel("main", "../../res/", new Array(mSelWin_.targetID), mSelWin_.selectedID);
			mSelWin_.removeMe();
		}
		
		private function onAvatarLoaded(model:DisplayObject3D):void {
			mGfx_.addObj(mAvatar_);
		}
		
		private function onEquipmentLoaded(model:DisplayObject3D):void {
			mAvatar_.getChildByName(mSelWin_.selectedID, true).addChild(mEquipment_, "sword");
		}
	}
}
