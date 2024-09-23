package tjson.styles;

import tjson.interfaces.EncodeStyle;

using StringTools;

class FancyStyle implements EncodeStyle
{
	public var tab(default, null):String;
	public function new(tab:String = "    "){
		this.tab = tab;
		charTimesNCache = [""];
	}
	public function beginObject(depth:Int):String{
		return "{\n";
	}
	public function endObject(depth:Int):String{
		return "\n"+charTimesN(depth)+"}";
	}
	public function beginArray(depth:Int):String{
		return "[\n";
	}
	public function endArray(depth:Int):String{
		return "\n"+charTimesN(depth)+"]";
	}
	public function firstEntry(depth:Int):String{
		return charTimesN(depth+1)+' ';
	}
	public function entrySeperator(depth:Int):String{
		return "\n"+charTimesN(depth+1)+",";
	}
	public function keyValueSeperator(depth:Int):String{
		return " : ";
	}
	private var charTimesNCache:Array<String>;
	private function charTimesN(n:Int):String{
		return if (n < charTimesNCache.length) {
			charTimesNCache[n];
		} else {
			charTimesNCache[n] = charTimesN(n-1) + tab;
		}
	}
}