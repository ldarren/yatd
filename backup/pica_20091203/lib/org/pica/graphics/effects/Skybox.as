// adapted from http://blog.projectnibble.org/2009/05/22/easy-papervision3d-skybox-tutorial-and-source/
package org.pica.graphics.effects {
	import flash.display.Bitmap;
    import org.papervision3d.materials.BitmapMaterial;  
    import org.papervision3d.materials.utils.MaterialsList;  
    import org.papervision3d.objects.primitives.Cube;  
  
    public class Skybox extends Cube {  
  
        public static const QUALITY_LOW:Number = 4;  
        public static const QUALITY_MEDIUM:Number = 6;  
        public static const QUALITY_HIGH:Number = 8;  
  
        public function Skybox(bf:Bitmap, bl:Bitmap, bb:Bitmap, bu:Bitmap, br:Bitmap, bd:Bitmap, skysize:Number, quality:Number):void {  
            var materials:MaterialsList = new MaterialsList();  
            if (bf) materials.addMaterial(new BitmapMaterial(bf.bitmapData), "front");  
            if (bl) materials.addMaterial(new BitmapMaterial(bl.bitmapData), "left");  
            if (bb) materials.addMaterial(new BitmapMaterial(bb.bitmapData), "back");  
            if (bu) materials.addMaterial(new BitmapMaterial(bu.bitmapData), "top");  
            if (br) materials.addMaterial(new BitmapMaterial(br.bitmapData), "right");  
            if (bd) materials.addMaterial(new BitmapMaterial(bd.bitmapData), "bottom");  
            
			for each (var material:BitmapMaterial in materials.materialsByName) {  
                material.opposite = true;  
            }    
            super(materials, skysize, skysize, skysize, quality, quality, quality);  
			
			//geometry.flipFaces(); // now you can only see the box from the inside...  
        }  
    }  
}  