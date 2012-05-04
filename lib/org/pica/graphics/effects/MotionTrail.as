// adapted from http://blog.zupko.info/?p=264
package org.pica.graphics.effects {
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.math.NumberUV;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Sphere;

	
	public class MotionTrail extends TriangleMesh3D	{
		
		private var iterations : int;
		private var invIterations:Number;
		private var target : DisplayObject3D;
		private var nodes : Array = [];
		public var maxWidth : Number;
		public var maxSpeed : Number;
		private var testViz : Array = [];
		public var  minEase  : Number;
		
		// maxWidth = thinkness of the trail
		public function MotionTrail(bd:BitmapData, target:DisplayObject3D, iterations:int = 10, maxWidth:Number = 40, maxSpeed:Number = 40, minEase:Number = 0.05) {
			var mat:BitmapMaterial = new BitmapMaterial(bd);
			super(mat, null, null, null);
			this.target = target;
			this.iterations = iterations;
			this.invIterations = 1.0 / iterations;
			mat.doubleSided = true;
			
			this.maxWidth = maxWidth;
			this.maxSpeed = maxSpeed * maxSpeed;
			this.minEase = minEase;
			
			buildTrailMesh();
		}
		
		public static function createGradientTexture(size:Number, type:String, colors:Array, alphas:Array, ratios:Array):BitmapData{
			
			var mat:Matrix = new Matrix();
			mat.createGradientBox(size, size);
			
			var s:Sprite = new Sprite();
			s.graphics.beginGradientFill(type, colors, alphas, ratios, mat);
			s.graphics.drawRect(0, 0, size, size);
			s.graphics.endFill();
			
			var bd:BitmapData = new BitmapData(size, size, true, 0);
			bd.draw(s);
			return bd;
		}
		
		public function resetTo(x:Number, y:Number, z:Number):void {
			for each (var n:TrailNode in nodes) {
				n.x = x; n.y = y; n.z = z;
			}
		}
		
		public override function project(parent:DisplayObject3D, renderSessionData:RenderSessionData):Number {
			// updateTrail
			if(target) {
				var i:int = 0;
				var v1:Vertex3D, v2:Vertex3D;
				var tSpeed:Number, dx:Number, dy:Number, dz:Number;
				for each (var n:TrailNode in nodes) {
					// update control nodes
					if (i) chase(nodes[i - 1], nodes[i]);
					else chase(new Number3D(target.x, target.y, target.z), nodes[0]);
				
					// update trails
					v1 = this.geometry.vertices[i*2];
					v2 = this.geometry.vertices[i*2+1];
					n.nodeVector.reset(world.n12, world.n22, world.n32);
					tSpeed = (1 - i * invIterations) * maxWidth;
					dx = n.nodeVector.x * tSpeed; dy = n.nodeVector.y * tSpeed; dz = n.nodeVector.z * tSpeed;
					v1.x = n.x + dx;
					v1.y = n.y + dy;
					v1.z = n.z + dz;
					v2.x = n.x - dx;
					v2.y = n.y - dy;
					v2.z = n.z - dz;
					++i;
				}
			}
			return super.project(parent, renderSessionData);
		}
		
		private function chase(node1:Number3D, node2:TrailNode):void{
			node2.dx = (node1.x-node2.x)*node2.spring;
			node2.dy = (node1.y-node2.y)*node2.spring;
			node2.dz = (node1.z-node2.z)*node2.spring;
			node2.updateNode();
		}
			
		private function buildTrailMesh():void{
			var gridX    :Number = iterations-1;
			var gridY    :Number = 1;
			var gridX1   :Number = gridX + 1;
			var gridY1   :Number = gridY + 1;
	
			var vertices :Array  = this.geometry.vertices;
			var faces    :Array  = this.geometry.faces;
	
			var textureX :Number = 1;
			var textureY :Number = 1;
	
			var iW       :Number = 1 / gridX;
			var iH       :Number = 1 / gridY;
	
			// Vertices
			var x:Number, y:Number;
			for( var ix:int = 0; ix < gridX1; ++ix ) {
				for( var iy:int = 0; iy < gridY1; ++iy ) {
					x = ix * iW - textureX;
					y = iy * iH - textureY;
	
					vertices.push( new Vertex3D( x, y, 0 ) );
				}
			}
	
			// Faces
			var uvA:NumberUV, uvC:NumberUV, uvB :NumberUV;
			var a:Vertex3D, b:Vertex3D, c:Vertex3D;
	
			for(  ix = 0; ix < gridX; ++ix ) {
				for(  iy= 0; iy < gridY; ++iy ) {
					// Triangle A
					a = vertices[ ix     * gridY1 + iy     ];
					c = vertices[ ix     * gridY1 + (iy+1) ];
					b = vertices[ (ix+1) * gridY1 + iy     ];
	
					uvA =  new NumberUV( ix     / gridX, iy     / gridY );
					uvC =  new NumberUV( ix     / gridX, (iy+1) / gridY );
					uvB =  new NumberUV( (ix+1) / gridX, iy     / gridY );
	
					faces.push(new Triangle3D(this, [ a, b, c ], material, [ uvA, uvB, uvC ] ) );
	
					// Triangle B
					a = vertices[ (ix+1) * gridY1 + (iy+1) ];
					c = vertices[ (ix+1) * gridY1 + iy     ];
					b = vertices[ ix     * gridY1 + (iy+1) ];
	
					uvA =  new NumberUV( (ix+1) / gridX, (iy+1) / gridY );
					uvC =  new NumberUV( (ix+1) / gridX, iy     / gridY );
					uvB =  new NumberUV( ix     / gridX, (iy+1) / gridY );
					
					faces.push(new Triangle3D(this, [ a, b, c ], material, [ uvA, uvB, uvC ] ) );
				}
			}

			//build the nodes, starting nodes r at the same spot
			for(var i : int = 0;i<iterations;++i) {
				nodes.push(new TrailNode(target.x, target.y, target.z, ((iterations - i) * invIterations * (1 - minEase)) + minEase));
				testViz.push(new Sphere(null, 20, 2, 2));
			}
			
			this.geometry.ready = true;
		}
		
	}
}

import org.papervision3d.core.math.Number3D;
	

internal class TrailNode extends Number3D{
	
	public var spring : Number = 1;
	public var nodeVector : Number3D = new Number3D(0, 1, 0);
	public var dx : Number;
	public var dy : Number;
	public var dz : Number;
	
	public function TrailNode(x:Number = 0, y:Number = 0, z:Number = 0, spring : Number = 1){
		super(x, y, z);
		this.spring = spring;
	}
	
	public function updateNode():void{
		x += dx;
		y += dy;
		z += dz;
	}
	
}