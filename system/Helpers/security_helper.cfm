<!---
 * ColdIgniter Security Helpers
 *
 * Not ported yet: the function of the original that converts the opening
 * and closing tags of the server-side language of the original to
 * entities. Its name is that of the language, which is kept out of the
 * source here.
 *
 * A function here has no guard against a second definition (the original
 * checks function_exists): helper() keeps the first definition of a name.
--->

<!---
 * Sanitize Filename
 *
 * Tries to sanitize filenames in order to prevent directory traversal attempts
 * and other security threats, which is particularly useful for files that
 * were supplied via user input.
 *
 * If it is acceptable for the user input to include relative paths,
 * e.g. file/in/some/approved/folder.txt, you can set the second optional
 * parameter, relativePath to true.
 * Only forward slashes are preserved, backslashes are always removed.
 *
 * @param filename     Input file name
 * @param relativePath Whether to preserve paths
--->
<cffunction name="sanitize_filename" returntype="string" output="no" hint="Sanitize Filename">
	<cfargument name="filename" type="string" required="yes">
	<cfargument name="relativePath" type="boolean" required="no" default="false">
	<cfset var bad = ArrayNew(1)>
	<cfset var old = "">

	<!--- List of sanitized filename strings --->
	<cfset ArrayAppend(bad, "\")>
	<cfset ArrayAppend(bad, "../")>
	<cfset ArrayAppend(bad, "<!--")>
	<cfset ArrayAppend(bad, "-->")>
	<cfset ArrayAppend(bad, "<")>
	<cfset ArrayAppend(bad, ">")>
	<cfset ArrayAppend(bad, "'")>
	<cfset ArrayAppend(bad, """")>
	<cfset ArrayAppend(bad, "&")>
	<cfset ArrayAppend(bad, "$")>
	<cfset ArrayAppend(bad, "##")>
	<cfset ArrayAppend(bad, "{")>
	<cfset ArrayAppend(bad, "}")>
	<cfset ArrayAppend(bad, "[")>
	<cfset ArrayAppend(bad, "]")>
	<cfset ArrayAppend(bad, "=")>
	<cfset ArrayAppend(bad, ";")>
	<cfset ArrayAppend(bad, "?")>
	<cfset ArrayAppend(bad, "%20")>
	<cfset ArrayAppend(bad, "%22")>
	<cfset ArrayAppend(bad, "%3c")>
	<cfset ArrayAppend(bad, "%253c")>
	<cfset ArrayAppend(bad, "%3e")>
	<cfset ArrayAppend(bad, "%0e")>
	<cfset ArrayAppend(bad, "%28")>
	<cfset ArrayAppend(bad, "%29")>
	<cfset ArrayAppend(bad, "%2528")>
	<cfset ArrayAppend(bad, "%26")>
	<cfset ArrayAppend(bad, "%24")>
	<cfset ArrayAppend(bad, "%3f")>
	<cfset ArrayAppend(bad, "%3b")>
	<cfset ArrayAppend(bad, "%3d")>

	<cfif NOT arguments.relativePath>
		<cfset ArrayAppend(bad, "./")>
		<cfset ArrayAppend(bad, "/")>
	</cfif>

	<cfset arguments.filename = remove_invisible_characters(arguments.filename, false)>

	<cfloop condition="true">
		<cfset old = arguments.filename>
		<cfset arguments.filename = str_replace(bad, "", arguments.filename)>

		<cfif Compare(old, arguments.filename) EQ 0>
			<cfbreak>
		</cfif>
	</cfloop>

	<cfreturn arguments.filename>
</cffunction>

<!---
 * Strip Image Tags
 *
 * Difference: the class [^\1] of the original (a character that is not
 * the code 1, as the backslash-one is read there) is written [^\x01], as
 * the regular expressions of Java do not take [^\1].
 *
 * Difference: the lazy parts that the original writes .*? are written
 * [^<]*? here, and the quoted value [^\x01]+? is written [^<]+?, so that a
 * match never runs into the next tag. The Java engine has no backtrack
 * limit, and input such as <img src='a' repeated took time that grew about
 * with the cube of its length. A look-ahead (?=[^<]*>) right after <img makes
 * a start that has no > before the next < fail at once, which also cuts off
 * a single <img followed by many src parts and no >. A > inside a tag, as in
 * <img src="a>b" onerror=x>, is still matched as in the original. What the
 * original matches across a < is not matched here: a tag with a < in its text
 * (as in <img alt="<" src=x>) is left as it is, and a match that the original
 * spreads over several tags is made one tag at a time.
--->
<cffunction name="strip_image_tags" returntype="string" output="no" hint="Strip Image Tags">
	<cfargument name="str" type="string" required="yes">
	<cfset var patterns = ArrayNew(1)>

	<cfset ArrayAppend(patterns, "##<img(?=[^<]*>)[\s/]+[^<]*?src\s*=\s*([""'])([^<]+?)\1[^<]*?\>##i")>
	<cfset ArrayAppend(patterns, "##<img(?=[^<]*>)[\s/]+[^<]*?src\s*=\s*?(([^\s""'=<>`]+))[^<]*?\>##i")>

	<cfreturn preg_replace(patterns, "\2", arguments.str)>
</cffunction>
