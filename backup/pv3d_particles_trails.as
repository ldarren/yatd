package  
{
   import org.papervision3d.core.effects.BitmapColorEffect;
   import org.papervision3d.core.effects.BitmapLayerEffect;
   import org.papervision3d.core.geom.Particles;
   import org.papervision3d.materials.WireframeMaterial;
   import org.papervision3d.materials.utils.MaterialsList;
   import org.papervision3d.objects.DisplayObject3D;
   import org.papervision3d.objects.primitives.Cube;
   import org.papervision3d.view.AbstractView;
   import org.papervision3d.view.BasicView;
   import org.papervision3d.view.layer.BitmapEffectLayer;
   
   import flash.display.StageQuality;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.filters.BlurFilter;
   import flash.geom.Point;      

   /**
    * @author Kelvin Luck
    */
   [SWF(width='450', height='450', backgroundColor='#000000', frameRate='41')]

   public class ParticlesCube extends BasicView 
   {
      
      public static const NUM_PARTICLES:int = 300;
      public static const CONTAINING_CUBE_SIZE:int = 500;
      
      public static const RENDER_MODE_CLEAN:int = 0;
      public static const RENDER_MODE_TRAILS:int = 1;
      public static const RENDER_MODE_FALLING:int = 2;
      
      private var particlesContainer:DisplayObject3D;
      private var particlesHolder:Particles;
      private var particles:Array;
      private var boundsCube:Cube;

      private var bfx:BitmapEffectLayer;
      
      private var _renderMode:int;
      public function set renderMode(value:int):void
      {
         if (value == _renderMode) return;
         
         clearBitmapEffects();
         
         var clippingPoint:Point = new Point();
         
         switch (value) {
            case RENDER_MODE_CLEAN:
               // nothing - effects already cleared above...
               break;
            case RENDER_MODE_FALLING:
               clippingPoint.y = -2;
               // fall through...
            case RENDER_MODE_TRAILS:
               bfx = new BitmapEffectLayer(viewport, stage.stageWidth, stage.stageHeight, true, 0xffffff);
               
               bfx.addEffect(new BitmapLayerEffect(new BlurFilter(2, 2, 2)));
               bfx.addEffect(new BitmapColorEffect(1, 1, 1, .9));
               
               bfx.clippingPoint = clippingPoint;
               
               bfx.addDisplayObject3D(particlesHolder);
               
               viewport.containerSprite.addLayer(bfx);
               break;
            default:
               throw new Error(value + ' is an invalid render mode');
         }
         _renderMode = value;
      }
      
      private var _displayCube:Boolean = true;
      public function set displayCube(value:Boolean):void
      {
         if (value != _displayCube) {
            _displayCube = value;
            boundsCube.visible = value;
         }
      }

      public function ParticlesCube()
      {
         super(550, 550);
         
         stage.quality = StageQuality.MEDIUM;
         
         particlesContainer = new DisplayObject3D();
         scene.addChild(particlesContainer);
         
         var cubeMaterial:WireframeMaterial = new WireframeMaterial(0x0000ff, 1, 2);
         var materialsList:MaterialsList = new MaterialsList();
         materialsList.addMaterial(cubeMaterial, 'all');
         
         boundsCube = new Cube(materialsList, CONTAINING_CUBE_SIZE, CONTAINING_CUBE_SIZE, CONTAINING_CUBE_SIZE);
         particlesContainer.addChild(boundsCube);
         displayCube = false;
         
         particlesHolder = new Particles();
         particlesContainer.addChild(particlesHolder);
         
         init(NUM_PARTICLES, CONTAINING_CUBE_SIZE);
         
         stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
         
         startRendering();
      }

      public function init(numParticles:int, containingCubeSize:int):void
      {
         var movingParticle:MovingParticle;
         
         if (particles) {
            particlesHolder.removeAllParticles();
         }
         
         particles = [];
         
         var i:int = numParticles;
         while (i--) {
            movingParticle = new MovingParticle(containingCubeSize);
            particlesHolder.addParticle(movingParticle);
            particles.push(movingParticle);
         }
         
      }

      override protected function onRenderTick(event:Event = null):void
      {
         // move each particle
         var movingParticle:MovingParticle;
         for each (movingParticle in particles) {
            movingParticle.position();
         }
         
         // twist the container based on mouse position
         particlesContainer.rotationY+=((stage.stageWidth/2)-mouseX)/200; 
         particlesContainer.rotationX+=((stage.stageHeight/2)-mouseY)/200;
         
         // render
         super.onRenderTick(event);
      }
      
      private function clearBitmapEffects():void
      {
         if (bfx) {
            viewport.containerSprite.removeLayer(bfx);
            bfx = null;
         }
      }
      
      private function onKeyDown(event:KeyboardEvent):void
      {
         switch (String.fromCharCode(event.keyCode)) {
            case '1':
               renderMode = RENDER_MODE_CLEAN;
               break;
            case '2':
               renderMode = RENDER_MODE_TRAILS;
               break;
            case '3':
               renderMode = RENDER_MODE_FALLING;
               break;
            case 'c':
            case 'C':
               displayCube = !_displayCube;
               break;
         }
      }
   }
}

import org.papervision3d.core.geom.renderables.Particle;
import org.papervision3d.materials.special.ParticleMaterial;

internal class MovingParticle extends Particle 
{
   
   public static const PARTICLE_SIZE:int = 10;
   public static const MAX_SPEED:int = 5;
   
   private var dX:Number;
   private var dY:Number;
   private var dZ:Number;
   private var halfSize:Number;

   public function MovingParticle(containingCubeSize:int)
   {
      var mat:ParticleMaterial = new ParticleMaterial(0xff0000, 1, ParticleMaterial.SHAPE_CIRCLE);
      super(mat, PARTICLE_SIZE);
      
      var size:int = containingCubeSize;
      halfSize = size / 2;
      
      x = (Math.random() * size) - halfSize;
      y = (Math.random() * size) - halfSize;
      z = (Math.random() * size) - halfSize;
      
      dX = Math.random() * MAX_SPEED;
      dY = Math.random() * MAX_SPEED;
      dZ = Math.random() * MAX_SPEED;
      
   }
   
   public function position():void
   {
      x += dX;
      if (x > halfSize || x < -halfSize) dX *= -1;
      y += dY;
      if (y > halfSize || y < -halfSize) dY *= -1;
      z += dZ;
      if (z > halfSize || z < -halfSize) dZ *= -1;
   }
}
// This line is just to stop the code formatter on my blog getting confused! >