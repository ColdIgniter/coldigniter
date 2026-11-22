<!---
 * Filters configuration
 *
 * The arrays of the original are maps (array_()) and lists (ArrayNew(1)).
--->
<cfcomponent output="no" extends="BaseConfig" hint="Filters configuration">

	<!---
	 * Configures aliases for Filter classes to
	 * make reading things nicer and simpler.
	 *
	 * [filter_name => classname]
	 * or [filter_name => [classname1, classname2, ...]]
	 *
	 * A map (see array_()) of strings, or of lists of strings.
	 *
	 * Not ported yet: csrf, toolbar, honeypot, pagecache and performance.
	 * The performance metrics are done inline in ColdIgniter.cfc and
	 * the others have no class yet. Cors is not ported yet either.
	--->
	<cfset this.aliases = CreateObject("java", "java.util.LinkedHashMap").init()>
	<!--- Not ported yet: csrf --->
	<!--- Not ported yet: toolbar --->
	<!--- Not ported yet: honeypot --->
	<cfset this.aliases["invalidchars"] = "ColdIgniter\Filters\InvalidChars">
	<cfset this.aliases["secureheaders"] = "ColdIgniter\Filters\SecureHeaders">
	<!--- Not ported yet: cors --->
	<cfset this.aliases["forcehttps"] = "ColdIgniter\Filters\ForceHTTPS">
	<!--- Not ported yet: pagecache --->
	<!--- Not ported yet: performance --->

	<!---
	 * List of special required filters.
	 *
	 * The filters listed here are special. They are applied before and after
	 * other kinds of filters, and always applied even if a route does not exist.
	 *
	 * Filters set by default provide framework functionality. If removed,
	 * those functions will no longer work.
	 *
	 * A map with the keys before and after, each a list of aliases.
	--->
	<cfset this.required = CreateObject("java", "java.util.LinkedHashMap").init()>
	<cfset this.required["before"] = ArrayNew(1)>
	<cfset ArrayAppend(this.required["before"], "forcehttps")> <!--- Force Global Secure Requests --->
	<!--- Not ported yet: pagecache (Web Page Caching) --->
	<cfset this.required["after"] = ArrayNew(1)>
	<!--- Not ported yet: pagecache (Web Page Caching) --->
	<!--- Not ported yet: performance (Performance Metrics) --->
	<!--- Not ported yet: toolbar (Debug Toolbar) --->

	<!---
	 * List of filter aliases that are always
	 * applied before and after every request.
	 *
	 * A map with the keys before and after. Each is either a list of aliases
	 * or a map of an alias to a map with the key except (a list of URI
	 * patterns, or a string).
	--->
	<cfset this.globals = CreateObject("java", "java.util.LinkedHashMap").init()>
	<cfset this.globals["before"] = ArrayNew(1)>
	<!--- 'honeypot', 'csrf' (not ported yet), 'invalidchars' --->
	<cfset this.globals["after"] = ArrayNew(1)>
	<!--- 'honeypot' (not ported yet), 'secureheaders' --->

	<!---
	 * List of filter aliases that works on a
	 * particular HTTP method (GET, POST, etc.).
	 *
	 * Example:
	 * a map with "POST" as the key and a list of aliases as the value.
	 *
	 * If you use this, you should disable auto-routing because auto-routing
	 * permits any HTTP method to access a controller. Accessing the controller
	 * with a method you don't expect could bypass the filter.
	--->
	<cfset this.methods = CreateObject("java", "java.util.LinkedHashMap").init()>

	<!---
	 * List of filter aliases that should run on any
	 * before or after URI patterns.
	 *
	 * Example:
	 * a map with "isLoggedIn" as the key and a map as the value, in which
	 * "before" is a list of patterns: account/*, profiles/*
	--->
	<cfset this.filters = CreateObject("java", "java.util.LinkedHashMap").init()>

</cfcomponent>
