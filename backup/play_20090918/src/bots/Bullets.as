package bots {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import org.papervision3d.core.data.UserData;
	import org.papervision3d.core.geom.Particles;
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.special.BitmapParticleMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.pica.animators.Animator;
	import org.pica.utils.Random;
	import wisps.IWisp;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Bullets extends Particles {
		
		[Embed(source = "D:/SmartFlex/pica/res/particles/bubble.png")]
		private var BubleBitmapClass:Class;
		
		private var particles_:Array;
		
		private var radius_:Number;
      
		private var noBlurBullet:BitmapData;
		private var ltBlurBullet:BitmapData;
		private var medBlurBullet:BitmapData;
		private var heavyBlurBullet:BitmapData;
		
		public function Bullets(size:uint) {
			super("bullets_holder");
			
			//createBullets();
			var bmp:Bitmap = new BubleBitmapClass();
			
			particles_ = new Array();
			
			var i:int = -1;
			var p:Particle;
			var bpm:BitmapParticleMaterial;
			while(++i<size) {
				bpm = new BitmapParticleMaterial(bmp.bitmapData , 1, -bmp.bitmapData.width * 0.5, -bmp.bitmapData.height * 0.5); 
				bpm.smooth = true;
				p = new Particle(bpm, 0.05);
 
				particles_.push(p); 
			}
			
			radius_ = 5 * 5;
		}
		
		public function shoot(from:Number3D, to:Number3D, spec:Object):void {
			var p:Particle = particles_.pop() as Particle;
			p.x = from.x;
			p.y = from.y;
			p.z = from.z;
			p.userData = new UserData(spec);
			this.addParticle(p);
			Animator.shoot(p, from, to, null, onDone);
		}
		
		// s: sub component of a swarm
		public function hit(p:Particle, c:IWisp, s:Particle=null):void {
			Animator.stop(p);
			c.damage(p.userData.data.damage, s);
			onDone(p);
		}
		
		public function get radius():Number {
			return radius_;
		}

		private function createBullets():void {
			var lightBlur:BlurFilter = new BlurFilter(4, 4, 1);
			var medBlur:BlurFilter = new BlurFilter (8, 8, 1);
			var heavyBlur:BlurFilter = new BlurFilter(16, 16, 1);

			var type:String = GradientType.RADIAL;
			var colors:Array = [0xffffff, 0xffffff, 0xffffff];
			var alphas:Array = [1, .1, 0];
			var ratios:Array = [0, 200, 255];
			var mat:Matrix = new Matrix();
			mat.createGradientBox(10, 10);

			var baseFlake:Sprite = new Sprite();
			baseFlake.graphics.beginGradientFill(type, colors, alphas, ratios, mat);
			baseFlake.graphics.drawCircle(5, 5, 5);
			baseFlake.graphics.endFill();

			noBlurBullet = new BitmapData(10, 10, true, 0x00000000);
			noBlurBullet.draw(baseFlake);

			ltBlurBullet = new BitmapData(10, 10, true, 0x00000000);
			ltBlurBullet.draw(baseFlake);
			ltBlurBullet.applyFilter(ltBlurBullet, baseFlake.getBounds(baseFlake), new Point(), lightBlur);

			medBlurBullet = new BitmapData(10, 10, true, 0x00000000);
			medBlurBullet.draw(baseFlake);
			medBlurBullet.applyFilter(medBlurBullet, baseFlake.getBounds(baseFlake), new Point(), medBlur);

			heavyBlurBullet = new BitmapData(10, 10, true, 0x00000000);
			heavyBlurBullet.draw(baseFlake);
			heavyBlurBullet.applyFilter(heavyBlurBullet, baseFlake.getBounds(baseFlake), new Point(), heavyBlur);
		}
		
		private function onDone(p:Particle):void {
			this.removeParticle(p);
			particles_.push(p);
		}
		
	}
	
}