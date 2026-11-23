<!---
 * Collector for the Database tab of the Debug Toolbar.
 *
 * Difference: the queries are a static property in the original. Here they
 * are in the one object that stands in for the class,
 * static_("ColdIgniter\Debug\Toolbar\Collectors\Database"), and collect()
 * is called on that object (see app/Config/Events.cfm).
 *
 * Difference: there is no debug_backtrace(). The trace of a query is the
 * tagContext of an error that collect() throws and catches. A row has a
 * template, a line and an id. The id is a name of the engine and says
 * nothing about the code, so a row of the trace has no class and no
 * function name: its "function" is empty.
 *
 * Difference: the data of the toolbar is written to a file with an object
 * stream (see ColdIgniter\Debug\Toolbar), so display() and
 * formatTimelineData() give text and numbers only, never the Query.
--->
<cfcomponent output="no" extends="BaseCollector" hint="Collector for the Database tab of the Debug Toolbar">

	<!---
	 * Whether this collector has timeline data.
	--->
	<cfset this.hasTimeline = true>

	<!---
	 * Whether this collector should display its own tab.
	--->
	<cfset this.hasTabContent = true>

	<!---
	 * Whether this collector has data for the Vars tab.
	--->
	<cfset this.hasVarData = false>

	<!---
	 * The name used to reference this collector in the toolbar.
	--->
	<cfset this.title = "Database">

	<!---
	 * Array of database connections.
	 *
	 * A map of group name to BaseConnection, see array_().
	--->
	<cfset this.connections = "">

	<!---
	 * The query instances that have been collected
	 * through the DBQuery Event.
	 *
	 * A list of maps with the keys query, string, duplicate and trace. Only
	 * the list of the object of static_() is used (see the top of this file).
	--->
	<cfset this.queries = ArrayNew(1)>

	<!---
	 * Constructor
	--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfset getConnections()>

		<cfreturn this>
	</cffunction>

	<!---
	 * The static method used during Events to collect
	 * data.
	 *
	 * @internal
	--->
	<cffunction name="collect" access="public" returntype="void" output="no">
		<cfargument name="query" type="any" required="yes">
		<cfset var config = variables.config("Config\Toolbar")>
		<cfset var holder = static_("ColdIgniter\Debug\Toolbar\Collectors\Database")>
		<cfset var max = config.maxQueries>
		<cfset var queryString = "">
		<cfset var backtrace = ArrayNew(1)>
		<cfset var duplicate = false>
		<cfset var i = 0>

		<!--- Provide default in case it's not set --->
		<cfif max EQ 0>
			<cfset max = 100>
		</cfif>

		<!---
		 * The list is used through its holder: a list is copied when it is
		 * assigned or returned, and the new row would go into the copy.
		--->
		<cfif ArrayLen(holder.queries) LT max>
			<cfset queryString = arguments.query.getQuery()>

			<cfset backtrace = callTrace()>

			<cfloop from="1" to="#ArrayLen(holder.queries)#" index="i">
				<cfif Compare(holder.queries[i]["string"], queryString) EQ 0>
					<cfset duplicate = true>
					<cfbreak>
				</cfif>
			</cfloop>

			<cfset ArrayAppend(holder.queries, array_(
				"query", arguments.query,
				"string", queryString,
				"duplicate", duplicate,
				"trace", backtrace
			))>
		</cfif>
	</cffunction>

	<!---
	 * Returns timeline data formatted for the toolbar.
	 *
	 * @return A list of maps with the keys name, component, start and
	 *         duration, and query for a query
	--->
	<cffunction name="formatTimelineData" access="private" returntype="any" output="no">
		<cfset var data = ArrayNew(1)>
		<cfset var queries = staticQueries()>
		<cfset var it = this.connections.keySet().iterator()>
		<cfset var alias = "">
		<cfset var connection = "">
		<cfset var i = 0>

		<cfloop condition="it.hasNext()">
			<cfset alias = it.next()>
			<cfset connection = this.connections[alias]>

			<!--- Connection Time --->
			<cfset ArrayAppend(data, array_(
				"name", "Connecting to Database: """ & alias & """",
				"component", "Database",
				"start", connection.getConnectStart(),
				"duration", connection.getConnectDuration()
			))>
		</cfloop>

		<cfloop from="1" to="#ArrayLen(queries)#" index="i">
			<cfset ArrayAppend(data, array_(
				"name", "Query",
				"component", "Database",
				"start", queries[i]["query"].getStartTime(true),
				"duration", queries[i]["query"].getDuration(),
				"query", queries[i]["query"].debugToolbarDisplay()
			))>
		</cfloop>

		<cfreturn data>
	</cffunction>

	<!---
	 * Returns the data of this collector to be formatted in the toolbar
	 *
	 * @return A map with the key queries, a list of maps with the keys
	 *         hover, class, duration, sql, trace, trace-file and qid
	--->
	<cffunction name="display" access="public" returntype="any" output="no">
		<cfset var rows = ArrayNew(1)>
		<cfset var queries = staticQueries()>
		<cfset var nbsp = Chr(160)>
		<cfset var item = "">
		<cfset var isDuplicate = false>
		<cfset var firstNonSystemLine = "">
		<cfset var traceRows = "">
		<cfset var line = "">
		<cfset var row = "">
		<cfset var hover = "">
		<cfset var cssClass = "">
		<cfset var i = 0>
		<cfset var index = 0>

		<cfloop from="1" to="#ArrayLen(queries)#" index="i">
			<cfset item = queries[i]>
			<cfset isDuplicate = item["duplicate"] IS true>

			<cfset firstNonSystemLine = "">
			<cfset traceRows = ArrayNew(1)>

			<cfloop from="1" to="#ArrayLen(item["trace"])#" index="index">
				<cfset line = item["trace"][index]>
				<cfset row = array_()>

				<!--- simplify file and line --->
				<cfif Len(line["file"]) GT 0>
					<cfset row["file"] = clean_path(line["file"]) & ":" & line["line"]>
				<cfelse>
					<cfset row["file"] = "[internal function]">
				</cfif>

				<!--- find the first trace line that does not originate from `system/` --->
				<cfif Len(firstNonSystemLine) EQ 0 AND Find("SYSTEMPATH", row["file"]) EQ 0>
					<cfset firstNonSystemLine = row["file"]>
				</cfif>

				<!--- Difference: there is no class and no function, see the top of this file. --->
				<cfset row["function"] = RepeatString(nbsp, 8) & line["function"]>

				<!--- add index numbering padded with nonbreaking space --->
				<cfset row["index"] = Replace(RJustify(index, 3), " ", nbsp, "all") & RepeatString(nbsp, 4)>

				<cfset ArrayAppend(traceRows, row)>
			</cfloop>

			<cfset hover = "">
			<cfset cssClass = "">
			<cfif isDuplicate>
				<cfset hover = "This query was called more than once.">
				<cfset cssClass = "duplicate">
			</cfif>

			<!--- Difference: the time in the qid of the original is here the time and the place in the list. --->
			<cfset ArrayAppend(rows, array_(
				"hover", hover,
				"class", cssClass,
				"duration", (item["query"].getDuration(5) * 1000) & " ms",
				"sql", item["query"].debugToolbarDisplay(),
				"trace", traceRows,
				"trace-file", firstNonSystemLine,
				"qid", md5(item["string"] & microtime(true) & " " & i)
			))>
		</cfloop>

		<cfreturn array_("queries", rows)>
	</cffunction>

	<!---
	 * Gets the "badge" value for the button.
	--->
	<cffunction name="getBadgeValue" access="public" returntype="any" output="no">
		<cfreturn ArrayLen(staticQueries())>
	</cffunction>

	<!---
	 * Information to be displayed next to the title.
	 *
	 * @return The number of queries (in parentheses) or an empty string.
	--->
	<cffunction name="getTitleDetails" access="public" returntype="string" output="no">
		<cfset var queries = staticQueries()>
		<cfset var queryCount = 0>
		<cfset var uniqueCount = 0>
		<cfset var connectionCount = 0>
		<cfset var queryWord = "y">
		<cfset var uniqueWord = "">
		<cfset var connectionWord = "">
		<cfset var i = 0>

		<cfset getConnections()>

		<cfset queryCount = ArrayLen(queries)>
		<cfloop from="1" to="#queryCount#" index="i">
			<cfif NOT (queries[i]["duplicate"] IS true)>
				<cfset uniqueCount = uniqueCount + 1>
			</cfif>
		</cfloop>
		<cfset connectionCount = this.connections.size()>

		<cfif queryCount GT 1>
			<cfset queryWord = "ies">
		</cfif>
		<cfif uniqueCount GT 1>
			<cfset uniqueWord = "of them">
		</cfif>
		<cfif connectionCount GT 1>
			<cfset connectionWord = "s">
		</cfif>

		<cfreturn "(" & queryCount & " total Quer" & queryWord & ", " & uniqueCount & " " & uniqueWord & " unique across " & connectionCount & " Connection" & connectionWord & ")">
	</cffunction>

	<!---
	 * Does this collector have any data collected?
	--->
	<cffunction name="isEmpty" access="public" returntype="boolean" output="no">
		<cfreturn ArrayLen(staticQueries()) EQ 0>
	</cffunction>

	<!---
	 * Display the icon.
	 *
	 * Icon from https://icons8.com - 1em package
	--->
	<cffunction name="icon" access="public" returntype="string" output="no">
		<cfreturn "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAADMSURBVEhLY6A3YExLSwsA4nIycQDIDIhRWEBqamo/UNF/SjDQjF6ocZgAKPkRiFeEhoYyQ4WIBiA9QAuWAPEHqBAmgLqgHcolGQD1V4DMgHIxwbCxYD+QBqcKINseKo6eWrBioPrtQBq/BcgY5ht0cUIYbBg2AJKkRxCNWkDQgtFUNJwtABr+F6igE8olGQD114HMgHIxAVDyAhA/AlpSA8RYUwoeXAPVex5qHCbIyMgwBCkAuQJIY00huDBUz/mUlBQDqHGjgBjAwAAACexpph6oHSQAAAAASUVORK5CYII=">
	</cffunction>

	<!---
	 * Gets the connections from the database config
	--->
	<cffunction name="getConnections" access="private" returntype="void" output="no">
		<cfset this.connections = static_("ColdIgniter\Database\Config").getConnections()>
	</cffunction>

	<!---
	 * Reset collector state for worker mode.
	 * Clears collected queries between requests.
	--->
	<cffunction name="reset" access="public" returntype="void" output="no">
		<cfset var holder = static_("ColdIgniter\Debug\Toolbar\Collectors\Database")>

		<cfset ArrayClear(holder.queries)>
	</cffunction>

	<!---
	 * Returns the list of the queries (static::$queries of the original).
	 * It is a copy, for reading only: collect() and reset() change the list
	 * through its holder.
	 *
	 * Difference: this function is not in the original, see the top of
	 * this file.
	--->
	<cffunction name="staticQueries" access="private" returntype="any" output="no">
		<cfreturn static_("ColdIgniter\Debug\Toolbar\Collectors\Database").queries>
	</cffunction>

	<!---
	 * Returns the place of the call of a query, a list of maps with the
	 * keys file, line and function.
	 *
	 * Difference: this function stands in for debug_backtrace() and the
	 * array_slice() of the original. The rows of this file and of the
	 * Events class, which called it, are left out, and so are the rows
	 * without a file that the engine adds for a call by name.
	--->
	<cffunction name="callTrace" access="private" returntype="array" output="no">
		<cfset var rows = ArrayNew(1)>
		<cfset var context = "">
		<cfset var frame = "">
		<cfset var skip = true>
		<cfset var generated = false>
		<cfset var i = 0>

		<cftry>
			<cfthrow type="ColdIgniter.Debug.Trace" message="trace">

			<cfcatch type="ColdIgniter.Debug.Trace">
				<cfset context = cfcatch.tagContext>

				<cfloop from="1" to="#ArrayLen(context)#" index="i">
					<cfset frame = context[i]>

					<!--- The rows the engine adds for a call by name have no file. --->
					<cfif Left(frame.template, 1) EQ "<">
						<cfset generated = true>
					<cfelse>
						<cfset generated = false>
					</cfif>

					<cfif skip AND NOT generated AND REFindNoCase("[\\/](Collectors[\\/]Database|Events[\\/]Events)\.cfc$", frame.template) EQ 0>
						<cfset skip = false>
					</cfif>

					<cfif NOT skip AND NOT generated>
						<cfset ArrayAppend(rows, array_(
							"file", ToString(frame.template),
							"line", ToString(frame.line),
							"function", ""
						))>
					</cfif>
				</cfloop>
			</cfcatch>
		</cftry>

		<cfreturn rows>
	</cffunction>

</cfcomponent>
