<!---
 * RedirectException
 *
 * An exception is not an object that can be thrown here, but this
 * component holds what the original exception holds. To raise it,
 *
 *     <cfset static_("ColdIgniter\HTTP\Exceptions\RedirectException").raise(response)>
 *
 * stands in for "throw new RedirectException($response)". It makes the
 * object, keeps it in request.ColdIgniter.redirectException and throws the
 * error with the type "ColdIgniter.HTTP.Exceptions.RedirectException" and
 * the code as the error code. The code that catches the type gets the
 * object with lastThrown() and calls getResponse() (see
 * ColdIgniter::run() and the ForceHTTPS filter).
 *
 * Difference: the original extends RuntimeException and implements
 * ExceptionInterface, ResponsableInterface and HTTPExceptionInterface, so
 * a catch of those types finds it; here the type is its own. The exception
 * cannot be a Throwable, so getMessage() and getCode() are methods of this
 * component and the "previous" exception is left out.
--->
<cfcomponent output="no" hint="RedirectException">

	<!---
	 * HTTP status code for redirects
	--->
	<cfset this.code = 302>

	<cfset this.message = "">

	<cfset this.response = "">

	<!---
	 * @param message Response object or a string containing a relative URI.
	 * @param code    HTTP status code to redirect if message is a string.
	--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="message" type="any" required="no" default="">
		<cfargument name="code" type="numeric" required="no" default="0">

		<cfif NOT IsSimpleValue(arguments.message) AND NOT instanceof_(arguments.message, "ColdIgniter\HTTP\ResponseInterface")>
			<cfthrow type="ColdIgniter.Exceptions.InvalidArgumentException" message="RedirectException::__construct() first argument must be a string or ResponseInterface">
		</cfif>

		<cfif NOT IsSimpleValue(arguments.message)>
			<cfset this.response = arguments.message>

			<cfset arguments.message = "">

			<cfif Compare(this.response.getHeaderLine("Location"), "") EQ 0 AND Compare(this.response.getHeaderLine("Refresh"), "") EQ 0>
				<cfthrow type="ColdIgniter.Exceptions.LogicException" message="The Response object passed to RedirectException does not contain a redirect address.">
			</cfif>

			<cfif this.response.getStatusCode() LT 301 OR this.response.getStatusCode() GT 308>
				<cfset this.response.setStatusCode(this.code)>
			</cfif>
		</cfif>

		<cfset this.message = arguments.message>

		<!--- the code of an exception stays the default one when it is 0 --->
		<cfif arguments.code NEQ 0>
			<cfset this.code = arguments.code>
		</cfif>

		<cfreturn this>
	</cffunction>

	<cffunction name="getMessage" access="public" returntype="string" output="no">
		<cfreturn this.message>
	</cffunction>

	<cffunction name="getCode" access="public" returntype="numeric" output="no">
		<cfreturn this.code>
	</cffunction>

	<cffunction name="getResponse" access="public" returntype="any" output="no">
		<cfset var location = "">

		<cfif NOT instanceof_(this.response, "ColdIgniter\HTTP\ResponseInterface")>
			<cfset helper("url")>

			<cfset this.response = service("response").redirect(
				base_url(getMessage()),
				"auto",
				getCode()
			)>
		</cfif>

		<cfset location = this.response.getHeaderLine("Location")>

		<cfif Compare(location, "") EQ 0>
			<!--- substr(Refresh, 6): the text after "0;url=" --->
			<cfset location = this.response.getHeaderLine("Refresh")>
			<cfset location = Mid(location, 7, Len(location))>
		</cfif>

		<cfset service("logger").info("REDIRECTED ROUTE at " & location)>

		<cfreturn this.response>
	</cffunction>

	<!---
	 * Not in the original, where "throw new RedirectException(...)" does
	 * this (see the top of the file).
	 *
	 * Named raise, because throw is a tag.
	--->
	<cffunction name="raise" access="public" returntype="void" output="no">
		<cfargument name="message" type="any" required="no" default="">
		<cfargument name="code" type="numeric" required="no" default="0">
		<cfset var exception = new_("ColdIgniter\HTTP\Exceptions\RedirectException", arguments.message, arguments.code)>

		<cfset request.ColdIgniter.redirectException = exception>

		<cfthrow type="ColdIgniter.HTTP.Exceptions.RedirectException" errorcode="#exception.getCode()#" message="#exception.getMessage()#">
	</cffunction>

	<!---
	 * Not in the original. The exception that was raised last, for the
	 * code that has caught the type.
	--->
	<cffunction name="lastThrown" access="public" returntype="any" output="no">
		<cfreturn request.ColdIgniter.redirectException>
	</cffunction>

</cfcomponent>
