package gates {
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.materials.special.LineMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class StartGate extends DisplayObject3D {
		
		public function StartGate() {
			var lines:Lines3D = new Lines3D();
			lines.addLine(
			  new Line3D(lines, new LineMaterial(0x000f30, 1.0), 2, 
				new Vertex3D( 0, 0, 0 ),
				new Vertex3D( 0, 20, 0 )));
			addChild(lines);
		}
		
	}
	
}