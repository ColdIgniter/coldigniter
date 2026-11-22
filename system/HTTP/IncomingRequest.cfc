<!---
 * Class IncomingRequest
 *
 * Represents an incoming, server-side HTTP request.
 *
 * Per the HTTP specification, this interface includes properties for
 * each of the following:
 *
 * - Protocol version
 * - HTTP method
 * - URI
 * - Headers
 * - Message body
 *
 * Additionally, it encapsulates all data as it has arrived to the
 * application from the CGI environment, including:
 *
 * - The values represented in the server values.
 * - Any cookies provided
 * - Query string arguments
 * - Upload files, if any
 * - Deserialized body binds
 *
 * Not ported yet: locale negotiation, is(), isCLI, isAJAX, isSecure,
 * the get, post, cookie, file and JSON values, old input and the
 * user agent.
--->
<cfcomponent output="no" extends="Request" hint="Represents an incoming, server-side HTTP request">

	<!---
	 * The URI for this request.
	 *
	 * Note: This WILL NOT match the actual URL in the browser since for
	 * everything this cares about (and the router, etc) is the portion
	 * AFTER the baseURL. So, if hosted in a sub-folder this will
	 * appear different than actual URI path. If you need that use getPath().
	--->
	<cfset this.uri = "">

	<!---
	 * The detected URI path (relative to the baseURL).
	 *
	 * Note: current_url() uses this to build its URI,
	 * so this becomes the source for the "current URL"
	 * when working with the share request instance.
	--->
	<cfset this.path = "">

	<!---
	 * Holds the default locale.
	--->
	<cfset this.defaultLocale = "">

	<!---
	 * The current locale of the application.
	 * Default value is set in app/Config/App.cfc
	--->
	<cfset this.locale = "">

	<!---
	 * Stores the valid locale codes.
	--->
	<cfset this.validLocales = ArrayNew(1)>

	<!---
	 * The UserAgent instance.
	--->
	<cfset this.userAgent = "">

	<!---
	 * Constructor
	 *
	 * @param config
	 * @param body
	--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="config" type="any" required="yes">
		<cfargument name="uri" type="any" required="no" default="">
		<cfargument name="body" type="any" required="no" default="">
		<cfargument name="userAgent" type="any" required="no" default="">

		<cfif is_null(arguments.uri)>
			<cfthrow type="CodeIgniter.Exceptions.InvalidArgumentException" message="You must supply the parameters: uri, userAgent.">
		</cfif>

		<cfset populateHeaders()>

		<!--- The body of the request is read here, where the original reads the input stream. --->
		<cfif is_null(arguments.body)>
			<cfset arguments.body = GetHttpRequestData().content>
		</cfif>

		<cfset this.uri = arguments.uri>
		<cfset this.body = arguments.body>
		<cfset this.userAgent = arguments.userAgent>
		<cfset this.validLocales = arguments.config.supportedLocales>

		<cfset super.__construct(arguments.config)>

		<cfif StructKeyExists(arguments.uri, "getRoutePath")>
			<cfset setPath(arguments.uri.getRoutePath())>
		<cfelse>
			<cfset setPath(arguments.uri.getPath())>
		</cfif>

		<cfset detectLocale(arguments.config)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Handles setting up the locale, perhaps auto-detecting through
	 * content negotiation.
	 *
	 * @param config
	--->
	<cffunction name="detectLocale" access="public" returntype="void" output="no">
		<cfargument name="config" type="any" required="yes">

		<cfset this.defaultLocale = arguments.config.defaultLocale>
		<cfset this.locale = this.defaultLocale>

		<cfif NOT arguments.config.negotiateLocale>
			<cfreturn>
		</cfif>

		<!--- Not ported yet: the negotiator --->
	</cffunction>

	<!---
	 * Returns the URI path relative to baseURL,
	 * running detection as necessary.
	--->
	<cffunction name="getPath" access="public" returntype="string" output="no">
		<cfreturn this.path>
	</cffunction>

	<!---
	 * Sets the relative path and updates the URI object.
	 *
	 * Note: Since current_url() accesses the shared request
	 * instance, this can be used to change the "current URL"
	 * for testing.
	 *
	 * @param path URI path relative to baseURL
	--->
	<cffunction name="setPath" access="public" returntype="any" output="no">
		<cfargument name="path" type="string" required="yes">

		<cfset this.path = arguments.path>

		<cfreturn this>
	</cffunction>

	<!---
	 * Sets the locale string for this request.
	 *
	 * Named with an underscore, because SetLocale is a built-in function.
	--->
	<cffunction name="setLocale_" access="public" returntype="any" output="no">
		<cfargument name="locale" type="string" required="yes">

		<!--- If it's not a valid locale, set it to the default locale for the site. --->
		<cfif NOT in_array(arguments.locale, this.validLocales)>
			<cfset arguments.locale = this.defaultLocale>
		</cfif>

		<cfset this.locale = arguments.locale>

		<cfreturn this>
	</cffunction>

	<!---
	 * Gets the current locale, with a fallback to the default
	 * locale if none is set.
	 *
	 * Named with an underscore, because GetLocale is a built-in function.
	--->
	<cffunction name="getLocale_" access="public" returntype="string" output="no">
		<cfreturn this.locale>
	</cffunction>

	<!---
	 * Returns the default locale as set in app/Config/App.cfc
	--->
	<cffunction name="getDefaultLocale" access="public" returntype="string" output="no">
		<cfreturn this.defaultLocale>
	</cffunction>

</cfcomponent>
