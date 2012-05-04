package org.pica.graphics.ui {
	import flash.display.Graphics;
	import flash.display.Sprite;
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.special.LineMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.DisplayObject3D;
	import org.pica.utils.Constant;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Coordinate3D {
		
		public function Coordinate3D() {
			
		}
		
		/// @param size size of the ground
		/// @param count line count
		public static function generateFloor(size:uint, count:uint):DisplayObject3D {
			var hsize:Number = size / 2;
			var dv:Number = size / count;
			var lines:Lines3D = new Lines3D();
			var mat:LineMaterial = new LineMaterial(0xffffff, 0.5);
			var weight:Number = 1;
			
			var cur:Number;
			for (var i:uint; i < count+1; ++i) {
				cur = hsize - (dv * i);
				lines.addLine(
				  new Line3D(lines, mat, weight, 
				    new Vertex3D( cur, 0, hsize ),
					new Vertex3D( cur, 0, -hsize )));
				lines.addLine(
				  new Line3D(lines, mat, weight, 
				    new Vertex3D( hsize, 0, cur ),
					new Vertex3D( -hsize, 0, cur )));
			}
			
			// plane is using interactive material
			var sprite:Sprite = new Sprite();
			var g:Graphics = sprite.graphics;
			
			g.beginFill(0xffffff, 0.1);
			g.drawRect(0, 0, size, size);
			g.endFill();
			
			// material's animate param must set to true for decal to work
			var movieMat:MovieMaterial = new MovieMaterial(sprite, true, true, false);
			movieMat.interactive = true;
			
			var plane:Plane = new Plane(movieMat, size, size, count);
			plane.pitch(90);// Constant.RAD_90);
			
			lines.addChild(plane);
			return lines;
		}
		
		public static function generateDatum(size:uint):DisplayObject3D {
			var hsize:uint = size/2;
			var lines:Lines3D = new Lines3D();
			var xmat:LineMaterial = new LineMaterial(0xff0000, 1.0);
			var ymat:LineMaterial = new LineMaterial(0x00ff00, 1.0);
			var zmat:LineMaterial = new LineMaterial(0x0000ff, 1.0);
			var weight:Number = 2;
			
			lines.addLine(
			  new Line3D(lines, xmat, weight, 
				new Vertex3D( 0, 0, 0 ),
				new Vertex3D( hsize, 0, 0 )));
			lines.addLine(
			  new Line3D(lines, ymat, weight, 
				new Vertex3D( 0, 0, 0 ),
				new Vertex3D( 0, hsize, 0 )));
			lines.addLine(
			  new Line3D(lines, zmat, weight, 
				new Vertex3D( 0, 0, 0 ),
				new Vertex3D( 0, 0, hsize )));
			return lines;
		}
		
	}
	
}