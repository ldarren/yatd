package scenes.td.ui {
	import flash.display.Sprite;
	import org.pica.graphics.ui.Button;
	import org.pica.graphics.ui.Label;
	import scenes.td.events.GameEvent;
	import scenes.td.events.TowerEvent;
	import scenes.td.events.TowerEventDispatcher;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Hud extends Sprite {
		
		private var label_score_:Label;
		private var label_level_:Label;
		private var label_cash_:Label;
		private var label_owner_:Label;
		private var label_mode_:Label;
		public var label_help:Label;
		
		private var button_quest_:Button;
		private var button_inventory_:Button;
		private var button_friends_:Button;
		private var button_save_:Button;
		private var button_help_:Button;
		
		private var play_mode_:Boolean;
		private var is_host_:Boolean = true;
		private var score_:int = 0;
		private var level_:int = 0;
		private var cash_:int = 0;
		private var harvested_:int = 0; // harvested in one round

		public var dispatcher:TowerEventDispatcher;
		
		public function Hud() {
			dispatcher = new TowerEventDispatcher("Hud");
			
			label_score_ = new Label("hud_score", "Score: "+score_, 10, 10, 100, 20);
			label_level_ = new Label("hud_level", "Level: "+level_, 10, 30, 100, 20);
			label_cash_ = new Label("hud_cash", "Cash: "+cash_, 10, 50, 100, 20);
			label_owner_ = new Label("hud_owner", "", 110, 10, 400, 20);
			label_mode_ = new Label("hud_mode", "", 110, 30, 100, 20);
			label_help = new Label("hud_help", "Welcome to Harvestor", 10, 570, 600, 20);
			
			button_quest_ = new Button("hud_btn_quest", "Quest", null, {up:onButton}, 680, 10, 70);
			button_friends_ = new Button("hud_btn_buddy", "Friends", null, {up:onButton}, 680, 30, 70);
			button_inventory_ = new Button("hud_btn_inv", "Inventory", null, {up:onButton}, 680, 50, 70);
			button_save_ = new Button("hud_btn_save", "Save", null, {up:onButton}, 680, 70, 70);
			button_help_ = new Button("hud_btn_help", "Help", null, {up:onButton}, 680, 90, 70);
			
			this.addChild(label_score_);
			this.addChild(label_level_);
			this.addChild(label_cash_);
			this.addChild(label_owner_);
			this.addChild(label_mode_);
			this.addChild(label_help);
			this.addChild(button_quest_);
			
			changeMode(false);
		}
		
		private function onButton(btn:Button):void {
			switch (btn.name) {
			case "hud_btn_quest":
				if (!play_mode_) dispatcher.dispatchEvent(new GameEvent(GameEvent.GAME_QUEST));
				else changeMode(false);
				break;
			case "hud_btn_inv":
				dispatcher.dispatchEvent(new TowerEvent(TowerEvent.TOWER_GEM, { viewonly:true } ));
				break;
			case "hud_btn_buddy":
				dispatcher.dispatchEvent(new GameEvent(GameEvent.GAME_BUDDY));
				break;
			case "hud_btn_save":
				dispatcher.dispatchEvent(new GameEvent(GameEvent.GAME_SAVE));
				break;
			case "hud_btn_help":
				dispatcher.dispatchEvent(new GameEvent(GameEvent.GAME_HELP));
				break;
			}
			label_help.text = "Welcome to Harvestor";
		}
		
		public function onScore(evt:GameEvent):void {
			score_ += 10;
			harvested_++;
			label_score_.text = "Score: " + score_;
		}
		
		public function changeMode(play:Boolean):void {
			play_mode_ = play;
			label_mode_.text = "Mode: " + (play_mode_?"Play":"Edit");
			if (play_mode_) {
				harvested_ = 0;
				dispatcher.dispatchEvent(new GameEvent(GameEvent.GAME_START));
				button_quest_.setContent("Cancel", null, 70);
				this.removeChild(button_friends_);
				if (button_inventory_.parent == this) this.removeChild(button_inventory_);
				if (button_save_.parent == this) this.removeChild(button_save_);
				if (button_help_.parent == this) this.removeChild(button_help_);
			} else {
				dispatcher.dispatchEvent(new GameEvent(GameEvent.GAME_END));
				button_quest_.setContent("Quest", null, 70);
				this.addChild(button_friends_);
				if (button_inventory_.parent != this && is_host_) this.addChild(button_inventory_);
				if (button_save_.parent != this && is_host_) this.addChild(button_save_);
				if (button_help_.parent != this && is_host_) this.addChild(button_help_);
			}
		}
		
		public function changeOwner(name:String, pic:String, is_host:Boolean):void {
			is_host_ = is_host;
			label_owner_.text = "Owner: " + name;
			if (is_host_) {
				if (button_inventory_.parent != this && !play_mode_) this.addChild(button_inventory_);
				if (button_save_.parent != this && !play_mode_) this.addChild(button_save_);
			} else {
				if (button_inventory_.parent == this) this.removeChild(button_inventory_);
				if (button_save_.parent == this) this.removeChild(button_save_);
			}
		}
		
		public function get score():int { return score_; }
		public function get level():int { return level_; }
		public function get cash():int { return cash_; }
		public function get harvested():int { return harvested_;}
		
		public function set score(val:int):void {
			score_ = val;
			label_score_.text = "Score: " + score_;
		}
		public function set level(val:int):void {
			level_ = val;
			label_level_.text = "Level: " + level_;
		}
		public function set cash(val:int):void {
			cash_ = val;
			label_cash_.text = "Cash: " + cash_;
		}
		
	}
	
}