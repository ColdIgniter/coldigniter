<!---
 * Adds the pairs of one value to a list of "name=value" parts. A map or a
 * list becomes name[key]=value, nested as deep as it goes. Shared with
 * http_build_query().
--->
<cffunction name="http_build_query_add" returntype="void" output="no" hint="Adds the query pairs of one value to a list">
	<cfargument name="parts" type="any" required="yes">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="value" type="any" required="yes">
	<cfset var keys = "">
	<cfset var i = 0>

	<cfif IsStruct(arguments.value)>
		<cfset keys = arguments.value.keySet().toArray()>
		<cfloop from="1" to="#ArrayLen(keys)#" index="i">
			<cfset http_build_query_add(arguments.parts, arguments.name & "[" & keys[i] & "]", arguments.value[keys[i]])>
		</cfloop>
	<cfelseif IsArray(arguments.value)>
		<cfloop from="1" to="#ArrayLen(arguments.value)#" index="i">
			<cfset http_build_query_add(arguments.parts, arguments.name & "[" & (i - 1) & "]", arguments.value[i])>
		</cfloop>
	<cfelse>
		<cfset ArrayAppend(arguments.parts, urlencode(arguments.name) & "=" & urlencode(arguments.value))>
	</cfif>
</cffunction>

<!---
 * Generates a url-encoded query string from a map (see array_()).
 *
 * The keys and values are encoded as urlencode() does it, and the pairs
 * are joined with an ampersand. A boolean is not turned into 1 or 0 as in
 * the original: it is written as the text it has here.
 *
 * Difference: only the data argument is taken (no prefix, separator or
 * encoding type).
--->
<cffunction name="http_build_query" returntype="string" output="no" hint="Generates a url-encoded query string">
	<cfargument name="data" type="any" required="yes">
	<cfset var parts = ArrayNew(1)>
	<cfset var keys = arguments.data.keySet().toArray()>
	<cfset var i = 0>

	<cfloop from="1" to="#ArrayLen(keys)#" index="i">
		<cfset http_build_query_add(parts, keys[i], arguments.data[keys[i]])>
	</cfloop>

	<cfreturn implode("&", parts)>
</cffunction>
