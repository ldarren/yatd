package {
	import bots.BasicBot;
	import bots.BotData;
	import bots.Bullets;
	import flash.events.Event;
	import gates.EndGate;
	import gates.StartGate;
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.view.Viewport3D;
	import org.pica.ai.Grid2D;
	import org.pica.ai.Node;
	import org.pica.ai.PathFinder;
	import org.pica.animators.Animator;
	import org.pica.graphics.Renderer;
	import org.pica.graphics.ui.Coordinate3D;
	import org.pica.net.PhpIO;
	import wisps.Boss;
	import wisps.IWisp;
	import wisps.Swarm;
	import wisps.WispData;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Scene {
		
		public static const MODE_NONE:uint = 0;
		public static const MODE_WALL:uint = 1;
		public static const MODE_DESTRUCT:uint = 2;
		public static const MODE_START:uint = 3;
		public static const MODE_END:uint = 4;
		
		private var mGfx_:Renderer;
		
		private var mPHP_:PhpIO;
		
		private var mGrid_:Grid2D;
		private var mPathFinder_:PathFinder;
		private var mPath_:Array;
		
		private var mBullets_:Bullets;
		private var mCreeps_:Array; // IWisp;
		private var mBots_:Array; // BasicBot;
		private var mSequence_:Array;
		
		public function Scene(gfx:Renderer) {
			mGfx_ = gfx;
			mGfx_.addObj(Coordinate3D.generateFloor(100, 10), "_ground_grid_");
			mGfx_.addObj(Coordinate3D.generateDatum(100), "_coor_symbol_");
			
			mPHP_ = new PhpIO("http://ldarren.g0dsoft.com/");
			
			mGrid_ = new Grid2D(10, 10, 100, 100);
			mPathFinder_ = new PathFinder();
			Animator.init();

			mCreeps_ = new Array();
			
			mBots_ = new Array();
			
			mBullets_ = new Bullets(50); 
			mGfx_.addObj(mBullets_);
			
			mSequence_ = new Array();
			mSequence_.push(WispData.TYPE_BOSS);
			mSequence_.push(WispData.TYPE_SWARM);
			mSequence_.push(WispData.TYPE_BOSS);
		}
		
		public function load():void {
			mPHP_.read(populate, function ():void { trace("open file failed"); } );
			trace("Reading file from file server...");
		}
		
		// TODO: for debugging
		public function nextWave():void {
			var creep:IWisp = new Boss(mGrid_);
			var type:uint = mSequence_.pop() as uint;
			switch (type) {
			case WispData.TYPE_BOSS:
				creep = new Boss(mGrid_);
				break;
			case WispData.TYPE_SWARM:
				creep = new Swarm(new WispData(1), 50, mGrid_);
				break;
			}
			mGfx_.addObj(creep as DisplayObject3D);
			mCreeps_.push(creep);
			creep.start(mPath_, onGoal);
		}
		
		public function update():void {
			for each (var bot:BasicBot in mBots_) {
				bot.update(mCreeps_, mBots_);
			}
			
			var bullets:Array = mBullets_.particles;
			var survival:Array = new Array();
			for each (var creep:IWisp in mCreeps_) {
				creep.update(mBullets_, bullets);
				if (creep.isAlive())	survival.push(creep);
				else 				mGfx_.removeObj(creep as DisplayObject3D);
			}
			mCreeps_ = survival;
		}
		
		private function populate(evt:Event):void {
			var data:String = evt.target.data.map as String;
			
			trace("date length: "+data.length);
			for (var i:uint = 0; i < data.length; ++i) {
				var node:Node = mGrid_.getNodeByIdx(i);
				if (node.visual != null) mGfx_.removeObj(node.visual);
				node.visual = null;
				switch(parseInt(data.charAt(i))) {
				case Node.TYPE_START:
					setNodeType(Scene.MODE_START, node);
					break;
				case Node.TYPE_END:
					setNodeType(Scene.MODE_END, node);
					break;
				case Node.TYPE_WALKABLE:
					break;
				case Node.TYPE_WALL:
					setNodeType(Scene.MODE_WALL, node);
					break;
				}
			}
			
			mGrid_.deserialize(data);  
			
			if (mPathFinder_.reset(mGrid_)) {
				mPath_ = mPathFinder_.search();
			}
			trace("open file ok: " + data);
		}
		
		private function setNodeType(type:uint, node:Node):uint {
			var obj:DisplayObject3D;
			var t:uint;
			switch (type) {
			case Scene.MODE_NONE:
				break;
			case Scene.MODE_WALL:
				obj = new BasicBot(new BotData(60, 2, 25, 1), mBullets_);
				mBots_.push(obj);
				t = Node.TYPE_WALL;
				break;
			case Scene.MODE_START:
				obj = new StartGate();
				t = Node.TYPE_START;
				break;
			case Scene.MODE_END:
				obj = new EndGate();
				t = Node.TYPE_END;
				break;
			}
			mGfx_.addObj(obj);
			obj.position = node.getPos(0);
			node.visual = obj;
			
			return t;
		}
		
		private function onGoal(creep:DisplayObject3D):void {
			var remaining:Array = new Array();
			for each (var c:DisplayObject3D in mCreeps_) {
				if (c != creep)
					remaining.push(c);
			}
			mCreeps_ = remaining;
			mGfx_.removeObj(creep);
		}
		
	}
	
}