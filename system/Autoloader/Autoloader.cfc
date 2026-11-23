<!---
 * An autoloader that uses both PSR4 autoloading, and traditional classmaps.
 *
 * Given a foo-bar package of classes in the file system at the following paths:
 *
 *      /path/to/packages/foo-bar/
 *          /src
 *              Baz.cfc         # Foo\Bar\Baz
 *              Qux/
 *                  Quux.cfc    # Foo\Bar\Qux\Quux
 *
 * you can add the path to the configuration array that is passed in the constructor.
 * The Config array consists of 2 primary keys, both of which are associative arrays:
 * 'psr4', and 'classmap'.
 *
 *      config = array_(
 *          "psr4", array_(
 *              "Foo\Bar", "/path/to/packages/foo-bar"
 *          ),
 *          "classmap", array_(
 *              "MyClass", "/path/to/class/file.cfc"
 *          )
 *      )
 *
 * Example:
 *
 *      <cfset loader = new_("\ColdIgniter\Autoloader\Autoloader")>
 *
 *      // register the autoloader
 *      <cfset loader.register()>
 *
 * Not in the original: instantiate(), keptClasses(), classInfo(),
 * parentClass(), includeComponent(), extend() and methods(). A
 * class file cannot be loaded and kept for later, so the autoloader creates
 * the object itself; new_() and static_() call instantiate().
 *
 * Not ported yet: classmap loading, sanitizeFilename, loadComposerAutoloader,
 * unregister.
--->
<cfcomponent output="no" hint="An autoloader that uses both PSR4 autoloading, and traditional classmaps">

	<!--- Stores namespaces as key, and path as values. --->
	<cfset this.prefixes = CreateObject("java", "java.util.LinkedHashMap").init()>

	<!--- Stores class name as key, and path as values. --->
	<cfset this.classmap = CreateObject("java", "java.util.LinkedHashMap").init()>

	<!--- Stores files as a list. --->
	<cfset this.files = ArrayNew(1)>

	<!--- Stores helper list. Always load the URL helper, it should be used in most apps. --->
	<cfset this.helpers = ArrayNew(1)>
	<cfset ArrayAppend(this.helpers, "url")>

	<!---
	 * Reads in the configuration array (described above) and stores
	 * the valid parts that we'll need.
	 *
	 * @return this
	--->
	<!--- Named with an underscore, because "initialize" is taken by a built-in function. --->
	<cffunction name="initialize_"access="public" returntype="any" output="no">
		<cfargument name="config" type="any" required="yes">
		<cfargument name="modules" type="any" required="yes">
		<cfset var i = 0>

		<cfset this.prefixes = array_()>
		<cfset this.classmap = array_()>
		<cfset this.files = ArrayNew(1)>

		<!---
		 We have to have one or the other, though we don't enforce the need
		 to have both present in order to work.
		--->
		<cfif StructCount(arguments.config.psr4) EQ 0 AND StructCount(arguments.config.classmap) EQ 0>
			<cfthrow type="InvalidArgumentException" message="Config array must contain either the 'psr4' key or the 'classmap' key.">
		</cfif>

		<cfif StructCount(arguments.config.psr4) NEQ 0>
			<cfset addNamespace(arguments.config.psr4)>
		</cfif>

		<cfif StructCount(arguments.config.classmap) NEQ 0>
			<cfset this.classmap = arguments.config.classmap>
		</cfif>

		<cfif ArrayLen(arguments.config.files) GT 0>
			<cfset this.files = arguments.config.files>
		</cfif>

		<!--- Should we load through Composer's namespaces, also? --->
		<cfif StructKeyExists(arguments.config, "helpers")>
			<cfloop from="1" to="#ArrayLen(arguments.config.helpers)#" index="i">
				<cfset ArrayAppend(this.helpers, arguments.config.helpers[i])>
			</cfloop>
		</cfif>

		<cfreturn this>
	</cffunction>

	<!---
	 * Register the loader with the SPL autoloader stack.
	 *
	 * Here that means: this object becomes the autoloader that new_()
	 * and static_() use.
	 *
	 * @return void
	--->
	<cffunction name="register" access="public" returntype="void" output="no">
		<cfset var i = 0>

		<cfset request.ColdIgniter.autoloader = this>

		<!--- Load our non-class files --->
		<cfloop from="1" to="#ArrayLen(this.files)#" index="i">
			<cfset includeFile(this.files[i])>
		</cfloop>
	</cffunction>

	<!---
	 * Registers namespaces with the autoloader.
	 *
	 * @return this
	--->
	<cffunction name="addNamespace" access="public" returntype="any" output="no">
		<cfargument name="namespace" type="any" required="yes">
		<cfargument name="path" type="string" required="no" default="">
		<cfset var prefix = "">
		<cfset var key = "">
		<cfset var namespacedPath = "">
		<cfset var i = 0>

		<cfif IsStruct(arguments.namespace)>
			<cfloop collection="#arguments.namespace#" item="key">
				<cfset prefix = REReplace(key, "^\\+|\\+$", "", "all")>
				<cfset namespacedPath = arguments.namespace[key]>

				<cfif NOT StructKeyExists(this.prefixes, prefix)>
					<cfset this.prefixes[prefix] = ArrayNew(1)>
				</cfif>

				<cfif IsArray(namespacedPath)>
					<cfloop from="1" to="#ArrayLen(namespacedPath)#" index="i">
						<cfset ArrayAppend(this.prefixes[prefix], REReplace(namespacedPath[i], "[\\/]+$", "") & request.DIRECTORY_SEPARATOR)>
					</cfloop>
				<cfelse>
					<cfset ArrayAppend(this.prefixes[prefix], REReplace(namespacedPath, "[\\/]+$", "") & request.DIRECTORY_SEPARATOR)>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset prefix = REReplace(arguments.namespace, "^\\+|\\+$", "", "all")>

			<cfif NOT StructKeyExists(this.prefixes, prefix)>
				<cfset this.prefixes[prefix] = ArrayNew(1)>
			</cfif>

			<cfset ArrayAppend(this.prefixes[prefix], REReplace(arguments.path, "[\\/]+$", "") & request.DIRECTORY_SEPARATOR)>
		</cfif>

		<cfreturn this>
	</cffunction>

	<!---
	 * Get namespaces with prefixes as keys and paths as values.
	 *
	 * If a prefix param is set, returns only paths to the given prefix.
	--->
	<cffunction name="getNamespace" access="public" returntype="any" output="no">
		<cfargument name="prefix" type="string" required="no" default="">
		<cfset var key = REReplace(arguments.prefix, "^\\+|\\+$", "", "all")>

		<cfif is_null(arguments.prefix)>
			<cfreturn this.prefixes>
		</cfif>

		<cfif StructKeyExists(this.prefixes, key)>
			<cfreturn this.prefixes[key]>
		</cfif>

		<cfreturn ArrayNew(1)>
	</cffunction>

	<!---
	 * Removes a single namespace from the psr4 settings.
	 *
	 * @return this
	--->
	<cffunction name="removeNamespace" access="public" returntype="any" output="no">
		<cfargument name="namespace" type="string" required="yes">
		<cfset var key = REReplace(arguments.namespace, "^\\+|\\+$", "", "all")>

		<cfif StructKeyExists(this.prefixes, key)>
			<cfset StructDelete(this.prefixes, key)>
		</cfif>

		<cfreturn this>
	</cffunction>

	<!---
	 * Loads the class file for a given class name.
	 *
	 * @return The mapped file name on success, or an empty string on fail
	--->
	<cffunction name="loadInNamespace" access="private" returntype="string" output="no">
		<cfargument name="class" type="string" required="yes">
		<cfset var namespace = "">
		<cfset var directories = "">
		<cfset var relativeClassPath = "">
		<cfset var filePath = "">
		<cfset var i = 0>

		<cfif Find("\", arguments.class) EQ 0>
			<cfreturn "">
		</cfif>

		<cfloop collection="#this.prefixes#" item="namespace">
			<cfif Compare(Left(arguments.class, Len(namespace)), namespace) EQ 0>
				<cfset relativeClassPath = Replace(substr(arguments.class, Len(namespace)), "\", request.DIRECTORY_SEPARATOR, "all")>
				<cfset directories = this.prefixes[namespace]>

				<cfloop from="1" to="#ArrayLen(directories)#" index="i">
					<cfset filePath = REReplace(directories[i], "[\\/]+$", "") & relativeClassPath & ".cfc">

					<cfif is_file(filePath)>
						<cfreturn filePath>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>

		<cfreturn "">
	</cffunction>

	<!---
	 * A central way to include a file. Split out primarily for testing purposes.
	 *
	 * @return The filename on success, an empty string if the file is not loaded
	--->
	<cffunction name="includeFile" access="private" returntype="string" output="no">
		<cfargument name="file" type="string" required="yes">

		<cfif is_file(arguments.file)>
			<cfset require_once(arguments.file)>

			<cfreturn arguments.file>
		</cfif>

		<cfreturn "">
	</cffunction>

	<!---
	 * Not in the original. Tells whether a class can be found.
	--->
	<cffunction name="classExists" access="public" returntype="boolean" output="no">
		<cfargument name="class" type="string" required="yes">

		<cfreturn loadInNamespace(REReplace(arguments.class, "^\\+", "")) NEQ "">
	</cffunction>

	<!---
	 * Loads helpers
	--->
	<cffunction name="loadHelpers" access="public" returntype="void" output="no">
		<cfset helper(this.helpers)>
	</cffunction>

	<!---
	 * Not in the original. Creates an object of a class, without calling
	 * its constructor: finds the file, creates the component, mixes in
	 * the class named in the "parent" attribute of cfcomponent, and gives
	 * the object the global functions.
	 *
	 * What is found out about a class (see classInfo()) is kept, so that
	 * it is found out once and not for every object. When what was kept
	 * no longer creates the component, the class is looked up again: a
	 * different answer (the file was moved or removed) takes the place of
	 * what was kept, and with the same answer the error is a real one, of
	 * the class file itself, and is thrown again as it is.
	--->
	<cffunction name="instantiate" access="public" returntype="any" output="no">
		<cfargument name="class" type="string" required="yes">
		<cfset var name = arguments.class>
		<cfset var info = "">
		<cfset var found = "">
		<cfset var object = "">

		<cfif Left(name, 1) EQ "\">
			<cfset name = REReplace(name, "^\\+", "")>
		</cfif>

		<cfif NOT StructKeyExists(variables, "classes")>
			<cfset variables.classes = keptClasses()>
		</cfif>

		<cfif StructKeyExists(variables.classes, name)>
			<cftry>
				<cfset info = variables.classes[name]>
				<cfset object = includeComponent(info.loader, info.component)>

				<cfcatch type="any">
					<cfset object = "">

					<cfif IsStruct(info)>
						<cfset StructDelete(variables.classes, name)>
						<cfset found = classInfo(name)>

						<cfif found.loader EQ info.loader AND found.component EQ info.component>
							<cfset variables.classes[name] = info>
							<cfrethrow>
						</cfif>
					</cfif>
				</cfcatch>
			</cftry>
		</cfif>

		<cfif NOT IsObject(object)>
			<cfset info = classInfo(name)>
			<cfset object = includeComponent(info.loader, info.component)>
			<cfset info.parent = parentClass(object)>
			<cfset variables.classes[name] = info>
		</cfif>

		<!---
		 * Difference: there is no get_included_files(), so the file of each class
		 * that is created is noted with the helper files that require_once()
		 * notes. The Files collector of the debug toolbar reads them.
		--->
		<cfset request.ColdIgniter.included[info.file] = true>

		<cfset object.__variables = request.ColdIgniter.functions.__variables>
		<!--- Difference: the class name cannot be read from the component metadata, which only has the name relative to the nearest autoload.cfm --->
		<cfset object.__class = name>

		<cfif info.parent NEQ "">
			<cfset extend(object, parentObject(info.parent))>
		</cfif>

		<cfset request.ColdIgniter.functions.__inject(object)>

		<cfreturn object>
	</cffunction>

	<!---
	 * Not in the original. Gives the object of a parent class that
	 * extend() reads the members from.
	 *
	 * extend() only reads the parent: its functions are given to the child
	 * as they are, and its constructor never runs. So when a class is asked
	 * for a second time in a request (BaseConfig is the parent of every
	 * config class), the first object serves again and no new one is made.
	 * That holds only while each property of the parent is a simple value
	 * or an empty array, which an assignment copies. A structure or an
	 * object would be one value shared by every child, so a class that has
	 * one gets a new object each time.
	 *
	 * @param class The name of the parent class
	--->
	<cffunction name="parentObject" access="private" returntype="any" output="no">
		<cfargument name="class" type="string" required="yes">
		<cfset var object = "">
		<cfset var name = "">

		<cfif NOT StructKeyExists(variables, "parents")>
			<cfset variables.parents = StructNew()>
			<cfset variables.parentsShared = StructNew()>
		</cfif>

		<!--- First time: the object is kept, and looked at only if the class comes again --->
		<cfif NOT StructKeyExists(variables.parents, arguments.class)>
			<cfset object = instantiate(arguments.class)>
			<cfset variables.parents[arguments.class] = object>

			<cfreturn object>
		</cfif>

		<cfif NOT StructKeyExists(variables.parentsShared, arguments.class)>
			<cfset object = variables.parents[arguments.class]>
			<cfset variables.parentsShared[arguments.class] = true>

			<cfloop collection="#object#" item="name">
				<cfif NOT IsCustomFunction(object[name]) AND NOT IsSimpleValue(object[name]) AND NOT (IsArray(object[name]) AND ArrayLen(object[name]) EQ 0)>
					<cfset variables.parentsShared[arguments.class] = false>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>

		<cfif variables.parentsShared[arguments.class]>
			<cfreturn variables.parents[arguments.class]>
		</cfif>

		<cfreturn instantiate(arguments.class)>
	</cffunction>

	<!---
	 * Not in the original. The map that keeps what is found out about
	 * each class, with the class name as key.
	 *
	 * In production the map is in the memory of the server
	 * (server.ColdIgniterClasses), so a class is looked up once and not
	 * once per request. There is one map per application and per list of
	 * namespaces: the first autoloader, which Boot makes by hand with two
	 * namespaces, has its own map, so it never answers for the real one.
	 * Anywhere else the map only lives as long as this object, so a class
	 * file that is added or moved is seen on the next request.
	 *
	 * The map only holds class names and file paths, never a value of the
	 * configuration. Other applications on the same server can read it,
	 * and it stays until the server is restarted.
	 *
	 * In production, what is kept is used as long as it creates a
	 * component. So after class files are changed in one of these ways,
	 * restart the server or run StructDelete(server, "ColdIgniterClasses"):
	 * the "parent" attribute or "extends" of a class is changed, a class
	 * file is copied to a new place and the old file stays, or a namespace
	 * or a folder is added that would now find another file first. A file
	 * that is moved or removed needs nothing, it is found again.
	 *
	 * An entry is written without a lock: it is complete before it is
	 * stored, and two requests that write the same class at the same time
	 * write the same values.
	--->
	<cffunction name="keptClasses" access="private" returntype="struct" output="no">
		<cfset var key = "">

		<cfif NOT StructKeyExists(request, "ENVIRONMENT") OR request.ENVIRONMENT NEQ "production">
			<cfreturn StructNew()>
		</cfif>

		<cfset key = request.SYSTEMPATH & "|" & request.APPPATH & "|" & this.prefixes.keySet().toString()>

		<cfif NOT StructKeyExists(server, "ColdIgniterClasses") OR NOT StructKeyExists(server.ColdIgniterClasses, key)>
			<cflock name="ColdIgniterClasses" type="exclusive" timeout="10">
				<cfif NOT StructKeyExists(server, "ColdIgniterClasses")>
					<cfset server.ColdIgniterClasses = StructNew()>
				</cfif>

				<cfif NOT StructKeyExists(server.ColdIgniterClasses, key)>
					<cfset server.ColdIgniterClasses[key] = StructNew()>
				</cfif>
			</cflock>
		</cfif>

		<cfreturn server.ColdIgniterClasses[key]>
	</cffunction>

	<!---
	 * Not in the original. Finds out what is needed to create the
	 * component of a class: the class file ("file"), and how to reach it.
	 * Only a file in the same folder tree can create a component, so the
	 * nearest autoload.cfm at or above the class file is asked to do it:
	 * "loader" is the path cfinclude needs for that autoload.cfm, and
	 * "component" is the name of the component as seen from there.
	--->
	<cffunction name="classInfo" access="private" returntype="struct" output="no">
		<cfargument name="class" type="string" required="yes">
		<cfset var info = StructNew()>
		<cfset var filePath = loadInNamespace(arguments.class)>
		<cfset var directory = "">
		<cfset var name = "">

		<cfif filePath EQ "">
			<cfthrow type="ColdIgniter.Autoloader.ClassNotFoundException" message="Class ""#arguments.class#"" not found">
		</cfif>

		<cfset directory = REReplace(Replace(GetDirectoryFromPath(filePath), "\", "/", "all"), "/+$", "")>
		<cfset name = ListFirst(GetFileFromPath(filePath), ".")>

		<cfloop condition="NOT is_file(directory & '/autoload.cfm')">
			<cfif ListLen(directory, "/") LTE 1>
				<cfthrow type="ColdIgniter.Autoloader.ClassNotFoundException" message="No autoload.cfm at or above ""#filePath#""">
			</cfif>

			<cfset name = ListLast(directory, "/") & "." & name>
			<cfset directory = ListDeleteAt(directory, ListLen(directory, "/"), "/")>
		</cfloop>

		<cfset info.file = filePath>
		<cfset info.loader = includePath(directory & "/autoload.cfm")>
		<cfset info.component = name>
		<cfset info.parent = "">

		<cfreturn info>
	</cffunction>

	<!---
	 * Not in the original. The class an object is to be given the members
	 * of. A class in another folder tree cannot be named in "extends", so
	 * it is named in the "parent" attribute of cfcomponent.
	 *
	 * @return The class name, an empty string when there is none
	--->
	<cffunction name="parentClass" access="private" returntype="string" output="no">
		<cfargument name="object" type="any" required="yes">
		<cfset var meta = GetMetaData(arguments.object)>

		<cfloop condition="true">
			<cfif StructKeyExists(meta, "parent")>
				<cfreturn meta.parent>
			</cfif>

			<cfif NOT StructKeyExists(meta, "extends")>
				<cfbreak>
			</cfif>

			<cfset meta = meta.extends>
		</cfloop>

		<cfreturn "">
	</cffunction>

	<!---
	 * Not in the original. Creates a component.
	 *
	 * @param loader The path cfinclude needs for an autoload.cfm
	 * @param class  The name of the component, as seen from that file
	--->
	<cffunction name="includeComponent" access="private" returntype="any" output="no">
		<cfargument name="loader" type="string" required="yes">
		<cfargument name="class" type="string" required="yes">

		<cfinclude template="#arguments.loader#">

		<cfreturn arguments.component>
	</cffunction>

	<!---
	 * Not in the original. Gives an object the members of its parent
	 * class: every function and property the object does not have itself.
	 * The parent's functions are also kept in "parent", so that
	 * parent.method() calls the parent's version of an overridden method.
	--->
	<cffunction name="extend" access="private" returntype="void" output="no">
		<cfargument name="object" type="any" required="yes">
		<cfargument name="parent" type="any" required="yes">
		<cfset var objectVariables = arguments.object.__variables()>
		<cfset var parentVariables = arguments.parent.__variables()>
		<cfset var objectFunctions = methods(arguments.object)>
		<cfset var parentFunctions = methods(arguments.parent)>
		<cfset var globalFunctions = request.ColdIgniter.functions.__functions()>
		<cfset var inherited = StructNew()>
		<cfset var member = "">
		<cfset var name = "">

		<cfif StructKeyExists(parentVariables, "parent")>
			<cfset inherited = parentVariables.parent>
		</cfif>

		<!---
		 * Functions the parent was given by its own parent class. A global
		 * function is left out: instantiate() gives the object its own copy
		 * after this, so a copy from the parent is work for nothing.
		--->
		<cfloop collection="#parentVariables#" item="name">
			<cfif name NEQ "this" AND name NEQ "parent" AND name NEQ "__variables" AND name NEQ "__member" AND IsCustomFunction(parentVariables[name]) AND NOT StructKeyExists(parentFunctions, name) AND (StructKeyExists(inherited, name) OR NOT StructKeyExists(globalFunctions, name))>
				<cfset parentFunctions[name] = StructKeyExists(arguments.parent, name)>
			</cfif>
		</cfloop>

		<cfloop collection="#parentFunctions#" item="name">
			<!--- A private function the parent inherits is not in its Variables scope, so only that one is asked for by name. --->
			<cfif StructKeyExists(parentVariables, name)>
				<cfset member = parentVariables[name]>
			<cfelse>
				<cfset member = arguments.parent.__member(name)>
			</cfif>

			<cfif NOT StructKeyExists(objectFunctions, name) AND NOT StructKeyExists(objectVariables, name)>
				<cfset objectVariables[name] = member>

				<!--- parentFunctions[name] tells whether the function is public --->
				<cfif parentFunctions[name]>
					<cfset arguments.object[name] = member>
				</cfif>
			</cfif>

			<cfset parentFunctions[name] = member>
		</cfloop>

		<cfloop collection="#arguments.parent#" item="name">
			<cfif NOT StructKeyExists(arguments.object, name) AND NOT IsCustomFunction(arguments.parent[name])>
				<cfset arguments.object[name] = arguments.parent[name]>
			</cfif>
		</cfloop>

		<cfset objectVariables.parent = parentFunctions>
	</cffunction>

	<!---
	 * Not in the original. Lists the functions written in the class of
	 * an object and in the classes it extends: the name, and whether the
	 * function is public. Inherited functions are not in the Variables
	 * scope, so the names are read from the metadata.
	--->
	<cffunction name="methods" access="private" returntype="struct" output="no">
		<cfargument name="object" type="any" required="yes">
		<cfset var result = StructNew()>
		<cfset var meta = GetMetaData(arguments.object)>
		<cfset var i = 0>

		<cfloop condition="true">
			<cfif StructKeyExists(meta, "functions")>
				<cfloop from="1" to="#ArrayLen(meta.functions)#" index="i">
					<cfif NOT StructKeyExists(result, meta.functions[i].name)>
						<cfset result[meta.functions[i].name] = NOT StructKeyExists(meta.functions[i], "access") OR meta.functions[i].access NEQ "private">
					</cfif>
				</cfloop>
			</cfif>

			<cfif NOT StructKeyExists(meta, "extends")>
				<cfbreak>
			</cfif>

			<cfset meta = meta.extends>
		</cfloop>

		<cfreturn result>
	</cffunction>

</cfcomponent>
