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
	import org.pica.graphics.ui.Picker3D;
	import org.pica.graphics.ui.Window;
	import scenes.td.events.GameEvent;
	import scenes.td.events.NetEvent;
	import scenes.td.events.TowerEvent;
	import scenes.td.Ground;
	import scenes.td.InnerNet;
	import scenes.td.SocialNet;
	import scenes.td.TowerFarm;
	import scenes.td.RcsMgr;
	import scenes.td.ui.Login;
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
		private var hud_:Hud;

		private var build_:BuildOption;
		private var login_:Login;
		
		private var isEditMode_:Boolean = true;
		private var parent_:DisplayObject;
		
		private var innerNet_:InnerNet;
		private var outerNet_:SocialNet;
		
		public function SceneTowers(parent:DisplayObject) {
			parent_ = parent;
			RcsMgr.load();

			Button.setDefaultTheme([RcsMgr.getTex("btn_n.png"), RcsMgr.getTex("btn_o.png"), RcsMgr.getTex("btn_p.png"), RcsMgr.getTex("btn_i.png")], new Rectangle(0, 0, 14, 12), new Rectangle(3, 2, 8, 8));
			Window.setDefaultTheme([RcsMgr.getTex("metal.png"), ], new Rectangle(0, 0, 46, 32), new Rectangle(22, 22, 2, 2));

			ground_ = new Ground(RcsMgr.getTex("box1b_d.jpg"), 32, 32, 10, 10);
			wisps_ = new WispGroup(64);
			towers_ = new TowerFarm(wisps_.getList());
				
			skybox_ = new Skybox(
				RcsMgr.getTex("orbe_ft.jpg"),
				RcsMgr.getTex("orbe_lf.jpg"),
				RcsMgr.getTex("orbe_bk.jpg"),
				null,
				RcsMgr.getTex("orbe_rt.jpg"), 
				RcsMgr.getTex("orbe_dn.jpg"), 
				1000, Skybox.QUALITY_LOW);

			cameraman_ = new CameraManIso(150, 65);
			
			build_ = new BuildOption(parent_.stage, (760 - 160)/2, (640-150)/2-30, 160, 150);
			login_ = new Login(parent_.stage, (760 - 160)/2, (640-200)/2-30, 160, 200, NetEvent.MODE_FACEBOOK);
			hud_ = new Hud();
			
			innerNet_ = new InnerNet("http://ldarren.g0dsoft.com/yatd/");// "http://localhost/td/");
			outerNet_ = new SocialNet();
		}
		
		public function load(gfx:Renderer):void {
			cameraman_.changeShot(gfx.camera, new Point(0, -50), new Rectangle( -128, -128, 256, 256));
			
			with (gfx) {
				addObj(skybox_);
				addObj(ground_.getPlane());
				addObj(towers_);
				addObj(wisps_);
				addOverlay(hud_);
			}
			
			hud_.dispatcher.addEventListener(GameEvent.GAME_START, ground_.onGameStart);
			hud_.dispatcher.addEventListener(GameEvent.GAME_END, ground_.onGameStop);
			hud_.dispatcher.addEventListener(GameEvent.GAME_START, towers_.onGameStart);
			hud_.dispatcher.addEventListener(GameEvent.GAME_END, towers_.onGameStop);
			hud_.dispatcher.addEventListener(GameEvent.GAME_END, wisps_.onGameStop);
			
			ground_.dispatcher.addEventListener(GameEvent.GAME_PATH, wisps_.onPathCreated);
			ground_.dispatcher.addEventListener(TowerEvent.RAISE_WALL, towers_.onRaiseWall);

			build_.dispatcher.addEventListener(TowerEvent.RAISE_TOWER, towers_.onRaiseTower);
			build_.dispatcher.addEventListener(TowerEvent.LOWER_TOWER, towers_.onLowerTower);
			build_.dispatcher.addEventListener(TowerEvent.LOWER_WALL, towers_.onLowerWall);
			login_.dispatcher.addEventListener(NetEvent.SEND, outerNet_.onSend);
			login_.dispatcher.addEventListener(NetEvent.CONNECT, this.onConnect);
			
			towers_.dispatcher.addEventListener(TowerEvent.TOWER_OPTION, this.onShowTowerOption);
			towers_.dispatcher.addEventListener(TowerEvent.WALL_LOWERED, ground_.onWallLowered);
			
			wisps_.dispatcher.addEventListener(GameEvent.GAME_SCORE, hud_.onScore);
			
			innerNet_.dispatcher.addEventListener(NetEvent.RECEIVED, this.onNetReceived);
			innerNet_.dispatcher.addEventListener(NetEvent.ERROR, this.onNetError);
			outerNet_.dispatcher.addEventListener(NetEvent.RECEIVED, this.onNetReceived);
			outerNet_.dispatcher.addEventListener(NetEvent.ERROR, this.onNetError);

			hud_.changeMode(false);
			login_.checkMode(); // in case mode is set
			
			//innerNet_.request( { id:6257, type:"All" } );
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
			build_.dispatcher.removeEventListener(TowerEvent.RAISE_TOWER, towers_.onRaiseTower);
			build_.dispatcher.removeEventListener(TowerEvent.LOWER_TOWER, towers_.onLowerTower);
			build_.dispatcher.removeEventListener(TowerEvent.LOWER_WALL, towers_.onLowerWall);
			
			ground_.dispatcher.removeEventListener(TowerEvent.RAISE_WALL, towers_.onRaiseWall);
			ground_.dispatcher.removeEventListener(GameEvent.GAME_PATH, wisps_.onPathCreated);

			hud_.dispatcher.removeEventListener(GameEvent.GAME_START, towers_.onGameStart);
			hud_.dispatcher.removeEventListener(GameEvent.GAME_END, towers_.onGameStop);
			hud_.dispatcher.removeEventListener(GameEvent.GAME_START, ground_.onGameStart);
			hud_.dispatcher.removeEventListener(GameEvent.GAME_END, ground_.onGameStop);
			hud_.dispatcher.removeEventListener(GameEvent.GAME_END, wisps_.onGameStop);

			with (gfx) {
				removeObj(skybox_);
				removeObj(wisps_);
				removeObj(towers_);
				removeObj(ground_.getPlane());
				removeOverlay(hud_);
			}

			cameraman_.resetShot();
			
			build_.onShow(false, 0);
			login_.onShow(false);

			//innerNet_.submit({id:6257, type:"game", score:hud_.score});
		}
		
		public function onMouse(evt:MouseEvent):void {
			if (build_.hidden) {
				if (isEditMode_) Picker3D.hitTest();

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
				ground_.update();
				wisps_.update();
				//towers_.update();	// using project instead
				cameraman_.update();
			}
		}
		
		private function onGameStarted(evt:GameEvent):void {
			isEditMode_ = false;
			innerNet_.submit( { id:6257, type:"edit", map:ground_.save(), castle:towers_.save() } );
		}
		
		private function onGameEnded(evt:GameEvent):void {
			isEditMode_ = true;
		}
		
		private function onShowTowerOption(evt:TowerEvent):void {
			build_.onShow(true, evt.data.mode);
		}
		
		private function onConnect(evt:NetEvent):void {
			trace("connecting...");
			innerNet_.request( { action:"get_api", title:"harvester" } );
		}
		
		private function onMapLoaded(evt:Event):void {
			trace("Data: "+evt.target.data);
		}
		
		private function onNetReceived(evt:NetEvent):void {
			var result:Object = evt.data;
			if (result.ret == "OK") {
				switch (result.action) {
				case "get_api":
					//trace("api: " + result.api + " secret: " + result.secret);
					// login to a social net, if this is not within the social net, show login box
					if (!outerNet_.login(result.api, result.secret, parent_.loaderInfo)) 
						login_.onShow(true, Login.STATE_VERIFY);
					break;
				case "fb_logined":
					hud_.label_help.text = "action: " + result.action;
					login_.onLogin(evt);
					break;
				case "get_name":
					hud_.label_help.text = "name: " + result.name;
					break;
				case "permission":
					hud_.label_help.text = "got permission to spam";
					outerNet_.postMessage("grand opening!!!");
					break;
				}
			} else {
				hud_.label_help.text = "error: " + result.error;
			}
		}
		
		private function onNetError(evt:NetEvent):void {
			hud_.label_help.text = "onNetError: "+evt.data.error;
		}
		
	}
	
}