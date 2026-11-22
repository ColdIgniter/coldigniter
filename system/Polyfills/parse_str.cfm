<!---
 * Parses a query string into an array with string keys (see array_()).
 *
 * Difference: the result is returned, as the original takes a second
 * argument to fill.
 *
 * The names are kept as they were sent, in their case. As in the
 * original, a dot or a space in the name before the first bracket
 * becomes an underscore, a[b]=1 makes a nested map, a[]=1 appends, and
 * a nested map whose keys are 0, 1, 2 ... is a list (an ArrayNew(1))
 * here. A name that repeats replaces the earlier value.
--->
<cffunction name="parse_str" returntype="any" output="no" hint="Parses a query string into an array with string keys">
	<cfargument name="string" type="string" required="yes">
	<cfset var result = CreateObject("java", "java.util.LinkedHashMap").init()>
	<cfset var nested = ArrayNew(1)>
	<cfset var pairs = explode("&", arguments.string)>
	<cfset var pair = "">
	<cfset var name = "">
	<cfset var value = "">
	<cfset var keys = "">
	<cfset var rest = "">
	<cfset var container = "">
	<cfset var child = "">
	<cfset var entry = "">
	<cfset var list = "">
	<cfset var key = "">
	<cfset var other = "">
	<cfset var found = true>
	<cfset var count = 0>
	<cfset var position = 0>
	<cfset var i = 0>
	<cfset var j = 0>

	<cfloop from="1" to="#ArrayLen(pairs)#" index="i">
		<cfset pair = pairs[i]>

		<cfif pair NEQ "">
			<cfset position = Find("=", pair)>
			<cfif position GT 0>
				<cfset name = Left(pair, position - 1)>
				<cfset value = substr(pair, position)>
			<cfelse>
				<cfset name = pair>
				<cfset value = "">
			</cfif>

			<cftry>
				<cfset name = URLDecode(name)>
				<cfcatch type="any"></cfcatch>
			</cftry>
			<cftry>
				<cfset value = URLDecode(value)>
				<cfcatch type="any"></cfcatch>
			</cftry>

			<cfset name = LTrim(name)>
			<cfset keys = ArrayNew(1)>
			<cfset rest = "">
			<cfset position = Find("[", name)>

			<cfif position GT 0 AND Find("]", name, position) GT 0>
				<cfset ArrayAppend(keys, Left(name, position - 1))>
				<cfset rest = substr(name, position - 1)>
			<cfelseif position GT 0>
				<!--- an opening bracket without a closing one is part of the name --->
				<cfset ArrayAppend(keys, Left(name, position - 1) & "_" & substr(name, position))>
			<cfelse>
				<cfset ArrayAppend(keys, name)>
			</cfif>

			<cfset keys[1] = Replace(Replace(keys[1], ".", "_", "all"), " ", "_", "all")>

			<cfloop condition="Left(rest, 1) EQ '[' AND Find(']', rest) GT 0">
				<cfset position = Find("]", rest)>
				<cfset ArrayAppend(keys, Mid(rest, 2, position - 2))>
				<cfset rest = substr(rest, position)>
			</cfloop>

			<cfif keys[1] NEQ "">
				<cfset container = result>

				<cfloop from="1" to="#ArrayLen(keys)#" index="j">
					<cfset key = keys[j]>

					<!--- an empty pair of brackets appends, with the next free number --->
					<cfif key EQ "" AND j GT 1>
						<cfset count = 0>
						<cfloop collection="#container#" item="other">
							<cfif REFind("^[0-9]+$", other) GT 0 AND Val(other) GTE count>
								<cfset count = Val(other) + 1>
							</cfif>
						</cfloop>
						<cfset key = ToString(count)>
					</cfif>

					<cfif j EQ ArrayLen(keys)>
						<cfset container[key] = value>
					<cfelse>
						<cfif NOT StructKeyExists(container, key) OR NOT IsStruct(container[key])>
							<cfset child = CreateObject("java", "java.util.LinkedHashMap").init()>
							<cfset entry = StructNew()>
							<cfset entry.parent = container>
							<cfset entry.key = key>
							<cfset entry.node = child>
							<cfset ArrayAppend(nested, entry)>
							<cfset container[key] = child>
						</cfif>

						<cfset container = container[key]>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
	</cfloop>

	<!--- A map whose keys are 0, 1, 2 ... becomes a list. The children come first. --->
	<cfloop from="#ArrayLen(nested)#" to="1" index="i" step="-1">
		<cfset entry = nested[i]>
		<cfset count = StructCount(entry.node)>
		<cfset found = true>

		<cfloop from="0" to="#count - 1#" index="j">
			<cfif NOT StructKeyExists(entry.node, ToString(j))>
				<cfset found = false>
			</cfif>
		</cfloop>

		<cfset child = "">
		<cfif StructKeyExists(entry.parent, entry.key)>
			<cfset child = entry.parent[entry.key]>
		</cfif>

		<cfif found AND IsStruct(child) AND child.equals(entry.node)>
			<cfset list = ArrayNew(1)>

			<cfloop from="0" to="#count - 1#" index="j">
				<cfset ArrayAppend(list, entry.node[ToString(j)])>
			</cfloop>

			<cfset entry.parent[entry.key] = list>
		</cfif>
	</cfloop>

	<cfreturn result>
</cffunction>
