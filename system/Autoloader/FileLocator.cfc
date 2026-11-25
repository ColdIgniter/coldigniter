<!---
 * Allows loading non-class files in a namespaced manner.
 * Works with Helpers, Views, etc.
 *
 * FileLocatorInterface is not a file here: there are no interfaces, and
 * FileLocatorCached has the same methods (see FileLocatorCached).
 *
 * Difference: a method that returns a path or false in the original
 * (locateFile(), findQualifiedNameFromPath(), legacyLocate()) returns an
 * empty string for "not found", as realpath() does: there are no union
 * types, and an empty string is never a path.
 *
 * Difference: the default extension is "cfm", the extension of the files that are not classes.
 * Class files are .cfc, other files are .cfm.
 *
 * Not ported yet: helper("filesystem"), so listFiles() and
 * listNamespaceFiles() read the folder with getFilenames() of this
 * component, which does what get_filenames(path, true, false, false) does.
--->
<cfcomponent output="no" hint="Allows loading non-class files in a namespaced manner">

	<!---
	 * The Autoloader to use.
	--->
	<cfset this.autoloader = "">

	<!---
	 * List of classnames that did not exist.
	--->
	<cfset variables.invalidClassnames = ArrayNew(1)>

	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="autoloader" type="any" required="yes">

		<cfset this.autoloader = arguments.autoloader>

		<cfreturn this>
	</cffunction>

	<!---
	 * Attempts to locate a file by examining the name for a namespace
	 * and looking through the PSR-4 namespaced files that we know about.
	 *
	 * @param file   The relative file path or namespaced file to
	 *               locate. If not namespaced, search in the app
	 *               folder.
	 * @param folder The folder within the namespace that we should
	 *               look for the file. If file does not contain
	 *               this value, it will be appended to the namespace
	 *               folder. An empty string (null) for none.
	 * @param ext    The file extension the file should have.
	 *
	 * @return The path to the file, or an empty string if not found.
	--->
	<cffunction name="locateFile" access="public" returntype="string" output="no">
		<cfargument name="file" type="string" required="yes">
		<cfargument name="folder" type="string" required="no" default="">
		<cfargument name="ext" type="string" required="no" default="cfm">
		<cfset var namespaces = "">
		<cfset var namespace = "">
		<cfset var paths = ArrayNew(1)>
		<cfset var filename = "">
		<cfset var fileWithoutNamespace = "">
		<cfset var path = "">
		<cfset var i = 0>

		<cfset arguments.file = ensureExt(arguments.file, arguments.ext)>

		<!--- Clears the folder name if it is at the beginning of the filename --->
		<cfif NOT is_null(arguments.folder) AND str_starts_with(arguments.file, arguments.folder)>
			<cfset arguments.file = substr(arguments.file, Len(arguments.folder & "/"))>
		</cfif>

		<!--- Is not namespaced? Try the application folder. --->
		<cfif Find("\", arguments.file) EQ 0>
			<cfreturn legacyLocate(arguments.file, arguments.folder)>
		</cfif>

		<!--- Standardize slashes to handle nested directories. --->
		<cfset arguments.file = Replace(arguments.file, "/", "\", "all")>
		<cfset arguments.file = REReplace(arguments.file, "^\\+", "")>

		<!---
		 * Difference: the original splits the name into segments and removes an
		 * empty first one, but never reads the segments again. Left out, for
		 * performance.
		--->

		<!--- Namespaces always comes with arrays of paths --->
		<cfset namespaces = this.autoloader.getNamespace()>

		<cfloop collection="#namespaces#" item="namespace">
			<cfif Compare(Left(arguments.file, Len(namespace) + 1), namespace & "\") EQ 0>
				<cfset fileWithoutNamespace = substr(arguments.file, Len(namespace))>

				<!---
				 * There may be sub-namespaces of the same vendor,
				 * so overwrite them with namespaces found later.
				--->
				<cfset paths = namespaces[namespace]>
				<cfset filename = REReplace(Replace(fileWithoutNamespace, "\", "/", "all"), "^/+", "")>
			</cfif>
		</cfloop>

		<!--- if no namespaces matched then quit --->
		<cfif ArrayLen(paths) EQ 0>
			<cfreturn "">
		</cfif>

		<!--- Check each path in the namespace --->
		<cfloop from="1" to="#ArrayLen(paths)#" index="i">
			<!--- Ensure trailing slash --->
			<!---
			 * Difference: both kinds of slash are trimmed, as the folders of the
			 * autoloader end in the directory separator, which can be a backslash
			 * here. The original trims only "/" and so has "\/" in the path
			 * there (cannot express a path that is the same on both systems).
			--->
			<cfset path = REReplace(paths[i], "[\\/]+$", "") & "/">

			<!---
			 * If we have a folder name, then the calling function
			 * expects this file to be within that folder, like 'Views',
			 * or 'libraries'.
			--->
			<cfif NOT is_null(arguments.folder) AND Find("/" & arguments.folder & "/", path & filename) EQ 0>
				<cfset path = path & REReplace(arguments.folder, "^/+|/+$", "", "all") & "/">
			</cfif>

			<cfset path = path & filename>

			<cfif is_file(path)>
				<cfreturn path>
			</cfif>
		</cfloop>

		<cfreturn "">
	</cffunction>

	<!---
	 * Examines a file and returns the fully qualified class name.
	 *
	 * Difference: the original reads the tokens of the source file for the
	 * namespace and class declarations. A component has neither, so the
	 * name is the one the autoloader gives the file: the prefix of the
	 * namespace whose folder holds the file (the longest folder, when
	 * there are several), and the path below it without the ".cfc". A file
	 * that is not a .cfc, or that no namespace folder holds, has no class
	 * name (an empty string).
	--->
	<cffunction name="getClassname" access="public" returntype="string" output="no">
		<cfargument name="file" type="string" required="yes">
		<cfset var namespaces = "">
		<cfset var resolvedPath = "">
		<cfset var namespacePath = "">
		<cfset var best = "">
		<cfset var bestPath = "">
		<cfset var i = 0>

		<cfif CreateObject("java", "java.io.File").init(arguments.file).isDirectory()>
			<cfreturn "">
		</cfif>

		<cfif Compare(LCase(Right(arguments.file, 4)), ".cfc") NEQ 0>
			<cfreturn "">
		</cfif>

		<!--- a file that does not exist has no class --->
		<cfif NOT is_file(arguments.file)>
			<cfreturn "">
		</cfif>

		<cfset resolvedPath = realpath(arguments.file)>

		<cfif resolvedPath EQ "">
			<cfset resolvedPath = arguments.file>
		</cfif>

		<cfset namespaces = getNamespaces()>

		<cfloop from="1" to="#ArrayLen(namespaces)#" index="i">
			<cfset namespacePath = realpath(namespaces[i].path)>

			<cfif namespacePath EQ "">
				<cfset namespacePath = namespaces[i].path>
			</cfif>

			<!--- the folder must be a whole folder: /x/app does not hold /x/application/Foo.cfc --->
			<cfset namespacePath = REReplace(namespacePath, "[\\/]+$", "")>

			<cfif namespacePath NEQ "" AND Len(namespacePath) GT Len(bestPath) AND Compare(Left(resolvedPath, Len(namespacePath)), namespacePath) EQ 0 AND REFind("[\\/]", Mid(resolvedPath, Len(namespacePath) + 1, 1)) GT 0>
				<cfset best = namespaces[i].prefix & "\" & REReplace(Replace(Mid(resolvedPath, Len(namespacePath) + 2, Len(resolvedPath)), "/", "\", "all"), "^\\+", "")>
				<cfset bestPath = namespacePath>
			</cfif>
		</cfloop>

		<cfif best EQ "">
			<cfreturn "">
		</cfif>

		<!--- Remove the file extension (.cfc) --->
		<cfreturn Left(best, Len(best) - 4)>
	</cffunction>

	<!---
	 * Searches through all of the defined namespaces looking for a file.
	 * Returns an array of all found locations for the defined file.
	 *
	 * Example:
	 *
	 *  locator.search("Config/Routes.cfm")
	 *  // Assuming PSR4 namespaces include foo and bar, might return:
	 *  [
	 *      "app/Modules/foo/Config/Routes.cfm",
	 *      "app/Modules/bar/Config/Routes.cfm",
	 *  ]
	 *
	 * @return A list of paths
	--->
	<cffunction name="search" access="public" returntype="array" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfargument name="ext" type="string" required="no" default="cfm">
		<cfargument name="prioritizeApp" type="boolean" required="no" default="true">
		<cfset var foundPaths = ArrayNew(1)>
		<cfset var appPaths = ArrayNew(1)>
		<cfset var namespaces = "">
		<cfset var fullPath = "">
		<cfset var resolvedPath = "">
		<cfset var i = 0>

		<cfset arguments.path = ensureExt(arguments.path, arguments.ext)>

		<cfset namespaces = getNamespaces()>

		<cfloop from="1" to="#ArrayLen(namespaces)#" index="i">
			<cfif StructKeyExists(namespaces[i], "path") AND is_file(namespaces[i].path & arguments.path)>
				<cfset fullPath = namespaces[i].path & arguments.path>
				<cfset resolvedPath = realpath(fullPath)>

				<cfif resolvedPath NEQ "">
					<cfset fullPath = resolvedPath>
				</cfif>

				<cfif arguments.prioritizeApp>
					<cfset ArrayAppend(foundPaths, fullPath)>
				<cfelseif str_starts_with(fullPath, request.APPPATH)>
					<cfset ArrayAppend(appPaths, fullPath)>
				<cfelse>
					<cfset ArrayAppend(foundPaths, fullPath)>
				</cfif>
			</cfif>
		</cfloop>

		<cfif NOT arguments.prioritizeApp AND ArrayLen(appPaths) GT 0>
			<cfset foundPaths = array_merge(foundPaths, appPaths)>
		</cfif>

		<cfreturn array_unique(foundPaths)>
	</cffunction>

	<!---
	 * Ensures a extension is at the end of a filename
	--->
	<cffunction name="ensureExt" access="private" returntype="string" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfargument name="ext" type="string" required="yes">

		<cfif arguments.ext NEQ "">
			<cfset arguments.ext = "." & arguments.ext>

			<cfif NOT (Len(arguments.path) GTE Len(arguments.ext) AND Compare(Right(arguments.path, Len(arguments.ext)), arguments.ext) EQ 0)>
				<cfset arguments.path = arguments.path & arguments.ext>
			</cfif>
		</cfif>

		<cfreturn arguments.path>
	</cffunction>

	<!---
	 * Return the namespace mappings we know about.
	 *
	 * Difference: the namespace of the system folder is ColdIgniter, where
	 * the original has CodeIgniter.
	 *
	 * @return A list of structs with the keys "prefix" and "path"
	--->
	<cffunction name="getNamespaces" access="private" returntype="array" output="no">
		<cfset var namespaces = ArrayNew(1)>
		<cfset var system = ArrayNew(1)>
		<cfset var all = this.autoloader.getNamespace()>
		<cfset var prefix = "">
		<cfset var paths = "">
		<cfset var entry = "">
		<cfset var i = 0>

		<cfloop collection="#all#" item="prefix">
			<cfset paths = all[prefix]>

			<cfloop from="1" to="#ArrayLen(paths)#" index="i">
				<cfset entry = StructNew()>
				<cfset entry.prefix = prefix>
				<cfset entry.path = REReplace(paths[i], "[\\/]+$", "") & request.DIRECTORY_SEPARATOR>

				<cfif Compare(prefix, "ColdIgniter") EQ 0>
					<cfset ArrayAppend(system, entry)>
				<cfelse>
					<cfset ArrayAppend(namespaces, entry)>
				</cfif>
			</cfloop>
		</cfloop>

		<!--- Save system for last --->
		<cfreturn array_merge(namespaces, system)>
	</cffunction>

	<cffunction name="findQualifiedNameFromPath" access="public" returntype="string" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfset var resolvedPath = realpath(arguments.path)>
		<cfset var namespaces = "">
		<cfset var namespacePath = "">
		<cfset var className = "">
		<cfset var i = 0>

		<cfif resolvedPath NEQ "">
			<cfset arguments.path = resolvedPath>
		</cfif>

		<cfif NOT is_file(arguments.path)>
			<cfreturn "">
		</cfif>

		<cfset namespaces = getNamespaces()>

		<cfloop from="1" to="#ArrayLen(namespaces)#" index="i">
			<cfset namespacePath = realpath(namespaces[i].path)>

			<cfif namespacePath EQ "">
				<cfset namespacePath = namespaces[i].path>
			</cfif>

			<!--- there is no continue: the rest of the body is in the branch --->
			<cfset namespacePath = REReplace(namespacePath, "[\\/]+$", "")>

			<cfif namespacePath NEQ "" AND Compare(Left(arguments.path, Len(namespacePath)), namespacePath) EQ 0 AND REFind("[\\/]", Mid(arguments.path, Len(namespacePath) + 1, 1)) GT 0>
				<cfset className = namespaces[i].prefix & "\" & REReplace(Replace(Mid(arguments.path, Len(namespacePath) + 2, Len(arguments.path)), "/", "\", "all"), "^\\+", "")>

				<!--- Remove the file extension (.cfc) --->
				<cfset className = Left(className, Len(className) - 4)>

				<cfif NOT in_array(className, variables.invalidClassnames)>
					<cfif class_exists(className)>
						<cfreturn className>
					</cfif>

					<cfset ArrayAppend(variables.invalidClassnames, className)>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn "">
	</cffunction>

	<!---
	 * Scans the defined namespaces, returning a list of all files
	 * that are contained within the subpath specified by path.
	 *
	 * @return A list of file paths
	--->
	<cffunction name="listFiles" access="public" returntype="array" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfset var files = ArrayNew(1)>
		<cfset var namespaces = "">
		<cfset var i = 0>

		<cfif arguments.path EQ "">
			<cfreturn files>
		</cfif>

		<!--- Not ported yet: helper("filesystem") --->

		<cfset namespaces = getNamespaces()>

		<cfloop from="1" to="#ArrayLen(namespaces)#" index="i">
			<cfset files = array_merge(files, getFilenames(namespaces[i].path & arguments.path))>
		</cfloop>

		<cfreturn files>
	</cffunction>

	<!---
	 * Scans the provided namespace, returning a list of all files
	 * that are contained within the sub path specified by path.
	 *
	 * @return A list of file paths
	--->
	<cffunction name="listNamespaceFiles" access="public" returntype="array" output="no">
		<cfargument name="prefix" type="string" required="yes">
		<cfargument name="path" type="string" required="yes">
		<cfset var files = ArrayNew(1)>
		<cfset var namespacePaths = "">
		<cfset var fullPath = "">
		<cfset var resolvedPath = "">
		<cfset var tempFiles = "">
		<cfset var i = 0>

		<cfif arguments.path EQ "" OR arguments.prefix EQ "">
			<cfreturn files>
		</cfif>

		<!--- Not ported yet: helper("filesystem") --->

		<!--- autoloader.getNamespace(prefix) returns an array of paths for that namespace --->
		<cfset namespacePaths = this.autoloader.getNamespace(arguments.prefix)>

		<cfloop from="1" to="#ArrayLen(namespacePaths)#" index="i">
			<cfset fullPath = REReplace(namespacePaths[i], "/+$", "") & "/" & arguments.path>
			<cfset resolvedPath = realpath(fullPath)>

			<cfif resolvedPath NEQ "">
				<cfset fullPath = resolvedPath>
			</cfif>

			<cfif CreateObject("java", "java.io.File").init(fullPath).isDirectory()>
				<cfset tempFiles = getFilenames(fullPath)>

				<cfif ArrayLen(tempFiles) GT 0>
					<cfset files = array_merge(files, tempFiles)>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn files>
	</cffunction>

	<!---
	 * Checks the app folder to see if the file can be found.
	 * Only for use with filenames that DO NOT include namespacing.
	 *
	 * @param folder An empty string (null) for none
	 *
	 * @return The path to the file, or an empty string if not found.
	--->
	<cffunction name="legacyLocate" access="private" returntype="string" output="no">
		<cfargument name="file" type="string" required="yes">
		<cfargument name="folder" type="string" required="no" default="">
		<cfset var path = request.APPPATH>
		<cfset var resolvedPath = "">

		<cfif is_null(arguments.folder)>
			<cfset path = path & arguments.file>
		<cfelse>
			<cfset path = path & arguments.folder & "/" & arguments.file>
		</cfif>

		<cfset resolvedPath = realpath(path)>

		<cfif resolvedPath NEQ "">
			<cfset path = resolvedPath>
		</cfif>

		<cfif is_file(path)>
			<cfreturn path>
		</cfif>

		<cfreturn "">
	</cffunction>

	<!---
	 * Not in the original (see the top of this file). What
	 * get_filenames(sourceDir, true, false, false) gives: the full path of
	 * each file below the folder, sorted. A name that begins with a period
	 * is left out; a folder is never listed (the files in a folder whose
	 * name begins with a period are listed). A folder that cannot be read
	 * gives an empty list.
	--->
	<cffunction name="getFilenames" access="private" returntype="array" output="no">
		<cfargument name="sourceDir" type="string" required="yes">
		<cfset var resolvedPath = realpath(arguments.sourceDir)>
		<cfset var found = CreateObject("java", "java.util.ArrayList").init()>
		<cfset var files = ArrayNew(1)>
		<cfset var i = 0>

		<cfif resolvedPath NEQ "">
			<cfset arguments.sourceDir = resolvedPath>
		</cfif>

		<cfset collectFilenames(arguments.sourceDir, found)>

		<cfloop from="0" to="#found.size() - 1#" index="i">
			<cfset ArrayAppend(files, found.get(JavaCast("int", i)))>
		</cfloop>

		<cfif ArrayLen(files) GT 0>
			<cfset ArraySort(files, "text")>
		</cfif>

		<cfreturn files>
	</cffunction>

	<!---
	 * Not in the original. Adds the files below a folder to a Java list
	 * (an array would be copied for each call).
	--->
	<cffunction name="collectFilenames" access="private" returntype="void" output="no">
		<cfargument name="directory" type="string" required="yes">
		<cfargument name="found" type="any" required="yes">
		<cfset var folder = CreateObject("java", "java.io.File").init(arguments.directory)>
		<cfset var entries = "">
		<cfset var entry = "">
		<cfset var name = "">
		<cfset var i = 0>

		<cfif folder.isDirectory()>
			<!--- list() gives null for a folder that cannot be read, and the variable is then not defined --->
			<cfset entries = folder.list()>

			<cfif IsDefined("entries")>
				<cfloop from="1" to="#ArrayLen(entries)#" index="i">
					<cfset name = entries[i]>
					<cfset entry = CreateObject("java", "java.io.File").init(folder, JavaCast("string", name))>

					<cfif entry.isDirectory()>
						<cfset collectFilenames(entry.getPath(), arguments.found)>
					<cfelseif Left(name, 1) NEQ ".">
						<cfset arguments.found.add(entry.getPath())>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
	</cffunction>

</cfcomponent>
