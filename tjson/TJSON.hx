
package tjson;

using StringTools;

class TJSON {    
	public static final OBJECT_REFERENCE_PREFIX = "@~obRef#";
	
	/**
	 * Parses a JSON string into a haxe dynamic object or array.
	 * @param String - The JSON string to parse
	 * @param String the file name to whic the JSON code belongs. Used for generating nice error messages.
	 */
	public static function parse(json:String, ?fileName:String="JSON Data", ?stringProcessor:String->Dynamic = null):Dynamic{
        var t = new TJSONParser(json, fileName, stringProcessor);
		return t.doParse();
	}

	/**
	 * Serializes a dynamic object or an array into a JSON string.
	 * @param Dynamic - The object to be serialized
	 * @param Dynamic - The style to use. Either an object implementing EncodeStyle interface or the strings 'fancy' or 'simple'.
	 */
	public static function encode(obj:Dynamic, ?style:Dynamic=null, useCache:Bool=true):String{
		var t = new TJSONEncoder(useCache);
		return t.doEncode(obj,style);
	}
}