#if js
package spinthebottle;
import Math.*;
import hxmath.math.Vector2;
import js.Browser;
import js.html.*;
import js.html.Element;

/**
 * ...
 * @author duke
 */
class Bottle
{
	static inline var GLIDING_COEFFICIENT = .99;
	static inline var ABSOLUTE_DAMPENING = .001;
	static inline var THRESHOLD = .001;
	static inline var PULL = .1;
	
	var targetRotation:Float = .0;
	var rSpeed:Float = .0;
	var rotation:Float = .0;
	var spinning:Bool = false;
	
	//var bottle:Element;
	
	var img:Image;
	var canvas:CanvasElement;
	var ctx:CanvasRenderingContext2D;
	
	public function new(/*bottle:Element, */canvas:CanvasElement)
	{
		//this.bottle = bottle;
		this.canvas = canvas;
		
		this.ctx = this.canvas.getContext2d();
		
		
		canvas.width = js.Browser.window.innerHeight;
		canvas.height = js.Browser.window.innerHeight;
		
		img = new Image();
		img.onload = function() {
			var imgWidth = (img.naturalWidth / img.naturalHeight) * canvas.height;
			ctx.drawImage(img, (canvas.width - imgWidth) / 2, 0, imgWidth, canvas.height);
		};
		img.src = 'img/bottle_small.png';

		this.canvas.addEventListener( "touchstart", touchGrab );
		this.canvas.addEventListener( "mousedown", mouseGrab );
		
		Browser.window.requestAnimationFrame( render );
	}
	
	function setTarget(pt:Vector2, center:Vector2, offset:Float) {
		//var rect = (cast e.currentTarget:Element).getBoundingClientRect();			
		var angle = angle(pt, center) - offset;
		targetRotation = angle + round((targetRotation - angle) / (2 * PI)) * 2 * PI;
		pursueTarget();
	}

	function angle(pt:Vector2, center:Vector2) {
		return (pt - center).angle;
	}

	function grab<T:Event>(options: { start:T, move: String, release:String, pos:T->Vector2 }) {
		halt(options.start);
		//if (!spinning) {
		
			rSpeed = 0;
			
			
			var e:Element = cast options.start.target;
			var center = center(e);
			
			var offset = angle(options.pos(options.start), center) - rotation;

			function onMove(e) 
				setTarget(options.pos(e), center, offset);
			
			e.ownerDocument.addEventListener(options.move, onMove);
			e.ownerDocument.addEventListener(options.release, function onRelease() {
				e.ownerDocument.removeEventListener(options.move, onMove);
				e.ownerDocument.removeEventListener(options.release, onRelease);
				release();
			});
			
		//}
	}

	function mouseGrab(e:MouseEvent) 
	{
		grab({
			start: e,
			move: 'mousemove',
			release: 'mouseup',
			pos: function (e) return new Vector2(e.clientX, e.clientY),
		});
	}

	function touchGrab(e:TouchEvent) 
		grab({
			start: e,
			move: 'touchmove',
			release: 'touchend',
			pos: function (e) return new Vector2(e.touches[0].clientX, e.touches[0].clientY),
		});		

	function release()
		if (!spinning) {
			rSpeed = targetRotation - rotation;
			spinning = abs(rSpeed) > .25;
		}
	
	function pursueTarget() 
		rotation = 				
			if (isNegligible(rotation - targetRotation)) targetRotation;
			else interpolate(targetRotation, rotation, PULL);	
	
	function render(_) {
		if (spinning) {
			rotation += rSpeed;
			targetRotation = rotation;
			rSpeed *= GLIDING_COEFFICIENT;
			if (isNegligible(rSpeed)) {
				spinning = false;		
			}
			else rSpeed += (if (rSpeed > 0) -1 else 1) * ABSOLUTE_DAMPENING;
		}
		else {
			rotation = 				
				if (isNegligible(rotation - targetRotation)) targetRotation;
				else interpolate(targetRotation, rotation, PULL);
		}	
		
		var iw = (img.naturalWidth / img.naturalHeight) * canvas.height;
		var ih = canvas.height;
		
		ctx.save(); //saves the state of canvas
		ctx.clearRect(0, 0, canvas.width, canvas.height); //clear the canvas
		ctx.translate(canvas.width/2, canvas.height/2); //let's translate
		ctx.rotate(this.rotation); //increment the angle and rotate the image 
		ctx.translate(-(canvas.width/2), -(canvas.height/2)); //let's translate
		ctx.drawImage(img, canvas.width/2 - iw/2, canvas.height/2 - ih/2, iw, ih); //draw the image ;)
		ctx.restore(); //restore the state of canvas
		
		Browser.window.requestAnimationFrame(render);
	}

	static function center(e:Element) {
		var rect = e.getBoundingClientRect();
		return new Vector2((rect.left + rect.right) / 2, (rect.top + rect.bottom) / 2);
	}

	static function halt(e:Event) {
		e.preventDefault();
		e.stopImmediatePropagation();
	}
	
	static inline function interpolate(a:Float, b:Float, fac:Float = .5)
		return a * fac + b * (1 - fac);
	
	static inline function isNegligible(f:Float)
		return abs(f) < THRESHOLD;
}
#end