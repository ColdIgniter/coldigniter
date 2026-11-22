<!---
 * Bootstrap for the application
--->
<cfcomponent output="no" hint="Bootstrap for the application">

	<cfinclude template="Polyfills/Polyfills.cfm">

	<!---
	 * Not in the original. What the runtime keeps for one request: the
	 * global functions, the autoloader, the objects that stand in for
	 * static classes, the files that require_once() has loaded, and the
	 * body that the response leaves for the front controller to print.
	--->
	<cfset request.ColdIgniter = StructNew()>
	<cfset request.ColdIgniter.functions = CreateObject("component", "Polyfills.Functions")>
	<cfset request.ColdIgniter.autoloader = "">
	<cfset request.ColdIgniter.statics = StructNew()>
	<cfset request.ColdIgniter.included = StructNew()>
	<cfset request.ColdIgniter.output = "">

	<cfset define("DIRECTORY_SEPARATOR", Right(GetDirectoryFromPath(GetCurrentTemplatePath()), 1))>

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
		<cfset var app = "">

		<cfset definePathConstants(arguments.paths)>
		<cfif NOT defined("APP_NAMESPACE")>
			<cfset loadConstants()>
		</cfif>
		<!--- Not ported yet: checkMissingExtensions --->

		<!--- Not ported yet: loadDotEnv --->
		<cfset defineEnvironment()>
		<cfset loadEnvironmentBootstrap(arguments.paths)>

		<cfset loadCommonFunctions()>
		<cfset loadAutoloader()>
		<!--- Not ported yet: setExceptionHandler, initializeKint, autoloadHelpers --->

		<cfset app = initializeColdIgniter()>
		<cfset runColdIgniter(app)>

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
			<cfset define("APPPATH", realpath(REReplace(arguments.paths.appDirectory, "[\\/ ]+$", "")) & request.DIRECTORY_SEPARATOR)>
		</cfif>

		<!--- The path to the project root directory. Just above APPPATH. --->
		<cfif NOT defined("ROOTPATH")>
			<cfset define("ROOTPATH", realpath(request.APPPATH & "../") & request.DIRECTORY_SEPARATOR)>
		</cfif>

		<!--- The path to the system directory. --->
		<cfif NOT defined("SYSTEMPATH")>
			<cfset define("SYSTEMPATH", realpath(REReplace(arguments.paths.systemDirectory, "[\\/ ]+$", "")) & request.DIRECTORY_SEPARATOR)>
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
			<cfset define("WRITEPATH", writePath & request.DIRECTORY_SEPARATOR)>
		</cfif>

		<!--- The path to the tests directory --->
		<cfif NOT defined("TESTPATH")>
			<cfset define("TESTPATH", realpath(REReplace(arguments.paths.testsDirectory, "[\\/ ]+$", "")) & request.DIRECTORY_SEPARATOR)>
		</cfif>
	</cffunction>

	<cffunction name="loadConstants" access="private" returntype="void" output="no">
		<cfinclude template="#includePath(request.APPPATH & "Config/Constants.cfm")#">
	</cffunction>

	<cffunction name="loadCommonFunctions" access="private" returntype="void" output="no">
		<!--- Require app/Common.cfm file if exists. --->
		<cfif is_file(request.APPPATH & "Common.cfm")>
			<cfset require_once(request.APPPATH & "Common.cfm")>
		</cfif>

		<!--- Require system/Common.cfm --->
		<cfset require_once(request.SYSTEMPATH & "Common.cfm")>
	</cffunction>

	<!---
	 * The autoloader allows all of the pieces to work together in the
	 * framework. We have to load it here, though, so that the config
	 * files can use the path constants.
	--->
	<cffunction name="loadAutoloader" access="private" returntype="void" output="no">
		<!---
		 A class file is not loaded ahead of time: the autoloader finds it
		 when an object is created. So where the original requires the
		 class files, a first autoloader is made here by hand, which only
		 knows the two namespaces that are needed to create the real one.
		--->
		<cfset var loader = request.ColdIgniter.functions.__inject(CreateObject("component", "Autoloader.Autoloader"))>

		<cfset loader.addNamespace("ColdIgniter", request.SYSTEMPATH)>
		<cfset loader.addNamespace("Config", request.APPPATH & "Config")>
		<cfset loader.register()>

		<!--- Initialize and register the loader with the SPL autoloader stack. --->
		<cfset static_("Config\Services").autoloader().initialize_(new_("Config\Autoload"), new_("Config\Modules")).register()>
	</cffunction>

	<cffunction name="initializeColdIgniter" access="private" returntype="any" output="no">
		<cfset var app = static_("Config\Services").coldigniter()>
		<cfset app.initialize_()>

		<cfreturn app>
	</cffunction>

	<!---
	 * Now that everything is set up, it's time to actually fire
	 * up the engines and make this app do its thang.
	--->
	<cffunction name="runColdIgniter" access="private" returntype="void" output="no">
		<cfargument name="app" type="any" required="yes">

		<!--- Not ported yet: is_cli(), so the context is always "web" --->
		<cfset arguments.app.setContext("web")>

		<!---
		 Stand-in until the exception handler is ported: a page that is
		 not found is answered here with a plain 404, and a bad request
		 with a plain 400.
		--->
		<cftry>
			<cfset arguments.app.run()>

			<cfcatch type="ColdIgniter.HTTP.Exceptions.BadRequestException">
				<cfheader statuscode="400" statustext="Bad Request">
				<cfcontent type="text/html; charset=UTF-8">
				<cfset request.ColdIgniter.output = "<h1>400 - Bad Request</h1><p>" & HTMLEditFormat(cfcatch.message) & "</p>">
			</cfcatch>

			<cfcatch type="ColdIgniter.Exceptions.PageNotFoundException">
				<cfheader statuscode="404" statustext="Not Found">
				<cfcontent type="text/html; charset=UTF-8">
				<cfset request.ColdIgniter.output = "<h1>404 - File Not Found</h1><p>" & HTMLEditFormat(cfcatch.message) & "</p>">
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>
