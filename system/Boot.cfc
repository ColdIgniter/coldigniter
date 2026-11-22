<!---
 * Bootstrap for the application
--->
<cfcomponent output="no" hint="Bootstrap for the application">

	<cfinclude template="Polyfills/define.cfm">
	<cfinclude template="Polyfills/defined.cfm">
	<cfinclude template="Polyfills/realpath.cfm">

	<cfset DIRECTORY_SEPARATOR = Right(GetDirectoryFromPath(GetCurrentTemplatePath()), 1)>

	<!---
	 * Used by `public/index.cfm`
	 *
	 * Context
	 *   web:     Invoked by HTTP request
	 *
	 * @return int Exit code.
	--->
	<cffunction name="bootWeb" access="public" returntype="numeric" output="no">
		<cfargument name="paths" type="any" required="yes">

		<cfset definePathConstants(arguments.paths)>

		<!---
		 Not ported yet, in the original order: loadConstants,
		 checkMissingExtensions, loadDotEnv, defineEnvironment,
		 loadEnvironmentBootstrap, loadCommonFunctions, loadAutoloader,
		 setExceptionHandler, initializeKint, autoloadHelpers,
		 initializeCodeIgniter, runCodeIgniter.
		--->

		<!---
		 Exits the application, setting the exit code for CLI-based
		 applications that might be watching.
		--->
		<cfreturn 0>
	</cffunction>

	<!---
	 * The path constants provide convenient access to the folders throughout
	 * the application. We have to set them up here, so they are available in
	 * the config files that are loaded.
	--->
	<cffunction name="definePathConstants" access="private" returntype="void" output="no">
		<cfargument name="paths" type="any" required="yes">
		<cfset var writePath = "">

		<!--- The path to the application directory. --->
		<cfif NOT defined("APPPATH")>
			<cfset define("APPPATH", realpath(REReplace(arguments.paths.appDirectory, "[\\/ ]+$", "")) & DIRECTORY_SEPARATOR)>
		</cfif>

		<!--- The path to the project root directory. Just above APPPATH. --->
		<cfif NOT defined("ROOTPATH")>
			<cfset define("ROOTPATH", realpath(request.APPPATH & "../") & DIRECTORY_SEPARATOR)>
		</cfif>

		<!--- The path to the system directory. --->
		<cfif NOT defined("SYSTEMPATH")>
			<cfset define("SYSTEMPATH", realpath(REReplace(arguments.paths.systemDirectory, "[\\/ ]+$", "")) & DIRECTORY_SEPARATOR)>
		</cfif>

		<!--- The path to the writable directory. --->
		<cfif NOT defined("WRITEPATH")>
			<cfset writePath = realpath(REReplace(arguments.paths.writableDirectory, "[\\/ ]+$", ""))>

			<cfif writePath EQ "">
				<cfheader statuscode="503" statustext="Service Unavailable">
				<cfset WriteOutput("The WRITEPATH is not set correctly.")>

				<!--- EXIT_ERROR is not yet defined --->
				<cfabort>
			</cfif>
			<cfset define("WRITEPATH", writePath & DIRECTORY_SEPARATOR)>
		</cfif>

		<!--- The path to the tests directory --->
		<cfif NOT defined("TESTPATH")>
			<cfset define("TESTPATH", realpath(REReplace(arguments.paths.testsDirectory, "[\\/ ]+$", "")) & DIRECTORY_SEPARATOR)>
		</cfif>
	</cffunction>

</cfcomponent>
