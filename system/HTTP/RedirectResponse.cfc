<!---
 * Handle a redirect response
 *
 * Not ported yet: withInput, withErrors, with, withCookies and
 * withHeaders (they need the session and the cookie store).
--->
<cfcomponent output="no" extends="Response" hint="Handle a redirect response">

	<!---
	 * Sets the URI to redirect to and, optionally, the HTTP status code to use.
	 * If no code is provided it will be automatically determined.
	 *
	 * @param uri  The URI path (relative to baseURL) to redirect to
	 * @param code HTTP status code (an empty string stands for null)
	 *
	 * @return this
	--->
	<cffunction name="to" access="public" returntype="any" output="no">
		<cfargument name="uri" type="string" required="yes">
		<cfargument name="code" type="any" required="no" default="">
		<cfargument name="method" type="string" required="no" default="auto">

		<!---
		 If it appears to be a relative URL, then convert to full URL
		 for better security.
		--->
		<cfif Left(arguments.uri, 4) NEQ "http">
			<cfset arguments.uri = site_url(arguments.uri)>
		</cfif>

		<cfreturn redirect(arguments.uri, arguments.method, arguments.code)>
	</cffunction>

	<!---
	 * Sets the URI to redirect to but as a reverse-routed or named route
	 * instead of a raw URI.
	 *
	 * Not ported yet: RouteCollection::reverseRoute, so the route is
	 * never found.
	 *
	 * @param route  Route name or Controller::method
	 * @param params Array of int|string
	 *
	 * @return this
	 *
	 * @throws HTTPException
	--->
	<cffunction name="route" access="public" returntype="any" output="no">
		<cfargument name="route" type="string" required="yes">
		<cfargument name="params" type="array" required="no" default="#ArrayNew(1)#">
		<cfargument name="code" type="any" required="no" default="">
		<cfargument name="method" type="string" required="no" default="auto">
		<cfset var namedRoute = arguments.route>

		<!--- Not ported yet: service("routes").reverseRoute(route, params) --->
		<cfset arguments.route = false>

		<cfif NOT arguments.route>
			<cfthrow type="ColdIgniter.HTTP.Exceptions.HTTPException" message="The route for ""#namedRoute#"" cannot be found.">
		</cfif>

		<cfreturn redirect(site_url(arguments.route), arguments.method, arguments.code)>
	</cffunction>

	<!---
	 * Helper function to return to previous page.
	 *
	 * Example:
	 *  return redirect()->back();
	 *
	 * @return this
	--->
	<cffunction name="back" access="public" returntype="any" output="no">
		<cfargument name="code" type="any" required="no" default="">
		<cfargument name="method" type="string" required="no" default="auto">

		<!--- Not ported yet: service("session") --->

		<cfreturn redirect(previous_url(), arguments.method, arguments.code)>
	</cffunction>

</cfcomponent>
