package  
{
	import com.gskinner.motion.GTween;
	
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.AbstractView;
	import org.papervision3d.view.BasicView;
	
	import mx.effects.easing.Quadratic;
	
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;	

	/**
	 * @author Kelvin Luck
	 */
	[SWF(width='400', height='400', backgroundColor='#A4A4A4', frameRate='30')]

	public class ScoreTest extends BasicView 
	{
		
		public static const NUM_PANELS:int = 6;
		public static const PADDING:int = 5;
		
		private var _scorePanels:Array;
		private var _scoresHolder:DisplayObject3D;
		
		private var _rotateToMouse:Boolean;
		private var _unrotateTween:GTween;

		public function ScoreTest()
		{
			super(stage.stageWidth, stage.stageHeight, true);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.HIGH;
			
			initScorePanels();
			
			stage.addEventListener(MouseEvent.CLICK, onStageClick);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onEnterFrame(event:Event):void
		{
			onRenderTick();
			
			if (_rotateToMouse) {
				var mouseOffsetX:Number = (stage.stageWidth / 2 - stage.mouseX)/stage.stageWidth;
				var mouseOffsetY:Number = (stage.stageHeight / 2 - stage.mouseY) / stage.stageHeight;
				
				var dY:Number = -2 * mouseOffsetX;
				var dX:Number = -2 * mouseOffsetY;
				_scoresHolder.rotationY += dY - (_scoresHolder.rotationY / 8); 
				_scoresHolder.rotationX += dX - (_scoresHolder.rotationX / 8);
			} 
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			_rotateToMouse = !_rotateToMouse;
			if (!_rotateToMouse) {
				_unrotateTween.setProperties({rotationY:0, rotationX:0});
			}
		}

		private function initScorePanels():void
		{
			_scorePanels = [];
			
			var i:int = 0;
			var n:int = NUM_PANELS;
			
			var scorePanel:ScorePanel;
			
			_scoresHolder = new DisplayObject3D();
			_scoresHolder.y = -Math.round(n * (ScorePanel.HEIGHT + PADDING) / 2);
			_unrotateTween = new GTween(_scoresHolder, .5, {}, {ease:Quadratic.easeOut});
			
			var z:int = (camera.zoom * camera.focus) - Math.abs(camera.z);
			
			for (; i<n; i++) {
				scorePanel = new ScorePanel(i, z);
				scorePanel.y = i * (ScorePanel.HEIGHT + PADDING);
				_scorePanels.push(scorePanel);
				_scoresHolder.addChild(scorePanel);
			}
			
			scene.addChild(_scoresHolder);
		}

		private function onStageClick(event:MouseEvent):void
		{
			var randomPanel:ScorePanel = _scorePanels[Math.floor(Math.random() * _scorePanels.length)];
			randomPanel.score += Math.random() * 100;
			positionPanels();
		}
		
		private function positionPanels():void
		{
			_scorePanels.sortOn(['score', 'userId'], Array.NUMERIC);
			var i:int = _scorePanels.length;
			var scorePanel:ScorePanel;
			
			while (i--) {
				scorePanel = _scorePanels[i];
				scorePanel.moveTo(i);
			}
			//trace(_scorePanels);
		}
	}
}

import com.gskinner.motion.GTween;

import org.papervision3d.materials.MovieMaterial;
import org.papervision3d.objects.primitives.Plane;

import mx.effects.easing.Quadratic;

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

internal class ScorePanel extends Plane
{
	
	public static const HEIGHT:int = 20;
	
	private var _score:int;
	public function get score():int
	{
		return _score;
	}
	
	public function set score(value:int):void
	{
		_score = value;
		_scoreLabel.text = value + '';
		_panelMaterial.drawBitmap();
	}

	private var _userId:int;
	public function get userId():int
	{
		return _userId;
	}

	private var _defaultZ:int;
	private var _moveTween:GTween;
	private var _position:int;
	private var _materialMovie:Sprite;
	private var _panelMaterial:MovieMaterial;
	private var _scoreLabel:TextField;

	public function ScorePanel(userId:int, defaultZ:int)
	{
		_materialMovie = new Sprite();
		_materialMovie.graphics.beginFill(0xff0000, .8);
		_materialMovie.graphics.drawRect(0, 0, 200, HEIGHT);
		var userLabel:TextField = new TextField();
		userLabel.x = 3;
		var tf:TextFormat = userLabel.getTextFormat();
		tf.size = 12;
		tf.color = 0xffffff;
		tf.bold = true;
		tf.font = 'Arial';
		userLabel.defaultTextFormat = tf;
		userLabel.text = 'Player ' + userId;
		_materialMovie.addChild(userLabel);
		
		tf.align = TextFormatAlign.RIGHT;
		_scoreLabel = new TextField();
		_scoreLabel.width = 30;
		_scoreLabel.x = 165;
		_scoreLabel.defaultTextFormat = tf;
		_scoreLabel.text = _score + '';
		
		_materialMovie.addChild(_scoreLabel);
		
		_panelMaterial = new MovieMaterial(_materialMovie, true, false, true, new Rectangle(0, 0, 200, HEIGHT));
		super(_panelMaterial, 200, HEIGHT);
		_userId = userId;
		_position = userId; // temp!
		z = _defaultZ = defaultZ;
		_score = 0;
		_moveTween = new GTween(this, .5, {}, {ease:Quadratic.easeOut});
	}
	
	public function moveTo(newPosition:int):void
	{
		if (newPosition != _position) {
			_moveTween.addEventListener(Event.COMPLETE, doVerticalMove);
			_moveTween.setProperties({z:_defaultZ - newPosition*10/*, rotationY:newPosition * 5*/});
			_position = newPosition;
		}
	}
	
	private function doVerticalMove(event:Event):void
	{
		event.target.removeEventListener(event.type, arguments.callee);
		_moveTween.addEventListener(Event.COMPLETE, doDepthMove);
		_moveTween.setProperties({y: _position * (HEIGHT + ScoreTest.PADDING)});
	}
	
	private function doDepthMove(event:Event):void
	{
		event.target.removeEventListener(event.type, arguments.callee);
		_moveTween.setProperties({z:_defaultZ/*, rotationY:0*/});
	}

	override public function toString():String
	{
		return '[ScoreTest: ' + _userId + ' -> ' + _score + ']';
	}
}