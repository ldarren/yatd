package wisps {
	import bots.Bullets;
	import flash.display.Bitmap;
	import org.papervision3d.core.data.UserData;
	import org.papervision3d.core.geom.Particles;
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.special.BitmapParticleMaterial;
	import org.pica.ai.Grid2D;
	import org.pica.utils.Random;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Swarm extends Particles implements IWisp {
		
		private var waiting_:Array;	// list of waiting wisps 
		private var completed_:Array; // list of completed wisps
		private var data_:WispData;
		private var size_:uint;
		private var grid_:Grid2D;
		
		private var startPt_:Number3D;
		private var endPt_:Number3D;
		private var path_:Array;
		private var onGoal_:Function;
		
		[Embed(source = "D:/SmartFlex/pica/res/particles/bubble.png")]
		private var CreepBitmapClass:Class;
		
		public function Swarm(data:WispData, size:uint, grid:Grid2D) {
			data_ = data;
			size_ = size;
			grid_ = grid;

			waiting_ = new Array();
			completed_ = new Array();
			
			var bmp:Bitmap = new CreepBitmapClass();
			var bpm:BitmapParticleMaterial;

			var p:Particle;
			var dna:Object;
			var i:int = -1;
			while(++i<size_) {
				bpm = new BitmapParticleMaterial(bmp.bitmapData , 1, -bmp.bitmapData.width * 0.5, -bmp.bitmapData.height * 0.5); 
				bpm.smooth = true;
				p = new Particle(bpm, 0.05);
				
				dna = new Object;
				dna.speed = data.speed;
				p.userData = new UserData(dna);
 
				completed_.push(p);
			}
		}
		
		public function start(path:Array, onGoal:Function):void {
			if (completed_.length != size_)
				return;
			onGoal_ = onGoal;
			changePath(path);
			waiting_ = completed_;
			
			emitWisp();
		}
		
		public function changePath(path:Array):void {
			endPt_ = path[0] as Number3D;
			startPt_ = path[path.length - 1] as Number3D;
			path_ = path;
		}
		
		public function update(bullet_type:Bullets, bullets:Array):void {
			if (path_ == null || path_.length < 2) return;
			
			if (this.numChildren > 0)
				moveWisps();
			
			if (waiting_.length > 0)
				emitWisp();
		}
		
		public function damage(d:Number, s:Particle):void {
			
		}
		
		public function isAlive():Boolean {
			return this.numChildren > 0;
		}
		
		private function emitWisp():void {
			var p:Particle = waiting_.pop() as Particle;
			p.x = startPt_.x + Random.between( -5, 5);
			p.y = startPt_.y;
			p.z = startPt_.z + Random.between( -5, 5);
			addParticle(p);
		}
		
		private function collectWisp(p:Particle):void {
			removeParticle(p);
			completed_.push(p);
			onGoal_(this);
		}
		
		private function moveWisps():void {
			var pos:Number3D;
			var list:Array = this.particles;
			for each (var p:Particle in list) {
				pos = grid_.getSnappedPos(p.x, p.y, p.z);
			}
		}
		
	}
	
}

// TODO
// preparation
// 1) resampling the grid to the wisp size
// 2) use flood fill to mark area of the path, simple scanline will do (dir of scanline is by comparing the x and z distance of start and end loc)
// 3) use heuristic method to find the cost of of each cell
// run time
// 4) emit wisp to the first line of path, emit until it is filled
// 4) iterate all wisp on scene from oldest to youngest
// 5) form force field base on adjacent cells cost
// 6) if adjacent field is occupy, cancel the force
// 7) select the biggest force dir and move the wisp to that loc