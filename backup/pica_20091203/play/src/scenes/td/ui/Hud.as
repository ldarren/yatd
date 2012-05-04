package scenes.td.ui {
	import flash.display.Sprite;
	import org.pica.graphics.ui.Button;
	import org.pica.graphics.ui.Label;
	import scenes.td.events.GameEvent;
	import scenes.td.events.TowerEventDispatcher;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Hud extends Sprite {
		
		private var label_score_:Label;
		private var label_mode_:Label;
		public var label_help:Label;
		private var button_mode_:Button;
		private var play_mode_:Boolean;
		private var score_:int = 0;

		public var dispatcher:TowerEventDispatcher;
		
		public function Hud() {
			dispatcher = new TowerEventDispatcher("Hud");
			label_score_ = new Label("hud_score", "Score: "+score_, 10, 10, 100, 20);
			label_mode_ = new Label("hud_mode", "", 600, 10, 100, 20);
			label_help = new Label("hud_help", "Welcome to Harvestor", 10, 570, 600, 20);
			button_mode_ = new Button("hud_btn_mode", "Change", null, {up:onButton}, 680, 10);
			this.addChild(label_score_);
			this.addChild(label_mode_);
			this.addChild(label_help);
			this.addChild(button_mode_);
			changeMode(false);
		}
		
		private function onButton(btn:Button):void {
			switch (btn.name) {
			case "hud_btn_mode":
				changeMode(!play_mode_);
				break;
			}
			label_help.text = "Welcome to Harvestor";
		}
		
		public function onScore(evt:GameEvent):void {
			score_ += 10;
			label_score_.text = "Score: " + score_;
		}
		
		public function changeMode(play:Boolean):void {
			play_mode_ = play;
			label_mode_.text = "Mode: " + (play_mode_?"Play":"Edit");
			if (play_mode_) dispatcher.dispatchEvent(new GameEvent(GameEvent.GAME_START));
			else dispatcher.dispatchEvent(new GameEvent(GameEvent.GAME_END));
		}
		
		public function get score():int {
			return score_;
		}
		
	}
	
}