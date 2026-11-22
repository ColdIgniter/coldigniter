<!---
 * Moves the position of a json reader past the white space.
 * The reader is a struct with the text, its length and the position.
--->
<cffunction name="json_skip" returntype="void" output="no" hint="Moves a json reader past white space">
	<cfargument name="reader" type="struct" required="yes">
	<cfset var white = " " & Chr(9) & Chr(10) & Chr(13)>

	<cfloop condition="arguments.reader.pos LTE arguments.reader.length AND Find(Mid(arguments.reader.text, arguments.reader.pos, 1), white) GT 0">
		<cfset arguments.reader.pos = arguments.reader.pos + 1>
	</cfloop>
</cffunction>

<!---
 * Reads a json string, the reader being on its opening quote.
--->
<cffunction name="json_string" returntype="string" output="no" hint="Reads a json string">
	<cfargument name="reader" type="struct" required="yes">
	<cfset var buffer = CreateObject("java", "java.lang.StringBuffer").init()>
	<cfset var found = 0>
	<cfset var character = "">
	<cfset var hex = "">

	<cfset arguments.reader.pos = arguments.reader.pos + 1>

	<cfloop condition="true">
		<cfset found = REFind("[""\\]", arguments.reader.text, arguments.reader.pos)>
		<cfif found EQ 0>
			<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
		</cfif>

		<cfset buffer.append(JavaCast("string", Mid(arguments.reader.text, arguments.reader.pos, found - arguments.reader.pos)))>
		<cfset character = Mid(arguments.reader.text, found, 1)>

		<cfif Compare(character, """") EQ 0>
			<cfset arguments.reader.pos = found + 1>
			<cfbreak>
		</cfif>

		<!--- a backslash --->
		<cfset character = Mid(arguments.reader.text, found + 1, 1)>
		<cfset arguments.reader.pos = found + 2>

		<cfif Compare(character, "n") EQ 0>
			<cfset buffer.append(JavaCast("string", Chr(10)))>
		<cfelseif Compare(character, "r") EQ 0>
			<cfset buffer.append(JavaCast("string", Chr(13)))>
		<cfelseif Compare(character, "t") EQ 0>
			<cfset buffer.append(JavaCast("string", Chr(9)))>
		<cfelseif Compare(character, "b") EQ 0>
			<cfset buffer.append(JavaCast("string", Chr(8)))>
		<cfelseif Compare(character, "f") EQ 0>
			<cfset buffer.append(JavaCast("string", Chr(12)))>
		<cfelseif Compare(character, "u") EQ 0>
			<cfset hex = Mid(arguments.reader.text, arguments.reader.pos, 4)>
			<cfif REFind("^[0-9A-Fa-f]{4}$", hex) EQ 0>
				<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
			</cfif>
			<cfset buffer.append(JavaCast("string", Chr(InputBaseN(hex, 16))))>
			<cfset arguments.reader.pos = arguments.reader.pos + 4>
		<cfelseif Compare(character, """") EQ 0 OR Compare(character, "\") EQ 0 OR Compare(character, "/") EQ 0>
			<cfset buffer.append(JavaCast("string", character))>
		<cfelse>
			<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
		</cfif>
	</cfloop>

	<cfreturn buffer.toString()>
</cffunction>

<!---
 * Reads one json value. When spans is a list, the members of the object
 * read here are recorded in it as structs with key, start and end (the
 * place of the first and of the last character of the member in the text).
--->
<cffunction name="json_value" returntype="any" output="no" hint="Reads a json value">
	<cfargument name="reader" type="struct" required="yes">
	<cfargument name="depth" type="numeric" required="yes">
	<cfargument name="spans" type="any" required="no" default="">
	<cfset var character = "">
	<cfset var result = "">
	<cfset var key = "">
	<cfset var span = "">
	<cfset var match = "">
	<cfset var token = "">

	<cfif arguments.depth GT arguments.reader.maxDepth>
		<cfthrow type="ColdIgniter.JsonException" message="Maximum stack depth exceeded">
	</cfif>

	<cfset json_skip(arguments.reader)>
	<cfif arguments.reader.pos GT arguments.reader.length>
		<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
	</cfif>

	<cfset character = Mid(arguments.reader.text, arguments.reader.pos, 1)>

	<cfif Compare(character, "{") EQ 0>
		<cfset result = CreateObject("java", "java.util.LinkedHashMap").init()>
		<cfset arguments.reader.pos = arguments.reader.pos + 1>
		<cfset json_skip(arguments.reader)>

		<cfif Compare(Mid(arguments.reader.text, arguments.reader.pos, 1), "}") EQ 0>
			<cfset arguments.reader.pos = arguments.reader.pos + 1>
			<cfreturn result>
		</cfif>

		<cfloop condition="true">
			<cfset json_skip(arguments.reader)>
			<cfif Compare(Mid(arguments.reader.text, arguments.reader.pos, 1), """") NEQ 0>
				<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
			</cfif>

			<cfset span = StructNew()>
			<cfset span.start = arguments.reader.pos>
			<cfset key = json_string(arguments.reader)>
			<cfset json_skip(arguments.reader)>

			<cfif Compare(Mid(arguments.reader.text, arguments.reader.pos, 1), ":") NEQ 0>
				<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
			</cfif>

			<cfset arguments.reader.pos = arguments.reader.pos + 1>
			<cfset result[key] = json_value(arguments.reader, arguments.depth + 1)>
			<cfset span.end = arguments.reader.pos - 1>
			<cfset span.key = key>
			<cfif IsArray(arguments.spans)>
				<cfset ArrayAppend(arguments.spans, span)>
			</cfif>

			<cfset json_skip(arguments.reader)>
			<cfset character = Mid(arguments.reader.text, arguments.reader.pos, 1)>
			<cfset arguments.reader.pos = arguments.reader.pos + 1>

			<cfif Compare(character, "}") EQ 0>
				<cfbreak>
			<cfelseif Compare(character, ",") NEQ 0>
				<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
			</cfif>
		</cfloop>

		<cfreturn result>
	</cfif>

	<cfif Compare(character, "[") EQ 0>
		<cfset result = ArrayNew(1)>
		<cfset arguments.reader.pos = arguments.reader.pos + 1>
		<cfset json_skip(arguments.reader)>

		<cfif Compare(Mid(arguments.reader.text, arguments.reader.pos, 1), "]") EQ 0>
			<cfset arguments.reader.pos = arguments.reader.pos + 1>
			<cfreturn result>
		</cfif>

		<cfloop condition="true">
			<cfset ArrayAppend(result, json_value(arguments.reader, arguments.depth + 1))>
			<cfset json_skip(arguments.reader)>
			<cfset character = Mid(arguments.reader.text, arguments.reader.pos, 1)>
			<cfset arguments.reader.pos = arguments.reader.pos + 1>

			<cfif Compare(character, "]") EQ 0>
				<cfbreak>
			<cfelseif Compare(character, ",") NEQ 0>
				<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
			</cfif>
		</cfloop>

		<cfreturn result>
	</cfif>

	<cfif Compare(character, """") EQ 0>
		<cfreturn json_string(arguments.reader)>
	</cfif>

	<!--- a number, true, false or null --->
	<cfset token = Mid(arguments.reader.text, arguments.reader.pos, 64)>
	<cfset match = REFind("^(-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][-+]?[0-9]+)?|true|false|null)", token, 1, true)>
	<cfif match.pos[1] EQ 0>
		<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
	</cfif>

	<cfset arguments.reader.pos = arguments.reader.pos + match.len[1]>

	<cfreturn Mid(token, 1, match.len[1])>
</cffunction>

<!---
 * Decodes a JSON string. Always as with JSON_THROW_ON_ERROR: a syntax error
 * throws ColdIgniter.JsonException.
 *
 * An object becomes a map (see array_()), a list becomes an ArrayNew(1).
 *
 * Difference: a number, true, false and null come back as the text they
 * are written with, as there are no such types here. A string and such a
 * scalar can not be told apart.
 *
 * Difference: the nesting is cut at a depth of 32 (the original allows 512),
 * to keep the recursion small.
 *
 * Difference: the optional spans argument is a list that is filled with
 * the members of the top-level object, as structs with key, start and end
 * (the place of the first and the last character of "key": value in the
 * text, counted from 1). It lets a caller cut a member out of the text
 * as it was written.
--->
<cffunction name="json_decode" returntype="any" output="no" hint="Decodes a JSON string">
	<cfargument name="json" type="string" required="yes">
	<cfargument name="spans" type="any" required="no" default="">
	<cfset var reader = StructNew()>
	<cfset var result = "">

	<cfset reader.text = arguments.json>
	<cfset reader.length = Len(arguments.json)>
	<cfset reader.pos = 1>
	<cfset reader.maxDepth = 32>

	<cfset result = json_value(reader, 1, arguments.spans)>
	<cfset json_skip(reader)>

	<cfif reader.pos LTE reader.length>
		<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
	</cfif>

	<cfreturn result>
</cffunction>
