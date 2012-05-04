package org.pica.graphics.ui {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class BaseUI extends Sprite {
		static protected const _STATE_BLUR:int		= 0;	// or normal buttons or normal window or etc
		static protected const _STATE_FOCUS:int		= 1;	// or roll-overed buttons or focus window or etc
		static protected const _STATE_ACTIVE:int	= 2;	// or pressed buttons
		static protected const _STATE_INACTIVE:int	= 3;
		static protected const _STATE_MAX:int		= 4;
		
		static private const GRID_TL_:int	= 0;
		static private const GRID_T_:int	= 1;
		static private const GRID_TR_:int	= 2;
		static private const GRID_R_:int	= 3;
		static private const GRID_BR_:int	= 4;
		static private const GRID_B_:int	= 5;
		static private const GRID_BL_:int	= 6;
		static private const GRID_L_:int	= 7;
		static private const GRID_C_:int	= 8;
		
		public var textFormat:TextFormat;
		private var raws_:Array;
		private var finals_:Array;
		private var area_:Rectangle, grid_:Rectangle;
		
		protected var _skins:Array;
		protected var _states:Array;
		private var currState_:int = 0;
		
		private var width_:int=0, height_:int=0;
		
		public function BaseUI() {
			textFormat = new TextFormat("Arial", 12, 0xeeeeee, null, null, null, null, null, TextFormatAlign.CENTER);
		}
		
		public function setSkin(bmps:Array, area:Rectangle, grid:Rectangle):void {
			_skins = bmps;
			area_ = area;
			grid_ = grid;
			var agx:int = area.x + grid.x, agy:int = area.y + grid.y;
			raws_ = new Array(9);
			raws_[BaseUI.GRID_TL_]	= new Rectangle(area.x, 			area.y,				grid.x,								grid.y);
			raws_[BaseUI.GRID_T_]	= new Rectangle(agx, 				area.y,				grid.width,							grid.y);
			raws_[BaseUI.GRID_TR_]	= new Rectangle(agx + grid.width,	area.y,				area.width - grid.x - grid.width,	grid.y);
			raws_[BaseUI.GRID_R_]	= new Rectangle(agx + grid.width,	agy,				area.width - grid.x - grid.width,	grid.height);
			raws_[BaseUI.GRID_BR_]	= new Rectangle(agx + grid.width,	agy + grid.height,	area.width - grid.x - grid.width,	area.height - grid.y - grid.height);
			raws_[BaseUI.GRID_B_]	= new Rectangle(agx, 				agy + grid.height,	grid.width,							area.height - grid.y - grid.height);
			raws_[BaseUI.GRID_BL_]	= new Rectangle(area.x, 			agy + grid.height,	grid.x,								area.height - grid.y - grid.height);
			raws_[BaseUI.GRID_L_]	= new Rectangle(area.x,				agy,				grid.x			,					grid.height);
			raws_[BaseUI.GRID_C_]	= new Rectangle(agx,				agy,				grid.width,							grid.height);
			
			if (width_ != 0)
				generate();
		}
		
		public function get logicalWidth():int {
			return width_;
		}
		
		public function get logicalHeight():int {
			return height_;
		}
		
		// is accurate up to the nearest multiple of br.width and br.height
		public function setSize(w:int, h:int):void {
			width_ = w;	// HACK: used it as flag
			height_ = h;
			if (raws_ != null)
				generate();
		}
		
		public function set state(state:int):void {
			if (state == currState_) return;
			//trace("state len: " + _states.length+" curr: "+currState_+" state: "+state);
			_states[currState_].visible = false;
			currState_ = state;
			_states[currState_].visible = true;
		}
		
		public function get state():int {
			return currState_;
		}
		
		private function generate():void {
			var tl:Rectangle = raws_[BaseUI.GRID_TL_]as Rectangle;
			var br:Rectangle = raws_[BaseUI.GRID_BR_]as Rectangle;
			// HACK? or BUG in flash? BitmapFill doesn't start from begining or rect but always 0,0
			width_ = int((width_ + br.width-1) / br.width) * br.width;
			height_ = int((height_ + br.height-1) / br.height) * br.height;
			//trace("w: " + width_ +" h: " + height_);
			
			var ax:int = 0, ay:int = 0, aw:int = width_, ah:int = height_;
			var gx:int = grid_.x, gy:int = grid_.y;
			var cw:int = aw - tl.width - br.width, ch:int = ah - tl.height - br.height;
			finals_ = new Array(9);
			finals_[BaseUI.GRID_TL_]	= new Rectangle(ax, 		ay,			tl.width,		tl.height);
			finals_[BaseUI.GRID_T_]		= new Rectangle(gx, 		ay,			cw,				tl.height);
			finals_[BaseUI.GRID_TR_]	= new Rectangle(gx + cw,	ay,			br.width,		tl.height);
			finals_[BaseUI.GRID_R_]		= new Rectangle(gx + cw,	gy,			br.width,		ch);
			finals_[BaseUI.GRID_BR_]	= new Rectangle(gx + cw,	gy + ch,	br.width,		br.height);
			finals_[BaseUI.GRID_B_]		= new Rectangle(gx, 		gy + ch,	cw,				br.height);
			finals_[BaseUI.GRID_BL_]	= new Rectangle(ax, 		gy + ch,	tl.width,		br.height);
			finals_[BaseUI.GRID_L_]		= new Rectangle(ax,			gy,			tl.width,		ch);
			finals_[BaseUI.GRID_C_]		= new Rectangle(gx,			gy,			cw,				ch);

			if (_states) {
				for each (var s:Sprite in _states) {
					this.removeChild(s);
				}
			}
			_states = new Array();
			var bd:BitmapData;
			var target:Sprite;
			var g:Graphics;
			var raw:Rectangle, dest:Rectangle;
			const pt:Point = new Point(0, 0);
			for each (var b:Bitmap in _skins) {
				target = new Sprite();
				g = target.graphics;
				for (var i:int = 0; i < 9; ++i) {
					raw = raws_[i] as Rectangle;
					dest = finals_[i] as Rectangle;
//trace("from x: "+raw.x+" y: "+raw.y+" w: "+raw.width+" h: "+raw.height+" to x: "+dest.x+" y: "+dest.y+" w: "+dest.width+" h: "+dest.height);					
					bd = new BitmapData(raw.width, raw.height);
					bd.copyPixels(b.bitmapData, raw, pt);
					
					g.beginBitmapFill(bd, null,i!=8?true:false);
					g.drawRect(dest.x, dest.y, dest.width, dest.height);
					g.endFill();
				}
				_states.push(target);
				this.addChild(target);
				target.visible = false;
			}
			
			_states[0].visible = true;
		}
		
		protected function onEvent(evt:Event):void {
			switch(evt.type) {
			case MouseEvent.MOUSE_DOWN:
			case MouseEvent.MOUSE_OVER:
			case MouseEvent.MOUSE_UP:
			case MouseEvent.MOUSE_OUT:
			case MouseEvent.MOUSE_WHEEL:
			case MouseEvent.CLICK:
				evt.stopImmediatePropagation();
				break;
			}
		}
		
	}
	
}