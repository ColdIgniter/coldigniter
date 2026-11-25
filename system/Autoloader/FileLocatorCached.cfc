<!---
 * FileLocator with Cache
 *
 * This component also stands for FileLocatorInterface: there are no
 * interfaces, and FileLocator and this component have the same methods.
 *
 * The cache holds file paths and class names only, as plain text, never a
 * value of the configuration or a secret.
 *
 * Difference: the original saves the cache in __destruct(). There is no
 * destructor (cannot express), so saveCache() is public and ColdIgniter
 * calls it at the end of the request, after the post_system event, when
 * the locator exists. A change only sets a flag, so a request that finds
 * everything in the cache does no writing, and one that adds several
 * entries writes once. It is not an event listener, as a listener on
 * post_system would turn off the page cache in front (see ResponseCache).
 * A save that is lost, as the request ends in an error or an exit, only
 * means that the lookups are done again.
 *
 * Difference: the default cache handler is the cache service (the handler
 * of Config\Cache), where the original makes a FileVarExportHandler, which
 * is not ported.
 *
 * Difference: a result that is "not found" is an empty string, as in
 * FileLocator, so it is stored and read back as text.
 *
 * Difference: the names of a struct are not case-sensitive, and a path is,
 * so the key of an entry is Hash() of the arguments joined with Chr(1)
 * (performance and cannot express: one call and one level, where nested
 * structs by path, ext and prioritizeApp would need several; a Java map
 * would be exact too, but the cache handler has to keep plain structs).
--->
<cfcomponent output="no" hint="FileLocator with Cache">

	<cfset variables.locator = "">

	<cfset variables.cacheHandler = "">

	<!---
	 * Cache data
	 *
	 * [method => data]
	 * E.g.,
	 * [
	 *     "search" => [path => foundPaths],
	 * ]
	--->
	<cfset variables.cache = StructNew()>

	<!---
	 * Is the cache updated?
	--->
	<cfset variables.cacheUpdated = false>

	<cfset variables.cacheKey = "FileLocatorCache">

	<!---
	 * @param locator The FileLocator
	 * @param cache   The cache handler. An empty string (null) for the cache service.
	--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="locator" type="any" required="yes">
		<cfargument name="cache" type="any" required="no" default="">

		<cfset variables.locator = arguments.locator>

		<cfif is_null(arguments.cache)>
			<cfset variables.cacheHandler = service("cache")>
		<cfelse>
			<cfset variables.cacheHandler = arguments.cache>
		</cfif>

		<cfset loadCache()>

		<cfreturn this>
	</cffunction>

	<cffunction name="loadCache" access="private" returntype="void" output="no">
		<cfset var data = variables.cacheHandler.get(variables.cacheKey)>

		<cfif IsStruct(data)>
			<cfset variables.cache = data>
		</cfif>
	</cffunction>

	<!---
	 * Difference: public, see the top of this file. Not a destructor (cannot
	 * express).
	--->
	<cffunction name="saveCache" access="public" returntype="void" output="no">
		<cfif variables.cacheUpdated>
			<cfset variables.cacheHandler.save(variables.cacheKey, variables.cache, 3600 * 24)>
			<cfset variables.cacheUpdated = false>
		</cfif>
	</cffunction>

	<!---
	 * Not in the original. Notes that the cache has changed (see the top of
	 * this file).
	--->
	<cffunction name="updated" access="private" returntype="void" output="no">
		<cfset variables.cacheUpdated = true>
	</cffunction>

	<!---
	 * Not in the original. The struct of a method of the cache, made when
	 * it is missing.
	--->
	<cffunction name="section" access="private" returntype="any" output="no">
		<cfargument name="method" type="string" required="yes">

		<cfif NOT StructKeyExists(variables.cache, arguments.method)>
			<cfset variables.cache[arguments.method] = StructNew()>
		</cfif>

		<cfreturn variables.cache[arguments.method]>
	</cffunction>

	<!---
	 * Not in the original. The list that was stored for a key: a list of
	 * zero entries can come back from the cache as an empty map.
	--->
	<cffunction name="asList" access="private" returntype="array" output="no">
		<cfargument name="value" type="any" required="yes">

		<cfif IsArray(arguments.value)>
			<cfreturn arguments.value>
		</cfif>

		<cfreturn ArrayNew(1)>
	</cffunction>

	<!---
	 * Delete cache data
	--->
	<cffunction name="deleteCache" access="public" returntype="void" output="no">
		<cfset variables.cache = StructNew()>
		<cfset variables.cacheUpdated = false>
		<cfset variables.cacheHandler.delete(variables.cacheKey)>
	</cffunction>

	<!---
	 * Not in the original. The key of an entry (see the top of this file).
	--->
	<cffunction name="keyOf" access="private" returntype="string" output="no">
		<cfargument name="parts" type="string" required="yes">

		<cfreturn Hash(arguments.parts)>
	</cffunction>

	<!---
	 * Not in the original. Whether the cache has a value for the method and
	 * the key.
	--->
	<cffunction name="has" access="private" returntype="boolean" output="no">
		<cfargument name="method" type="string" required="yes">
		<cfargument name="key" type="string" required="yes">

		<cfreturn StructKeyExists(variables.cache, arguments.method) AND IsStruct(variables.cache[arguments.method]) AND StructKeyExists(variables.cache[arguments.method], arguments.key)>
	</cffunction>

	<cffunction name="findQualifiedNameFromPath" access="public" returntype="string" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfset var key = keyOf(arguments.path)>
		<cfset var classname = "">

		<cfif has("findQualifiedNameFromPath", key)>
			<cfreturn variables.cache["findQualifiedNameFromPath"][key]>
		</cfif>

		<cfset classname = variables.locator.findQualifiedNameFromPath(arguments.path)>

		<cfset section("findQualifiedNameFromPath")>
		<cfset variables.cache["findQualifiedNameFromPath"][key] = classname>
		<cfset updated()>

		<cfreturn classname>
	</cffunction>

	<cffunction name="getClassname" access="public" returntype="string" output="no">
		<cfargument name="file" type="string" required="yes">
		<cfset var key = keyOf(arguments.file)>
		<cfset var classname = "">

		<cfif has("getClassname", key)>
			<cfreturn variables.cache["getClassname"][key]>
		</cfif>

		<cfset classname = variables.locator.getClassname(arguments.file)>

		<cfset section("getClassname")>
		<cfset variables.cache["getClassname"][key] = classname>
		<cfset updated()>

		<cfreturn classname>
	</cffunction>

	<!---
	 * @return A list of paths
	--->
	<cffunction name="search" access="public" returntype="array" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfargument name="ext" type="string" required="no" default="cfm">
		<cfargument name="prioritizeApp" type="boolean" required="no" default="true">
		<cfset var flag = "0">
		<cfset var key = "">
		<cfset var foundPaths = "">

		<cfif arguments.prioritizeApp>
			<cfset flag = "1">
		</cfif>

		<cfset key = keyOf(arguments.path & Chr(1) & arguments.ext & Chr(1) & flag)>

		<cfif has("search", key)>
			<cfreturn asList(variables.cache["search"][key])>
		</cfif>

		<cfset foundPaths = variables.locator.search(arguments.path, arguments.ext, arguments.prioritizeApp)>

		<cfset section("search")>
		<cfset variables.cache["search"][key] = foundPaths>
		<cfset updated()>

		<cfreturn foundPaths>
	</cffunction>

	<cffunction name="listFiles" access="public" returntype="array" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfset var key = "">
		<cfset var files = "">

		<!--- as in FileLocator: nothing to list, nothing to keep --->
		<cfif arguments.path EQ "">
			<cfreturn ArrayNew(1)>
		</cfif>

		<cfset key = keyOf(arguments.path)>

		<cfif has("listFiles", key)>
			<cfreturn asList(variables.cache["listFiles"][key])>
		</cfif>

		<cfset files = variables.locator.listFiles(arguments.path)>

		<cfset section("listFiles")>
		<cfset variables.cache["listFiles"][key] = files>
		<cfset updated()>

		<cfreturn files>
	</cffunction>

	<cffunction name="listNamespaceFiles" access="public" returntype="array" output="no">
		<cfargument name="prefix" type="string" required="yes">
		<cfargument name="path" type="string" required="yes">
		<cfset var key = "">
		<cfset var files = "">

		<!--- as in FileLocator: nothing to list, nothing to keep --->
		<cfif arguments.path EQ "" OR arguments.prefix EQ "">
			<cfreturn ArrayNew(1)>
		</cfif>

		<cfset key = keyOf(arguments.prefix & Chr(1) & arguments.path)>

		<cfif has("listNamespaceFiles", key)>
			<cfreturn asList(variables.cache["listNamespaceFiles"][key])>
		</cfif>

		<cfset files = variables.locator.listNamespaceFiles(arguments.prefix, arguments.path)>

		<cfset section("listNamespaceFiles")>
		<cfset variables.cache["listNamespaceFiles"][key] = files>
		<cfset updated()>

		<cfreturn files>
	</cffunction>

	<cffunction name="locateFile" access="public" returntype="string" output="no">
		<cfargument name="file" type="string" required="yes">
		<cfargument name="folder" type="string" required="no" default="">
		<cfargument name="ext" type="string" required="no" default="cfm">
		<cfset var key = keyOf(arguments.file & Chr(1) & arguments.folder & Chr(1) & arguments.ext)>
		<cfset var files = "">

		<cfif has("locateFile", key)>
			<cfreturn variables.cache["locateFile"][key]>
		</cfif>

		<cfset files = variables.locator.locateFile(arguments.file, arguments.folder, arguments.ext)>

		<cfset section("locateFile")>
		<cfset variables.cache["locateFile"][key] = files>
		<cfset updated()>

		<cfreturn files>
	</cffunction>

</cfcomponent>
