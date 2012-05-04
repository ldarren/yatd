package wisps {
	
	import bots.Bullets;
	import org.papervision3d.core.geom.renderables.Particle;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public interface IWisp {
		
		function start(path:Array, onGoal:Function):void;
		function changePath(path:Array):void;
		function update(bullet_type:Bullets, bullets:Array):void;
		function damage(d:Number, s:Particle):void;
		function isAlive():Boolean;
	}
	
}