<!---
 * Bootstrap for the application
--->
<cfcomponent output="no" hint="Bootstrap for the application">

	<cfinclude template="Polyfills/define.cfm">
	<cfinclude template="Polyfills/defined.cfm">
	<cfinclude template="Polyfills/is_file.cfm">
	<cfinclude template="Polyfills/realpath.cfm">

	<cfset __DIR__ = GetDirectoryFromPath(GetCurrentTemplatePath())>
	<cfset DIRECTORY_SEPARATOR = Right(__DIR__, 1)>

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
		<cfif NOT defined("APP_NAMESPACE")>
			<cfset loadConstants()>
		</cfif>
		<!--- Not ported yet: checkMissingExtensions --->

		<!--- Not ported yet: loadDotEnv --->
		<cfset defineEnvironment()>
		<cfset loadEnvironmentBootstrap(arguments.paths)>

		<!---
		 Not ported yet, in the original order: loadCommonFunctions,
		 loadAutoloader, setExceptionHandler, initializeKint,
		 autoloadHelpers, initializeCodeIgniter, runCodeIgniter.
		--->

		<!---
		 Exits the application, setting the exit code for CLI-based
		 applications that might be watching.
		--->
		<cfreturn request.EXIT_SUCCESS>
	</cffunction>

	<cffunction name="defineEnvironment" access="private" returntype="void" output="no">
		<cfset var env = "">

		<cfif NOT defined("ENVIRONMENT")>
			<cfset env = CGI.CI_ENVIRONMENT>
			<cfif env EQ "">
				<cfset env = "production">
			</cfif>

			<cfset define("ENVIRONMENT", env)>
		</cfif>
	</cffunction>

	<cffunction name="loadEnvironmentBootstrap" access="private" returntype="void" output="no">
		<cfargument name="paths" type="any" required="yes">
		<cfargument name="exit" type="boolean" required="no" default="true">

		<cfif is_file(arguments.paths.appDirectory & "/Config/Boot/" & request.ENVIRONMENT & ".cfm")>
			<cfinclude template="#includePath(arguments.paths.appDirectory & "/Config/Boot/" & request.ENVIRONMENT & ".cfm")#">

			<cfreturn>
		</cfif>

		<cfif arguments.exit>
			<cfheader statuscode="503" statustext="Service Unavailable">
			<cfset WriteOutput("The application environment is not set correctly.")>

			<!--- exit(EXIT_ERROR): a request has no exit code --->
			<cfabort>
		</cfif>
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

	<cffunction name="loadConstants" access="private" returntype="void" output="no">
		<cfinclude template="#includePath(request.APPPATH & "Config/Constants.cfm")#">
	</cffunction>

	<!---
	 * Not in the original. cfinclude only takes a path relative to this
	 * file, so a full path is reached by climbing to the top of the drive.
	 * The file has to be on the same drive as this one.
	--->
	<cffunction name="includePath" access="private" returntype="string" output="no">
		<cfargument name="path" type="string" required="yes">

		<cfreturn RepeatString("../", ListLen(REReplace(__DIR__, "^[A-Za-z]:", ""), "\/")) & REReplace(Replace(arguments.path, "\", "/", "all"), "^([A-Za-z]:)?/", "")>
	</cffunction>

</cfcomponent>
