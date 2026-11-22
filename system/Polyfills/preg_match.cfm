<!---
 * Compiles a pattern written as in the original, with a delimiter on both
 * ends and modifiers after the closing one: #^[0-9a-f]+$#i. The
 * modifiers i, s, m and x are applied; u and S are accepted and have no
 * effect (a string is Unicode here already).
 *
 * The pattern itself is a Java regular expression, which reads the same
 * as the original for the patterns the framework uses. Shared with
 * preg_replace().
 *
 * @return A java.util.regex.Pattern
--->
<cffunction name="preg_pattern" returntype="any" output="no" hint="Compiles a pattern written with delimiters and modifiers">
	<cfargument name="pattern" type="string" required="yes">
	<cfset var delimiter = Left(arguments.pattern, 1)>
	<cfset var last = 0>
	<cfset var body = "">
	<cfset var modifiers = "">
	<cfset var flags = 0>
	<cfset var i = 0>

	<cfloop from="#Len(arguments.pattern)#" to="2" index="i" step="-1">
		<cfif Compare(Mid(arguments.pattern, i, 1), delimiter) EQ 0>
			<cfset last = i>
			<cfbreak>
		</cfif>
	</cfloop>

	<cfif last EQ 0>
		<cfthrow type="ColdIgniter.ErrorException" message="preg: No ending delimiter '#delimiter#' found">
	</cfif>

	<cfset body = Mid(arguments.pattern, 2, last - 2)>
	<cfset modifiers = Mid(arguments.pattern, last + 1, Len(arguments.pattern))>

	<cfif Find("i", modifiers) GT 0>
		<cfset flags = BitOr(flags, 2)>
	</cfif>
	<cfif Find("m", modifiers) GT 0>
		<cfset flags = BitOr(flags, 8)>
	</cfif>
	<cfif Find("s", modifiers) GT 0>
		<cfset flags = BitOr(flags, 32)>
	</cfif>
	<cfif Find("x", modifiers) GT 0>
		<cfset flags = BitOr(flags, 4)>
	</cfif>

	<cfreturn CreateObject("java", "java.util.regex.Pattern").compile(JavaCast("string", body), JavaCast("int", flags))>
</cffunction>

<!---
 * Performs a regular expression match: 1 if the pattern matches the
 * subject, else 0. See preg_pattern() for the form of the pattern.
 *
 * Difference: the matches are not returned.
--->
<cffunction name="preg_match" returntype="numeric" output="no" hint="Performs a regular expression match">
	<cfargument name="pattern" type="string" required="yes">
	<cfargument name="subject" type="string" required="yes">

	<cfif preg_pattern(arguments.pattern).matcher(JavaCast("string", arguments.subject)).find()>
		<cfreturn 1>
	</cfif>

	<cfreturn 0>
</cffunction>
