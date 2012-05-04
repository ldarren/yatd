package scenes.td.ui {
	import flash.display.Stage;
	import org.pica.graphics.loader.Object2D;
	import org.pica.graphics.ui.Button;
	import org.pica.graphics.ui.ListBox;
	import scenes.td.events.GameEvent;
	import scenes.td.RcsMgr;
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Friends extends Dialog {
		
		private var list_ui_:ListBox;
		private var buddies_:Object;
		
		public function Friends(stage:Stage, x:Number, y:Number, w:Number, h:Number) {
			super("Comrades", "buddy", stage, x, y, w, h);
			super.enableClose(true);

			list_ui_ = new ListBox("buddies", 86, 100, 7, onSelect, ListBox.ALIGN_HORIZONTAL);
			list_ui_.x = 15;
			list_ui_.y = 30;
			_window.addChild(list_ui_);
			
			buddies_ = new Object();
		}
		
		// minimum player level is 1, 0 means non-player :D
		public function addHost(id:String, label:String, pic:String):void {
			buddies_[id] = {id:id, name:label, pic:pic, isOwner:true, loaded:false};
		}
		
		public function addFriend(id:String, label:String, pic:String):void {
			buddies_[id] = {id:id, name:label, pic:pic, isOwner:false, loaded:false};
		}
		
		public function addDetail(id:String, lvl:int):void {
			var data:Object = buddies_[id];
			data.level = lvl;
			if (!data.loaded) {
				var obj:Object2D = new Object2D(id);
				obj.load(data.pic, 50, 50, onPictureLoaded);
				//var b:Button = list_ui_.addItem(data.name, data.name, null);
			}
		}
		
		public function onShow(visible:Boolean):void {
			super.show(visible);
		}
		
		private function onSelect(btn:Button):void {
			var obj:Object = buddies_[btn.name];
			dispatcher.dispatchEvent(new GameEvent(GameEvent.GAME_LOAD, { uid:obj.id, name:obj.name, pic:obj.pic, lvl:obj.level } ));
			onShow(false);
		}
		
		private function onPictureLoaded(obj:Object2D):void {
			var data:Object = buddies_[obj.name];
			var b:Button = list_ui_.addItem(obj.name, data.name, obj);
			if (data.isOwner) list_ui_.selectedItem(b);
			data.loaded = true;
		}
		
	}

}