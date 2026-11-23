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
 * Difference: the nesting is cut at a depth of 32 (the original allows 512).
 *
 * Difference: the optional spans argument is a list that is filled with
 * the members of the top-level object, as structs with key, start and end
 * (the place of the first and the last character of "key": value in the
 * text, counted from 1). It lets a caller cut a member out of the text
 * as it was written.
 *
 * The text is read by one function with its own stack, one token for each
 * match of a Java regular expression, as a function call costs much more
 * here than the work of a token. The matchers search the text in place:
 * REFind() with a start place was found to take time with the length of the
 * whole text on each call. A string is read in runs up to the next quote,
 * backslash or control character, not by the token expression, so a long
 * string can not overflow the stack of the regular expression engine.
 *
 * The open lists and maps are kept in a java.util.ArrayList and filled with
 * their own add() and put() methods, so a list is never copied while it is
 * being filled. A closed one leaves its slot, which the next one opened at
 * that depth takes over.
--->
<cffunction name="json_decode" returntype="any" output="no" hint="Decodes a JSON string">
	<cfargument name="json" type="string" required="yes">
	<cfargument name="spans" type="any" required="no" default="">
	<cfset var text = arguments.json>
	<cfset var length = Len(arguments.json)>
	<cfset var maxDepth = 32>
	<cfset var regex = CreateObject("java", "java.util.regex.Pattern")>
	<cfset var token = regex.compile(JavaCast("string", "[ \t\r\n]*(?:([{}\[\],:""])|(-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][-+]?[0-9]+)?|true|false|null))")).matcher(JavaCast("string", text))>
	<cfset var stop = regex.compile(JavaCast("string", "[""\\\x00-\x1f]")).matcher(JavaCast("string", text))>
	<cfset var white = regex.compile(JavaCast("string", "[^ \t\r\n]")).matcher(JavaCast("string", text))>
	<cfset var containers = CreateObject("java", "java.util.ArrayList").init()>
	<cfset var kinds = CreateObject("java", "java.util.ArrayList").init()>
	<cfset var keys = CreateObject("java", "java.util.ArrayList").init()>
	<cfset var starts = CreateObject("java", "java.util.ArrayList").init()>
	<cfset var buffer = "">
	<cfset var expect = "value">
	<cfset var pos = 1>
	<cfset var top = -1>
	<cfset var at = 0>
	<cfset var found = 0>
	<cfset var character = "">
	<cfset var hex = "">
	<cfset var value = "">
	<cfset var haveValue = false>
	<cfset var valueEnd = 0>
	<cfset var result = "">
	<cfset var done = false>
	<cfset var span = "">
	<cfset var container = "">
	<cfset var kind = "">

	<!---
	 expect is what may come next: "value", "valueOrClose" (just after [),
	 "key", "keyOrClose" (just after {), "colon", or "next" (a comma or the
	 end of the open list or map).
	--->
	<cfloop condition="NOT done">
		<cfif pos GT length>
			<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
		</cfif>

		<cfif NOT token.find(JavaCast("int", pos - 1)) OR token.start() NEQ pos - 1>
			<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
		</cfif>

		<cfset haveValue = false>

		<!--- as in the original, a value that is too deep fails before it is read; a ] that closes an empty list is not a value --->
		<cfif Compare(expect, "value") EQ 0 OR Compare(expect, "valueOrClose") EQ 0>
			<cfif top + 2 GT maxDepth>
				<cfif Compare(expect, "value") EQ 0 OR token.start(JavaCast("int", 1)) LT 0>
					<cfthrow type="ColdIgniter.JsonException" message="Maximum stack depth exceeded">
				</cfif>
				<cfset at = token.start(JavaCast("int", 1)) + 1>
				<cfif Compare(Mid(text, at, 1), "]") NEQ 0>
					<cfthrow type="ColdIgniter.JsonException" message="Maximum stack depth exceeded">
				</cfif>
			</cfif>
		</cfif>

		<cfif token.start(JavaCast("int", 2)) GTE 0>
			<!--- a number, true, false or null --->
			<cfif Compare(expect, "value") NEQ 0 AND Compare(expect, "valueOrClose") NEQ 0>
				<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
			</cfif>
			<cfset value = token.group(JavaCast("int", 2))>
			<cfset pos = token.end() + 1>
			<cfset haveValue = true>
		<cfelse>
			<cfset at = token.start(JavaCast("int", 1)) + 1>
			<cfset character = Mid(text, at, 1)>
			<cfset pos = at + 1>

			<cfif Compare(character, """") EQ 0>
				<cfif Compare(expect, "colon") EQ 0 OR Compare(expect, "next") EQ 0>
					<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
				</cfif>

				<!--- the string, in runs up to a quote, a backslash or a control character below 0x20 --->
				<cfset buffer = CreateObject("java", "java.lang.StringBuffer").init()>
				<cfloop condition="true">
					<cfset found = 0>
					<cfif pos LTE length AND stop.find(JavaCast("int", pos - 1))>
						<cfset found = stop.start() + 1>
					</cfif>
					<cfif found EQ 0>
						<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
					</cfif>

					<cfif found GT pos>
						<cfset buffer.append(JavaCast("string", Mid(text, pos, found - pos)))>
					</cfif>
					<cfset character = Mid(text, found, 1)>

					<cfif Compare(character, """") EQ 0>
						<cfset pos = found + 1>
						<cfbreak>
					</cfif>

					<!--- a raw control character inside a string is malformed --->
					<cfif Compare(character, "\") NEQ 0>
						<cfthrow type="ColdIgniter.JsonException" message="Control character error, possibly incorrectly encoded">
					</cfif>

					<!--- a backslash --->
					<cfset character = Mid(text, found + 1, 1)>
					<cfset pos = found + 2>

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
						<cfset hex = Mid(text, pos, 4)>
						<cfif REFind("^[0-9A-Fa-f]{4}$", hex) EQ 0>
							<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
						</cfif>
						<cfset buffer.append(JavaCast("string", Chr(InputBaseN(hex, 16))))>
						<cfset pos = pos + 4>
					<cfelseif Compare(character, """") EQ 0 OR Compare(character, "\") EQ 0 OR Compare(character, "/") EQ 0>
						<cfset buffer.append(JavaCast("string", character))>
					<cfelse>
						<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
					</cfif>
				</cfloop>

				<cfif Compare(expect, "key") EQ 0 OR Compare(expect, "keyOrClose") EQ 0>
					<cfset keys.set(JavaCast("int", top), buffer.toString())>
					<cfset starts.set(JavaCast("int", top), JavaCast("int", at))>
					<cfset expect = "colon">
				<cfelse>
					<cfset value = buffer.toString()>
					<cfset haveValue = true>
				</cfif>
			<cfelseif Compare(character, ":") EQ 0>
				<cfif Compare(expect, "colon") NEQ 0>
					<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
				</cfif>
				<cfset expect = "value">
			<cfelseif Compare(character, ",") EQ 0>
				<cfif Compare(expect, "next") NEQ 0>
					<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
				</cfif>
				<cfif Compare(kinds.get(JavaCast("int", top)), "o") EQ 0>
					<cfset expect = "key">
				<cfelse>
					<cfset expect = "value">
				</cfif>
			<cfelseif Compare(character, "{") EQ 0 OR Compare(character, "[") EQ 0>
				<cfif Compare(expect, "value") NEQ 0 AND Compare(expect, "valueOrClose") NEQ 0>
					<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
				</cfif>
				<cfif Compare(character, "{") EQ 0>
					<cfset container = CreateObject("java", "java.util.LinkedHashMap").init()>
					<cfset kind = "o">
					<cfset expect = "keyOrClose">
				<cfelse>
					<cfset container = ArrayNew(1)>
					<cfset kind = "a">
					<cfset expect = "valueOrClose">
				</cfif>
				<cfset top = top + 1>
				<!--- a slot left by a closed list or map is used again: remove() can not be called here, as it has two forms --->
				<cfif containers.size() GT top>
					<cfset containers.set(JavaCast("int", top), container)>
					<cfset kinds.set(JavaCast("int", top), kind)>
					<cfset keys.set(JavaCast("int", top), "")>
					<cfset starts.set(JavaCast("int", top), JavaCast("int", 0))>
				<cfelse>
					<cfset containers.add(container)>
					<cfset kinds.add(kind)>
					<cfset keys.add("")>
					<cfset starts.add(JavaCast("int", 0))>
				</cfif>
			<cfelse>
				<!--- } or ] --->
				<cfif top LT 0>
					<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
				</cfif>
				<cfif Compare(character, "}") EQ 0>
					<cfif Compare(kinds.get(JavaCast("int", top)), "o") NEQ 0 OR (Compare(expect, "next") NEQ 0 AND Compare(expect, "keyOrClose") NEQ 0)>
						<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
					</cfif>
				<cfelse>
					<cfif Compare(kinds.get(JavaCast("int", top)), "a") NEQ 0 OR (Compare(expect, "next") NEQ 0 AND Compare(expect, "valueOrClose") NEQ 0)>
						<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
					</cfif>
				</cfif>
				<cfset value = containers.get(JavaCast("int", top))>
				<cfset top = top - 1>
				<cfset haveValue = true>
			</cfif>
		</cfif>

		<cfif haveValue>
			<!--- the place of the last character of the value --->
			<cfset valueEnd = pos - 1>

			<cfif top LT 0>
				<cfset result = value>
				<cfset done = true>
			<cfelseif Compare(kinds.get(JavaCast("int", top)), "o") EQ 0>
				<cfset containers.get(JavaCast("int", top)).put(keys.get(JavaCast("int", top)), value)>
				<cfif top EQ 0 AND IsArray(arguments.spans)>
					<cfset span = StructNew()>
					<cfset span.start = starts.get(JavaCast("int", top))>
					<cfset span.end = valueEnd>
					<cfset span.key = keys.get(JavaCast("int", top))>
					<cfset ArrayAppend(arguments.spans, span)>
				</cfif>
				<cfset expect = "next">
			<cfelse>
				<cfset containers.get(JavaCast("int", top)).add(value)>
				<cfset expect = "next">
			</cfif>
		</cfif>
	</cfloop>

	<!--- only white space may follow --->
	<cfif pos LTE length AND white.find(JavaCast("int", pos - 1))>
		<cfthrow type="ColdIgniter.JsonException" message="Syntax error">
	</cfif>

	<cfreturn result>
</cffunction>
