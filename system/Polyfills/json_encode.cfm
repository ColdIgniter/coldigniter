<!---
 * Returns the JSON representation of a value.
 *
 * Difference: the platform has no JSON functions and no null, and a literal
 * is always a string, so the type of a value is taken from its Java class:
 * a Boolean gives true or false, a Double, Integer or Long gives a number
 * and everything else gives a string. A map or struct gives an object (a
 * LinkedHashMap keeps the order of the keys) and an array gives a list.
 * Slashes are escaped, and so are the characters that could close a script
 * element, so the result is safe inside one.
 *
 * Not ported yet: the flags and the depth argument.
--->
<cffunction name="json_encode" returntype="string" output="no" hint="Returns the JSON representation of a value">
	<cfargument name="value" type="any" required="yes">
	<cfset var buf = CreateObject("java", "java.lang.StringBuffer").init()>
	<cfset var cls = "">
	<cfset var keys = "">
	<cfset var it = "">
	<cfset var key = "">
	<cfset var i = 0>
	<cfset var n = 0>
	<cfset var c = 0>
	<cfset var ch = "">
	<cfset var text = "">
	<cfset var hex = "">

	<cfif IsArray(arguments.value)>
		<cfset n = ArrayLen(arguments.value)>
		<cfset buf.append("[")>
		<cfloop from="1" to="#n#" index="i">
			<cfif i GT 1>
				<cfset buf.append(",")>
			</cfif>
			<cfset buf.append(json_encode(arguments.value[i]))>
		</cfloop>
		<cfset buf.append("]")>
		<cfreturn buf.toString()>
	</cfif>

	<cfif IsStruct(arguments.value)>
		<cfset buf.append("{")>
		<cfset i = 0>
		<cfif arguments.value.getClass().getName() EQ "java.util.LinkedHashMap">
			<cfset it = arguments.value.keySet().iterator()>
			<cfloop condition="it.hasNext()">
				<cfset key = it.next()>
				<cfif i GT 0>
					<cfset buf.append(",")>
				</cfif>
				<cfset buf.append(json_encode(key & "") & ":" & json_encode(arguments.value.get(key)))>
				<cfset i = i + 1>
			</cfloop>
		<cfelse>
			<cfset keys = StructKeyArray(arguments.value)>
			<cfloop from="1" to="#ArrayLen(keys)#" index="n">
				<cfif i GT 0>
					<cfset buf.append(",")>
				</cfif>
				<cfset buf.append(json_encode(keys[n]) & ":" & json_encode(arguments.value[keys[n]]))>
				<cfset i = i + 1>
			</cfloop>
		</cfif>
		<cfset buf.append("}")>
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

	<!---
	 a string: one search finds each character that needs an escape, and
	 the runs between them are copied whole. The pattern is compiled once
	 for each request.
	--->
	<cfif NOT StructKeyExists(request, "__jsonEncodeEscapes")>
		<cfset request.__jsonEncodeEscapes = CreateObject("java", "java.util.regex.Pattern").compile(JavaCast("string", "[^\x20-\x7e]|[""\\/<>&']"))>
	</cfif>
	<cfset text = JavaCast("string", arguments.value & "")>
	<cfset it = request.__jsonEncodeEscapes.matcher(text)>
	<cfset n = 0>
	<cfset buf.append("""")>
	<cfloop condition="it.find()">
		<cfset i = it.start()>
		<cfif i GT n>
			<cfset buf.append(text.substring(JavaCast("int", n), JavaCast("int", i)))>
		</cfif>
		<cfset n = it.end()>
		<cfset ch = it.group()>
		<cfset c = Asc(ch)>
		<cfif Compare(ch, """") EQ 0>
			<cfset buf.append("\""")>
		<cfelseif Compare(ch, "\") EQ 0>
			<cfset buf.append("\\")>
		<cfelseif Compare(ch, "/") EQ 0>
			<cfset buf.append("\/")>
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
		<cfelse>
			<cfset hex = UCase(FormatBaseN(c, 16))>
			<cfset buf.append("\u" & RepeatString("0", 4 - Len(hex)) & hex)>
		</cfif>
	</cfloop>
	<cfif Len(text) GT n>
		<cfset buf.append(text.substring(JavaCast("int", n)))>
	</cfif>
	<cfset buf.append("""")>

	<cfreturn buf.toString()>
</cffunction>
