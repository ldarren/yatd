package org.pica.graphics.ui {

	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Input extends Button {
		
		static private var btnTheme_:Object;
		
		public function Input(name:String, text:String, x:Number, y:Number, w:Number, h:Number, args:Object=null, theme:Object=null) {
			
			super(name, text, null, {}, x, y, w, h, Button.ICON_LEFT, theme?theme:btnTheme_);
			
			this.buttonMode = false;
			this.mouseChildren = true;
			if (args) for (var key:String in args) _label[key] = args[key];
			_label.autoSize = TextFieldAutoSize.NONE;
			_label.x = 5;
			_label.y = 3;
			_label.width = w;
			_label.height = h;
			_label.type = TextFieldType.INPUT;
			_label.selectable = true;
			//_label.border = true;
		}
		
		// TODO: better theme system so that multiple skins per instance
		static public function setTheme(skins:Array, outer:Rectangle, inner:Rectangle):void {
			btnTheme_ = { skin:skins, outer:outer, inner:inner };
		}
		
		public function set text(txt:String):void {
			_label.text = text;
		}
		
		public function get text():String {
			return _label.text;
		}
		
	}
	
}
