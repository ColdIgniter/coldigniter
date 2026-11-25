<!---
 * Optimize settings.
--->
<cfcomponent output="no" hint="Optimize settings">

	<!---
	 * Config caching.
	 *
	 * Not ported yet: nothing reads this setting.
	--->
	<cfset this.configCacheEnabled = false>

	<!---
	 * Enables caching of the file locator results (FileLocatorCached),
	 * kept by the cache service.
	--->
	<cfset this.locatorCacheEnabled = false>

</cfcomponent>
