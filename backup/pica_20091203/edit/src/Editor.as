package {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import mx.containers.ApplicationControlBar;
	import mx.controls.Button;
	import mx.core.UIComponent;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;
	import caurina.transitions.Tweener;
	import caurina.transitions.properties.CurveModifiers;
	import org.papervision3d.objects.primitives.Sphere;
	import org.pica.ai.Grid2D;
	import org.pica.ai.Node;
	import org.pica.ai.PathFinder;
	import org.pica.graphics.Renderer;
	import org.pica.graphics.ui.Coordinate3D;
	import org.pica.graphics.ui.Picker3D;
	import org.pica.net.PhpIO;
	
	public class Editor extends UIComponent {
		
		public static const MODE_NONE:uint = 0;
		public static const MODE_WALL:uint = 1;
		public static const MODE_DESTRUCT:uint = 2;
		public static const MODE_START:uint = 3;
		public static const MODE_END:uint = 4;

		private var mGfx_:Renderer;
		private var mToolBar_:ApplicationControlBar;
		
		private var bBuildMode_:uint = Editor.MODE_NONE;
		private var mGrid_:Grid2D;
		private var mPathFinder_:PathFinder;
		private var nOldStartIdx_:int = -1;
		private var nOldEndIdx_:int = -1;
		private var mSphere_:Sphere;
		
		private var nOldMouseX_:Number;
		private var nOldMouseY_:Number;
		private var nCamEle_:Number = 45.0;
		private var nCamSec_:Number = -45.0;
		
		private var mPHP_:PhpIO;
		
		public function Editor() {
			super();

			mGrid_ = new Grid2D(10, 10, 100, 100);
			mPathFinder_ = new PathFinder();
			
			CurveModifiers.init();
			
			mPHP_ = new PhpIO("http://ldarren.g0dsoft.com/");
		}
		
		public function init(toolbar:ApplicationControlBar):void {
			this.graphics.beginFill(0x000000);
			this.graphics.drawRect(0, 0, this.width, this.height);
			this.graphics.endFill();
			
			mToolBar_ = toolbar;

			mGfx_ = new Renderer(this);
			mGfx_.rotCamera(nCamEle_, nCamSec_);
			
			bBuildMode_ = Editor.MODE_NONE;

			mGfx_.addObj(Coordinate3D.generateFloor(100, 10), "_ground_grid_");
			mGfx_.addObj(Coordinate3D.generateDatum(100), "_coor_symbol_");
			
			Picker3D.init(mGfx_.viewport);
		}
		
		public function onUpdate(evt:Event):void {
			mGfx_.onEnterFrame(evt);
		}
		
		public function onEvent(evt:Event):void {
			var e:MouseEvent;
			switch(evt.type) {
			case MouseEvent.MOUSE_WHEEL:
				e = evt as MouseEvent;
				var delta:int = e.delta;
				if (e.altKey) delta += delta * 10;
				if (e.ctrlKey) delta += delta * 10;
				if (e.altKey) delta += delta * 10;
				mGfx_.moveCamera(delta);
				break;
			case MouseEvent.MOUSE_DOWN:
				nOldMouseX_ = this.mouseX;
				nOldMouseY_ = this.mouseY;
				
				if (bBuildMode_ != Editor.MODE_NONE) {
					var pos:Number3D = Picker3D.getNumber3D();
					pos = mGrid_.getSnappedPos(pos.x, 5, mGrid_.sizeZ - pos.z);
					var node:Node = mGrid_.getNode(pos.x, pos.z);
					if (node != null) {
						if (node.visual != null) {
							if (bBuildMode_ == Editor.MODE_DESTRUCT) {
								mGfx_.removeObj(node.visual);
								node.visual = null;
								mGrid_.setNodeType(node.index, Node.TYPE_WALKABLE);
							}
							bBuildMode_ = Editor.MODE_NONE;
							break;
						}
						mGrid_.setNodeType(node.index, setNodeType(bBuildMode_, node));
					}
					bBuildMode_ = Editor.MODE_NONE;
				}
				break;
			case MouseEvent.MOUSE_UP:
			case MouseEvent.MOUSE_OUT:
				break;
			case MouseEvent.MOUSE_MOVE:
				Picker3D.hitTest();
				e = evt as MouseEvent;
				if (e.buttonDown) {
					nCamEle_ += nOldMouseY_ - this.mouseY;
					nCamSec_ += nOldMouseX_ - this.mouseX;
					nOldMouseX_ = this.mouseX;
					nOldMouseY_ = this.mouseY;
					nCamEle_ %= 360;
					nCamSec_ %= 360;

					mGfx_.rotCamera(nCamEle_, nCamSec_);
				}
				break;
			}
			mGfx_.onEvent(evt);
		}
		
		public function onButton(evt:Event):void {
			var btn:Button = evt.currentTarget as Button;
			switch(btn.id)
			{
			case "btnopen":
				openFile();
				break;
			case "btnsave":
				saveFile();
				break;
			case "btnaddwall":
				bBuildMode_ = Editor.MODE_WALL;
				break;
			case "btndelwall":
				bBuildMode_ = Editor.MODE_DESTRUCT;
				break;
			case "btnstart":
				bBuildMode_ = Editor.MODE_START;
				break;
			case "btnend":
				bBuildMode_ = Editor.MODE_END;
				break;
			case "btnrun":
				if (mPathFinder_.reset(mGrid_)) {
					var path:Array = mPathFinder_.search();
					if (path.length > 1) {
						animate(path);
					}
				}
				break;
			}
		}
		
		private function setNodeType(type:uint, node:Node):uint {
			var box:Cube;
			var mat:MaterialsList;
			var old:Node;
			var t:uint;
			switch (type) {
			case Editor.MODE_WALL:
				mat = new MaterialsList( { all: new ColorMaterial(0x00ff00) } );
				box = new Cube(mat, 10, 10, 10);
				mGfx_.addObj(box);
				t = Node.TYPE_WALL;
				break;
			case Editor.MODE_START:
				if (nOldStartIdx_ != -1) {
					old = mGrid_.getNodeByIdx(nOldStartIdx_);
					mGrid_.setNodeType(old.index, Node.TYPE_WALKABLE);
					box = old.visual as Cube;
					old.visual = null;
				} else {
					mat = new MaterialsList( { all: new ColorMaterial(0xff0000, 0.3) } );
					box = new Cube(mat, 10, 10, 10);
					mGfx_.addObj(box);
				}
				nOldStartIdx_ = node.index;
				if (mSphere_ != null) mSphere_.position = node.getPos(5);
				t = Node.TYPE_START;
				break;
			case Editor.MODE_END:
				if (nOldEndIdx_ != -1) {
					old = mGrid_.getNodeByIdx(nOldEndIdx_);
					mGrid_.setNodeType(old.index, Node.TYPE_WALKABLE);
					box = old.visual as Cube;
					old.visual = null;
				} else {
					mat = new MaterialsList( { all: new ColorMaterial(0x0000ff, 0.3) } );
					box = new Cube(mat, 10, 10, 10);
					mGfx_.addObj(box);
				}
				nOldEndIdx_ = node.index;
				t = Node.TYPE_END;
				break;
			}
			if (box != null) {
				box.position = node.getPos(5);
				node.visual = box;
			}
			
			return t;
		}
		
		private function openFile():void {
			mPHP_.read(populate, function ():void { trace("open file failed"); } );
			trace("Reading file from file server...");
		}
		
		private function populate(evt:Event):void {
			var data:String = evt.target.data.map as String;
			
			trace("date length: "+data.length);
			for (var i:uint = 0; i < data.length; ++i) {
				var node:Node = mGrid_.getNodeByIdx(i);
				if (node.visual != null) mGfx_.removeObj(node.visual);
				node.visual = null;
trace("i: " + node.index + " char: " + parseInt(data.charAt(i)));
				switch(parseInt(data.charAt(i))) {
				case Node.TYPE_START:
					setNodeType(Editor.MODE_START, node);
					break;
				case Node.TYPE_END:
					setNodeType(Editor.MODE_END, node);
					break;
				case Node.TYPE_WALKABLE:
					setNodeType(Editor.MODE_NONE, node);
					break;
				case Node.TYPE_WALL:
					setNodeType(Editor.MODE_WALL, node);
					break;
				}
			}
			
			mGrid_.deserialize(data);  
			trace("open file ok: " + data);
		}
		
		private function saveFile():void {
			mPHP_.write(mGrid_.serialize(), function ():void { trace("save file ok"); }, function ():void { trace("save file failed"); } );
			trace("writing file to file server...");
		}
		
		private function animate(path:Array):void {
			var s2:Number = mGrid_.divX / 2;
			if (mSphere_ == null) {
				mSphere_ = new Sphere(new ColorMaterial(0xbbbbbb), s2, 16, 12);
				mSphere_.position = mGrid_.startNode.getPos(s2);
				mGfx_.addObj(mSphere_);
			}
			
			var endpos:Number3D = mGrid_.endNode.getPos(s2);
			var tweenObj: Object = 
			{
				x: endpos.x, 
				y: endpos.y, 
				z: endpos.z, 
				_bezier: path2Bezier(path), 
				time: 5, 
				transition: "easeinoutquad",
				//onUpdate: this.handleUpdate
				onComplete: this.onBallReached
			};
			//this.view.render();
			Tweener.addTween(mSphere_, tweenObj);
		}
		
		private function path2Bezier(path:Array):Array {
			var bezier:Array = new Array();
			var pos:Number3D;
			var rad:Number = mGrid_.divX / 2;
			for (var i:uint = path.length - 1; i > 0; --i) {
				pos = path[i].getPos(rad);
				bezier.push({x: pos.x, y: pos.y, z: pos.z});
			}
			return bezier;
		}
		
		private function onBallReached():void {
			if (mSphere_ != null) 
				mSphere_.position = mGrid_.startNode.getPos(5);
		}
	}
}