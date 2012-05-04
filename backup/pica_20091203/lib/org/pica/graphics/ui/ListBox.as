package org.pica.graphics.ui {
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class ListBox extends Sprite {
		
		static public const ALIGN_VERTICAL:int = 0;
		static public const ALIGN_HORIZONTAL:int = 1;
		
		static private var btnTheme_:Object;
		static private var icons_:Array;
		
		private var itemWidth_:Number;
		private var itemHeight_:Number;
		private var itemCount_:int;
		private var isVertical:Boolean;
		private var onSel_:Function;
		private var selItem_:Button;

		private var items_:Array;
		private var displayItems_:Array;
		private var btnPrev_:Button;
		private var btnNext_:Button;
		private var currFirst_:int = 0;
		private var lastFirst_:int = 0;
		
		public function ListBox(name:String, itemWidth:Number, itemHeight:Number, itemCount:int, onSelected:Function, align:int=ListBox.ALIGN_VERTICAL) {
			this.name = name;
			itemWidth_ = itemWidth; itemHeight_ = itemHeight; itemCount_ = itemCount;
			onSel_ = onSelected; isVertical = align == ListBox.ALIGN_VERTICAL;
			items_ = new Array();
			displayItems_ = new Array();
			
			btnPrev_ = new Button(name + "_prev", null, [isVertical?icons_[0]:icons_[2]], { up:onButton }, 0, 0, 
				isVertical?itemWidth_:-1, isVertical?-1:itemHeight_,
				Button.ICON_LEFT, btnTheme_ );
			btnNext_ = new Button(name + "_next", null, [isVertical?icons_[1]:icons_[3]], { up:onButton }, isVertical?0:btnPrev_.logicalWidth+itemWidth_*itemCount_, isVertical?btnPrev_.logicalHeight+itemHeight_*itemCount_:0, 
				isVertical?itemWidth_:-1, isVertical?-1:itemHeight_,
				Button.ICON_LEFT, btnTheme_);
			addChild(btnPrev_);
			addChild(btnNext_);
		}
		
		static public function setTheme(s:Array, o:Rectangle, i:Rectangle, icons:Array):void {
			btnTheme_ = { skin:s, outer:o, inner:i };
			icons_ = icons;
		}
		
		public function addItem(name:String, label:String, icon:Bitmap):void {
			var b:Button = new Button(name, label, [icon], { up:onButton }, 0, 0, itemWidth_, itemHeight_, isVertical?Button.ICON_LEFT:Button.ICON_UP, btnTheme_);
			b.toggle = true;
			itemWidth_ = b.logicalWidth; itemHeight_ = b.logicalHeight;
			items_.push(b);
			if (displayItems_.length < itemCount_) {
				setPosition(b, displayItems_.length);
				addChild(b);
				displayItems_.push(b);
			} else {
			}
			lastFirst_ = items_.length - displayItems_.length;
			setPosition(btnNext_, itemCount_);
			validation();
		}
		
		public function removeItem(name:String):void {
			var b:DisplayObject = this.getChildByName(name);
			removeChild(b);
			lastFirst_ = items_.length - displayItems_.length;
			validation();
		}
		
		private function onButton(btn:Button):void {
			if (items_.length <= displayItems_.length) return;
			var curr:int = currFirst_;
			switch(btn.name) {
			case btnPrev_.name: curr--; break;
			case btnNext_.name:	curr++;	break;
			default:
				if (onSel_ != null) {
					if (selItem_ && selItem_ != btn) selItem_.isOn = false;
					selItem_ = btn;
					onSel_(btn);
				}
				return;
			}
			
			if (curr < 0) curr = 0;
			else if (curr > lastFirst_) curr = lastFirst_;
			if (curr == currFirst_) return;

			var tmp:DisplayObject;
			if (curr < currFirst_) { // move to prev
				removeChild(displayItems_.pop());
				tmp = items_[curr] as DisplayObject;
				displayItems_.unshift(tmp);
				addChild(tmp);
			} else { // move to next
				removeChild(displayItems_.shift());
				tmp = items_[curr + itemCount_ - 1] as DisplayObject;
				displayItems_.push(tmp);
				addChild(tmp);
			}
			var i:int = 0;
			for each(tmp in displayItems_) {
				setPosition(tmp, i);
				i++;
			}
			currFirst_ = curr;
			validation();
		}
		
		private function setPosition(b:DisplayObject, loc:int):void {
			if (isVertical) b.y = btnNext_.logicalHeight + loc * itemHeight_;
			else			b.x = btnNext_.logicalWidth + loc * itemWidth_;
		}
		
		private function validation():void {
			if (currFirst_ == 0) btnPrev_.disable = true;
			else btnPrev_.disable = false;
			if (currFirst_ == lastFirst_) btnNext_.disable = true;
			else btnNext_.disable = false;
		}
		
	}
	
}