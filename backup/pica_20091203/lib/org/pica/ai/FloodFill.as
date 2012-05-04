// scanline method of floodfill http://www.student.kuleuven.be/~m0216922/CG/floodfill.html#Recursive_Scanline_Floodfill_Algorithm
package org.pica.ai {
	import org.papervision3d.core.math.Number3D;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class FloodFill {
		
		private var map_:FloodMap;
		private var points_:Array;
		private var startCell_:FloodCell;
		private var pointIdSeed_:uint = 0;
		
		public function FloodFill() {
			map_ = new FloodMap();
			points_ = new Array();
		}
		
		public function build(grid:Grid2D, path:Array):Array {
			map_.construct(grid, path);
			var start:Node = path[path.length - 1] as Node;
			startCell_ = map_.cells[start.index] as FloodCell;
			
			var weights:Array = new Array();
			for each (var cell:FloodCell in map_.cells) {
				weights.push(cell.weight);
			}
			return weights;
		}
		
		public function addPoints(num:uint):Array {
			var comers:Array = new Array();
			var point:FloodPoint;
			var count:uint = num;
			for each (var cell:FloodCell in startCell_.dir) {
trace("addPoint: "+cell.idx);
				if (cell.isUnoccupied()) {
					point = new FloodPoint(++pointIdSeed_, cell.idx);
					cell.occupyBy(point);
					points_.push(point);
					comers.push(point);
					if (count-- == 0)
						break;
				}
			}
			return comers;
		}
		
		public function removePoints(goners:Array):void {
			var i:int;
			for each (var goner:FloodPoint in goners) {
				i = 0;
				for each (var point:FloodPoint in points_) {
					if (point.id == goner.id) {
						map_.cells[goner.homeId].freeup();
						points_.splice(i, 1);
						break;
					}
					++i;
				}
			}
		}
		
		public function step():Array {
			var n:FloodCell, c:FloodCell; // neightbour and current cell
			var dir:Array;
			for each (var point:FloodPoint in points_) {
				if (!point.searching)
					continue;
				c = map_.cells[point.homeId] as FloodCell;
				dir = c.dir;
				for each (n in dir) {
					if (n.isUnoccupied()) {
						c.freeup();
						// make sure end point or wall never get occupier
						// TODO: consider a hack?
						if (n.dir.length != 0)
							n.occupyBy(point);
						point.homeId = n.idx;
						break;
					}
				}
			}
			return points_;
		}
		
		// for testing purpose, actual operation shouldn't require this
		public function getAllDir():Array {
			var map:Array = new Array();
			var dirs:Array;
			var d:FloodCell;
			for each (var cell:FloodCell in map_.cells) {
				dirs = new Array();
				for each (d in cell.dir) {
					dirs.push(d.idx);
				}
				map.push(dirs);
			}
			return map;
		}
		
	}
	
}
import org.pica.ai.Grid2D;
import org.pica.ai.Node;
import org.pica.ai.FloodPoint;

class FloodCell {
	
	static public const WEIGHT_STEP:uint = 10;
	static public const WEIGHT_WALL:uint = 0xffffffff;

	public var idx:uint;
	public var weight:uint;
	public var dir:Array;
	private var occupier_:FloodPoint;
	
	public function FloodCell(idx:uint, weight:uint = FloodCell.WEIGHT_WALL) {
		this.idx = idx;
		this.weight = weight;
		this.dir = new Array();
		this.occupier_ = null;
	}
	
	public function occupyBy(pt:FloodPoint):Boolean {
		if (occupier_ != null)
			return false;
		occupier_ = pt;
		return true;
	}
	
	public function freeup():void {
		occupier_ = null;
	}
	
	public function isUnoccupied():Boolean {
		return occupier_ == null;
	}
}

class FloodMap {
	
	public var cells:Array;
	private var sizeX_:uint;
	private var sizeZ_:uint;
	
	public function FloodMap() {
	}
	
	public function construct(map:Grid2D, path:Array):void {
		// build FloodMap
		cells = new Array();
		sizeX_ = map.cutsX;
		sizeZ_ = map.cutsZ;
		var count:uint = sizeX_ * sizeZ_;
		var i:uint;
		for (i = 0; i < count; ++i) {
			cells.push(new FloodCell(i));
		}
		
		i = 0;
		count = path.length;
		var weight:uint = 0;
		
		// first scan
		var currNode:Node = path[i] as Node;
		var connNode:Node = path[i + 1] as Node;
		scanline(currNode, weight, currNode.x - connNode.x, currNode.z - connNode.z);
		
		// scan for the rest
		while (++i < count) {
			weight+=100;
			currNode = path[i] as Node;
			connNode = path[i - 1] as Node;
			scanline(currNode, weight, currNode.x - connNode.x, currNode.z - connNode.z);
		}
		
		postProcess(map);
		
		calResults(map);
	}
	
	private function scanline(node:Node, weight:uint, dx:int, dz:int):void {
		var neg_x:int, neg_z:int;
		var pos_x:int, pos_z:int;
		if (dx == 0) {
			neg_x = -1;
			pos_x = 1;
			neg_z = pos_z = 0;
		} else if (dz == 0) {
			neg_z = -1;
			pos_z = 1;
			neg_x = pos_x = 0;
		} else {
			neg_x = -dx;
			neg_z = dz;
			pos_x = dx;
			pos_z = -dz;
		}
		
		cells[node.index].weight = weight;
		
		// negative loop
		scanline_ext(node, weight, neg_x, neg_z);
		// positve loop
		scanline_ext(node, weight, pos_x, pos_z);
	}
	
	private function scanline_ext(node:Node, weight:uint, x:int, z:int):void {
		var currNode:Node=node;
		var currWeight:uint = weight;
		while (currNode = currNode.getNeighbour(x, z)) {
			if (currNode == null || !currNode.isWalkable())
				break;
			currWeight += FloodCell.WEIGHT_STEP;
			if (cells[currNode.index].weight > currWeight)
				cells[currNode.index].weight = currWeight;
		}
	}
	
	private function postProcess(map:Grid2D):void {
		var count:uint = cells.length;
		var totalWeight:uint, totalCount:uint;
		var node:Node, n:Node;
		var cell:FloodCell;
		for (var i:uint = 0; i < count; ++i) {
			cell = cells[i] as FloodCell;
			node = map.getNodeByIdx(i);
			if (cell.weight == FloodCell.WEIGHT_WALL && node.type != Node.TYPE_WALL) {
				totalCount = 0;
				totalWeight = 0;
				for (var x:int = 0; x < 4; ++x) {
					n = node.nextStraightNeightbour(x);
					if (n == null || n.type == Node.TYPE_WALL)
						continue;
					totalWeight += cells[n.index].weight;
					++totalCount;
				}
				cell.weight = totalWeight / totalCount;
			}
		}
	}
	
	private function calResults(map:Grid2D):void {
		var count:uint = cells.length;
		var node:Node, n:Node;
		var cell:FloodCell, c:FloodCell;
		var j:uint;
		for (var i:uint = 0; i < count; ++i) {
			cell = cells[i] as FloodCell;
			node = map.getNodeByIdx(i);
			// no dir for wall and end point
			if (node.type == Node.TYPE_WALL || cell.weight==0)
				continue;
			for (j = 0; j < 4; ++j) {
				n = node.nextStraightNeightbour(j);
				if (n == null || n.type == Node.TYPE_WALL)
					continue;
				c = cells[n.index];
				if (c.weight - cell.weight > 99)
					continue;
				cell.dir.push(c);
			}
			for (j = 0; j < 4; ++j) {
				n = node.nextDiagonalNeightbour(j);
				if (n == null || n.type == Node.TYPE_WALL)
					continue;
				c = cells[n.index];
				if (c.weight - cell.weight > 99)
					continue;
				cell.dir.push(c);
			}
			cell.dir.sort(function (a:FloodCell, b:FloodCell):int { if (a.weight < b.weight) return -1; else if (a.weight > b.weight) return 1; return 0; } );
		}
	}
	
	private function getWeight(x:int, z:int):uint {
		if (x < 0 || x >= sizeX_) return FloodCell.WEIGHT_WALL;
		if (z < 0 || z >= sizeZ_) return FloodCell.WEIGHT_WALL;
		
		return cells[getIndex(x, z)].weight;
	}
	
	private function getIndex(x:int, z:int):uint {
		return x * sizeZ_ + z;
	}
}