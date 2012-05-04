package scenes.td.ui {
	import flash.display.Stage;
	import org.pica.graphics.ui.Button;
	import scenes.td.events.GameEvent;
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Quests extends Dialog {
		
		public static var itemWidth:int = 70;
		public static const itemHeight:int = 70;
		private static const initialX:int = 10;
		private static const initialY:int = 20;
		
		public function Quests(stage:Stage, x:Number, y:Number, w:Number, h:Number) {
			super("Quests", "quest", stage, x, y, w, h);
			super.enableClose(true);
			Quests.itemWidth = w;
		}
		
		public function onShow(visible:Boolean):void {
			super.show(visible);
		}
		
		public function addQuest(id:int, kills:int, cash:int, orb:int, count:int):void {
			var quest:Quest = new Quest(id, kills, cash, orb, count, onSelect);
			quest.x = initialX;
			quest.y = initialY + id*itemHeight;
			_window.addChild(quest);
		}
		
		public function getQuest(quest:int):Object {
			var q:Quest = _window.getChildByName("q" + quest) as Quest;
			var obj:Object = {kills:q.kills, cash:q.cash, orb:q.orb_level, count:q.orb_count };
			return obj;
		}
		
		private function onSelect(btn:Button):void {
			dispatcher.dispatchEvent(new GameEvent(GameEvent.GAME_DO, { quest:btn.name} ));
			onShow(false);
		}
		
	}

}
import flash.display.Sprite;
import org.pica.graphics.ui.Button;
import org.pica.graphics.ui.Label;

class Quest extends Sprite {
	public var solved:Boolean;
	public var id:int;
	public var kills:int;
	public var cash:int;
	public var orb_level:int;
	public var orb_count:int;
	
	private var label_obj_:Label;
	private var label_rewards_:Label;
	private var btn_select_:Button;
	
	private static const prefix_obj_:String = "Quest: ";
	private static const prefix_rewards_:String = "Rewards: ";
	
	public function Quest(id:int, kills:int, cash:int, orb:int, count:int, onSelect:Function) {
		this.name = "q" + id;
		this.solved = false;
		this.id = id;
		this.kills = kills;
		this.cash = cash;
		this.orb_level = orb;
		this.orb_count = count;
		var w:int = scenes.td.ui.Quests.itemWidth;
		
		label_obj_ = new Label("obj", prefix_obj_+"Capture "+kills+" wisp", 5, 5, w-10, 20);
		label_rewards_ = new Label("rew", prefix_rewards_+cash+" cash "+(count > 0? "and "+count+" orb level "+orb:""), 5, 25, w-10, 20);
		btn_select_ = new Button(""+id, "Select", null, {up:onSelect}, (w-100)/2, 45, 100, 25);
		
		this.addChild(label_obj_);
		this.addChild(label_rewards_);
		this.addChild(btn_select_);
	}
}