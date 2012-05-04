package bots {
	import org.pica.utils.Constant;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Cylinder;
	import wisps.Boss;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class BasicBot extends DisplayObject3D {
		
		static private const PERIOD_:uint = 5; // 5 sec
		private var period_:uint = 0;
		private var elapsed_:uint = 0;
		private var range_:Number;
		
		private var turret_:DisplayObject3D;
		private var base_:DisplayObject3D;
		private var lookat_:Number = 0;
		
		private var data_:BotData;
		private var bullets_:Bullets;
		
		public function BasicBot(data:BotData, bullets:Bullets) {
			data_ = data;
			bullets_ = bullets;
			
			period_ = Math.ceil((PERIOD_ * Constant.FPS) / data.speed);
			elapsed_ = 0;
			range_ = data.range * data_.range;
			
			var mat:MaterialsList;
			mat = new MaterialsList( { all: new ColorMaterial(0x00ff00) } );
			base_ = new Cube(mat, 10, 10, 2);
			turret_ = new Cylinder(new ColorMaterial(0xff0000), 2.5, 12, 6, 1, -1, false, false);
			turret_.pitch(90);// Constant.RAD_90);
			turret_.roll(lookat_);
			turret_.position = new Number3D(0, 5, 0);
			addChild(base_);
			addChild(turret_);
		}
		
		public function update(creeps:Array, bots:Array):void {
			if (creeps.length == 0) return;
			var creep:DisplayObject3D = getTarget(creeps);
			if (creep == null) return;
			
			var dx:Number = creep.x - this.x;
			var dz:Number = creep.z - this.z;
			var deg:Number = - Math.atan2(dx, dz);	// funny actionscript and papervision convention are opposite
			turret_.roll(Constant.RAD_2_DEG*(deg - lookat_));
			lookat_ = deg;
			
			if (++elapsed_ > period_) {
				elapsed_ = 0;
				shoot();
			}
		}
		
		public function shoot():void {
			var r:Number = data_.range;
			var c:Number = Math.cos(lookat_);
			var s:Number = -Math.sin(lookat_);
			var target:Number3D = new Number3D(r * s + this.x, turret_.y, r * c + this.z);
			var source:Number3D = new Number3D(5 * s + this.x, turret_.y, 5 * c + this.z);
			var spec:Object = new Object;
			spec.damage = data_.damage;
			bullets_.shoot(source, target, spec);
		}
		
		private function getTarget(creeps:Array):DisplayObject3D {
			var dx:Number;
			var dz:Number;
			for each (var bot:DisplayObject3D in creeps) {
				dx = bot.x - this.x;
				dz = bot.z - this.z;
				if (dx * dx + dz * dz < range_) {
					return bot;
				}
			}
			
			return null;
		}
		
	}
	
}