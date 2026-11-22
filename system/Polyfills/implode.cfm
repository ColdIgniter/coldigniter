<!---
 * Joins array elements with a string. Empty elements are kept.
--->
<cffunction name="implode" returntype="string" output="no" hint="Joins array elements with a string">
	<cfargument name="separator" type="string" required="yes">
	<cfargument name="array" type="array" required="yes">
	<cfset var result = "">
	<cfset var i = 0>

	<cfloop from="1" to="#ArrayLen(arguments.array)#" index="i">
		<cfif i GT 1>
			<cfset result = result & arguments.separator>
		</cfif>

		<cfset result = result & arguments.array[i]>
	</cfloop>

	<cfreturn result>
</cffunction>
