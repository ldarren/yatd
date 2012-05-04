package org.pica.ai 
{
	import org.papervision3d.core.math.Number3D;
	
	/**
	 * ...
	 * @author Darren Liew
	 * @usage customised for Picker3D (z axis is the reverse of Mouse3D)
	 */
	public class Grid2D {
		private var nCutsX_:uint; // number of cuts on each axis
		private var nCutsZ_:uint; // number of cuts on each axis
		private var nCount_:uint; // total count of cuts (for array index)
		private var nSizeX_:uint; // dimensions on each axis
		private var nSizeZ_:uint; // dimensions on each axis
		private var nDivX_:uint; // division = nSizes_/nCuts_
		private var nDivZ_:uint; // division = nSizes_/nCuts_
		private var nHDivX_:uint; // half division = nDiv_/2
		private var nHDivZ_:uint; // half division = nDiv_/2
		
		private var nStartIdx_:int = -1;
		private var nEndIdx_:int = -1;
		
		private var mNodes_:Array;
		
		public function Grid2D(cutX:uint, cutZ:uint, sizeX:uint, sizeZ:uint) {
			nCutsX_ = cutX;
			nCutsZ_ = cutZ;
			nCount_ = nCutsX_ * nCutsZ_;
			
			nSizeX_ = sizeX;
			nSizeZ_ = sizeZ;
			
			nDivX_ = nSizeX_ / nCutsX_;
			nDivZ_ = nSizeZ_ / nCutsZ_;
			nHDivX_ = nDivX_ / 2;
			nHDivZ_ = nDivZ_ / 2;
			
			mNodes_ = new Array();
			for (var i:uint = 0; i < nCount_; ++i) {
				mNodes_.push(new Node(this, i/nCutsZ_, i%nCutsZ_));
			}
		}
		
		// start and ending remain unchanged
		public function resetCosts():void {
			for each (var n:Node in mNodes_) {
				n.status = Node.STAT_FREE;
				n.costG = 0;
				n.costH = 0;
				n.parent = null;
			}
		}
		
		public function setNodeType(idx:int, type:uint):void {
			switch (type) {
			case Node.TYPE_START:
				nStartIdx_  = idx;
				break;
			case Node.TYPE_END:
				nEndIdx_  = idx;
				break;
			}
			
			if (idx > 0)
				getNodeByIdx(idx).type = type;
		}
		
		public function resetAllType():void {
			for each (var n:Node in mNodes_) {
				n.type = Node.TYPE_WALKABLE;
			}
			nStartIdx_ = -1;
			nEndIdx_ = -1;
		}
		
		public function serialize():String {
			var data:String = "";
			for each (var n:Node in mNodes_) {
				data += n.type;
			}
			return data;
		}
		
		public function deserialize(data:String):Boolean {
			if (data.length < nCount_) return false;

			for (var i:uint = 0; i < nCount_; ++i ) {
				mNodes_[i].type = parseInt(data.charAt(i));
			}
			
			return true;
		}
		
		public function getSnappedPos(x:Number, y:Number, z:Number):Number3D {
			var p:Number3D = new Number3D(x, y, z);
			p.x -= p.x % nDivX_; // make sure it is multiple of 5
			p.z -= p.z % nDivZ_;
			p.x += nHDivX_;
			p.z += nHDivZ_;
			return p;
		}
		
		public function getSnappedIndex(px:int, pz:int):int {
			var x:uint = (px - (px % nDivX_))/nDivX_; // make sure it is multiple of 5
			var z:uint = (pz - (pz % nDivZ_))/nDivZ_;
			return x * nCutsZ_ + z;
		}
		
		public function getNode(x:int, y:int):Node {
			return mNodes_[getSnappedIndex(x, y)] as Node;
		}
		
		public function getNodeByIdx(idx:uint):Node {
			return mNodes_[idx] as Node;
		}
		
		public function get cutsX():uint {
			return nCutsX_;
		}
		
		public function get cutsZ():uint {
			return nCutsZ_;
		}
		
		public function get divX():uint {
			return nDivX_;
		}
		
		public function get divZ():uint {
			return nDivZ_;
		}
		
		public function get sizeX():uint {
			return nSizeX_;
		}
		
		public function get sizeZ():uint {
			return nSizeZ_;
		}
		
		public function get startIdx():int {
			return nStartIdx_;
		}
		
		public function get endIdx():int {
			return nEndIdx_;
		}
		
		public function get startNode():Node {
			if (nStartIdx_ == -1) return null;
			return mNodes_[nStartIdx_];
		}
		
		public function get endNode():Node {
			if (nEndIdx_ == -1) return null;
			return mNodes_[nEndIdx_];
		}
	}
}