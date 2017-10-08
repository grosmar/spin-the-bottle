package;

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
	@:state var rotation:Float = .0;
	@:state var spinning:Bool = false;
	
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
		if (!spinning) {
			
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
		}
	}

	function mouseGrab(e:MouseEvent) 
		grab({
			start: e,
			move: 'mousemove',
			release: 'mouseup',
			pos: function (e) return new Vector2(e.clientX, e.clientY),
		});

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
	
	function render() {
		haxe.Timer.delay(function () {
			if (spinning) {
				rotation += rSpeed;
				targetRotation = rotation;
				rSpeed *= GLIDING_COEFFICIENT;
				if (isNegligible(rSpeed)) {
					spinning = false;
					/*var personDegree = (360 / model.players.length);
					var choosenPerson = Math.floor((((rotation * 180 / PI) + 90 + personDegree / 2) % 360) / personDegree);
					
					switch (model.state)
					{
						case GameState.Spin(choosePlayer):
							choosePlayer(choosenPerson);
						default:
					}*/
					
				}
				else rSpeed += (if (rSpeed > 0) -1 else 1) * ABSOLUTE_DAMPENING;
			}
			else {
				rotation = 				
					if (isNegligible(rotation - targetRotation)) targetRotation;
					else interpolate(targetRotation, rotation, PULL);
			}	
		}, 0);
		return @hxx '
			<div 
				id="bottle" 
				style="transform: rotate(${90 + this.rotation * 180 / PI}deg)" 
				onmousedown={mouseGrab}
				ontouchstart={touchGrab}
				data-spinning={spinning}
			></div>
		';
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