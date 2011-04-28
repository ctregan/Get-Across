﻿package sample.ui.components{	import flash.display.Sprite	import flash.events.Event	import flash.display.DisplayObject	public class Box extends Component{		protected var _top:Number = NaN		protected var _bottom:Number = NaN		protected var _left:Number = NaN		protected var _right:Number = NaN				protected var _color:int		protected var _corner:Number = 0;		protected var _alpha:Number		protected var _strokeWidth:Number		protected var _strokeColor:Number		protected var _strokeAlpha:Number		protected var useFill:Boolean = false;		function Box(){			redraw();		}				public function margin(top:Number = NaN, right:Number = NaN, bottom:Number = NaN, left:Number = NaN):*{			_top = top			_right = right			_bottom = bottom			_left = left			redraw();			return this;		}				public function fill(color:int = 0, alpha:Number = 1, corner:Number = 0):*{			_width = width			_height = height			_color = color			_corner = corner			_alpha = alpha			useFill = true;			redraw()			return this;		}				public function border(strokeWidth:Number = 0, strokeColor:Number = 0, strokeAlpha:Number = 1):*{			_strokeWidth = strokeWidth			_strokeColor = strokeColor			_strokeAlpha = strokeAlpha						redraw();			return this		}				public function minSize(w:Number, h:Number):Box{			this.minWidth = w;			this.minHeight = h			redraw();			return this;		}						public function add(...args:Array):Box{			for each(var d:DisplayObject in args)				addChild(d);			redraw();			return this;		}					protected function get borderHeight():Number{			return (_top ? _top : 0) + (_bottom ? _bottom : 0)		}				protected function get borderWidth():Number{			return (_left ? _left : 0) + (_right ? _right : 0)				}				public function reset(first:Boolean = true, queue:Array = null):void{						if(first) queue = []						for(var a:int=0;a<numChildren;a++){				var content:DisplayObject = getChildAt(a);				if(content is Box)					(content as Box).reset(false, queue)			}						queue.push(redraw)						if(first){				for each( var f:Function in queue){					f();f()				}			}		}				protected override function redraw():void{			//reset(false)						var nw = _width;			var nh = _height;						for(var a:int=0;a<numChildren;a++){				var content:DisplayObject = getChildAt(a);								nw = Math.max(nw, content.width + borderWidth)				nh = Math.max(nh, content.height + borderHeight)								if(!isNaN(_left)){					content.x = _left					if(!isNaN(_right)){						content.width = rwidth - borderWidth					}				}else if(!isNaN(_right)){					content.x = nw - content.width - _right				}else{					content.x = (Math.max(rwidth,nw) - content.width)/2				}								if(!isNaN(_top)){					content.y = _top					if(!isNaN(_bottom)){						content.height = rheight - borderHeight					 }				}else if(!isNaN(_bottom)){					content.y = nh - content.height - _bottom//					trace(nh - content.height - _bottom)				}else{					content.y = (Math.max(rheight,nh) - content.height)/2				}							}								graphics.clear()			if(_strokeWidth){				graphics.lineStyle(_strokeWidth, _strokeColor, _strokeAlpha, true);				if(_minWidth || _minHeight){					graphics.drawRoundRect(0, 0, Math.max(rwidth,nw), Math.max(rheight,nh), _corner)				}else{					graphics.drawRoundRect(0, 0, Math.max(rwidth,_width), Math.max(rheight,_height), _corner)				}			}			if(useFill){				graphics.beginFill(_color, _alpha)								if(_minWidth || _minHeight){					graphics.drawRoundRect(0, 0, Math.max(rwidth,nw), Math.max(rheight,nh), _corner)				}else{					graphics.drawRoundRect(0, 0, Math.max(rwidth,_width), Math.max(rheight,_height), _corner)				}				graphics.endFill()							}					}	}}