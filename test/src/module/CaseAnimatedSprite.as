package module {
	import flash.events.Event;
	import org.pica.graphics.effects.SpriteGroup;
	import org.pica.graphics.loader.Object2D;
	import org.pica.graphics.Renderer;
	import org.pica.utils.Random;
	import org.papervision3d.core.math.Number3D;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class CaseAnimatedSprite implements ICase {
		
		public static const ID:String = Test.CASE_GFX_ANIMATED_SPRITE;
		private var particles_:SpriteGroup;
		private var bmp_:Object2D;
		
		public function CaseAnimatedSprite() {
			bmp_ = new Object2D("Plasma");
			bmp_.load("../../res/particles/PlasmaWisp.png", 54, 54, onLoaded, 0xFF0184ff);
			
			particles_ = new SpriteGroup("test_animated_sprites");
		}
		
		public function load(gfx:Renderer):void {
			gfx.setCameraPos(new Number3D(0, 0, -100));

			//gfx.addOverlay(bmp_);
			gfx.addObj(particles_);
		}
		
		public function unload(gfx:Renderer):void {
			gfx.removeObj(particles_);
			//gfx.removeOverlay(bmp_);
		}
		
		public function onEvent(evt:Event):void {
		}
		
		public function onUpdate():void {
			//bmp_.animate();
			particles_.animate(67);
			particles_.yaw(1);
		}
		
		private function onLoaded(bmp:Object2D):void {
			bmp.addAnimation("idle", { start:0, end:4, fps:5 } );
			bmp.play("idle");
			particles_.init(bmp, 100);
			
			for (var i:uint = 0; i < 100; ++i) {
				particles_.createSprite(Random.between(-100, 100),Random.between(-100, 100),Random.between(0, 100));
			}
		}
		
	}
	
}
