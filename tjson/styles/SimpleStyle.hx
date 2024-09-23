package tjson.styles;

import tjson.interfaces.EncodeStyle;

using StringTools;

class SimpleStyle implements EncodeStyle
{
	public function new(){}

	public function beginObject(depth:Int):String{
		return "{";
	}
	public function endObject(depth:Int):String{
		return "}";
	}
	public function beginArray(depth:Int):String{
		return "[";
	}
	public function endArray(depth:Int):String{
		return "]";
	}
	public function firstEntry(depth:Int):String{
		return "";
	}
	public function entrySeperator(depth:Int):String{
		return ",";
	}
	public function keyValueSeperator(depth:Int):String{
		return ":";
	}	
}