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
 * destructor, so saveCache() is public and is called by the post_system
 * event (see the first change of the cache). It is registered only when
 * something was added to the cache, so a request that finds everything in
 * the cache does no registering and no writing.
 *
 * Difference: the default cache handler is the cache service (the handler
 * of Config\Cache), where the original makes a FileVarExportHandler, which
 * is not ported.
 *
 * Difference: a result that is "not found" is an empty string, as in
 * FileLocator, so it is stored and read back as text. The key of
 * prioritizeApp is 1 or 0.
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

	<!--- Is saveCache() registered with the post_system event? --->
	<cfset variables.saveRegistered = false>

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
	 * Difference: public, see the top of this file.
	--->
	<cffunction name="saveCache" access="public" returntype="void" output="no">
		<cfif variables.cacheUpdated>
			<cfset variables.cacheHandler.save(variables.cacheKey, variables.cache, 3600 * 24)>
		</cfif>
	</cffunction>

	<!---
	 * Not in the original. Notes that the cache has changed, and makes
	 * sure that saveCache() runs at the end of the request.
	--->
	<cffunction name="updated" access="private" returntype="void" output="no">
		<cfset var pair = "">

		<cfset variables.cacheUpdated = true>

		<cfif NOT variables.saveRegistered>
			<cfset pair = ArrayNew(1)>
			<cfset ArrayAppend(pair, this)>
			<cfset ArrayAppend(pair, "saveCache")>
			<cfset static_("ColdIgniter\Events\Events").on("post_system", pair)>
			<cfset variables.saveRegistered = true>
		</cfif>
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

	<cffunction name="findQualifiedNameFromPath" access="public" returntype="string" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfset var classname = "">

		<cfif StructKeyExists(variables.cache, "findQualifiedNameFromPath") AND StructKeyExists(variables.cache["findQualifiedNameFromPath"], arguments.path)>
			<cfreturn variables.cache["findQualifiedNameFromPath"][arguments.path]>
		</cfif>

		<cfset classname = variables.locator.findQualifiedNameFromPath(arguments.path)>

		<cfset section("findQualifiedNameFromPath")>
		<cfset variables.cache["findQualifiedNameFromPath"][arguments.path] = classname>
		<cfset updated()>

		<cfreturn classname>
	</cffunction>

	<cffunction name="getClassname" access="public" returntype="string" output="no">
		<cfargument name="file" type="string" required="yes">
		<cfset var classname = "">

		<cfif StructKeyExists(variables.cache, "getClassname") AND StructKeyExists(variables.cache["getClassname"], arguments.file)>
			<cfreturn variables.cache["getClassname"][arguments.file]>
		</cfif>

		<cfset classname = variables.locator.getClassname(arguments.file)>

		<cfset section("getClassname")>
		<cfset variables.cache["getClassname"][arguments.file] = classname>
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
		<cfset var foundPaths = "">
		<cfset var key = "0">
		<cfset var entry = "">

		<cfif arguments.prioritizeApp>
			<cfset key = "1">
		</cfif>

		<cfif StructKeyExists(variables.cache, "search") AND StructKeyExists(variables.cache["search"], arguments.path)>
			<cfset entry = variables.cache["search"][arguments.path]>

			<cfif StructKeyExists(entry, arguments.ext) AND StructKeyExists(entry[arguments.ext], key)>
				<cfreturn asList(entry[arguments.ext][key])>
			</cfif>
		</cfif>

		<cfset foundPaths = variables.locator.search(arguments.path, arguments.ext, arguments.prioritizeApp)>

		<cfset section("search")>

		<cfif NOT StructKeyExists(variables.cache["search"], arguments.path)>
			<cfset variables.cache["search"][arguments.path] = StructNew()>
		</cfif>

		<cfif NOT StructKeyExists(variables.cache["search"][arguments.path], arguments.ext)>
			<cfset variables.cache["search"][arguments.path][arguments.ext] = StructNew()>
		</cfif>

		<cfset variables.cache["search"][arguments.path][arguments.ext][key] = foundPaths>
		<cfset updated()>

		<cfreturn foundPaths>
	</cffunction>

	<cffunction name="listFiles" access="public" returntype="array" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfset var files = "">

		<cfif StructKeyExists(variables.cache, "listFiles") AND StructKeyExists(variables.cache["listFiles"], arguments.path)>
			<cfreturn asList(variables.cache["listFiles"][arguments.path])>
		</cfif>

		<cfset files = variables.locator.listFiles(arguments.path)>

		<cfset section("listFiles")>
		<cfset variables.cache["listFiles"][arguments.path] = files>
		<cfset updated()>

		<cfreturn files>
	</cffunction>

	<cffunction name="listNamespaceFiles" access="public" returntype="array" output="no">
		<cfargument name="prefix" type="string" required="yes">
		<cfargument name="path" type="string" required="yes">
		<cfset var files = "">

		<cfif StructKeyExists(variables.cache, "listNamespaceFiles") AND StructKeyExists(variables.cache["listNamespaceFiles"], arguments.prefix) AND StructKeyExists(variables.cache["listNamespaceFiles"][arguments.prefix], arguments.path)>
			<cfreturn asList(variables.cache["listNamespaceFiles"][arguments.prefix][arguments.path])>
		</cfif>

		<cfset files = variables.locator.listNamespaceFiles(arguments.prefix, arguments.path)>

		<cfset section("listNamespaceFiles")>

		<cfif NOT StructKeyExists(variables.cache["listNamespaceFiles"], arguments.prefix)>
			<cfset variables.cache["listNamespaceFiles"][arguments.prefix] = StructNew()>
		</cfif>

		<cfset variables.cache["listNamespaceFiles"][arguments.prefix][arguments.path] = files>
		<cfset updated()>

		<cfreturn files>
	</cffunction>

	<cffunction name="locateFile" access="public" returntype="string" output="no">
		<cfargument name="file" type="string" required="yes">
		<cfargument name="folder" type="string" required="no" default="">
		<cfargument name="ext" type="string" required="no" default="cfm">
		<cfset var folderKey = arguments.folder>
		<cfset var files = "">
		<cfset var entry = "">

		<!--- an empty key is not a key of a struct: the key of no folder is a single dash, which no folder name is --->
		<cfif folderKey EQ "">
			<cfset folderKey = "-">
		</cfif>

		<cfif StructKeyExists(variables.cache, "locateFile") AND StructKeyExists(variables.cache["locateFile"], arguments.file)>
			<cfset entry = variables.cache["locateFile"][arguments.file]>

			<cfif StructKeyExists(entry, folderKey) AND StructKeyExists(entry[folderKey], arguments.ext)>
				<cfreturn entry[folderKey][arguments.ext]>
			</cfif>
		</cfif>

		<cfset files = variables.locator.locateFile(arguments.file, arguments.folder, arguments.ext)>

		<cfset section("locateFile")>

		<cfif NOT StructKeyExists(variables.cache["locateFile"], arguments.file)>
			<cfset variables.cache["locateFile"][arguments.file] = StructNew()>
		</cfif>

		<cfif NOT StructKeyExists(variables.cache["locateFile"][arguments.file], folderKey)>
			<cfset variables.cache["locateFile"][arguments.file][folderKey] = StructNew()>
		</cfif>

		<cfset variables.cache["locateFile"][arguments.file][folderKey][arguments.ext] = files>
		<cfset updated()>

		<cfreturn files>
	</cffunction>

</cfcomponent>
