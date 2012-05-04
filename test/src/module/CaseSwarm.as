package module {
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.pica.ai.FloodFill;
	import org.pica.ai.FloodPoint;
	import org.pica.ai.Grid2D;
	import org.pica.ai.Node;
	import org.pica.ai.PathFinder;
	import org.pica.graphics.effects.Decal;
	import org.pica.graphics.Renderer;
	import org.pica.graphics.ui.Button;
	import org.pica.graphics.ui.Label;
	import org.pica.graphics.ui.Picker3D;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class CaseSwarm implements ICase {
		
		public static const ID:String = Test.CASE_AI_SWARM;
		
		private var creepGroup_:CreepGroup;
		
		private static const MODE_BUILD_NONE:uint = 0;
		private static const MODE_BUILD_WALL:uint = 1;
		private static const MODE_BUILD_START:uint = 2;
		private static const MODE_BUILD_END:uint = 3;
		
		[Embed(source = "../../../res/ui/buttons/but_b.png")]		private var NormBitmapClass:Class;
		[Embed(source = "../../../res/ui/buttons/but_f.png")]		private var OverBitmapClass:Class;
		[Embed(source = "../../../res/ui/buttons/but_a.png")]		private var DownBitmapClass:Class;
		[Embed(source = "../../../res/ui/buttons/but_i.png")]		private var InacBitmapClass:Class;
		
		private var buildMode_:int = CaseSwarm.MODE_BUILD_NONE;
		private var cursorColor_:int;
		private var path_:Array;
		private var dirs_:Array;
		
		private var plane_:Plane;
		private var currPt_:Point;
		
		private var decalCursor_:Decal;
		private var decalMat_:Decal;
		private var grid_:Grid2D;
		private var pathfinder_:PathFinder;
		private var filler_:FloodFill;
		
		private var btnStart_:Button;
		private var btnStep_:Button;
		private var lblDir_:Label;
		
		public function CaseSwarm() {
			currPt_ = new Point(0, 0);
			grid_ = new Grid2D(10, 10, 500, 500);

			var sprite:Sprite = new Sprite();
			var g:Graphics = sprite.graphics;
			
			g.beginFill(0xaaaaaa);
			g.drawRect(0, 0, grid_.sizeX, grid_.sizeZ);
			g.endFill();
			
			// material's animate param must set to true for decal to work
			var movieMat:MovieMaterial = new MovieMaterial(sprite, false, true, false);
			
			plane_ = new Plane(movieMat, grid_.sizeX, grid_.sizeZ, 1, 1);
			
			// order does matter here
			decalMat_ = new Decal("mat", plane_, 1);
			decalCursor_ = new Decal("cur", plane_, 0.3);
			
			pathfinder_ = new PathFinder();
			creepGroup_ = new CreepGroup(100, grid_);
			
			filler_ = new FloodFill();
			
			Button.setDefaultTheme([new NormBitmapClass(), new OverBitmapClass(), new DownBitmapClass(), new InacBitmapClass()], new Rectangle(0, 0, 10, 19), new Rectangle(3, 9, 4, 1));
			btnStart_ = new Button("btn_start", "Start", null, {up:onButton}, 10, 600);
			btnStep_ = new Button("btn_step", "Step", null, {up:onButton}, 250, 600);
			lblDir_ = new Label("lbl_dir", "Dir: ", 500, 600, 300, 20);

			createBuildStage();
		}
		
		public function load(gfx:Renderer):void {
			gfx.setCameraPos(new Number3D(0, 0, -300));

			gfx.addOverlay(btnStart_);
			gfx.addOverlay(btnStep_);
			gfx.addOverlay(lblDir_);

			gfx.addObj(plane_);
			Picker3D.setPickable(plane_);
			gfx.addObj(creepGroup_);
		}
		
		public function unload(gfx:Renderer):void {
			gfx.removeObj(creepGroup_);
			Picker3D.setPickable(plane_, false);
			gfx.removeObj(plane_);
			
			gfx.removeOverlay(lblDir_);
			gfx.removeOverlay(btnStep_);
			gfx.removeOverlay(btnStart_);
		}
		
		public function onEvent(evt:Event):void {
			var me:MouseEvent = evt as MouseEvent;
			var idx:int;
			switch (evt.type) {
			case MouseEvent.MOUSE_MOVE:
				Picker3D.hitTest();
				if (Picker3D.getPickedPoint(plane_, currPt_)) {
					updateCursor(currPt_.x, currPt_.y);
					if (dirs_ != null) {
						idx = grid_.getSnappedIndex(currPt_.x, grid_.sizeZ - currPt_.y);
						var dirs:Array = dirs_[idx] as Array;
						lblDir_.text = "Dir: ";
						for each (var d:uint in dirs) {
							lblDir_.text += d + ", ";
						}
					}
				}
				break;
			case MouseEvent.MOUSE_WHEEL:
				rotateBuildMode(me.delta > 0);
				break;
			case MouseEvent.MOUSE_UP:
				if (currPt_.x == -1)
					break;
				// grid_.sizeZ - currPt_.y due to Picker3D coordinate is follow tex
				idx = grid_.getSnappedIndex(currPt_.x, grid_.sizeZ - currPt_.y);
				
				switch (buildMode_) {
				case CaseSwarm.MODE_BUILD_NONE:
					destroyStructureAt(idx)
					break;
				case CaseSwarm.MODE_BUILD_WALL:
					createWallAt(idx);
					break;
				case CaseSwarm.MODE_BUILD_START:
					createStartPtAt(idx);
					break;
				case CaseSwarm.MODE_BUILD_END:
					createEndPtAt(idx);
					break;
				}
				break;
			}
		}
		
		public function onUpdate():void {
		}
		
		private function onButton(btn:Button):void {
			switch (btn.name) {
			case "btn_start":
				if (pathfinder_.setup(grid_)) {
					path_ = pathfinder_.search();
					createFindStage(path_);
					creepGroup_.setEndIndex(path_[0].index);
				}
				createFillStage();
				break;
			case "btn_step":
				var array:Array = filler_.step();
				var goners:Array = creepGroup_.step(array);
				
				if (goners.length != 0)
					filler_.removePoints(goners);

				var comers:Array = filler_.addPoints(3);
				if (comers.length != 0)
					creepGroup_.addCreeps(comers);
				
				break;
			}
		}
		
		private function createBuildStage():void {
			var count:int = grid_.cutsX * grid_.cutsZ;
			var divx:int = grid_.divX, divz:int = grid_.divZ;
			var hdivx:int = grid_.divX / 2, hdivz:int = grid_.divZ / 2;
			for (var i:uint = 0; i < count; ++i) {
				decalMat_.drawText("" + i, "" + i, 
					divx * int(i / grid_.cutsZ) + hdivx, 
					(500 - divz * (i % grid_.cutsZ)) - hdivz, 
					hdivx, hdivz);
			}
			
			grid_.resetAllType();
			
			setBuildMode(CaseSwarm.MODE_BUILD_START);
		}
		
		private function createFindStage(path:Array):void {
			if (path.length == -1)
				return;
			
			var i:int;
			var count:int = grid_.cutsX * grid_.cutsZ;
			for (i = 0; i < count;++i) {
				if (grid_.getNodeByIdx(i).type == Node.TYPE_WALL) {
					createFindMapAt(i, "-1");
				} else {
					createFindMapAt(i, "");
				}
			}
			
			i = 0;
			for each (var node:Node in path) {
				createFindMapAt(node.index, ""+i++);
			}
		}
		
		private function createFillStage():void {
			var weights:Array = filler_.build(grid_, path_);
			
			var i:int;
			var count:int = grid_.cutsX * grid_.cutsZ;
			for (i = 0; i < count;++i) {
				createFindMapAt(i, ""+(weights[i] as uint));
			}
			
			dirs_ = filler_.getAllDir();
		}
		
		private function rotateBuildMode(inc:Boolean):void {
			if (inc) {
				setBuildMode(++buildMode_);
			} else {
				setBuildMode(--buildMode_);
			}
		}
		
		private function setBuildMode(mode:uint):void {
			buildMode_ = mode;
			if (buildMode_ > CaseSwarm.MODE_BUILD_END) {
				buildMode_ = CaseSwarm.MODE_BUILD_NONE;
			} else if (buildMode_ < CaseSwarm.MODE_BUILD_NONE) {
				buildMode_ = CaseSwarm.MODE_BUILD_END;
			}

			switch (buildMode_) {
			case CaseSwarm.MODE_BUILD_NONE:
				cursorColor_ = 0xffffff;
				break;
			case CaseSwarm.MODE_BUILD_WALL:
				cursorColor_ = 0xff0000;
				break;
			case CaseSwarm.MODE_BUILD_START:
				cursorColor_ = 0x00ff00;
				break;
			case CaseSwarm.MODE_BUILD_END:
				cursorColor_ = 0x0000ff;
				break;
			}
			
			updateCursor(currPt_.x, currPt_.y);
		}
		
		private function updateCursor(x:Number, y:Number):void {
			var p:Number3D = grid_.getSnappedPos(x, 0, y);
			decalCursor_.clear();
			decalCursor_.drawSquare(p.x, p.z, 25, 25, cursorColor_);
		}
		
		private function checkGatePt(idx:int):void {
			if (grid_.startIdx == idx) grid_.setNodeType(-1, Node.TYPE_START);
			if (grid_.endIdx == idx) grid_.setNodeType(-1, Node.TYPE_END);
		}
		
		private function createStartPtAt(idx:int):void {
			var sidx:int = grid_.startIdx;
			if (sidx == idx) return;
			if (sidx != -1)
				destroyStructureAt(sidx);
			decalMat_.drawText("" + idx, "start");
			grid_.setNodeType(idx, Node.TYPE_START);
		}
		
		private function createEndPtAt(idx:int):void {
			var eidx:int = grid_.endIdx;
			if (eidx == idx) return;
			if (eidx != -1)
				destroyStructureAt(eidx);
			decalMat_.drawText("" + idx, "end");
			grid_.setNodeType(idx, Node.TYPE_END);
		}
		
		private function createWallAt(idx:int):void {
			checkGatePt(idx);
			decalMat_.drawText("" + idx, "wall");
			grid_.setNodeType(idx, Node.TYPE_WALL);
		}
		
		private function destroyStructureAt(idx:int):void {
			checkGatePt(idx);
			decalMat_.drawText("" + idx, ""+idx);
			grid_.setNodeType(idx, Node.TYPE_WALKABLE);
		}
		
		private function createFindMapAt(idx:int, path:String):void {
			decalMat_.drawText("" + idx, path);
		}
		
	}
	
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import org.papervision3d.core.data.UserData;
import org.papervision3d.core.geom.Particles;
import org.papervision3d.core.geom.renderables.Particle;
import org.papervision3d.core.math.Number3D;
import org.papervision3d.materials.special.BitmapParticleMaterial;
import org.papervision3d.objects.DisplayObject3D;
import org.pica.ai.FloodPoint;
import org.pica.ai.Grid2D;
import org.pica.ai.Node;

/**
 * ...
 * @author Darren Liew
 * @see Bullets.as
 */
class CreepGroup extends Particles {
	
	[Embed(source = "../../../res/particles/bubble.png")]
	private var BubleBitmapClass:Class;
	
	private var creeps_:Array;
	private var grid_:Grid2D;
	private var endIdx_:int;
	
	public function CreepGroup(size:uint, grid:Grid2D) {
		super("creep_holder");
		
		//createBullets();
		var bmp:Bitmap = new BubleBitmapClass();
		
		creeps_ = new Array();
		
		var i:int = -1;
		var p:Particle;
		var bpm:BitmapParticleMaterial;
		while(++i<size) {
			bpm = new BitmapParticleMaterial(bmp.bitmapData , 1, -bmp.bitmapData.width * 0.5, -bmp.bitmapData.height * 0.5); 
			bpm.smooth = true;
			p = new Particle(bpm, 0.05);

			creeps_.push(p); 
		}
		this.grid_ = grid;
	}
	
	public function setEndIndex(idx:int):void {
		this.endIdx_ = idx;
	}
	
	public function addCreeps(comers:Array):Array {
		var particles:Array = new Array();
		var p:Particle;
		var node:Node;
		var pos:Number3D;
		for each (var comer:FloodPoint in comers) {
			p = creeps_.pop() as Particle;
			node = grid_.getNodeByIdx(comer.homeId);
			pos = node.getPos();
			p.x = pos.x;
			p.y = pos.z;
			p.z = -5;
			comer.userData = new UserData(p);
			this.addParticle(p);
			particles.push(p);
		}
		return particles;
	}
	
	public function step(points:Array):Array {
		var goners:Array = new Array();
		var p:Particle;
		var n:Node;
		var pos:Number3D;
		for each (var point:FloodPoint in points) {
			n = grid_.getNodeByIdx(point.homeId);
			p = point.userData.data as Particle;
			if (point.homeId == endIdx_) {
				this.removeParticle(p);
				creeps_.push(p);
				goners.push(point);
			} else {
				pos = n.getPos();
				p.x = pos.x;
				p.y = pos.z;
				p.z = -5;
			}
		}
		return goners;
	}
}
