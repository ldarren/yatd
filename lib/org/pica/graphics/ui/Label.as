package org.pica.graphics.ui {

	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Label extends TextField {
		
		
		public function Label(name:String, text:String, x:Number, y:Number, width:Number, height:Number, align:String = TextFormatAlign.LEFT) {
			
			var format:TextFormat = new TextFormat("Arial", 12, 0xffffff);
			format.align = align;
			
			this.name = name;
			this.defaultTextFormat = format;
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.text = text;
			this.antiAliasType = AntiAliasType.ADVANCED;
			
		}
		
	}
	
}