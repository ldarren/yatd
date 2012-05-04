package scenes.td {
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.primitives.Plane;
	
	import org.pica.ai.FloodFill;
	import org.pica.ai.FloodPoint;
	import org.pica.ai.Grid2D;
	import org.pica.ai.Node;
	import org.pica.ai.PathFinder;
	import org.pica.graphics.effects.Decal;
	import org.pica.graphics.effects.LightBeam;
	import org.pica.graphics.ui.Picker3D;

	import scenes.td.events.GameEvent;
	import scenes.td.events.TowerEvent;
	import scenes.td.events.TowerEventDispatcher;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Ground extends DisplayObject3D{
		
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
		private var decal_:Decal;
		private var selPt_:Point;
		
		private var spawn_:LightBeam;
		private var exit_:LightBeam;
		private var spawnNode_:Node;
		private var exitNode_:Node;
		
		private var dw_:uint, dh_:uint, dhw_:uint, dhh_:uint, cols_:uint, rows_:uint;
		private var hw_:Number, hh_:Number;
		
		private var grid_:Grid2D;
		private var pathfinder_:PathFinder;
		private var filler_:FloodFill;
		
		public function Ground(bmp:Bitmap, dw:uint, dh:uint, cols:uint, rows:uint) {
			dispatcher = new TowerEventDispatcher("Ground");

			dw_ = dw; dhw_ = dw * 0.5; dh_ = dh; dhh_ = dh * 0.5; cols_ = cols; rows_ = rows;

			grid_ = new Grid2D(cols_, rows_, dw * cols, dh * rows);
			pathfinder_ = new PathFinder();
			filler_ = new FloodFill();
			
			var w:uint = grid_.sizeX, h:uint = grid_.sizeZ;

			var sprite:Sprite = new Sprite();
			var g:Graphics = sprite.graphics;
			g.beginBitmapFill(bmp.bitmapData, null, true);
			g.drawRect(0, 0, w, h);
			g.endFill();
			
			// material's animate param must set to true for decal to work
			var movieMat:MovieMaterial = new MovieMaterial(sprite, false, true, false);
			
			plane_ = new Plane(movieMat, w, h, cols, rows);
			plane_.pitch(90);
			this.addChild(plane_);
			
			decal_ = new Decal("grd_decal", plane_, 0.3);

			selPt_ = new Point(dhw_, dhh_);
			spawn_ = new LightBeam(RcsMgr.getTex("portal.png"), 16, 50, 1, 0.7, 0.8);
			setPortalAtSelPt(spawn_, Node.TYPE_START);
			this.addChild(spawn_);

			selPt_.x = w - dhw_; selPt_.y = h - dhh_;
			exit_ = new LightBeam(RcsMgr.getTex("portal.png"), 16, 50, 0.8, 1, 0.9);
			setPortalAtSelPt(exit_, Node.TYPE_END);
			this.addChild(exit_);
		}
		
		public function setEditable(state:Boolean):void {
			decal_.clear();
			Picker3D.setPickable(plane_, state);
			Picker3D.setPickable(spawn_, state);
			Picker3D.setPickable(exit_, state);
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
					if (Picker3D.getPickedPoint(plane_, selPt_)) {
						if (grid_.getNode(selPt_.x, selPt_.y).type != Node.TYPE_WALKABLE) return true;
						snapCursor(selPt_);
						if (mode_==Ground.MODE_STARTING) hightlight(spawn_, false);
						if (mode_ == Ground.MODE_ENDING) hightlight(exit_, false);
						if (mode_ != Ground.MODE_START && mode_ != Ground.MODE_END) mode_ = Ground.MODE_WALL;
					}
					return true;
				case spawn_.id:
					if (mode_ == Ground.MODE_ENDING) hightlight(exit_, false);
					if (mode_ != Ground.MODE_START && mode_ != Ground.MODE_END) {
						mode_ = Ground.MODE_STARTING;
						hightlight(spawn_);
					}
					return true;
				case exit_.id:
					if (mode_ == Ground.MODE_STARTING) hightlight(spawn_, false);
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
		}
		
		public function onWallLowered(evt:TowerEvent):void {
			//var loc:Point = global2Local(evt.data.loc);
			//var idx:int = grid_.getSnappedIndex(loc.x, loc.y);
			grid_.setNodeType(evt.data.idx, Node.TYPE_WALKABLE);
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
			return "" + Node.TYPE_START + ":" + spawnNode_.index + ";" + Node.TYPE_END + ":" + exitNode_.index + ";";
		}
		
		public function load(data:String):void {
			var args:Array, vals:Array;
			var val:String;
			var type:int, idx:int;
			var n:Node;
			var pt:Number3D;

			var lines:Array = data.split(";");
			for each (var line:String in lines) {
				if (line == "") continue;
				args = line.split(":");
				if (args[0] == "" || args[1] == "") continue;
				type = parseInt(args[0]);

				switch(type) {
				case Node.TYPE_START:
					idx = parseInt(args[1]);
					setPortalAtSelPt(spawn_, Node.TYPE_START, idx);
					break;
				case Node.TYPE_END:
					idx = parseInt(args[1]);
					setPortalAtSelPt(exit_, Node.TYPE_END, idx);
					break;
				case Node.TYPE_WALL:
				case TowerFarm.ORB_BLUE_CODE:
				case TowerFarm.ORB_BLACK_CODE:
				case TowerFarm.ORB_AMBER_CODE:
				case TowerFarm.ORB_CLEAR_CODE:
				case TowerFarm.ORB_GREEN_CODE:
				case TowerFarm.ORB_RED_CODE:
				case TowerFarm.ORB_PURPLE_CODE:
					vals = args[1].split(",");
					for each (val in vals) {
						if (val == "") continue;
						idx = parseInt(val);
						n = grid_.getNodeByIdx(idx);
						grid_.setNodeType(n.index, Node.TYPE_WALL);
						pt = n.getPos();
						dispatcher.dispatchEvent(new TowerEvent(TowerEvent.TOWER_LOAD, { type:type, idx:idx, loc:new Point(pt.x, -pt.z) } ));
					}
					break;
				}
			}
		}
		
		private function hightlight(portal:LightBeam, sel:Boolean=true):void {
			if (sel) portal.setColor(0, 0, 1);
			else portal.resetColor();
		}
		
		private function snapCursor(pt:Point):void {
			//decal_.clear();
			var p:Number3D = grid_.getSnappedPos(pt.x, 0, pt.y);
			if (mode_ == Ground.MODE_WALL || mode_ == Ground.MODE_START || mode_ == Ground.MODE_END) {
				pt.x = p.x; pt.y = p.z;
				hw_ = dhw_; hh_ = dhh_;
				decal_.drawSquare(pt.x, pt.y, hw_, hh_, 0x0000ff);
			}
		}
		
		// transform ground texture xy coor to global coor
		// there are three coor systems, 
		// 1) global coordinate or papervision space, center is at ground center, y pointing up, x pointing right
		// 2) texture coordinate, center is at top left, y is pointing down, x is pointing right
		// 3) Grid2D coordinate, center is at bottom left, y is pointing up and x is pointing right
		private function local2Global(local:Point):Point {
			return new Point(local.x - (grid_.sizeX * 0.5), -local.y + (grid_.sizeZ * 0.5));
		}
		
		private function global2Local(global:Point):Point {
			return new Point(global.x + (grid_.sizeX * 0.5), -global.y + (grid_.sizeZ * 0.5));
		}
		
		private function setWallAtSelPt():Boolean {
			var n:Node = grid_.getNode(selPt_.x, selPt_.y);
			if (n.type != Node.TYPE_WALKABLE) return false;
			grid_.setNodeType(n.index, Node.TYPE_WALL);

			dispatcher.dispatchEvent(new TowerEvent(TowerEvent.RAISE_WALL, {loc:local2Global(selPt_),idx:n.index}));
			return true;
		}
		
		// use property selPt_ or idx to get node
		private function setPortalAtSelPt(portal:DisplayObject3D, type:uint, idx:int=-1):Boolean {
			var n:Node;
			if (idx == -1) n = grid_.getNode(selPt_.x, selPt_.y);
			else n = grid_.getNodeByIdx(idx);

			if (n==null || n.type != Node.TYPE_WALKABLE) return false;
			grid_.setNodeType(n.index, type);
			
			if (type == Node.TYPE_START) {
				if (spawnNode_ != null) spawnNode_.type = Node.TYPE_WALKABLE;
				spawnNode_ = n;
			} else {
				if (exitNode_ != null) exitNode_.type = Node.TYPE_WALKABLE;
				exitNode_ = n;
			}

			var global:Point;
			if (idx == -1) global = local2Global(selPt_);
			else {
				var pt:Number3D = n.getPos();
				global = new Point(pt.x, -pt.z);
			}
			portal.x = global.x;
			portal.z = global.y;
			portal.y = 30;
			return true;
		}

	}
	
}