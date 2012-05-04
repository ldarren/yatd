package scenes {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.pica.graphics.cameras.CameraManIso;
	import org.pica.graphics.effects.Skybox;
	import org.pica.graphics.Renderer;
	import org.pica.graphics.ui.Button;
	import org.pica.graphics.ui.ListBox;
	import org.pica.graphics.ui.Picker3D;
	import org.pica.graphics.ui.Window;
	import org.pica.net.ExternalLoader;
	import org.pica.net.NetEvent;
	import scenes.td.events.GameEvent;
	import scenes.td.events.TowerEvent;
	import scenes.td.Ground;
	import scenes.td.InnerNet;
	import scenes.td.SocialNet;
	import scenes.td.TowerFarm;
	import scenes.td.RcsMgr;
	import scenes.td.ui.Friends;
	import scenes.td.ui.Help;
	import scenes.td.ui.Inventory;
	import scenes.td.ui.Login;
	import scenes.td.ui.MessageBox;
	import scenes.td.ui.Quests;
	import scenes.td.WispGroup;
	import scenes.td.ui.Hud;
	import scenes.td.ui.BuildOption;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class SceneTowers implements IScene	{
		
		private var ground_:Ground;
		private var towers_:TowerFarm;
		private var cameraman_:CameraManIso;
		private var wisps_:WispGroup;
		private var skybox_:Skybox;

		private var build_:BuildOption;
		private var login_:Login;
		private var friends_:Friends;
		private var inventory_:Inventory;
		private var quests_:Quests;
		private var help_:Help;
		private var msgbox_:MessageBox;
		private var hud_:Hud;
		
		private var isEditMode_:Boolean = true;
		private var currQuest_:int = -1;
		private var parent_:DisplayObject;
		
		private var innerNet_:ExternalLoader;
		private var outerNet_:SocialNet;
		
		private var hostId_:String = "";
		private var isHost_:Boolean = false;
		
		public function SceneTowers(parent:DisplayObject) {
			parent_ = parent;
			RcsMgr.load();

			var btn_skin:Array = [RcsMgr.getTex("btn_n.png"), RcsMgr.getTex("btn_o.png"), RcsMgr.getTex("btn_p.png"), RcsMgr.getTex("btn_i.png")];
			var btn_outer:Rectangle = new Rectangle(0, 0, 14, 12);
			var btn_inner:Rectangle = new Rectangle(3, 2, 8, 8);
			Button.setDefaultTheme(btn_skin, btn_outer, btn_inner);
			Window.setDefaultTheme([RcsMgr.getTex("metal.png"), ], new Rectangle(0, 0, 46, 32), new Rectangle(22, 22, 2, 2));
			ListBox.setTheme(btn_skin, btn_outer, btn_inner, [RcsMgr.getTex("arrow_up"), RcsMgr.getTex("arrow_down"), RcsMgr.getTex("arrow_left"), RcsMgr.getTex("arrow_right")]);

			ground_ = new Ground(RcsMgr.getTex("box1b_d.jpg"), 32, 32, 10, 10);
			wisps_ = new WispGroup(32);
			towers_ = new TowerFarm(wisps_.getList());
				
			skybox_ = new Skybox(//front, left,back,up,right,down;
				RcsMgr.getTex("orbe_rt.jpg"),
				RcsMgr.getTex("orbe_ft.jpg"),
				RcsMgr.getTex("orbe_lf.jpg"),
				null,
				RcsMgr.getTex("orbe_bk.jpg"), 
				RcsMgr.getTex("orbe_dn.jpg"), 
				1000, Skybox.QUALITY_LOW);

			cameraman_ = new CameraManIso(150, 65);
			
			build_ = new BuildOption(parent_.stage, (760 - 160)/2, (600-150)/2-30, 160, 150);
			login_ = new Login(parent_.stage, (760 - 160)/2, (600-200)/2-30, 160, 200, SocialNet.MODE_FACEBOOK);
			friends_ = new Friends(parent_.stage, (760 - 720) / 2, 600 - 150 - 10, 720, 150);
			inventory_ = new Inventory(parent_.stage, (760 - 160) / 2, (600 - 560) / 2, 160, 560);
			quests_ = new Quests(parent_.stage, (760 - 480) / 2, (600 - 480) / 2 - 30, 480, 480);
			msgbox_ = new MessageBox(parent_.stage, (760 - 320) / 2, (600 - 120) / 2, 320, 120);
			help_ = new Help(parent_.stage, (760 - 500) / 2, (600 - 400) / 2, 500, 400);
			hud_ = new Hud();
			
			innerNet_ = new ExternalLoader("http://ldarren.g0dsoft.com/yatd/");// "http://localhost/td/");
			outerNet_ = new SocialNet();
		}
		
		public function load(gfx:Renderer):void {
			cameraman_.changeShot(gfx.camera, new Point(0, -50), new Rectangle( -128, -128, 256, 256));
			
			with (gfx) {
				addObj(skybox_);
				addObj(ground_);
				addObj(towers_);
				addObj(wisps_);
				addOverlay(hud_);
			}
			
			hud_.dispatcher.addEventListener(GameEvent.GAME_START, ground_.onGameStart);
			hud_.dispatcher.addEventListener(GameEvent.GAME_END, ground_.onGameStop);
			hud_.dispatcher.addEventListener(GameEvent.GAME_START, towers_.onGameStart);
			hud_.dispatcher.addEventListener(GameEvent.GAME_END, towers_.onGameStop);
			hud_.dispatcher.addEventListener(GameEvent.GAME_END, wisps_.onGameStop);
			hud_.dispatcher.addEventListener(GameEvent.GAME_START, this.onGameStart);
			hud_.dispatcher.addEventListener(GameEvent.GAME_END, this.onGameStop);
			hud_.dispatcher.addEventListener(GameEvent.GAME_SAVE, this.onMapSave);
			hud_.dispatcher.addEventListener(GameEvent.GAME_QUEST, this.showQuest);
			hud_.dispatcher.addEventListener(GameEvent.GAME_BUDDY, this.showFriends);
			hud_.dispatcher.addEventListener(GameEvent.GAME_HELP, this.showHelp);
			hud_.dispatcher.addEventListener(TowerEvent.TOWER_GEM, this.showInventory);
			
			ground_.dispatcher.addEventListener(GameEvent.GAME_PATH, wisps_.onPathCreated);
			ground_.dispatcher.addEventListener(TowerEvent.TOWER_LOAD, towers_.onLoad);
			ground_.dispatcher.addEventListener(TowerEvent.RAISE_WALL, towers_.onRaiseWall);

			build_.dispatcher.addEventListener(TowerEvent.LOWER_TOWER, towers_.onLowerTower);
			build_.dispatcher.addEventListener(TowerEvent.LOWER_WALL, towers_.onLowerWall);
			build_.dispatcher.addEventListener(TowerEvent.TOWER_GEM, this.showInventory);
			login_.dispatcher.addEventListener(NetEvent.SEND, outerNet_.onSend);
			login_.dispatcher.addEventListener(NetEvent.CONNECT, this.onConnect);
			friends_.dispatcher.addEventListener(GameEvent.GAME_LOAD, this.onShowNeighbour);
			quests_.dispatcher.addEventListener(GameEvent.GAME_DO, this.onDoQuest);
			inventory_.dispatcher.addEventListener(TowerEvent.RAISE_TOWER, towers_.onRaiseTower);
			
			towers_.dispatcher.addEventListener(TowerEvent.TOWER_OPTION, this.onShowTowerOption);
			towers_.dispatcher.addEventListener(TowerEvent.WALL_LOWERED, ground_.onWallLowered);	// need to change path finding
			towers_.dispatcher.addEventListener(TowerEvent.TOWER_COST, this.onConstruction);
			
			wisps_.dispatcher.addEventListener(GameEvent.GAME_SCORE, hud_.onScore);
			
			innerNet_.dispatcher.addEventListener(NetEvent.RECEIVED, this.onNetReceived);
			innerNet_.dispatcher.addEventListener(NetEvent.ERROR, this.onNetError);
			outerNet_.dispatcher.addEventListener(NetEvent.RECEIVED, this.onNetReceived);
			outerNet_.dispatcher.addEventListener(NetEvent.ERROR, this.onNetError);

			hud_.changeMode(false);
			login_.checkMode(); // in case mode is set
		}
		
		public function unload(gfx:Renderer):void {
			
			outerNet_.dispatcher.removeEventListener(NetEvent.RECEIVED, this.onNetReceived);
			outerNet_.dispatcher.removeEventListener(NetEvent.ERROR, this.onNetError);
			innerNet_.dispatcher.removeEventListener(NetEvent.RECEIVED, this.onNetReceived);
			innerNet_.dispatcher.removeEventListener(NetEvent.ERROR, this.onNetError);

			wisps_.dispatcher.removeEventListener(GameEvent.GAME_SCORE, hud_.onScore);

			towers_.dispatcher.removeEventListener(TowerEvent.WALL_LOWERED, ground_.onWallLowered);
			towers_.dispatcher.removeEventListener(TowerEvent.TOWER_OPTION, this.onShowTowerOption);

			login_.dispatcher.removeEventListener(NetEvent.SEND, outerNet_.onSend);
			login_.dispatcher.removeEventListener(NetEvent.CONNECT, this.onConnect);
			build_.dispatcher.removeEventListener(TowerEvent.LOWER_TOWER, towers_.onLowerTower);
			build_.dispatcher.removeEventListener(TowerEvent.LOWER_WALL, towers_.onLowerWall);
			build_.dispatcher.removeEventListener(TowerEvent.TOWER_GEM, this.showInventory);
			friends_.dispatcher.removeEventListener(GameEvent.GAME_LOAD, this.onShowNeighbour);
			quests_.dispatcher.removeEventListener(GameEvent.GAME_DO, this.onDoQuest);
			inventory_.dispatcher.removeEventListener(TowerEvent.RAISE_TOWER, towers_.onRaiseTower);
			
			ground_.dispatcher.removeEventListener(TowerEvent.RAISE_WALL, towers_.onRaiseWall);
			ground_.dispatcher.removeEventListener(TowerEvent.TOWER_LOAD, towers_.onLoad);
			ground_.dispatcher.removeEventListener(GameEvent.GAME_PATH, wisps_.onPathCreated);

			hud_.dispatcher.removeEventListener(GameEvent.GAME_SAVE, this.onMapSave);
			hud_.dispatcher.removeEventListener(GameEvent.GAME_START, towers_.onGameStart);
			hud_.dispatcher.removeEventListener(GameEvent.GAME_START, ground_.onGameStart);
			hud_.dispatcher.removeEventListener(GameEvent.GAME_START, this.onGameStart);
			hud_.dispatcher.removeEventListener(GameEvent.GAME_END, this.onGameStop);
			hud_.dispatcher.removeEventListener(GameEvent.GAME_END, towers_.onGameStop);
			hud_.dispatcher.removeEventListener(GameEvent.GAME_END, ground_.onGameStop);
			hud_.dispatcher.removeEventListener(GameEvent.GAME_END, wisps_.onGameStop);
			hud_.dispatcher.removeEventListener(GameEvent.GAME_QUEST, this.showQuest);
			hud_.dispatcher.removeEventListener(GameEvent.GAME_BUDDY, this.showFriends);
			hud_.dispatcher.removeEventListener(GameEvent.GAME_HELP, this.showHelp);
			hud_.dispatcher.removeEventListener(TowerEvent.TOWER_GEM, this.showInventory);

			with (gfx) {
				removeObj(skybox_);
				removeObj(wisps_);
				removeObj(towers_);
				removeObj(ground_);
				removeOverlay(hud_);
			}

			cameraman_.resetShot();
			
			build_.onShow(false, 0);
			login_.onShow(false);
		}
		
		public function onMouse(evt:MouseEvent):void {
			if (isEditMode_ && build_.hidden) {
				Picker3D.hitTest();

				ground_.onMouse(evt);
				towers_.onMouse(evt);
			}
		}
		
		public function onKeyboard(evt:KeyboardEvent):void {
			switch(evt.type) {
			case KeyboardEvent.KEY_DOWN:
				switch(evt.keyCode) {
				case 87: cameraman_.moveForward(2);	break;
				case 83: cameraman_.moveForward(-2); break;
				case 65: cameraman_.moveSide(-2); break;
				case 68: cameraman_.moveSide(2); break;
				case 81: cameraman_.rotate(1); break;
				case 69: cameraman_.rotate(-1);	break;
				}
				break;
			case KeyboardEvent.KEY_UP:
				switch(evt.keyCode) {
				case 87: cameraman_.moveForward(0);	break;
				case 83: cameraman_.moveForward(0);	break;
				case 65: cameraman_.moveSide(0); break;
				case 68: cameraman_.moveSide(0); break;
				case 81: cameraman_.rotate(0); break;
				case 69: cameraman_.rotate(0); break;
				}
				break;
			}
		}
		
		public function onUpdate():void {
			if (build_.hidden) {
				ground_.update();	// using project instead
				wisps_.update();
				//towers_.update();	// using project instead
				cameraman_.update();
			}
		}
		
		private function onGameStart(evt:GameEvent):void {
			isEditMode_ = false;
			onMapSave();
		}
		
		private function onGameStop(evt:GameEvent):void {
			// if the current player own the map, show rewards and save the result
			if (isHost_) {
				if (hostId_ != "" && currQuest_ != -1) {
					var quest:Object = quests_.getQuest(currQuest_);
					currQuest_ = -1;
					if (hud_.harvested >= quest.kills) {
						hud_.cash += quest.cash;
						if (quest.count > 0) inventory_.addOrb(quest.orb, quest.count);
					}
					innerNet_.submit( { id:hostId_, action:InnerNet.ACTION_SAVE, score:hud_.score, cash:hud_.cash, inv:inventory_.save() } );
				}
				isEditMode_ = true;
			} else {
				isEditMode_ = false;
			}
		}
		
		private function onShowTowerOption(evt:TowerEvent):void {
			build_.onShow(true, evt.data.mode);
		}
		
		private function onConstruction(evt:TowerEvent):void {
			hud_.cash -= evt.data.cost;
		}
		
		private function onConnect(evt:NetEvent):void {
			innerNet_.request( { action:InnerNet.ACTION_API, title:"harvester" } );
		}
		
		private function onMapSave(evt:GameEvent = null):void {
			if (isHost_ && hostId_ != ""){
				innerNet_.submit( { id:hostId_, action:InnerNet.ACTION_SAVE, map:ground_.save() + towers_.save() } );
			}
		}
		
		private function onMapLoaded(map:String):void {
			if (map) {
				towers_.load();
				ground_.load(map);//0:25;1:76;3:45,65,56,36,;4:35,55,66,46,;
			}
		}
		
		private function onShowNeighbour(evt:GameEvent):void {
			var data:Object = evt.data;
			if (data.lvl > 0) {
				isEditMode_ = isHost_ = data.uid == hostId_; // only in editmode could change owner
				innerNet_.request( { id:data.uid, action:InnerNet.ACTION_LOAD } );
				hud_.changeOwner(data.name, data.pic, isHost_);
			} else {
				msgbox_.onShow("invite", "Invite " + data.name + " ?", MessageBox.OPTION_YES_NO);
			}
		}
		
		private function showFriends(evt:GameEvent):void {
			friends_.onShow(true);
		}
		
		private function showInventory(evt:TowerEvent):void {
			inventory_.onShow(true, evt.data.viewonly);
		}
		
		private function showQuest(evt:GameEvent):void {
			innerNet_.request( { lvl:hud_.level, action:InnerNet.ACTION_QUESTS } );
		}
		
		private function showHelp(evt:GameEvent):void {
			help_.onShow(true);
		}
		
		private function onDoQuest(evt:GameEvent):void {
			currQuest_ = int(evt.data.quest);
			hud_.changeMode(true);
		}
		
		private function onNetReceived(evt:NetEvent):void {
			var result:Object = evt.data;
			if (result.ret == "OK") {
				switch (result.action) {
				case InnerNet.ACTION_API:
					//trace("api: " + result.api + " secret: " + result.secret);
					// login to a social net, if this is not within the social net, show login box
					if (!outerNet_.login(result.api, result.secret, parent_.loaderInfo)) 
						login_.onShow(true, Login.STATE_VERIFY);
					break;
				case InnerNet.ACTION_LOAD:
					onMapLoaded(result.map);
					inventory_.load(result.inv);
					hud_.score = result.score;
					hud_.level = result.lvl;
					hud_.cash = result.cash;
					friends_.addDetail(result.uid, result.lvl);
					break;
				case InnerNet.ACTION_SAVE:
					hud_.label_help.text = "Saved";
					break;
				case InnerNet.ACTION_PREVIEW:
					friends_.addDetail(result.uid, result.lvl);
					break;
				case InnerNet.ACTION_QUESTS:
					var p:Array;
					for (var i:int = 0; i < result.num; ++i) {
						p = String(result["q" + i]).split(",");
						quests_.addQuest(i, int(p[0]), int(p[1]), int(p[2]), int(p[3]) );
					}
					quests_.onShow(true);
					break;
				case SocialNet.ACTION_LOGINED:
					login_.onLogin(evt);
					break;
				case SocialNet.ACTION_SELFINFO:
					isHost_ = true;
					hud_.changeOwner(result.name, result.pic, isHost_);
					hud_.changeMode(false);
					hostId_ = result.uid;	// place after changeMode so that it doesn't save on the first time
					friends_.addHost(hostId_, result.name, result.pic);
					innerNet_.request( { id:hostId_, action:InnerNet.ACTION_LOAD } );
					outerNet_.getFriends();
					break;
				case SocialNet.ACTION_BUDDYINFO:
					friends_.addFriend(result.uid, result.name, result.pic);
					innerNet_.request({id:result.uid, action:InnerNet.ACTION_PREVIEW});
					break;
				case SocialNet.ACTION_PERMISSION:
					//outerNet_.postMessage("grand opening!!!");
					break;
				}
			} else {
				if (result.msg) hud_.label_help.text = "error: " + result.msg;
				else hud_.label_help.text = "network error, check your output for more detail" ;
			}
		}
		
		private function onNetError(evt:NetEvent):void {
			hud_.label_help.text = "onNetError: "+evt.data;
		}
		
	}
	
}