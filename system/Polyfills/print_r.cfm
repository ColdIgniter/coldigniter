<!---
 * Returns information about a variable in a human-readable form, as
 * print_r() of the original does with its second argument set to true.
 *
 * A list is shown with its positions counted from zero. Objects are
 * not supported: a component is shown as "[object]".
--->
<cffunction name="print_r" returntype="string" output="no" hint="Returns information about a variable in a human-readable form">
	<cfargument name="value" type="any" required="yes">
	<cfargument name="indent" type="string" required="no" default="">
	<cfset var result = "">
	<cfset var key = "">
	<cfset var i = 0>
	<cfset var lf = Chr(10)>

	<cfif IsSimpleValue(arguments.value)>
		<cfreturn arguments.value>
	</cfif>

	<cfif NOT IsArray(arguments.value) AND NOT IsStruct(arguments.value)>
		<cfreturn "[object]">
	</cfif>

	<cfset result = "Array" & lf & arguments.indent & "(" & lf>

	<cfif IsArray(arguments.value)>
		<cfloop from="1" to="#ArrayLen(arguments.value)#" index="i">
			<cfset result = result & arguments.indent & "    [" & (i - 1) & "] => " & print_r(arguments.value[i], arguments.indent & "        ") & lf>
		</cfloop>
	<cfelse>
		<cfloop collection="#arguments.value#" item="key">
			<cfset result = result & arguments.indent & "    [" & key & "] => " & print_r(arguments.value[key], arguments.indent & "        ") & lf>
		</cfloop>
	</cfif>

	<cfreturn result & arguments.indent & ")" & lf>
</cffunction>
