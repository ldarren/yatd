package org.pica.graphics.effects {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.materials.MovieMaterial;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Decal extends Sprite {
		
		private var host_:DisplayObject3D;
		private static const prefix_:String = "_pcc"; // pica_cast_clip
		
		public function Decal(id:String, host:DisplayObject3D, alpha:Number=1) {
			var movie:Sprite = Sprite(MovieMaterial(host.material).movie);
			this.name = prefix_ + id;
			this.scrollRect = new Rectangle(0, 0, movie.width, movie.height);
			this.alpha = alpha;
			movie.addChild(this);
		}
		
		public function clear():void {
			this.graphics.clear();
		}
		
		public function drawCircle():void {
			
		}
		
		public function drawSquare(x:Number, y:Number, hw:Number, hh:Number, color:int):void {
			var tl_x:Number = x - hw;
			var tl_y:Number = y + hh;
			var br_x:Number = x + hw;
			var br_y:Number = y - hh;
			
			var g:Graphics = this.graphics;
			g.beginFill(color);
			g.moveTo(tl_x, tl_y);
			g.lineTo(tl_x, br_y); 
			g.lineTo(br_x, br_y);
			g.lineTo(br_x, tl_y);
			g.endFill();
		}
		
		public function drawBitmap():void {
			
		}
		
		// draw text is only useful if castclip size bigger or equal to 50px x 50px
		public function drawText(name:String, text:String, x:Number=0, y:Number=0, half_width:Number=0, half_height:Number=0):void {
			var txtField:TextField = getChildByName(this.name + name) as TextField;
			if (txtField == null) {
				txtField = new TextField();
				var f:TextFormat = new TextFormat("Arial", 12, 0x000000);
				f.align = TextFormatAlign.CENTER;
				
				txtField.name = this.name + name;
				txtField.defaultTextFormat = f;
				txtField.antiAliasType = AntiAliasType.ADVANCED;
				
				txtField.width = half_width*2;
				txtField.height = half_height*2;
				txtField.x = x - half_width;
				txtField.y = y - half_height;

				addChild(txtField);
			} 
			
			txtField.text = text;
			
		}
		
		// TODO: any use?
		public static function getCastClip(id:String, host:DisplayObject3D):Sprite {
			
			var hostMovie:Sprite = Sprite(MovieMaterial(host.material).movie);
			var sprite:Sprite = hostMovie.getChildByName(Decal.prefix_ +id) as Sprite;
			if(sprite != null)
				return sprite;
			else {
				var castClip:Sprite = new Sprite();
				castClip.name = Decal.prefix_+id;
				castClip.scrollRect = new Rectangle(0, 0, hostMovie.width, hostMovie.height);
				castClip.alpha = 0.4;
				hostMovie.addChild(castClip);
				return castClip;
			}
		}
		
	}
	
}