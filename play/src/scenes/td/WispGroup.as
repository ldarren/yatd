package scenes.td {
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Timer;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.pica.ai.Node;
	import org.pica.graphics.effects.BillBoard;
	import org.pica.graphics.effects.MotionTrail;
	import scenes.td.events.GameEvent;
	import scenes.td.events.TowerEventDispatcher;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class WispGroup extends DisplayObject3D {

		static public const RADIUS:int = 25;
		
		public var dispatcher:TowerEventDispatcher;
		
		private var wisps_:Array;
		private var spare_:Array;
		private var path_:Array;
		private var size_:Number;
		
		private var color_:uint;
		
		private var gameStarted_:Boolean = false;
		private var spawnTimer_:Timer;
		
		public function WispGroup(size:Number) {
			dispatcher = new TowerEventDispatcher("Wisps");
			size_ = size;
			wisps_ = new Array();
			spare_ = new Array();

			color_ = 0xff0000 | 0x999999;// * 0x444444 | 0x999999;
			Wisp.generateColorSet([0xffffff | 0x999999, 0x0000ff | 0x4b4b4b], size, 10);
			
			spawnTimer_ = new Timer(4000);
			spawnTimer_.addEventListener(TimerEvent.TIMER, onSpawn);
		}
		
		public function update():void {
			if (gameStarted_  && path_.length > 1) {
				floating();
			}
		}
		
		public function getList():Array {
			return wisps_;
		}
		
		// equivalent to onGameStart
		// TODO: handled path failed to create problem
		public function onPathCreated(evt:GameEvent):void {
			gameStarted_ = true;
			path_ = evt.data.path;
			spawnTimer_.start();
			onSpawn(null);
		}
		
		public function onGameStop(evt:GameEvent):void {
			spawnTimer_.stop();
			gameStarted_ = false;
			for each (var w:Wisp in wisps_) {
				this.removeChild(w);
				this.removeChild(w.trail);
				spare_.push(w);
			}
			wisps_.splice(0);
		}
		
		private function onSpawn(evt:TimerEvent):void {
			var w:Wisp;
			var p:Point = path_[0] as Point;
			if (spare_.length == 0) {
				w = new Wisp(100, size_, p.x, 25, p.y);
			} else {
				w = spare_.pop() as Wisp;
				w.resetTo(p.x, 25, p.y);
			}
			wisps_.push(w);
			this.addChild(w);
			this.addChild(w.trail);
		}
		
		private function floating():void {
			var end:Point, start:Point;
			var curr:Number3D;
			var dx:Number, dz:Number;
			var w:Wisp;
			for (var i:int = 0, l:int = wisps_.length; i < l; ) {
				w = wisps_[i] as Wisp;
				end = path_[w.endPt] as Point;
				start = path_[w.startPt] as Point;
				curr = w.position;
				dx = end.x - curr.x; dz = end.y - curr.z;
				if (dx * dx + dz * dz < WispGroup.RADIUS) {
					w.startPt = w.endPt;
					++w.endPt;
					if (w.endPt >= path_.length) {
						if (w.life<=0) dispatcher.dispatchEvent(new GameEvent(GameEvent.GAME_SCORE));
						this.removeChild(w);
						this.removeChild(w.trail);
						spare_.push(w);
						wisps_.splice(i, 1);
						--l;
						continue;
					}
				}
				++i;
				w.position = new Number3D(curr.x + 0.1 * (end.x - start.x), 25, curr.z + 0.1 * (end.y - start.y));
			}
		}
		
	}
	
}
