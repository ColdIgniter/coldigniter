<!---
 * Services Configuration file.
 *
 * Services are simply other classes/libraries that the system uses
 * to do its job. This is used by ColdIgniter to allow the core of the
 * framework to be swapped out easily without affecting the usage within
 * the rest of your application.
 *
 * This is used in place of a Dependency Injection container primarily
 * due to its simplicity, which allows a better long-term maintenance
 * of the applications built on top of ColdIgniter. A bonus side-effect
 * is that IDEs are able to determine what class you are calling
 * whereas with DI Containers there usually isn't a way for them to do this.
 *
 * @see http://blog.ircmaxell.com/2015/11/simple-easy-risk-and-change.html
 * @see http://www.infoq.com/presentations/Simple-Made-Easy
 *
 * AppServices in the original is static_("Config\Services") here.
 * Where the original takes the locator or the logger, an empty string
 * is passed until they are ported.
 *
 * Not ported yet: every service that is not listed below.
--->
<cfcomponent output="no" extends="BaseService" hint="Services Configuration file">

	<!---
	 * ColdIgniter, the core of the framework.
	--->
	<cffunction name="coldigniter" access="public" returntype="any" output="no">
		<cfargument name="config" type="any" required="no" default="">
		<cfargument name="getShared" type="boolean" required="no" default="true">

		<cfif arguments.getShared>
			<cfreturn getSharedInstance("coldigniter", arguments.config)>
		</cfif>

		<cfif is_null(arguments.config)>
			<cfset arguments.config = variables.config("Config\App")>
		</cfif>

		<cfreturn new_("ColdIgniter\ColdIgniter", arguments.config)>
	</cffunction>

	<!---
	 * The Exceptions class holds the Exception handler.
	--->
	<cffunction name="exceptions" access="public" returntype="any" output="no">
		<cfargument name="config" type="any" required="no" default="">
		<cfargument name="getShared" type="boolean" required="no" default="true">

		<cfif arguments.getShared>
			<cfreturn getSharedInstance("exceptions", arguments.config)>
		</cfif>

		<cfif is_null(arguments.config)>
			<cfset arguments.config = variables.config("Config\Exceptions")>
		</cfif>

		<cfreturn new_("ColdIgniter\Debug\Exceptions", arguments.config)>
	</cffunction>

	<!---
	 * The Renderer class is the class that actually displays a file to the user.
	 * The default View class within ColdIgniter is intentionally simple, but this
	 * service could easily be replaced by a template engine if the user needed to.
	--->
	<cffunction name="renderer" access="public" returntype="any" output="no">
		<cfargument name="viewPath" type="string" required="no" default="">
		<cfargument name="config" type="any" required="no" default="">
		<cfargument name="getShared" type="boolean" required="no" default="true">

		<cfif arguments.getShared>
			<cfreturn getSharedInstance("renderer", arguments.viewPath, arguments.config)>
		</cfif>

		<cfif arguments.viewPath EQ "" OR arguments.viewPath EQ "0">
			<cfset arguments.viewPath = new_("Config\Paths").viewDirectory>
		</cfif>
		<cfif is_null(arguments.config)>
			<cfset arguments.config = variables.config("Config\View")>
		</cfif>

		<cfreturn new_("ColdIgniter\View\View", arguments.config, arguments.viewPath, "", request.CI_DEBUG, "")>
	</cffunction>

	<!---
	 * Returns the current Request object.
	 *
	 * createRequest() injects IncomingRequest or CLIRequest.
	--->
	<cffunction name="request" access="public" returntype="any" output="no">
		<cfargument name="config" type="any" required="no" default="">
		<cfargument name="getShared" type="boolean" required="no" default="true">

		<cfif arguments.getShared>
			<cfreturn getSharedInstance("request", arguments.config)>
		</cfif>

		<!--- @TODO remove the following code for backward compatibility --->
		<cfreturn static_("Config\Services").incomingrequest(arguments.config, arguments.getShared)>
	</cffunction>

	<!---
	 * Create the current Request object, either IncomingRequest or CLIRequest.
	 *
	 * This method is called from ColdIgniter::getRequestObject().
	--->
	<cffunction name="createRequest" access="public" returntype="void" output="no">
		<cfargument name="config" type="any" required="yes">
		<cfargument name="isCli" type="boolean" required="no" default="false">
		<cfset var request_ = "">

		<!--- Not ported yet: clirequest --->
		<cfset request_ = static_("Config\Services").incomingrequest(arguments.config, false)>

		<!--- guess at protocol if needed --->
		<cfset request_.setProtocolVersion(static_("Config\Services").superglobals().server("SERVER_PROTOCOL", "HTTP/1.1"))>

		<!--- Inject the request object into Services. --->
		<cfset this.instances["request"] = request_>
	</cffunction>

	<!---
	 * The IncomingRequest class models an HTTP request.
	--->
	<cffunction name="incomingrequest" access="public" returntype="any" output="no">
		<cfargument name="config" type="any" required="no" default="">
		<cfargument name="getShared" type="boolean" required="no" default="true">

		<cfif arguments.getShared>
			<cfreturn getSharedInstance("request", arguments.config)>
		</cfif>

		<cfif is_null(arguments.config)>
			<cfset arguments.config = variables.config("Config\App")>
		</cfif>

		<!--- Not ported yet: UserAgent --->
		<cfreturn new_("ColdIgniter\HTTP\IncomingRequest", arguments.config, static_("Config\Services").get("uri"), "", "")>
	</cffunction>

	<!---
	 * The Response class models an HTTP response.
	--->
	<cffunction name="response" access="public" returntype="any" output="no">
		<cfargument name="config" type="any" required="no" default="">
		<cfargument name="getShared" type="boolean" required="no" default="true">

		<cfif arguments.getShared>
			<cfreturn getSharedInstance("response", arguments.config)>
		</cfif>

		<cfif is_null(arguments.config)>
			<cfset arguments.config = variables.config("Config\App")>
		</cfif>

		<cfreturn new_("ColdIgniter\HTTP\Response", arguments.config)>
	</cffunction>

	<!---
	 * The Routes service is a class that allows for easily building
	 * a collection of routes.
	--->
	<cffunction name="routes" access="public" returntype="any" output="no">
		<cfargument name="getShared" type="boolean" required="no" default="true">

		<cfif arguments.getShared>
			<cfreturn getSharedInstance("routes")>
		</cfif>

		<cfreturn new_("ColdIgniter\Router\RouteCollection", "", new_("Config\Modules"), config("Config\Routing"))>
	</cffunction>

	<!---
	 * The Router class uses a RouteCollection's array of routes, and determines
	 * the correct Controller and Method to execute.
	--->
	<cffunction name="router" access="public" returntype="any" output="no">
		<cfargument name="routes" type="any" required="no" default="">
		<cfargument name="request_" type="any" required="no" default="">
		<cfargument name="getShared" type="boolean" required="no" default="true">

		<cfif arguments.getShared>
			<cfreturn getSharedInstance("router", arguments.routes, arguments.request_)>
		</cfif>

		<cfif is_null(arguments.routes)>
			<cfset arguments.routes = static_("Config\Services").get("routes")>
		</cfif>
		<cfif is_null(arguments.request_)>
			<cfset arguments.request_ = static_("Config\Services").get("request")>
		</cfif>

		<cfreturn new_("ColdIgniter\Router\Router", arguments.routes, arguments.request_)>
	</cffunction>

	<!---
	 * The Factory for SiteURI.
	--->
	<cffunction name="siteurifactory" access="public" returntype="any" output="no">
		<cfargument name="config" type="any" required="no" default="">
		<cfargument name="superglobals" type="any" required="no" default="">
		<cfargument name="getShared" type="boolean" required="no" default="true">

		<cfif arguments.getShared>
			<cfreturn getSharedInstance("siteurifactory", arguments.config, arguments.superglobals)>
		</cfif>

		<cfif is_null(arguments.config)>
			<cfset arguments.config = variables.config("App")>
		</cfif>
		<cfif is_null(arguments.superglobals)>
			<cfset arguments.superglobals = static_("Config\Services").get("superglobals")>
		</cfif>

		<cfreturn new_("ColdIgniter\HTTP\SiteURIFactory", arguments.config, arguments.superglobals)>
	</cffunction>

	<!---
	 * Superglobals.
	--->
	<cffunction name="superglobals" access="public" returntype="any" output="no">
		<cfargument name="server" type="any" required="no" default="">
		<cfargument name="get" type="any" required="no" default="">
		<cfargument name="post" type="any" required="no" default="">
		<cfargument name="cookie" type="any" required="no" default="">
		<cfargument name="files" type="any" required="no" default="">
		<cfargument name="request_" type="any" required="no" default="">
		<cfargument name="getShared" type="boolean" required="no" default="true">

		<cfif arguments.getShared>
			<cfreturn getSharedInstance("superglobals", arguments.server, arguments.get, arguments.post, arguments.cookie, arguments.files, arguments.request_)>
		</cfif>

		<cfreturn new_("ColdIgniter\Superglobals", arguments.server, arguments.get, arguments.post, arguments.cookie, arguments.files, arguments.request_)>
	</cffunction>

	<!---
	 * The URI class provides a way to model and manipulate URIs.
	--->
	<cffunction name="uri" access="public" returntype="any" output="no">
		<cfargument name="uri" type="string" required="no" default="">
		<cfargument name="getShared" type="boolean" required="no" default="true">
		<cfset var appConfig = "">
		<cfset var factory = "">

		<cfif arguments.getShared>
			<cfreturn getSharedInstance("uri", arguments.uri)>
		</cfif>

		<cfif is_null(arguments.uri)>
			<cfset appConfig = config("Config\App")>
			<cfset factory = static_("Config\Services").siteurifactory(appConfig, static_("Config\Services").get("superglobals"))>

			<cfreturn factory.createFromGlobals()>
		</cfif>

		<cfreturn new_("ColdIgniter\HTTP\URI", arguments.uri)>
	</cffunction>

</cfcomponent>
