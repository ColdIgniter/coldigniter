<!---
 * Returns part of a string.
 *
 * The offset starts at 0. Without a length, the rest of the string is
 * returned. Negative offsets and lengths are not supported.
--->
<cffunction name="substr" returntype="string" output="no" hint="Returns part of a string">
	<cfargument name="string" type="string" required="yes">
	<cfargument name="offset" type="numeric" required="yes">
	<cfargument name="length" type="numeric" required="no" default="-1">
	<cfset var rest = Len(arguments.string) - arguments.offset>

	<cfif rest LTE 0>
		<cfreturn "">
	</cfif>

	<cfif arguments.length GTE 0 AND arguments.length LT rest>
		<cfset rest = arguments.length>
	</cfif>

	<cfif rest EQ 0>
		<cfreturn "">
	</cfif>

	<cfreturn Mid(arguments.string, arguments.offset + 1, rest)>
</cffunction>
