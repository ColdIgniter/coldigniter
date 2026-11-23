<!---
 * Class JSONFormatter
 *
 * Difference: the platform has no JSON functions (see the json_encode
 * polyfill, which has no flags and escapes more than this needs), so the
 * text is built here, as json_encode() with the flags of the original
 * would. The type of a value comes from its Java class, as in the
 * polyfill: a Boolean gives true or false, a Double, Integer or Long gives
 * a number, a list (ArrayNew) gives a list, a map or struct gives an
 * object, or a list when its keys are 0, 1, 2 ... in order (as an array of
 * the original), and everything else gives a string. A null is an empty
 * string (see is_null()). A component gives {}.
 *
 * Difference: of the flags only JSON_UNESCAPED_UNICODE (256),
 * JSON_UNESCAPED_SLASHES (64) and JSON_PRETTY_PRINT (128) are honoured,
 * the others are ignored. JSON_PARTIAL_OUTPUT_ON_ERROR is always on in the
 * original and changes nothing here, as an error is thrown for the two
 * kinds of error that can happen: a string that is not valid (a lone
 * surrogate stands in for malformed UTF-8) and a depth that is too deep.
 * The recursion error cannot happen, as there is no reference.
--->
<cfcomponent output="no" extends="FormatterInterface" hint="Formats data as JSON">

	<!---
	 * Takes the given data and formats it.
	 *
	 * @param data
	 *
	 * @return The JSON text
	--->
	<cffunction name="format" access="public" returntype="any" output="no">
		<cfargument name="data" type="any" required="yes">
		<cfset var cfg = new_("Config\Format")>
		<cfset var options = 320>

		<!--- JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES --->
		<cfif array_key_exists("application/json", cfg.formatterOptions)>
			<cfset options = cfg.formatterOptions["application/json"]>
		</cfif>

		<cfif request.ENVIRONMENT NEQ "production">
			<cfset options = BitOr(options, 128)> <!--- JSON_PRETTY_PRINT --->
		</cfif>

		<cfreturn encode(arguments.data, options, 1, cfg.jsonEncodeDepth)>
	</cffunction>

	<!---
	 * Encodes a value. The level is the depth of the value (1 for the
	 * top). The indent of a pretty print is four spaces per level.
	--->
	<cffunction name="encode" access="private" returntype="string" output="no">
		<cfargument name="value" type="any" required="yes">
		<cfargument name="options" type="numeric" required="yes">
		<cfargument name="level" type="numeric" required="yes">
		<cfargument name="depth" type="numeric" required="yes">
		<cfset var buf = CreateObject("java", "java.lang.StringBuffer").init()>
		<cfset var pretty = BitAnd(arguments.options, 128) NEQ 0>
		<cfset var cls = "">
		<cfset var keys = ArrayNew(1)>
		<cfset var it = "">
		<cfset var key = "">
		<cfset var isList = true>
		<cfset var isMap = false>
		<cfset var n = 0>
		<cfset var i = 0>
		<cfset var sep = ",">
		<cfset var pad = "">
		<cfset var padEnd = "">
		<cfset var item = "">
		<cfset var text = "">
		<cfset var ch = "">
		<cfset var c = 0>
		<cfset var hex = "">

		<cfif IsObject(arguments.value)>
			<cfreturn "{}">
		</cfif>

		<cfif IsArray(arguments.value) OR IsStruct(arguments.value)>
			<cfif arguments.level GT arguments.depth>
				<cfset static_("ColdIgniter\Format\Exceptions\FormatException").forInvalidJSON("Maximum stack depth exceeded")>
			</cfif>

			<cfif IsArray(arguments.value)>
				<cfset n = ArrayLen(arguments.value)>
			<cfelse>
				<cfset isMap = true>
				<cfif arguments.value.getClass().getName() EQ "java.util.LinkedHashMap">
					<cfset it = arguments.value.keySet().iterator()>
					<cfloop condition="it.hasNext()">
						<cfset ArrayAppend(keys, it.next())>
					</cfloop>
				<cfelse>
					<cfset keys = StructKeyArray(arguments.value)>
				</cfif>
				<cfset n = ArrayLen(keys)>
				<!--- a map with the keys 0, 1, 2 ... in order is a list, as an array of the original --->
				<cfloop from="1" to="#n#" index="i">
					<cfif Compare(keys[i] & "", i - 1) NEQ 0>
						<cfset isList = false>
						<cfbreak>
					</cfif>
				</cfloop>
			</cfif>

			<cfif n EQ 0>
				<cfreturn "[]">
			</cfif>

			<cfif pretty>
				<cfset pad = Chr(10) & RepeatString("    ", arguments.level)>
				<cfset padEnd = Chr(10) & RepeatString("    ", arguments.level - 1)>
				<cfset sep = "," & pad>
			</cfif>

			<cfif isMap AND isList>
				<cfset isMap = false>
			</cfif>

			<cfif isMap>
				<cfset buf.append("{")>
			<cfelse>
				<cfset buf.append("[")>
			</cfif>
			<cfset buf.append(pad)>

			<cfloop from="1" to="#n#" index="i">
				<cfif i GT 1>
					<cfset buf.append(sep)>
				</cfif>
				<cfif isMap>
					<cfset buf.append(encode(keys[i] & "", arguments.options, arguments.level + 1, arguments.depth))>
					<cfif pretty>
						<cfset buf.append(": ")>
					<cfelse>
						<cfset buf.append(":")>
					</cfif>
					<cfset item = arguments.value[keys[i]]>
				<cfelseif IsArray(arguments.value)>
					<cfset item = arguments.value[i]>
				<cfelse>
					<cfset item = arguments.value[keys[i]]>
				</cfif>
				<cfset buf.append(encode(item, arguments.options, arguments.level + 1, arguments.depth))>
			</cfloop>

			<cfset buf.append(padEnd)>
			<cfif isMap>
				<cfset buf.append("}")>
			<cfelse>
				<cfset buf.append("]")>
			</cfif>

			<cfreturn buf.toString()>
		</cfif>

		<cfset cls = arguments.value.getClass().getName()>

		<cfif cls EQ "java.lang.Boolean">
			<cfif arguments.value.booleanValue()>
				<cfreturn "true">
			</cfif>
			<cfreturn "false">
		</cfif>

		<cfif cls EQ "java.lang.Double" OR cls EQ "java.lang.Integer" OR cls EQ "java.lang.Long">
			<cfreturn Replace(arguments.value & "", ",", "", "all")>
		</cfif>

		<!--- a string: when nothing in it needs an escape it is quoted as it is --->
		<cfset text = arguments.value & "">

		<cfif REFind("[^ -~]", text) EQ 0 AND NOT Find("""", text) AND NOT Find("\", text) AND (NOT Find("/", text) OR BitAnd(arguments.options, 64) NEQ 0)>
			<cfreturn """" & text & """">
		</cfif>

		<cfset buf.append("""")>
		<cfset n = Len(text)>
		<cfset i = 1>
		<cfloop condition="i LTE n">
			<cfset ch = Mid(text, i, 1)>
			<cfset c = Asc(ch)>
			<cfif ch EQ """">
				<cfset buf.append("\""")>
			<cfelseif ch EQ "\">
				<cfset buf.append("\\")>
			<cfelseif ch EQ "/">
				<cfif BitAnd(arguments.options, 64) NEQ 0>
					<cfset buf.append("/")>
				<cfelse>
					<cfset buf.append("\/")>
				</cfif>
			<cfelseif c EQ 8>
				<cfset buf.append("\b")>
			<cfelseif c EQ 9>
				<cfset buf.append("\t")>
			<cfelseif c EQ 10>
				<cfset buf.append("\n")>
			<cfelseif c EQ 12>
				<cfset buf.append("\f")>
			<cfelseif c EQ 13>
				<cfset buf.append("\r")>
			<cfelseif c LT 32>
				<cfset hex = LCase(FormatBaseN(c, 16))>
				<cfset buf.append("\u" & RepeatString("0", 4 - Len(hex)) & hex)>
			<cfelseif c GTE 55296 AND c LTE 57343>
				<!--- a surrogate: only a high one followed by a low one is valid --->
				<cfif c GT 56319 OR i EQ n>
					<cfset static_("ColdIgniter\Format\Exceptions\FormatException").forInvalidJSON("Malformed UTF-8 characters, possibly incorrectly encoded")>
				</cfif>
				<cfset c = Asc(Mid(text, i + 1, 1))>
				<cfif c LT 56320 OR c GT 57343>
					<cfset static_("ColdIgniter\Format\Exceptions\FormatException").forInvalidJSON("Malformed UTF-8 characters, possibly incorrectly encoded")>
				</cfif>
				<cfif BitAnd(arguments.options, 256) NEQ 0>
					<cfset buf.append(ch & Mid(text, i + 1, 1))>
				<cfelse>
					<cfset hex = LCase(FormatBaseN(Asc(ch), 16))>
					<cfset buf.append("\u" & hex)>
					<cfset hex = LCase(FormatBaseN(c, 16))>
					<cfset buf.append("\u" & hex)>
				</cfif>
				<cfset i = i + 1>
			<cfelseif c GT 127 AND (BitAnd(arguments.options, 256) EQ 0 OR c EQ 8232 OR c EQ 8233)>
				<cfset hex = LCase(FormatBaseN(c, 16))>
				<cfset buf.append("\u" & RepeatString("0", 4 - Len(hex)) & hex)>
			<cfelse>
				<cfset buf.append(ch)>
			</cfif>
			<cfset i = i + 1>
		</cfloop>
		<cfset buf.append("""")>

		<cfreturn buf.toString()>
	</cffunction>

</cfcomponent>
