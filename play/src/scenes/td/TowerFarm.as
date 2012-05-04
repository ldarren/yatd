package scenes.td {
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.utils.Timer;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.MD2;
	import org.pica.ai.Node;
	import org.pica.graphics.ui.Picker3D;
	import scenes.td.events.GameEvent;
	import scenes.td.events.TowerEvent;
	import scenes.td.events.TowerEventDispatcher;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class TowerFarm extends DisplayObject3D {
		
		// orb code using for saving and loading. Inventory.ORB_XXX are 0 based id
		static public const ORB_BLUE_CODE:int	= 4;	// since Node.TYPE_WALL = 3
		static public const ORB_BLACK_CODE:int	= 5;
		static public const ORB_AMBER_CODE:int	= 6;
		static public const ORB_CLEAR_CODE:int	= 7;
		static public const ORB_GREEN_CODE:int	= 8;
		static public const ORB_RED_CODE:int	= 9;
		static public const ORB_PURPLE_CODE:int	= 10;

		static public const MODE_NONE:int = 0;
		static public const MODE_LOWER:int = 1;
		static public const MODE_RAISE:int = 2;
		
		public var dispatcher:TowerEventDispatcher;
		
		private var light_:PointLight3D;
		
		private var queue_tower_:Array;		// new tower
		private var queue_rumble_:Array;	// destroy tower
		private var queue_load_:Array;		// load tower
		private var towers_:Array;
		private var firingTimer_:Timer;
		private var coolDownTimer_:Timer;
		private var loadingTimer_:Timer;
		
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
		
		private const cost_build_wall_:int = 4;
		private const cost_build_tower_:int = 2;
		private const cost_destroy_wall_:int = 2;
		private const cost_destroy_tower_:int = 1;
		
		public function TowerFarm(wisps:Array) {
			dispatcher = new TowerEventDispatcher("Towers");
			wisps_ = wisps;
			light_ = new PointLight3D();
			light_.y = 200;
			this.addChild(light_);
			
			queue_tower_ = new Array();
			queue_rumble_ = new Array();
			queue_load_ = new Array();
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
			loadingTimer_ = new Timer(150);
			loadingTimer_.addEventListener(TimerEvent.TIMER, onBuild);
			
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
								/*if (!t.wall.playing)*/ hightlight(i, true); // ignore animated tower due to some hittest bugs
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
			var t:Tower = new Tower(evt.data.idx, RcsMgr.getModel("wall.md2"), RcsMgr.getTex("wall.jpg"));
			var wall:MD2 = t.wall;
			wall.x = loc.x;
			wall.z = loc.y;
			wall.play("e_wall", false);
			sfxGrd2Wall_.play();
			this.addChild(wall);
			towers_.push(t);
			Picker3D.setPickable(wall, !isRunning_);
			
			dispatcher.dispatchEvent(new TowerEvent(TowerEvent.TOWER_COST, { cost:cost_build_wall_ } ));
		}
		
		public function onRaiseTower(evt:TowerEvent):void {
			if (downTowerIdx_ < 0) { trace("onRaiseTower idx: "+downTowerIdx_); return };
			var t:Tower = towers_[downTowerIdx_] as Tower;
			var wall:MD2 = t.wall;
			wall.play("e_twr", false);
			sfxWall2Twr_.play();
			
			var orb:Weapon = t.addWeapon(evt.data.orb, wisps_, light_);
			this.addChild(orb);

			queue_tower_.push(t);
			orb.powerOn();
			
			var time:Timer = new Timer(2000);
			time.addEventListener(TimerEvent.TIMER, onOff);
			time.start();
			
			dispatcher.dispatchEvent(new TowerEvent(TowerEvent.TOWER_COST, { cost:cost_build_tower_ } ));
		}
		
		public function onLowerWall(evt:TowerEvent):void {
			if (downTowerIdx_ < 0) { trace("onLowerWall idx: "+downTowerIdx_); return };
			var t:Tower = towers_[downTowerIdx_] as Tower;
			var wall:MD2 = t.wall;
			this.dispatcher.dispatchEvent(new TowerEvent(TowerEvent.WALL_LOWERED, {idx:t.index}));
			wall.play("r_wall", false);
			sfxWall2Grd_.play();
			
			queue_rumble_.push(t);
			towers_.splice(downTowerIdx_, 1);
			downTowerIdx_ = -1;
			overTowerIdx_ = -1;
			
			var time:Timer = new Timer(2000);
			time.addEventListener(TimerEvent.TIMER, onDestroy);
			time.start();
			
			dispatcher.dispatchEvent(new TowerEvent(TowerEvent.TOWER_COST, { cost:cost_destroy_wall_  } ));
		}
		
		public function onLowerTower(evt:TowerEvent):void {
			if (downTowerIdx_ < 0) { trace("onLowerTower idx: "+downTowerIdx_); return };
			var t:Tower = towers_[downTowerIdx_] as Tower;
			var wall:MD2 = t.wall;
			this.dispatcher.dispatchEvent(new TowerEvent(TowerEvent.TOWER_LOWERED, {loc:new Point(wall.x, wall.z)}));
			this.removeChild(t.orb);
			t.orb = null;
			wall.play("r_twr", false);
			sfxTwr2Wall_.play();
					
			dispatcher.dispatchEvent(new TowerEvent(TowerEvent.TOWER_COST, { cost:cost_destroy_tower_  } ));
		}
		
		public function onLoad(evt:TowerEvent):void {
			queue_load_.push( { type:evt.data.type, idx:evt.data.idx, loc:evt.data.loc } );
			if (!loadingTimer_.running)
				loadingTimer_.start();
		}

		private function onBuild(evt:TimerEvent):void {
			var data:Object = queue_load_.pop() as Object;
			var t:Tower = new Tower(data.idx, RcsMgr.getModel("wall.md2"), RcsMgr.getTex("wall.jpg"));
			var wall:MD2 = t.wall;
			var loc:Point=data.loc as Point;
			wall.x = loc.x;
			wall.z = loc.y;
			this.addChild(wall);

			switch(data.type) {
			case Node.TYPE_WALL:
				wall.play("wall", false);
				break;
			default:
				wall.play("twr", false);
				this.addChild(t.addWeapon(data.type, wisps_, light_));
				break;
			}
			towers_.push(t);
			Picker3D.setPickable(wall, !isRunning_);
			
			if (queue_load_.length == 0) {
				loadingTimer_.stop();
			}
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
			var walls:String = "" + Node.TYPE_WALL + ":";
			var blues:String = "" + TowerFarm.ORB_BLUE_CODE + ":";
			var blacks:String = "" + TowerFarm.ORB_BLACK_CODE + ":";
			var ambers:String = "" + TowerFarm.ORB_AMBER_CODE + ":";
			var clears:String = "" + TowerFarm.ORB_CLEAR_CODE + ":";
			var greens:String = "" + TowerFarm.ORB_GREEN_CODE + ":";
			var reds:String = "" + TowerFarm.ORB_RED_CODE + ":";
			var purples:String = "" + TowerFarm.ORB_PURPLE_CODE + ":";
			for each (var t:Tower in towers_) {
				if (t.orb == null) {
					walls += t.index + ",";
				} else {
					switch(t.orb.type) {
					case TowerFarm.ORB_BLUE_CODE: blues += t.index + ","; break;
					case TowerFarm.ORB_BLACK_CODE: blacks += t.index + ","; break;
					case TowerFarm.ORB_AMBER_CODE: ambers += t.index + ",";	break;
					case TowerFarm.ORB_CLEAR_CODE: clears += t.index + ","; break;
					case TowerFarm.ORB_GREEN_CODE: greens += t.index + ","; break;
					case TowerFarm.ORB_RED_CODE: reds += t.index + ",";	break;
					case TowerFarm.ORB_PURPLE_CODE: purples += t.index + ","; break;
					}
				}
			}
			return walls + ";" + blues + ";" + blacks + ";" + ambers + ";" + clears + ";" + greens + ";" + reds + ";" + purples + ";";
		}
		
		public function load():void {
			// clear towers
			for each (var t:Tower in towers_) {
				this.dispatcher.dispatchEvent(new TowerEvent(TowerEvent.WALL_LOWERED, {idx:t.index}));
				this.removeChild(t.wall);
				this.removeChild(t.orb);
			}
			towers_ = new Array();
		}
		
		private function onStrike(evt:TimerEvent):void {
			var count:int = 0;
			for each (var t:Tower in towers_) {
				if (t.orb) {
					t.orb.powerOn();	// TODO: have a active tower list, for those near to path and with orb
					count++;
				}
			}
			if (count) {
				sfxShock_.play();
				coolDownTimer_.start();
			}
		}
		
		private function onCalm(evt:TimerEvent):void {
			for each (var t:Tower in towers_) {
				if (t.orb) t.orb.powerOff();	// TODO: have a active tower list, for those near to path and with orb
			}

			var timer:Timer = evt.target as Timer;
			timer.stop();
		}
		
		private function onDestroy(evt:TimerEvent):void {
			var tower:Tower = queue_rumble_.shift() as Tower;
			var wall:MD2 = tower.wall;
			this.removeChild(wall);
			
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
			
			if (sel) t.setColor(1, 1, 3);
			else t.resetColor();
		}
		
	}
	
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.utils.ByteArray;
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import org.papervision3d.lights.PointLight3D;
import org.papervision3d.objects.parsers.MD2;
import org.papervision3d.core.animation.clip.AnimationClip3D;
import org.papervision3d.core.controller.AnimationController;
import org.papervision3d.materials.BitmapMaterial;
import org.papervision3d.materials.shaders.CellShader;
import org.papervision3d.materials.shaders.ShadedMaterial;
import scenes.td.Weapon;

class Tower {

	public var wall:MD2;
	public var orb:Weapon;
	public var index:int;
	private var baseBD_:BitmapData;
	
	public function Tower(idx:int, mesh:ByteArray, tex:Bitmap, orb:Weapon = null) {
		index = idx;
		this.orb = orb;
		this.wall = new MD2(false);
		this.baseBD_ = tex.bitmapData as BitmapData;

		wall.load(mesh, /*new ShadedMaterial(*/new BitmapMaterial(baseBD_.clone())/*, new CellShader(light_, 0xffffff, 0x555555, 5))*/, 6);
		var ctrl:AnimationController = wall.animation;
		ctrl.addClip(new AnimationClip3D("grd_2_twr", 0, 4));
		ctrl.addClip(new AnimationClip3D("twr_2_grd", 4, 8));
		ctrl.addClip(new AnimationClip3D("e_wall", 0, 2));
		ctrl.addClip(new AnimationClip3D("e_twr", 2, 4));
		ctrl.addClip(new AnimationClip3D("r_twr", 4, 6));
		ctrl.addClip(new AnimationClip3D("r_wall", 6, 8));
		ctrl.addClip(new AnimationClip3D("wall", 1, 2));	// goto frame directly
		ctrl.addClip(new AnimationClip3D("twr", 3, 4));
	}
	
	public function addWeapon(type:int, targets:Array, light:PointLight3D):Weapon {
		this.orb = new Weapon(type, 8, targets, light);
		
		if (!orb) return null;
			
		orb.x = wall.x;
		orb.z = wall.z;
		orb.y = 56;
		return orb;
	}
		
	public function setColor(red:int, green:int, blue:int):void {
		var arr:Array = [ red,0,0,0,0, 0,green,0,0,0, 0,0,blue,0,0, 0,0,0,1,0 ];
		var colorMat:ColorMatrixFilter = new ColorMatrixFilter(arr);

		var newDB_:BitmapData = new BitmapData(baseBD_.width, baseBD_.height, true);
		newDB_.applyFilter(baseBD_, new Rectangle(0, 0, baseBD_.width, baseBD_.height), new Point(), colorMat);
		var bmpmat:BitmapMaterial = wall.material as BitmapMaterial;
		bmpmat.bitmap = newDB_;
	}
	
	public function resetColor():void {
		var bmpmat:BitmapMaterial = wall.material as BitmapMaterial;
		bmpmat.bitmap = baseBD_.clone();
	}
}