<!---
 * Encodes a string as the RFC 3986 URL form: every character except
 * letters, digits and - _ . ~ becomes %XX (UTF-8 bytes). A space is %20.
--->
<cffunction name="rawurlencode" returntype="string" output="no" hint="URL-encodes a string according to RFC 3986">
	<cfargument name="string" type="string" required="yes">
	<cfset var encoded = CreateObject("java", "java.net.URLEncoder").encode(arguments.string, "UTF-8")>

	<!--- the encoder is the form variant: a plus is a space, and these three differ --->
	<cfset encoded = Replace(encoded, "+", "%20", "all")>
	<cfset encoded = Replace(encoded, "*", "%2A", "all")>
	<cfset encoded = Replace(encoded, "%7E", "~", "all")>

	<cfreturn encoded>
</cffunction>
