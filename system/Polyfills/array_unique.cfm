<!---
 * Removes duplicate values from a list. The first of each value is kept
 * and the order stays. The comparison is exact (case-sensitive). The
 * argument is not changed. Unlike the original, the result is renumbered.
--->
<cffunction name="array_unique" returntype="array" output="no" hint="Removes duplicate values from a list">
	<cfargument name="array" type="array" required="yes">
	<cfset var result = ArrayNew(1)>
	<cfset var i = 0>

	<cfloop from="1" to="#ArrayLen(arguments.array)#" index="i">
		<cfif NOT in_array(arguments.array[i], result)>
			<cfset ArrayAppend(result, arguments.array[i])>
		</cfif>
	</cfloop>

	<cfreturn result>
</cffunction>
