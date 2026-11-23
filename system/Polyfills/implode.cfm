<!---
 * Joins array elements with a string. Empty elements are kept.
 *
 * The parts are collected in a string buffer: joining them with & copies
 * the whole text for every part, which takes far longer than the list grows.
--->
<cffunction name="implode" returntype="string" output="no" hint="Joins array elements with a string">
	<cfargument name="separator" type="string" required="yes">
	<cfargument name="array" type="array" required="yes">
	<cfset var buffer = CreateObject("java", "java.lang.StringBuffer").init()>
	<cfset var i = 0>

	<cfloop from="1" to="#ArrayLen(arguments.array)#" index="i">
		<cfif i GT 1>
			<cfset buffer.append(JavaCast("string", arguments.separator))>
		</cfif>

		<!--- the & gives a number or a boolean the text it has in a string --->
		<cfset buffer.append(JavaCast("string", arguments.array[i] & ""))>
	</cfloop>

	<cfreturn buffer.toString()>
</cffunction>
