<!---
 * Database collector
 *
 * Not ported yet: this collector, as there is no database layer. It is not
 * in the list of collectors in Config\Toolbar. The file keeps the place and
 * the properties of the original.
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
	 * The connections that were used, a list of connection names.
	--->
	<cfset this.connections = ArrayNew(1)>

	<!---
	 * The queries that were run, a list of maps.
	--->
	<cfset this.queries = ArrayNew(1)>

	<!--- Not ported yet: collect(query), formatTimelineData(), display(), getBadgeValue(), isEmpty(), icon() and the query hooks --->

</cfcomponent>
