package org.pica.graphics.ui {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Darren Liew
	 * 
	 */
	public class Window extends BaseUI {
		
		static protected var defaultSkins_:Array;
		static protected var defaultOuter_:Rectangle;
		static protected var defaultInner_:Rectangle;
		
		protected var _title:TextField;
		
		public function Window(name:String, title:String, x:Number, y:Number, w:Number, h:Number, theme:Object=null) {
			super();
			
			this.name = name;
			this.x = x;
			this.y = y;
			
			if (theme) setSkin(theme.skin, theme.outer, theme.inner);
			else setSkin(defaultSkins_, defaultOuter_, defaultInner_);
			setSize(w, h);
			
			_title = new TextField();
			_title.defaultTextFormat = this.textFormat;
			_title.selectable = false;
			_title.antiAliasType = AntiAliasType.NORMAL;
			_title.autoSize = TextFieldAutoSize.CENTER;
			_title.text = title;
			_title.x = 0; _title.y = 2;
			_title.width = this.logicalWidth; _title.height = defaultInner_.y - defaultOuter_.y - 2;
			this.addChild(_title);

			addEventListener(MouseEvent.MOUSE_UP, onEvent);
			addEventListener(MouseEvent.MOUSE_DOWN, onEvent);
			addEventListener(MouseEvent.MOUSE_OVER, onEvent);
			addEventListener(MouseEvent.MOUSE_OUT, onEvent);
		}
		
		public function showModal():void {
			var main:Sprite = this.stage.getChildAt(0) as Sprite;
			main.filters = [new BlurFilter(8,8)];
			main.mouseChildren = false;
		}
		
		public function hideModal():void {
			var main:Sprite = this.stage.getChildAt(0) as Sprite;
			main.filters = null;
			main.mouseChildren = true;
			stage.focus = main;	// HACK: if not focus will remain on button
		}
		
		// TODO: better theme system so that multiple skins per instance
		static public function setDefaultTheme(skins:Array, outer:Rectangle, inner:Rectangle):void {
			defaultSkins_ = skins; defaultOuter_ = outer; defaultInner_ = inner;
		}
		
		override protected function onEvent(evt:Event):void {
			var e:MouseEvent = evt as MouseEvent;
			switch(e.type) {
			case MouseEvent.MOUSE_DOWN:
			case MouseEvent.MOUSE_OVER:
			case MouseEvent.MOUSE_UP:
			case MouseEvent.MOUSE_OUT:
				break;
			}
			
			super.onEvent(evt);
		}
		
	}
	
}