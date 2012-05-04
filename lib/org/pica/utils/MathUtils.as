// taken from http://sourceforge.net/projects/papervisiontut/files/Papervision%20Tutorials/Billboards/
package org.pica.utils {
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	public final class MathUtils {
		public static function matrix3DPosition( matrix:Matrix3D ) : Number3D {
			return new Number3D(matrix.n14, matrix.n24, matrix.n34)
		}
		
		public static function distanceToSquaredNumber3D( obj1:Number3D, obj2:Number3D ):Number	{
			var x :Number = obj1.x - obj2.x;
			var y :Number = obj1.y - obj2.y;
			var z :Number = obj1.z - obj2.z;
	
			return x*x + y*y + z*z;
		}
		
		public static function distanceToNumber3D( obj1:Number3D, obj2:Number3D ):Number {
			var x :Number = obj1.x - obj2.x;
			var y :Number = obj1.y - obj2.y;
			var z :Number = obj1.z - obj2.z;
	
			return Math.sqrt( x*x + y*y + z*z );
		}
		
		public static function distanceToMatrix3D( obj1:Matrix3D, obj2:Matrix3D ):Number {
			return distanceToNumber3D(matrix3DPosition(obj1), matrix3DPosition(obj2));
		}
		
		public static function translate( transform:Matrix3D, distance:Number, axis:Number3D ):Number3D	{
			var vector:Number3D = axis.clone();
	
			Matrix3D.rotateAxis( transform, vector );
	
			return new Number3D(
				transform.n14 + distance * vector.x,
				transform.n24 + distance * vector.y,
				transform.n34 + distance * vector.z);
		}
		
		public static function randomInt(min:int, max:int):int {
			return int(Math.round(Math.random() * (max - min) + min));
		}
		
		public static function randomNumber(min:Number, max:Number):Number {
			return Math.random() * (max - min) + min;
		}
		
		public static function getPosition(obj:DisplayObject3D):Number3D {
			return new Number3D(obj.x, obj.y, obj.z);
		}
		
		public static function setPosition(val:Number3D, obj:DisplayObject3D):void	{
			obj.x = val.x;
			obj.y = val.y;
			obj.z = val.z;
		}
		
		public static function number3DMultiply(vec:Number3D, mult:Number):Number3D	{
			var returnValue:Number3D = new Number3D(vec.x, vec.y, vec.z);
			returnValue.multiplyEq(mult);
			return returnValue;
		}
		
		// An efficient copy and transpose function (which is also equivalent to an inversion)
       	public static function copyAndTranspose(a:Matrix3D, b:Matrix3D, NoTrans:Boolean=false):void  {
			b.n11 = a.n11;      b.n12 = a.n21;    b.n13 = a.n31;
			b.n21 = a.n12;      b.n22 = a.n22;    b.n23 = a.n32;    
			b.n31 = a.n13;      b.n32 = a.n23;    b.n33 = a.n33;    
			b.n41 = a.n14;      b.n42 = a.n24;    b.n43 = a.n34;
              
			if (!NoTrans) 
			{
				b.n14 = a.n41;
				b.n24 = a.n42;
				b.n34 = a.n43;
				b.n44 = a.n44;
          	}
       	}
	}
}