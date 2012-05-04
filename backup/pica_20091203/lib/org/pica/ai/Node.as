package org.pica.ai {
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class Node {
		// node type, for external use (map building)
		public static const TYPE_START:uint = 0;
		public static const TYPE_END:uint = 1;
		public static const TYPE_WALKABLE:uint = 2;	// anything before is not obstacle
		public static const TYPE_WALL:uint = 3;
		
		// node status, for library internal use (path searching)
		public static const STAT_FREE:uint = 0;
		public static const STAT_OPEN:uint = 1;
		public static const STAT_CLOSE:uint = 2;

		private var mGrid_:Grid2D;
		
		private var mParent_:Node;
		private var nType_:uint = Node.TYPE_WALKABLE;
		private var mVisual_:DisplayObject3D;
		
		private var nX_:uint;
		private var nZ_:uint;
		private var nIdx_:uint;
		
		private var nGCost_:uint;
		private var nHCost_:uint;
		private var nFCost_:uint;
		
		private var nStatus_:uint = Node.STAT_FREE; 
		
		public function Node(grid:Grid2D, x:uint, z:uint, obj:DisplayObject3D = null) {
			mGrid_ = grid;
			nX_ = x;
			nZ_ = z;
			nIdx_ = nX_ * mGrid_.cutsZ + nZ_;
			mVisual_ = obj;
		}
		
		public function set parent(p:Node):void {
			this.mParent_  = p;
		}
		
		public function get parent():Node {
			return this.mParent_;
		}
		
		public function set type(t:uint):void {
			nType_ = t;
		}
		
		public function get type():uint {
			return nType_;
		}
		
		public function set status(s:uint):void {
			nStatus_ = s;
		}
		
		public function isOpen():Boolean {
			return nStatus_ == Node.STAT_OPEN;
		}
		
		public function isClosed():Boolean {
			return nStatus_ == Node.STAT_CLOSE;
		}
		
		public function isWalkable():Boolean {
			return nType_ <= Node.TYPE_WALKABLE;
		}
		
		public function set visual(obj:DisplayObject3D):void {
			mVisual_ = obj;
		}
		
		public function get visual():DisplayObject3D {
			return mVisual_;
		}
		
		public function costCalAndSave(source:Node, target:Node):uint {
			costG = calG(source);
			costH = calH(target);
			return nFCost_;
		}
		
		public function costCompAndSaveIfLower(source:Node, target:Node):Boolean {
			var g:uint = calG(source);
			if (g < nGCost_) {
				costG = g;
				costH = calH(target);
				return true;
			}
			return false;
		}
		
		public function set costG(cost:uint):void {
			nGCost_ = cost;
			nFCost_ = nGCost_ + nHCost_;
		}
		
		public function get costG():uint {
			return nGCost_;
		}
		
		public function set costH(cost:uint):void {
			nHCost_ = cost;
			nFCost_ = nGCost_ + nHCost_;
		}
		
		public function get costF():uint {
			return nFCost_;
		}
		
		public function get x():uint {
			return nX_;
		}
		
		public function get z():uint {
			return nZ_;
		}
		
		public function getPos(height:Number=0):Number3D {
			return new Number3D(
			(nX_ - mGrid_.cutsX / 2) * mGrid_.divX + mGrid_.divX / 2, 
			height, 
			(nZ_ - mGrid_.cutsZ / 2) * mGrid_.divZ + mGrid_.divZ / 2);
		}
		
		public function nextStraightNeightbour(i:uint):Node {
			switch(i) {
			case 0:
				return getNeighbour(0, 1);	// top
			case 1:
				return getNeighbour(1, 0);	// right
			case 2:
				return getNeighbour(0, -1);	// bottom
			case 3:
				return getNeighbour(-1, 0);	// left
			}
			return null;
		}
		
		public function nextDiagonalNeightbour(i:uint):Node {
			switch(i) {
			case 0:
				return getNeighbour(1, 1);	// top right
			case 1:
				return getNeighbour(1, -1);	// bottom right
			case 2:
				return getNeighbour(-1, -1);	// bottom left
			case 3:
				return getNeighbour(-1, 1);	// top left
			}
			return null;
		}
		
		public function getNeighbour(dirX:int, dirZ:int):Node {
			var x:int = nX_ + dirX;
			var z:int = nZ_ + dirZ;
			if (x < 0 || x >= mGrid_.cutsX) return null;
			if (z < 0 || z >= mGrid_.cutsZ) return null;
			
			return mGrid_.getNodeByIdx(x * mGrid_.cutsZ + z);
		}
		
		public function get index():uint {
			return nIdx_;
		}
		
		private function calG(curr:Node):uint {
			var cx:uint = curr.index / mGrid_.cutsZ;
			var cz:uint = curr.index % mGrid_.cutsZ;
			var dx:uint = Math.abs(nX_ - cx);
			var dz:uint = Math.abs(nZ_ - cz);
			if (dx + dz == 2) return 14 + curr.costG;
			return 10 + curr.costG;
		}
		
		private function calH(dest:Node):uint {
			var dx:uint = dest.index / mGrid_.cutsZ;
			var dz:uint = dest.index % mGrid_.cutsZ;
			var hx:uint = Math.abs(dx - nX_);
			var hz:uint = Math.abs(dz - nZ_);
			return (hx + hz) * 10;
		}
	}
}