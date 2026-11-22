<!---
 * Class Controller
 *
 * Not ported yet: forceHTTPS, cachePage, validate, validateData and
 * the helpers.
--->
<cfcomponent output="no" hint="Class Controller">

	<!---
	 * Helpers that will be automatically loaded on class instantiation.
	--->
	<cfset this.helpers = ArrayNew(1)>

	<!---
	 * Instance of the main Request object.
	 *
	 * Named with an underscore, because "request" is a scope.
	--->
	<cfset this.request_ = "">

	<!---
	 * Instance of the main response object.
	--->
	<cfset this.response = "">

	<!---
	 * Instance of logger to use.
	--->
	<cfset this.logger = "">

	<!---
	 * Should enforce HTTPS access for all methods in this controller.
	 *
	 * @var int Number of seconds to set HSTS header
	--->
	<cfset this.forceHTTPS = 0>

	<!---
	 * Constructor.
	--->
	<cffunction name="initController" access="public" returntype="void" output="no">
		<cfargument name="request_" type="any" required="yes">
		<cfargument name="response" type="any" required="yes">
		<cfargument name="logger" type="any" required="yes">

		<cfset this.request_ = arguments.request_>
		<cfset this.response = arguments.response>
		<cfset this.logger = arguments.logger>

		<!--- Not ported yet: forceHTTPS --->

		<!--- Not ported yet: Autoload helper files. --->
	</cffunction>

</cfcomponent>
