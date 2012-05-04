package  
{
 
	import org.papervision3d.view.BasicView;
 
	import flash.events.Event;
 
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.core.geom.Particles;
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.materials.special.MovieAssetParticleMaterial;	
 
	/**
	 * @author Seb Lee-Delisle
	 */
	public class MovieAssetParticleTest extends BasicView 
	{
		public var particleContainer:DisplayObject3D;
		private var particles : Array; 
 
		public function MovieAssetParticleTest()
		{
			super(stage.stageWidth, stage.stageHeight, false, true);
			init(); 
 
 
		}
 
		private function init():void
		{
 
			particleContainer = new DisplayObject3D("Particle Container");
			particles = new Array(); 
 
			for(var i:int = 0; i<400; i++)
			{
 
				var spm:MovieAssetParticleMaterial = new MovieAssetParticleMaterial("Sphere",true); 
				spm.interactive = true; 
				spm.smooth = true; 
 
				var particles3D:Particles = new Particles("ParticleContainer#"+i);
				var p:Particle = new Particle(spm,2,600,0,0);
 
				particles3D.addParticle(p); 
 
				particles3D.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, particleOver);	
 
				particles3D.rotationY = Math.random()*360; 
				particles3D.rotationZ = Math.random()*180; 
 
 
				particles3D.extra = {spin: 0};
 
				particleContainer.addChild(particles3D); 
				particles.push(particles3D); 
 
			}
 
			scene.addChild(particleContainer); 
 
			singleRender(); 
 
			addEventListener(Event.ENTER_FRAME, frameLoop); 
		}
 
 
 
 
		private function particleOver(e : InteractiveScene3DEvent) : void
		{
			e.displayObject3D.extra["spin"] = 10;
 
		}
 
		function frameLoop(e:Event): void 
		{
 
			particleContainer.rotationY+=((stage.stageWidth/2)-mouseX)/200; 
			particleContainer.rotationX+=((stage.stageHeight/2)-mouseY)/200; 
			var drag:Number = 0.99; 
 
			for(var i:int=0; i<particles .length; i++)
			{
				var p:Particles = particles[i]; 
				var spin:Number = p.extra["spin"]; 
 
				if(spin>0.1)
				{
					p.extra["spin"]*=drag; 
					p.rotationY+=spin; 
 
				}
				else
				{
					p.extra["spin"] = 0; 
				}
 
 
			}
 
 
			singleRender(); 
 
 
		}
	}
}