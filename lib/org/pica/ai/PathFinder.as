package org.pica.ai {
	public class PathFinder {
		
		private var mGrid_:Grid2D;
		private var mClosed_:Array;
		private var mOpen_:Array;
		private var mPath_:Array;
		private var mStartNode_:Node;
		private var mEndNode_:Node;
		
		public function PathFinder() {
		}
		
		public function setup(grid:Grid2D):Boolean {
			return reset(grid);
		}
		
		public function reset(grid:Grid2D):Boolean {
			if (grid == null) return false;
				
			mGrid_ = grid;
			mGrid_.resetCosts();
			mStartNode_ = mGrid_.startNode;
			mEndNode_ = mGrid_.endNode;
			
			if (mStartNode_ == null || mEndNode_ == null) return false;
			
			mClosed_ = new Array();
			mOpen_ = new Array();
			mPath_ = new Array();
			
			return true;
		}
		
		public function search():Array {
			if (mGrid_ == null || mStartNode_ == null || mEndNode_ == null)
				return new Array();
trace("start: "+mStartNode_.index+" end: "+mEndNode_.index);
			var found:Boolean = false;
			var currNode:Node;
			var cornerTest:Array = new Array(0, 0, 0, 0);
			var i:uint, j:uint;
			
			// 1) Add the starting square (or node) to the open list.
			addToOpenList(mStartNode_, null);
			
			// 2) Repeat the following:
			while (!found ) {
				
				// b) Switch it to the closed list.
				currNode = mOpen_.pop() as Node;
				if (addToClosedList(currNode)) {
					// Stop when you:
					// i) Add the target square to the closed list, in which case the path has been found (see note below), or
					found = true;
					break;
				}
				
				// c) For each of the 8 squares adjacent to this current square
				j = 3;
				for (i = 0; i < 4; ++i) {
					// If it is not walkable or if it is on the closed list, ignore it. Otherwise do the following.
					if (evaluate(currNode.nextStraightNeightbour(i), currNode)) {
						++cornerTest[j];
						++j;
						if (j >= 4) j = 0;
						++cornerTest[j];
					} else {
						++j;
						if (j >= 4) j = 0;
					}
				}
				for (i = 0; i < 4; ++i) {
					// If it is not walkable or if it is on the closed list, ignore it. Otherwise do the following.
					if (cornerTest[i] == 2)
						evaluate(currNode.nextDiagonalNeightbour(i), currNode);
					cornerTest[i] = 0;
				}
				
				// Stop when you:
				if (mOpen_.length == 0) {
					return new Array();
				}

				// a) Look for the lowest F cost square on the open list. We refer to this as the current square.
				mOpen_.sort(function(a:Node, b:Node):Number { if (a.costF > b.costF) return -1; else if (a.costF < b.costF) return 1; else return 0; } );
			}
			
			// 3) Save the path. Working backwards from the target square, 
			// go from each square to its parent square until you reach the starting square. That is your path.
			//currNode = mEndNode_.parent;
			while (currNode != null) {
trace("Path: "+currNode.index);
				mPath_.push(currNode);
				currNode = currNode.parent;
			}
			
			return mPath_;
		}
		
		private function addToOpenList(n:Node, curr:Node):void {
			n.status = Node.STAT_OPEN;
			n.parent = curr;
			mOpen_.push(n);
		}
		
		private function addToClosedList(n:Node):Boolean {
			n.status = Node.STAT_CLOSE;
			mClosed_.push(n);
			if (n.index == mEndNode_.index)
				return true;
			return false;
		}
		
		private function evaluate(n:Node, curr:Node):Boolean {
			if (n != null && n.isWalkable() && !n.isClosed()) {
				if (n.isOpen()) {
					// If it is on the open list already, check to see if this path to that square is better, 
					// using G cost as the measure. A lower G cost means that this is a better path. 
					// If so, change the parent of the square to the current square, and recalculate the G and F scores of the square. 
					// If you are keeping your open list sorted by F score, you may need to resort the list to account for the change.
					if (n.costCompAndSaveIfLower(curr, mEndNode_))
						n.parent = curr;
				} else {
					// If it isn’t on the open list, add it to the open list. Make the current square the parent of this square. 
					// Record the F, G, and H costs of the square.
					n.costCalAndSave(curr, mEndNode_);
					addToOpenList(n, curr);
				}
			}
			return n == null ? false : n.isWalkable(); 
		}
	}
}