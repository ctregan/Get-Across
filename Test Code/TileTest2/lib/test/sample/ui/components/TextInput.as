package sample.ui.components 
{
	import org.flixel.*;
	import org.flixel.system.input.Keyboard;
	import flash.text.TextFieldType
	/**
	 * ...
	 * @author Ji Mun
	 */
	public class TextInput extends FlxText 
	{
		public function TextInput(x:int, y:int, width:int, s:String = "") 
		{
			super(x, y, width, "", true);
			this.text = s;
		}
		
		public function clear() {
			this.text = "";
		}
		
		public function append(keyboard:Keyboard) {
			if (keyboard.A) {
				this.text += "A";
			} else if (keyboard.B) {
				this.text += "B";
			} else if (keyboard.C) {
				this.text += "C";
			} else if (keyboard.D) {
				this.text += "D";
			}else if (keyboard.E) {
				this.text += "E";
			} else if (keyboard.F) {
				this.text += "F";
			} else if (keyboard.G) {
				this.text += "G";
			}else if (keyboard.H) {
				this.text += "H";
			} else if (keyboard.I) {
				this.text += "I";
			} else if (keyboard.J) {
				this.text += "J";
			}else if (keyboard.K) {
				this.text += "K";
			} else if (keyboard.L) {
				this.text += "L";
			} else if (keyboard.M) {
				this.text += "M";
			}else if (keyboard.N) {
				this.text += "N";
			} else if (keyboard.O) {
				this.text += "O";
			} else if (keyboard.P) {
				this.text += "P";
			}else if (keyboard.Q) {
				this.text += "Q";
			} else if (keyboard.R) {
				this.text += "R";
			} else if (keyboard.S) {
				this.text += "S";
			} else if (keyboard.T) {
				this.text += "T";
			} else if (keyboard.R) {
				this.text += "R";
			} else if (keyboard.V) {
				this.text += "V";
			} else if (keyboard.W) {
				this.text += "W";
			} else if (keyboard.U) {
				this.text += "U";
			} else if (keyboard.Y) {
				this.text += "Y";
			}else if (keyboard.X) {
				this.text += "X";
			} else if (keyboard.Z) {
				this.text += "Z";
			} 			
		}
		
	}

}