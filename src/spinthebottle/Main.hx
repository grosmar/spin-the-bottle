package spinthebottle;
#if js
import js.Browser;
import spinthebottle.Bottle;
#end

/**
 * ...
 * @author duke
 */
class Main 
{
	
	static function main() 
	{
		#if js
		Browser.document.body.innerHTML = '
		<div id="root" class="container">
			<div class="square" id="squareContainer">
				<!--<div id="bottle"></div>-->
				<canvas id="canvas" ></canvas>
			</div>
		</div>';
		
		new Bottle(/*Browser.document.getElementById("bottle"), */cast Browser.document.getElementById("canvas"));
		#end
	}
	
}