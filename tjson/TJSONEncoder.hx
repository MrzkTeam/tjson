package tjson;

import tjson.interfaces.EncodeStyle;
import tjson.styles.*;

using StringTools;

class TJSONEncoder
{
	var cache:Array<Dynamic>;
	var uCache:Bool;

	public function new(useCache:Bool = true) {
		uCache = useCache;

		if(uCache)
			cache = new Array();
	}

	public function doEncode(obj:Dynamic, ?style:Dynamic = null) {
		if(!Reflect.isObject(obj)) {
			throw("Provided object is not an object.");
		}

		var st:EncodeStyle;
		if(Std.isOfType(style, EncodeStyle)){
			st = style;
		}
		else if(style == 'fancy'){
			st = new FancyStyle();
		}
		else st = new SimpleStyle();

		var buffer = new StringBuf();
		if(Std.isOfType(obj,Array) || Std.isOfType(obj,List)) {
			buffer.add(encodeIterable( obj, st, 0));
		} else if(Std.isOfType(obj, haxe.ds.StringMap)){
			buffer.add(encodeMap(obj, st, 0));
		} else {
			cacheEncode(obj);
			buffer.add(encodeObject(obj, st, 0));
		}
		return buffer.toString();
	}

	private function encodeObject(obj:Dynamic, style:EncodeStyle, depth:Int):String {
		var buffer = new StringBuf();
		buffer.add(style.beginObject(depth));

		var fieldCount = 0;
		var fields:Array<String>;
		var dontEncodeFields:Array<String> = null;
		var cls = Type.getClass(obj);
		if (cls != null) {
			fields = Type.getInstanceFields(cls);
		} else {
			fields = Reflect.fields(obj);
		}
		//preserve class name when serializing class objects
		//is there a way to get c outside of a switch?
		switch(Type.typeof(obj)) {
			case TClass(c):
				if(fieldCount++ > 0) buffer.add(style.entrySeperator(depth));
				else buffer.add(style.firstEntry(depth));
				buffer.add('"_hxcls"' + style.keyValueSeperator(depth));
				buffer.add(encodeValue( Type.getClassName(c), style, depth));

				if( #if flash9 try obj.TJ_noEncode != null catch( e : Dynamic ) false #elseif (cs || java) Reflect.hasField(obj, "TJ_noEncode") #else obj.TJ_noEncode != null #end  ) {
					dontEncodeFields = obj.TJ_noEncode();
				}
			default: //no lol
		}

		for (field in fields) {
			if(dontEncodeFields!=null && dontEncodeFields.indexOf(field)>=0)continue;
			var value:Dynamic = Reflect.field(obj,field);
			var vStr:String = encodeValue(value, style, depth);

			if(vStr!=null) {
				if(fieldCount++ > 0) buffer.add(style.entrySeperator(depth));
				else buffer.add(style.firstEntry(depth));
				buffer.add('"' + field + '"' + style.keyValueSeperator(depth) + vStr);
			}	
		}
		
		buffer.add(style.endObject(depth));
		return buffer.toString();
	}

	private function encodeMap(obj:Map<Dynamic, Dynamic>, style:EncodeStyle, depth:Int):String {
		var buffer = new StringBuf();
		buffer.add(style.beginObject(depth));
		
		var fieldCount = 0;
		for (field in obj.keys()) {
			if(fieldCount++ > 0) buffer.add(style.entrySeperator(depth));
			else buffer.add(style.firstEntry(depth));
			var value:Dynamic = obj.get(field);
			buffer.add('"' + field + '"' + style.keyValueSeperator(depth));
			buffer.add(encodeValue(value, style, depth));
		}
		buffer.add(style.endObject(depth));
		return buffer.toString();
	}

	private function encodeIterable(obj:Iterable<Dynamic>, style:EncodeStyle, depth:Int):String {
		var buffer = new StringBuf();
		buffer.add(style.beginArray(depth));
		
		var fieldCount = 0;
		for (value in obj) {
			if(fieldCount++ >0) buffer.add(style.entrySeperator(depth));
			else buffer.add(style.firstEntry(depth));
			buffer.add(encodeValue(value, style, depth));
		}
		buffer.add(style.endArray(depth));
		return buffer.toString();
	}

	private function cacheEncode(value:Dynamic):String{
		if(!uCache)return null;

		for(c in 0...cache.length) {
			if(cache[c] == value) {
				return '"' + TJSON.OBJECT_REFERENCE_PREFIX + c + '"';
			}
		}
		cache.push(value);
		return null;
	}

	private function encodeValue( value:Dynamic, style:EncodeStyle, depth:Int):String {
		if(Std.isOfType(value, Int) || Std.isOfType(value, Float))
			return(value);
		else if(Std.isOfType(value, Array) || Std.isOfType(value, List)) {
			var v:Array<Dynamic> = value;
			return encodeIterable(v, style, depth + 1);
		}
		else if(Std.isOfType(value,List)) {
			var v:List<Dynamic> = value;
			return encodeIterable(v, style, depth + 1);
		}
		else if(Std.isOfType(value, haxe.ds.StringMap))
			return encodeMap(value, style, depth + 1);
		else if(Std.isOfType(value, String))
			return('"' + Std.string(value).replace("\\","\\\\").replace("\n","\\n").replace("\r","\\r").replace('"','\\"') + '"');
		else if(Std.isOfType(value, Bool))
			return(value);
		else if(Reflect.isObject(value)) {
			var ret = cacheEncode(value);
			if(ret != null) return ret;
			return encodeObject(value, style, depth + 1);
		}
		else if(value == null)
			return("null");
		else
			return null;
	}
}