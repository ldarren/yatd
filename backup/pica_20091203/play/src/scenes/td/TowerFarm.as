package scenes.td {
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import org.papervision3d.core.animation.clip.AnimationClip3D;
	import org.papervision3d.core.controller.AnimationController;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.shaders.CellShader;
	import org.papervision3d.materials.shaders.ShadedMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.MD2;
	import org.pica.graphics.ui.Picker3D;
	import scenes.td.events.GameEvent;
	import scenes.td.events.TowerEvent;
	import scenes.td.events.TowerEventDispatcher;
	import org.pica.graphics.effects.Lightning;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class TowerFarm extends DisplayObject3D {
		
		static public const MODE_NONE:int = 0;
		static public const MODE_LOWER:int = 1;
		static public const MODE_RAISE:int = 2;
		
		public var dispatcher:TowerEventDispatcher;
		
		private var light_:PointLight3D;
		
		private var queue_tower_:Array;		// new tower
		private var queue_rumble_:Array;	// destroy tower
		private var towers_:Array;
		private var firingTimer_:Timer;
		private var coolDownTimer_:Timer;
		
		private var wisps_:Array;
		
		private var isRunning_:Boolean = false;
		private var overTowerIdx_:int = -1;
		private var downTowerIdx_:int = -1;
		private var pickMode_:int = TowerFarm.MODE_NONE;
		private	var glow_:GlowFilter;
		
		private var sfxShock_:Sound;
		private var sfxGrd2Wall_:Sound;
		private var sfxWall2Twr_:Sound;
		private var sfxTwr2Wall_:Sound;
		private var sfxWall2Grd_:Sound;
		
		public function TowerFarm(wisps:Array) {
			dispatcher = new TowerEventDispatcher("Towers");
			wisps_ = wisps;
			light_ = new PointLight3D();
			light_.y = 200;
			this.addChild(light_);
			
			queue_tower_ = new Array();
			queue_rumble_ = new Array();
			towers_ = new Array();
			
			sfxShock_ = RcsMgr.getSound("shock.mp3");
			sfxGrd2Wall_ = RcsMgr.getSound("grd2wall.mp3");
			sfxWall2Twr_ = RcsMgr.getSound("wall2twr.mp3");
			sfxTwr2Wall_ = RcsMgr.getSound("twr2wall.mp3");
			sfxWall2Grd_ = RcsMgr.getSound("wall2grd.mp3");
			
			firingTimer_ = new Timer(4000);
			firingTimer_.addEventListener(TimerEvent.TIMER, onStrike);
			coolDownTimer_ = new Timer(2000);
			coolDownTimer_.addEventListener(TimerEvent.TIMER, onCalm);
			
			glow_ = new GlowFilter(0x0033ff, 0.8);
		}
		
		public function update():void {
		}
		
		public function onMouse(evt:MouseEvent):Boolean {
			if (isRunning_) return false;
			switch(evt.type) {
			case MouseEvent.MOUSE_MOVE:
				var id:int = Picker3D.getPickedObjId();
				if (id != -1) {
					var i:int = 0;
					for each (var t:Tower in towers_) {
						if (t.wall.id == id) {
							if (i != overTowerIdx_) {
								if (overTowerIdx_ != -1) hightlight(overTowerIdx_, false);
								if (!t.wall.playing) hightlight(i, true);
							}
							return true;
						}
						i++;
					}
				}
				if (overTowerIdx_ != -1) {
					hightlight(overTowerIdx_, false);
				}
				break;
			case MouseEvent.MOUSE_UP:
				downTowerIdx_ = overTowerIdx_;
				if (downTowerIdx_ != -1) {
					var twr:Tower = towers_[downTowerIdx_] as Tower;
					dispatcher.dispatchEvent(new TowerEvent(TowerEvent.TOWER_OPTION, {mode:(twr.orb?1:2)}));
				}
				break;
			}
			return false;
		}
		
		public function onRaiseWall(evt:TowerEvent):void {
			var loc:Point = evt.data.loc;
			var wall:MD2 = prepareModel(RcsMgr.getModel("wall.md2"), RcsMgr.getTex("wall.jpg"));
			wall.x = loc.x;
			wall.z = loc.y;
			wall.play("e_wall", false);
			sfxGrd2Wall_.play();
			this.addChild(wall);
			towers_.push(new Tower(wall));
		}
		
		public function onRaiseTower(evt:TowerEvent):void {
			var t:Tower = towers_[downTowerIdx_] as Tower;
			var wall:MD2 = t.wall;
			wall.play("e_twr", false);
			sfxWall2Twr_.play();
			
			var orb:Weapon = new Weapon(8, wisps_, light_, 0x5466ff, 0x040666);
			orb.x = wall.x;
			orb.z = wall.z;
			orb.y = 56;
			//orb.setTargetPos(new Number3D(x, 0, y));
			this.addChild(orb);
			t.orb = orb;

			queue_tower_.push(t);
			orb.powerOn();
			
			var time:Timer = new Timer(2000);
			time.addEventListener(TimerEvent.TIMER, onOff);
			time.start();
		}
		
		public function onLowerWall(evt:TowerEvent):void {
			var t:Tower = towers_[downTowerIdx_] as Tower;
			var wall:MD2 = t.wall;
			this.dispatcher.dispatchEvent(new TowerEvent(TowerEvent.WALL_LOWERED, {loc:new Point(wall.x, wall.z)}));
			wall.play("r_wall", false);
			sfxWall2Grd_.play();
			
			queue_rumble_.push(t);
			
			var time:Timer = new Timer(2000);
			time.addEventListener(TimerEvent.TIMER, onDestroy);
			time.start();
		}
		
		public function onLowerTower(evt:TowerEvent):void {
			var t:Tower = towers_[downTowerIdx_] as Tower;
			var wall:MD2 = t.wall;
			this.dispatcher.dispatchEvent(new TowerEvent(TowerEvent.TOWER_LOWERED, {loc:new Point(wall.x, wall.z)}));
			this.removeChild(t.orb);
			t.orb = null;
			wall.play("r_twr", false);
			sfxTwr2Wall_.play();
		}
		
		public function onGameStart(evt:GameEvent):void {
			if (firingTimer_.running) return;
			setEditable(false);
			for each (var t:Tower in towers_) {
				if (t.orb) {
					firingTimer_.start();
					return;
				}
			}
		}
		
		public function onGameStop(evt:GameEvent):void {
			setEditable(true);
			firingTimer_.stop();
		}
		
		public function save():String {
			return "TowerFarm";
		}
		
		private function onStrike(evt:TimerEvent):void {
			for each (var t:Tower in towers_) {
				if (t.orb) t.orb.powerOn();	// TODO: have a active tower list, for those near to path and with orb
			}
			sfxShock_.play();
			coolDownTimer_.start();
		}
		
		private function onCalm(evt:TimerEvent):void {
			for each (var t:Tower in towers_) {
				if (t.orb) t.orb.powerOff();	// TODO: have a active tower list, for those near to path and with orb
			}

			var timer:Timer = evt.target as Timer;
			timer.stop();
		}
		
		private function prepareModel(mesh:ByteArray, tex:Bitmap):MD2 {
			var wall:MD2 = new MD2(false);
			wall.load(mesh, /*new ShadedMaterial(*/new BitmapMaterial(tex.bitmapData)/*, new CellShader(light_, 0xffffff, 0x555555, 5))*/, 6);
			var ctrl:AnimationController = wall.animation;
			ctrl.addClip(new AnimationClip3D("grd_2_twr", 0, 4));
			ctrl.addClip(new AnimationClip3D("twr_2_grd", 4, 8));
			ctrl.addClip(new AnimationClip3D("e_wall", 0, 2));
			ctrl.addClip(new AnimationClip3D("e_twr", 2, 4));
			ctrl.addClip(new AnimationClip3D("r_twr", 4, 6));
			ctrl.addClip(new AnimationClip3D("r_wall", 6, 8));
			Picker3D.setPickable(wall, !isRunning_);
			wall.useOwnContainer = !isRunning_;
			return wall;
		}
		
		private function onDestroy(evt:TimerEvent):void {
			var tower:Tower = queue_rumble_.shift() as Tower;
			var wall:MD2 = tower.wall;
			this.removeChild(wall);
			towers_.splice(downTowerIdx_, 1);
			downTowerIdx_ = -1;
			overTowerIdx_ = -1;
			
			var t:Timer = evt.target as Timer;
			t.removeEventListener(TimerEvent.TIMER, onDestroy);
			t.stop();
		}
		
		private function onOff(evt:TimerEvent):void {
			var tower:Tower = queue_tower_.shift() as Tower;
			var orb:Weapon = tower.orb;
			orb.setTargetPos(null);
			orb.powerOff();
			/*if (towers_.length != 0) {
				towers_[0].orb.setPartner(orb);
				orb.setPartner(towers_[towers_.length - 1].orb);
			}*/
			
			var t:Timer = evt.target as Timer;
			t.removeEventListener(TimerEvent.TIMER, onOff);
			t.stop();
		}
		
		private function setEditable(state:Boolean):void {
			isRunning_ = !state;

			for each (var t:Tower in towers_) {
				Picker3D.setPickable(t.wall, state);
			}
		}
		
		private function hightlight(idx:int, sel:Boolean):void {
			var t:Tower = towers_[idx] as Tower;
			if (sel) overTowerIdx_ = idx;
			else overTowerIdx_ = -1;
			t.wall.useOwnContainer = sel;
			t.wall.filters = sel?[glow_]:null;
		}
		
	}
	
}

import org.papervision3d.objects.parsers.MD2;
import scenes.td.Weapon;

class Tower {
	public var wall:MD2;
	public var orb:Weapon;
	
	public function Tower(wall:MD2, orb:Weapon = null) {
		this.wall = wall;
		this.orb = orb;
	}
}