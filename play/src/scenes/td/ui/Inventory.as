package scenes.td.ui {
	import flash.display.Stage;
	import org.pica.graphics.ui.Button;
	import org.pica.graphics.ui.ListBox;
	import scenes.td.events.TowerEvent;
	import scenes.td.RcsMgr;
	import scenes.td.TowerFarm;
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Inventory extends Dialog {
		
		// zero based orb id, TowerFarm.ORB_XXX_CODE are for saving and loading.
		static public const ORB_BLUE:int		= 0;
		static public const ORB_BLACK:int		= 1;
		static public const ORB_AMBER:int		= 2;
		static public const ORB_CLEAR:int		= 3;
		static public const ORB_GREEN:int		= 4;
		static public const ORB_RED:int			= 5;
		static public const ORB_PURPLE:int		= 6;
		static public const ORB_MAX:int			= 7;
		static public const ORB_PINK:int		= 7;
		static public const ORB_WOOD:int		= 8;
		static public const ORB_WATER:int		= 9;
		static public const ORB_STONE:int		= 10;
		static public const ORB_METAL:int		= 11;
		static public const ORB_HOWLITE:int		= 12;
		static public const ORB_EARTH:int		= 13;
		static public const ORB_LIGHTNING:int	= 14;
		static public const ORB_AIR:int			= 15;
		static public const ORB_FIRE:int		= 16;

		static private const arts_:Array = ["blue_orb", "black_orb", "amber_orb", "clear_orb", "green_orb", "red_orb", "purple_orb"];
		
		private var list_ui_:ListBox;
		private var stash_:Array;
		private var is_viewonly_:Boolean = true;
		
		public function Inventory(stage:Stage, x:Number, y:Number, w:Number, h:Number) {
			super("Inventory", "inv", stage, x, y, w, h);
			super.enableClose(true);

			list_ui_ = new ListBox("goods", 145, 84, 5, onSelect, ListBox.ALIGN_VERTICAL);
			list_ui_.x = 15;
			list_ui_.y = 30;
			_window.addChild(list_ui_);
			
			stash_ = new Array(arts_.length);
			for (var i:int = 0, l:int = stash_.length; i < l; i++) {
				stash_[i] = 0;
			}
		}
		
		public function setOrb(type:int, count:int):void {
			if (type < 0 || type >= stash_.length) return;
			var n:String = "" + type;
			stash_[type] = count;
			var item:Button = list_ui_.getItem(n);
			if (item == null) {
				list_ui_.addItem(n, "Count: " + count, RcsMgr.getTex(arts_[type]));
			} else {
				item.setContent("Count: " + count, [RcsMgr.getTex(arts_[type])] );
			}
		}
		
		public function addOrb(type:int, count:int):void {
			if (type < 0 || type >= stash_.length) return;
			stash_[type] += count;
			setOrb(type, stash_[type]);
		}
		
		public function updateOrb(type:int, count:int):void {
			stash_[type] = count;
		}
		
		// 0:5;1:0;1:0;
		public function load(data:String):void {
			var args:Array;
			var lines:Array = data.split(";");
			if (lines.length == 0) {	// give away 5 orbs
				setOrb(Inventory.ORB_BLUE, 5);
			}
			for each (var line:String in lines) {
				if (line == "") continue;
				args = line.split(":");
				if (args[0] == "" || args[1] == "") continue;
				setOrb(parseInt(args[0]), parseInt(args[1]));
			}
		}
		
		public function save():String {
			var data:String = "";
			for (var i:int = 0, l:int = stash_.length; i < l; i++) {
				data += i + ":" + stash_[i] + ";";
			}
			return data;
		}
		
		public function onShow(visible:Boolean, viewonly:Boolean):void {
			super.show(visible);
			list_ui_.unselectAll();
			is_viewonly_ = viewonly;
		}
		
		private function onSelect(btn:Button):void {
			if (is_viewonly_) return;
			var type:int = parseInt(btn.name);
			if (stash_[type] < 1) return;
			addOrb(type, -1);
			dispatcher.dispatchEvent(new TowerEvent(TowerEvent.RAISE_TOWER, {orb:type+(TowerFarm.ORB_BLUE_CODE-ORB_BLUE)}));
			onShow(false, true);
		}
		
	}

}