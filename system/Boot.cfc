<!---
 * Bootstrap for the application.
 *
 * - The path values live in the Request scope (request.APPPATH and so on).
 * - Where the boot has to stop with a message, this throws "ci.boot";
 *   Boot.cfm catches it and sends the 503 response.
 * - bootWeb() takes the folder of Paths.cfm as a second argument, because
 *   the values in that file are relative to it.
--->
<cfcomponent output="no" hint="Bootstrap for the application">

	<cffunction name="bootWeb" access="public" returntype="numeric" output="no" hint="Used by public/index.cfm. Returns the exit code.">
		<cfargument name="paths" type="struct" required="yes">
		<cfargument name="configDirectory" type="string" required="yes" hint="Folder that holds Paths.cfm">

		<cfset definePathConstants(arguments.paths, arguments.configDirectory)>

		<!---
		 Not ported yet, in the original order: loadConstants, loadDotEnv,
		 defineEnvironment, loadEnvironmentBootstrap, loadCommonFunctions,
		 loadAutoloader, setExceptionHandler, autoloadHelpers,
		 initializeCodeIgniter, runCodeIgniter.
		--->

		<cfreturn 0>
	</cffunction>

	<!---
	 The path values provide convenient access to the folders throughout
	 the application. We have to set them up here, so they are available in
	 the config files that are loaded.
	--->
	<cffunction name="definePathConstants" access="private" returntype="void" output="no">
		<cfargument name="paths" type="struct" required="yes">
		<cfargument name="configDirectory" type="string" required="yes">
		<cfset var base = arguments.configDirectory & "/">

		<!--- The path to the application directory. --->
		<cfif NOT StructKeyExists(request, "APPPATH")>
			<cfset request.APPPATH = realPath(base & arguments.paths.appDirectory)>
		</cfif>

		<!--- The path to the project root directory. Just above APPPATH. --->
		<cfif NOT StructKeyExists(request, "ROOTPATH")>
			<cfset request.ROOTPATH = realPath(request.APPPATH & "..")>
		</cfif>

		<!--- The path to the system directory. --->
		<cfif NOT StructKeyExists(request, "SYSTEMPATH")>
			<cfset request.SYSTEMPATH = realPath(base & arguments.paths.systemDirectory)>
		</cfif>

		<!--- The path to the writable directory. --->
		<cfif NOT StructKeyExists(request, "WRITEPATH")>
			<cfset request.WRITEPATH = realPath(base & arguments.paths.writableDirectory)>
			<cfif NOT DirectoryExists(request.WRITEPATH)>
				<cfthrow type="ci.boot" message="The WRITEPATH is not set correctly.">
			</cfif>
		</cfif>

		<!--- The path to the tests directory --->
		<cfif NOT StructKeyExists(request, "TESTPATH")>
			<cfset request.TESTPATH = realPath(base & arguments.paths.testsDirectory)>
		</cfif>
	</cffunction>

	<cffunction name="realPath" access="private" returntype="string" output="no" hint="Full path of a folder with '..' parts resolved, ending in the directory separator. Does not check that the folder exists.">
		<cfargument name="path" type="string" required="yes">
		<cfset var separator = Right(GetDirectoryFromPath(GetCurrentTemplatePath()), 1)>
		<cfset var full = CreateObject("java", "java.io.File").init(arguments.path).getCanonicalPath()>

		<cfif Right(full, 1) NEQ separator>
			<cfset full = full & separator>
		</cfif>

		<cfreturn full>
	</cffunction>

</cfcomponent>
