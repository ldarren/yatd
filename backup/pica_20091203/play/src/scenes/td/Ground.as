package scenes.td {
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.pica.graphics.loader.Object2D;
	import scenes.td.events.GameEvent;
	import scenes.td.events.TowerEvent;
	import scenes.td.events.TowerEventDispatcher;
	
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.primitives.Plane;
	
	import org.pica.ai.FloodFill;
	import org.pica.ai.FloodPoint;
	import org.pica.ai.Grid2D;
	import org.pica.ai.Node;
	import org.pica.ai.PathFinder;
	import org.pica.graphics.effects.Decal;
	import org.pica.graphics.ui.Picker3D;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Ground {
		
		static private const MODE_NONE:int 		= 0;
		static private const MODE_WALL:int 		= 1;
		static private const MODE_STARTING:int 	= 2;	// spawn portal highlighting
		static private const MODE_ENDING:int 	= 3;	// exit portal highlighting
		static private const MODE_START:int 	= 4;
		static private const MODE_END:int 		= 5;
		
		private var mode_:uint = Ground.MODE_NONE;
		private var isRunning_:Boolean = false;
		
		public var dispatcher:TowerEventDispatcher;
		
		private var plane_:Plane;
		private var spawn_:Plane;
		private var exit_:Plane;
		private var spawnTex_:Object2D;
		private var exitTex_:Object2D;
		private var spawnNode_:Node;
		private var exitNode_:Node;
		private var decal_:Decal;
		private var selPt_:Point;
		private	var glow_:GlowFilter;
		
		private var dw_:uint, dh_:uint, dhw_:uint, dhh_:uint, cols_:uint, rows_:uint;
		private var hw_:Number, hh_:Number;
		
		private var grid_:Grid2D;
		private var pathfinder_:PathFinder;
		private var filler_:FloodFill;
		
		public function Ground(bmp:Bitmap, dw:uint, dh:uint, cols:uint, rows:uint) {
			dw_ = dw; dhw_ = dw * 0.5; dh_ = dh; dhh_ = dh * 0.5; cols_ = cols; rows_ = rows;

			grid_ = new Grid2D(cols_, rows_, dw * cols, dh * rows);
			pathfinder_ = new PathFinder();
			filler_ = new FloodFill();
			
			var w:uint = grid_.sizeX, h:uint = grid_.sizeZ;

			var sprite:Sprite = new Sprite();
			with (sprite.graphics) {
				beginBitmapFill(bmp.bitmapData, null, true);
				drawRect(0, 0, w, h);
				endFill();
			}
			
			// material's animate param must set to true for decal to work
			var movieMat:MovieMaterial = new MovieMaterial(sprite, false, true, false);
			
			plane_ = new Plane(movieMat, w, h, cols, rows);
			plane_.pitch(90);
			
			decal_ = new Decal("grd_decal", plane_, 0.3);
			
			selPt_ = new Point(dw_, dh_);
			
			exit_ = new Plane(null, dw_ * 2, dh_ * 2, 2, 2);
			setPortalAtSelPt(exit_, Node.TYPE_END);
			plane_.addChild(exit_);
			
			selPt_.x = w - dw; selPt_.y = h - dh;
			spawn_ = new Plane(null, dw_ * 2, dh_ * 2, 2, 2);
			setPortalAtSelPt(spawn_, Node.TYPE_START);
			plane_.addChild(spawn_);

			var mat:Array = new Array();
			mat = mat.concat([0.95, 0, 0, 0, 0]); mat = mat.concat([0, 0.07, 0, 0, 0]); mat = mat.concat([0, 0, 0.07, 0, 0]); mat = mat.concat([0, 0, 1, 0, 0]);
			spawnTex_ = new Object2D("spawn");
			spawnTex_.load(RcsMgr.getTex("water.jpg"), 64, 64, 0x00aaaaaa, onPortalTexLoaded, new ColorMatrixFilter(mat), Bitmap(RcsMgr.getTex("mask.png")).bitmapData);

			mat = new Array();
			mat = mat.concat([0.07, 0, 0, 0, 0]); mat = mat.concat([0, 0.95, 0, 0, 0]); mat = mat.concat([0, 0, 0.07, 0, 0]); mat = mat.concat([0, 0, 1, 0, 0]);
			exitTex_ = new Object2D("exit");
			exitTex_.load(RcsMgr.getTex("water.jpg"), 64, 64, 0x00aaaaaa, onPortalTexLoaded, new ColorMatrixFilter(mat), Bitmap(RcsMgr.getTex("mask.png")).bitmapData);
			
			glow_ = new GlowFilter(0x0033ff, 0.8);
			
			dispatcher = new TowerEventDispatcher("Ground");
		}
		
		public function getPlane():Plane {
			return plane_;
		}
		
		public function setEditable(state:Boolean):void {
			decal_.clear();
			Picker3D.setPickable(plane_, state);
			Picker3D.setPickable(spawn_, state);
			Picker3D.setPickable(exit_, state);
			// enable glow effect
			spawn_.useOwnContainer = state;
			exit_.useOwnContainer = state;
			isRunning_ = !state;
			mode_ = Ground.MODE_NONE;
		}
		
		public function onMouse(evt:MouseEvent):Boolean {
			if (isRunning_) return false;
			
			switch (evt.type) {
			case MouseEvent.MOUSE_MOVE:
				decal_.clear();
				switch (Picker3D.getPickedObjId()) {
				case plane_.id:
					if (mode_==Ground.MODE_STARTING) hightlight(spawn_, false);
					if (mode_ == Ground.MODE_ENDING) hightlight(exit_, false);
					if (mode_ != Ground.MODE_START && mode_ != Ground.MODE_END) mode_ = Ground.MODE_WALL;
					if (Picker3D.getPickedPoint(plane_, selPt_)) snapCursor(selPt_);
					return true;
				case spawn_.id:
					if (mode_ != Ground.MODE_START && mode_ != Ground.MODE_END) {
						mode_ = Ground.MODE_STARTING;
						hightlight(spawn_);
					}
					return true;
				case exit_.id:
					if (mode_ != Ground.MODE_START && mode_ != Ground.MODE_END) {
						mode_ = Ground.MODE_ENDING;
						hightlight(exit_);
					}
					return true;
				default:
					if (mode_ == Ground.MODE_STARTING || mode_ == Ground.MODE_START) hightlight(spawn_, false);
					if (mode_ == Ground.MODE_ENDING || mode_ == Ground.MODE_END) hightlight(exit_, false);
					mode_ = Ground.MODE_NONE;
					return false;
				}
				break;
			case MouseEvent.MOUSE_UP:
				if (mode_ == Ground.MODE_NONE) break;
				switch(mode_) {
				case Ground.MODE_WALL:
					setWallAtSelPt();
					return true;
				case Ground.MODE_STARTING:
					mode_ = Ground.MODE_START;
					return true;
				case Ground.MODE_ENDING:
					mode_ = Ground.MODE_END;
					return true;
				case Ground.MODE_START:
					setPortalAtSelPt(spawn_, Node.TYPE_START);
					hightlight(spawn_, false);
					mode_ = Ground.MODE_NONE;
					return true;
				case Ground.MODE_END:
					setPortalAtSelPt(exit_, Node.TYPE_END);
					hightlight(exit_, false);
					mode_ = Ground.MODE_NONE;
					return true;
				}
				break;
			}
			return false;
		}
		
		public function update():void {
			if (spawnTex_.animate(67))
				spawn_.material.bitmap = spawnTex_.currentFrame;
			if (exitTex_.animate(67))
				exit_.material.bitmap = exitTex_.currentFrame;
		}
		
		public function onWallLowered(evt:TowerEvent):void {
			trace("x: "+evt.data.loc.x+" y: "+evt.data.loc.y);
			var loc:Point = global2Local(evt.data.loc);
			var idx:int = grid_.getSnappedIndex(loc.x, loc.y);
			grid_.setNodeType(idx, Node.TYPE_WALKABLE);
		}
		
		public function onGameStart(evt:GameEvent):void {
			if (pathfinder_.setup(grid_)) {
				setEditable(false);

				var path:Array = pathfinder_.search();
				// convert to a global coor
				var p:Array = new Array();
				var pos:Number3D;
				for each (var n:Node in path) {
					pos = n.getPos();
					p.push(new Point( pos.x, -pos.z));
				}
				p.reverse();
				dispatcher.dispatchEvent(new GameEvent(GameEvent.GAME_PATH, {path:p}));
			}
		}
		
		public function onGameStop(evt:GameEvent):void {
			setEditable(true);
		}
		
		public function save():String {
			return "Ground";
		}
		
		private function hightlight(portal:Plane, sel:Boolean=true):void {
			portal.filters = sel?[glow_]:null;
		}
		
		private function snapCursor(pt:Point):void {
			//decal_.clear();
			var p:Number3D = grid_.getSnappedPos(pt.x, 0, pt.y);
			if (mode_ == Ground.MODE_WALL) {
				pt.x = p.x; pt.y = p.z;
				hw_ = dhw_; hh_ = dhh_;
				decal_.drawSquare(pt.x, pt.y, hw_, hh_, 0xff0000);
			} else if (mode_ == Ground.MODE_START || mode_ == Ground.MODE_END) {
				pt.x = p.x - dhw_; pt.y = p.z - dhh_;
				hw_ = dw_; hh_ = dh_;
				decal_.drawSquare(pt.x, pt.y, hw_, hh_, 0xff0000);
			}
		}
		
		// transform ground local xy coor to global coor
		private function local2Global(local:Point):Point {
			return new Point(local.x - (grid_.sizeX * 0.5), -local.y + (grid_.sizeZ * 0.5));
		}
		
		private function global2Local(global:Point):Point {
			return new Point(global.x + (grid_.sizeX * 0.5), -global.y + (grid_.sizeZ * 0.5));
		}
			
		private function onPortalTexLoaded(bmp:Object2D):void {
			bmp.addAnimation("all", { start:0, end:15, fps:5 } );
			bmp.play("all");
			if (bmp.name == "exit")
				exit_.material = new BitmapMaterial(bmp.currentFrame);
			else
				spawn_.material = new BitmapMaterial(bmp.currentFrame);
		}
		
		private function setWallAtSelPt():Boolean {
			var n:Node = grid_.getNode(selPt_.x, selPt_.y);
			if (n.type != Node.TYPE_WALKABLE) return false;
			grid_.setNodeType(n.index, Node.TYPE_WALL);

			dispatcher.dispatchEvent(new TowerEvent(TowerEvent.RAISE_WALL, {loc:local2Global(selPt_)}));
			return true;
		}
		
		private function setPortalAtSelPt(portal:Plane, type:uint):Boolean {
			var n:Node = grid_.getNode(selPt_.x, selPt_.y);
			if (n.type != Node.TYPE_WALKABLE) return false;
			grid_.setNodeType(n.index, type);
			
			if (type == Node.TYPE_START) {
				if (spawnNode_ != null) spawnNode_.type = Node.TYPE_WALKABLE;
				spawnNode_ = n;
			} else {
				if (exitNode_ != null) exitNode_.type = Node.TYPE_WALKABLE;
				exitNode_ = n;
			}

			var global:Point = local2Global(selPt_);
			with (portal) {
				x = global.x;
				y = global.y;
				z = -10;
			}
			return true;
		}

	}
	
}