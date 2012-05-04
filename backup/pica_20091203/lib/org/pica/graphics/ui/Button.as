package org.pica.graphics.ui {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Darren Liew
	 * @TODO consume events
	 */
	public class Button extends BaseUI {
		
		static public const ICON_UP:int		= 0;
		static public const ICON_DOWN:int	= 1;
		static public const ICON_LEFT:int	= 2;
		static public const ICON_RIGHT:int	= 3;
		
		static protected var defaultSkins_:Array;
		static protected var defaultOuter_:Rectangle;
		static protected var defaultInner_:Rectangle;
		
		private var disable_:Boolean = false;
		public var toggle:Boolean = false;	// if toggle==true, radio button state
		private var isOn_:Boolean = false;	// if isOn==true, radio button is selected
		
		private var funUp_:Function;
		private var funDown_:Function;
		private var funOver_:Function;
		private var funOut_:Function;
		
		protected var _label:TextField;
		protected var _icon:Bitmap;
		
		public function Button(name:String, label:String, icons:Array, cb:Object, x:Number, y:Number, w:Number=-1, h:Number=-1, align:int=Button.ICON_LEFT, theme:Object=null) {
			super();
			
			this.name = name;
			this.x = x;
			this.y = y;
			this.buttonMode = true;
			this.mouseChildren = false;
			
			//setSkin(skins, new Rectangle(0, 0, 10, 19), new Rectangle(3, 9, 4, 1));	// graphite
			//setSkin(skins, new Rectangle(0, 0, 14, 12), new Rectangle(3, 2, 8, 8));	// metal
			if (theme) setSkin(theme.skin, theme.outer, theme.inner);
			else setSkin(defaultSkins_, defaultOuter_, defaultInner_);
			
			_label = new TextField();
			_label.defaultTextFormat = this.textFormat;
			_label.selectable = false;
			_label.antiAliasType = AntiAliasType.NORMAL;
			_label.autoSize = TextFieldAutoSize.CENTER;
			setContent(label, icons, w, h, align);
			
			funUp_ = cb.up;
			funDown_ = cb.down;
			funOver_ = cb.over;
			funOut_ = cb.out;
			addEventListener(MouseEvent.MOUSE_UP, onEvent);
			addEventListener(MouseEvent.MOUSE_DOWN, onEvent);
			addEventListener(MouseEvent.MOUSE_OVER, onEvent);
			addEventListener(MouseEvent.MOUSE_OUT, onEvent);
		}
		
		// TODO: better theme system so that multiple skins per instance
		static public function setDefaultTheme(skins:Array, outer:Rectangle, inner:Rectangle):void {
			defaultSkins_ = skins; defaultOuter_ = outer; defaultInner_ = inner;
		}
		
		public function setContent(text:String, icons:Array = null, width:Number = -1, height:Number = -1, align:int=Button.ICON_LEFT):void {
			// clean up old resources
			if (_label.text != "") {
				removeChild(_label);
				_label.text = "";
			}
			if (_icon) {
				removeChild(_icon);
				_icon = null;
			}
			
			// check states
			var hasIcon:Boolean = icons != null, hasLabel:Boolean = text != null && text != "";
			
			// populate new resources
			if (hasLabel) {
				_label.text = text;
			}
			if (hasIcon) _icon = new Bitmap(icons[0].bitmapData);
			
			// layout
			var w:Number = 0, h:Number = 0, nx:Number = 0, ny:Number = 0;
			const MARGIN:Number = 5, MARGIN2:Number = MARGIN * 2;
			if (hasIcon){ // this is working bcos flash doesn't respect scope
				const IW:Number = _icon.width, IH:Number = _icon.height, IWM:Number = IW + MARGIN2, IHM:Number = IH + MARGIN2;
			}
			if (hasLabel){
				const LW:Number = _label.width, LH:Number = _label.height, LWM:Number = LW + MARGIN2, LHM:Number = LH;
			}

			// estimate the width and height
			switch(align) {
			case Button.ICON_LEFT:
				if (hasIcon) {
					w = IWM;
					h = IHM;
				}
				if (hasLabel) {
					w += LWM;
					if (h < LH) h = LHM;
				}
				break;
			case Button.ICON_UP:
				if (hasIcon) {
					w = IWM;
					h = IHM;
				}
				if (hasLabel) {
					if (w < LWM) w = LWM;
					h += LHM;
				}
				break;
			case Button.ICON_RIGHT:
				if (hasLabel) {
					w = LWM;
					h = LHM;
				}
				if (hasIcon) {
					w += IWM;
					if (h < IHM) h = IHM;
				}
				break;
			case Button.ICON_DOWN:
				if (hasLabel) {
					w = LWM;
					h = LHM;
				}
				if (hasIcon) {
					if (w < IWM) w = IWM;
					h += IHM;
				}
				break;
			}

			setSize(width == -1?w:width, height == -1?h:height);
			w = super.logicalWidth; h = super.logicalHeight;
			
			switch(align) {
			case Button.ICON_LEFT:
				if (hasIcon) {
					_icon.x = _icon.y = (h - IH) / 2; // for aesthetic reason, y and x should be the same
					if (!hasLabel) _icon.x = (w - IW) / 2;
					nx = IW + _icon.x * 2;
				}
				if (hasLabel) {
					_label.x = nx + ((w - nx) - LW) / 2;
					_label.y = ny + (h - LH) / 2;
				}
				break;
			case Button.ICON_UP:
				if (hasIcon) {
					_icon.x = (w - IW) / 2;
					_icon.y = (h - IH - (hasLabel?LH:0)) / (hasLabel?4:2);
					nx = 0;
					ny = IH + _icon.y * 2;
				}
				if (hasLabel) {
					_label.x = nx + (w - LW) / 2;
					_label.y = ny + (h - ny - LH) / 2;
				}
				break;
			case Button.ICON_RIGHT:
				if (hasIcon) { // calculate from backward
					_icon.y = (h - IH) / 2;
					if (hasLabel) _icon.x = w - _icon.y - IW;
					else _icon.x = (w - IW) / 2;
					nx = IW + _icon.y * 2;
				}
				if (hasLabel) {
					_label.x = (w - nx - LW) / 2;
					_label.y = (h - LH) / 2;
				}
				break;
			case Button.ICON_DOWN:
				if (hasLabel) {
					_label.x = (w - LW) / 2;
					_label.y = (h - LH - (hasIcon?IH:0)) / (hasIcon?4:2);
					nx = 0;
					ny = LH + _label.y * 2;
				}
				if (hasIcon) {
					_icon.x = nx + (w - IW) / 2;
					_icon.y = ny + (h - ny - IH) / 2;
				}
				break;
			}
			
			// adding to scene
			if (hasIcon) addChild(_icon);
			addChild(_label); // must add after the button's states
		}
		
		public function getLabel():String {
			return _label.text;
		}
		
		public function set disable(off:Boolean):void {
			super.state = off?BaseUI._STATE_INACTIVE:BaseUI._STATE_BLUR;
			disable_ = off;
		}
		
		public function get disable():Boolean {
			return disable_;
		}
		
		public function set isOn(active:Boolean):void {
			if (!toggle) return; // ignore if not in radio mode
			isOn_ = active;
			state = isOn_?BaseUI._STATE_ACTIVE:BaseUI._STATE_BLUR;
		}
		
		public function get isOn():Boolean {
			return isOn_;
		}
		
		override protected function onEvent(evt:Event):void {
			var e:MouseEvent = evt as MouseEvent;
			if (disable_) {
				super.onEvent(evt);
				return;
			}
			switch(e.type) {
			case MouseEvent.MOUSE_DOWN:
				state = toggle?(isOn?BaseUI._STATE_BLUR:BaseUI._STATE_ACTIVE):BaseUI._STATE_ACTIVE;
				isOn = state == BaseUI._STATE_ACTIVE;
				if (funDown_ != null) funDown_(this);
				break;
			case MouseEvent.MOUSE_OVER:
				if (e.buttonDown) {
					state = toggle?(isOn?BaseUI._STATE_BLUR:BaseUI._STATE_ACTIVE):BaseUI._STATE_ACTIVE;
					if (funDown_ != null) funDown_(this);
				} else {
					state = BaseUI._STATE_FOCUS;
					if (funOver_ != null) funOver_(this);
				}
				break;
			case MouseEvent.MOUSE_UP:
				if (!toggle) state = BaseUI._STATE_FOCUS;
				if (funUp_ != null) funUp_(this);
				break;
			case MouseEvent.MOUSE_OUT:
				state = BaseUI._STATE_BLUR;
				state = toggle?(isOn?BaseUI._STATE_ACTIVE:BaseUI._STATE_BLUR):BaseUI._STATE_BLUR;
				if (funOut_ != null) funOut_(this);
				break;
			}
			
			super.onEvent(evt);
		}
		
	}
	
}