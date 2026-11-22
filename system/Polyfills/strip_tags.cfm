<!---
 * Strips tags from a string.
 *
 * Every "<" up to the next ">" is removed. The finer rules of the
 * original (allowed tags, comments, a lone "<") are not ported.
--->
<cffunction name="strip_tags" returntype="string" output="no" hint="Strips tags from a string">
	<cfargument name="string" type="string" required="yes">

	<cfreturn REReplace(arguments.string, "<[^>]*>", "", "all")>
</cffunction>
