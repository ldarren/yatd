// taken from http://sourceforge.net/projects/papervisiontut/files/Papervision%20Tutorials/Billboards/
package org.pica.graphics.effects {
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.math.Matrix3D;
	import org.pica.utils.MathUtils;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class BillBoard extends Plane {
		
		public var frame:uint = 0;
		public var elapsed:uint = 0;
		
		public function BillBoard(material:MaterialObject3D = null, width:Number = 0, height:Number = 0, segmentsW:Number = 0, segmentsH:Number = 0) {
			super(material, width, height, segmentsW, segmentsH);
		}
		
		// This is basically a lookAt function, and is capable of handling thousands of sprites/particles without breaking a sweat
		// This also handles any level of DO3D nesting, and plays 100% by the rules of Papervision projection.
		public override function project( parent:DisplayObject3D,  renderSessionData:RenderSessionData):Number {
			MathUtils.copyAndTranspose(parent.world, transform, true);   // Perform the inversion, while also handling nested chains of DO3D
			transform.calculateMultiply3x3(transform, renderSessionData.camera.transform);
			return super.project(parent, renderSessionData);
		}
		
	}
	
}