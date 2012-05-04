package scenes.td.ui {
	import flash.display.Stage;
	import flash.text.StyleSheet;
	import flash.text.TextFormatAlign;
	import org.pica.graphics.ui.Button;
	import org.pica.graphics.ui.Label;
	import scenes.td.RcsMgr;
	/**
	 * ...
	 * @author Darren Liew
	 * @info only subset of html tag are supported by as3 there are 
	 * Anchor tag (<a>)
	 * Bold tag (<b>)
	 * Break tag (<br>)
	 * Font tag (<font>)
	 * Image tag (<img>)
	 * Italic tag (<i>)
	 * List item tag (<li>)
	 * Paragraph tag (<p>)
	 * Text format tag (<textformat>)
	 * Underline tag (<u>)
	 */
	public class Help extends Dialog {
		static private const titles:Array = ["<b>Introduction</b>", "<b>Game Modes and controls</b>", "<b>Map Editing</b>", "<b>Construction costs</b>", "<b>Quests</b>", "<b>Orbs</b>"];
		static private const descs:Array = [
		"YATD is a tower defense game, but instead of creeps YATD uses wisps. wisp is an energized-able organism in YATD world. instead of killing creeps \
YATD required you to energize the wisp, when a energized wisp return to destination, you earned points.",
		"<p>YATD has two game modes, the edit mode and play mode. the indicator of game mode is located at top right corner. in edit mode you could place towers \
on the floor tiles, and in play mode, your tower map will be put on tests, wisps will be spawn from pink color portal and exit to green color portal</p><br\>\
<p>to move camera, use <i>w</i>, <i>s</i>, <i>a</i> and <i>d</i> keys to move camera forward and backward and sideway respectively and <i>q</i> and <i>e</i> to rotate camera, left mouse click could be\
 used for tower construction and destruction</p>",
		"In map editing mode, following operations could be performed:<li>build a wall: single click on the platform</li>\
<li>build a tower: you need a spare orb in your inventory to perform this. click on a wall and select a orb type to build a tower</li>\
<li>destroy a wall: click on a wall or tower and select <u>destroy wall</u> in the popup menu</li>\
<li>destroy a tower: click on a tower and select <u>destroy tower</u> in the popup menu</li>\
<li>move wisp spawn portal: click on the pink color portal to select it and click on a empty floor tile to move the portal to that location</li>\
<li>move wisp exit portal: click on the green color portal to select it and click on a empty floor tile to move the portal to that location</li>",
		"various operations in map editing cost you cash. cost listing:<li>build a wall: 4 cash points</li><li>build a tower: 2 cash points</li>\
<li>destroy a wall: 2 cash points</li><li>destroy a tower: 1 cash point and the mounted orb</li>",
		"You need to take a quest to change the game mode from edit to play. after fufilling a quest you will be rewarded by items stated in the quest.",
		"Orbs are used to mount on the top of tower to emit laser beam and charge up wisps into ionized wisps, there are 7 grades of orbs, which could \
be see from inventory window. for a beginner 5 blue orbs will be given to start your job. to earn more orbs, you have to complete the given quests"];

		private var btn_prev_:Button;
		private var btn_next_:Button;
		private var lbl_title_:Label;
		private var lbl_desc_:Label;
		
		private var pageNum:int = 0;

		public function Help(stage:Stage, x:Number, y:Number, w:Number, h:Number) {
			super("Helps", "help", stage, x, y, w, h);
			super.enableClose(true);
			
			lbl_title_ = new Label("help_title", "", 20, 40, w - 40, 20, TextFormatAlign.CENTER);
			lbl_desc_ = new Label("help_desc", "", 20, 80, w-40, h - 100, TextFormatAlign.JUSTIFY);
			lbl_desc_.multiline = true;
			lbl_desc_.wordWrap = true;
			btn_prev_ = new Button("help_prev", "Previous", null, { up:onChangePage }, 20, h-40, 100, 20);
			btn_next_ = new Button("help_next", "Next", null, { up:onChangePage }, w-110, h-40, 100, 20);

			_window.addChild(lbl_title_);
			_window.addChild(lbl_desc_);
			_window.addChild(btn_prev_);
			_window.addChild(btn_next_);
		}
		
		public function onShow(visible:Boolean):void {
			super.show(visible);
			showPage();
		}
		
		public function onChangePage(btn:Button):void {
			switch (btn.name) {
			case btn_prev_.name:
				pageNum--;
				break;
			case btn_next_.name:
				pageNum++;
				break;
			}
			if (pageNum <= 0) {
				pageNum = 0;
				btn_prev_.setContent("End", null, 100, 20);
			} else {
				btn_prev_.setContent("Previous", null, 100, 20);
			}
			
			if (pageNum >= Help.titles.length - 1) {
				pageNum = Help.titles.length - 1;
				btn_next_.setContent("End", null, 100, 20);
			} else {
				btn_next_.setContent("Next", null, 100, 20);
			}
			
			showPage();
		}
		
		private function showPage():void {
			lbl_title_.htmlText = Help.titles[pageNum];
			lbl_desc_.htmlText = Help.descs[pageNum];
		}
		
	}

}