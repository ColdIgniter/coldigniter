<!---
 * Representation of an outgoing, server-side response.
 *
 * Per the HTTP specification, this interface includes properties for
 * each of the following:
 *
 * - Protocol version
 * - Status code and reason phrase
 * - Headers
 * - Message body
 *
 * The body is not written to the client here. No output can leave a
 * method, so send() leaves the body in request.ColdIgniter.output and
 * the front controller writes it.
 *
 * Not ported yet: the Content Security Policy, cookies, redirect,
 * download, setJSON, setXML, setDate, setLastModified and setCache.
--->
<cfcomponent output="no" extends="Message" hint="Representation of an outgoing, server-side response">

	<!---
	 * HTTP status codes
	--->
	<cfset this.statusCodes = CreateObject("java", "java.util.LinkedHashMap").init()>
	<!--- 1xx: Informational --->
	<cfset this.statusCodes["100"] = "Continue">
	<cfset this.statusCodes["101"] = "Switching Protocols">
	<cfset this.statusCodes["102"] = "Processing"> <!--- http://www.iana.org/go/rfc2518 --->
	<cfset this.statusCodes["103"] = "Early Hints"> <!--- http://www.ietf.org/rfc/rfc8297.txt --->
	<!--- 2xx: Success --->
	<cfset this.statusCodes["200"] = "OK">
	<cfset this.statusCodes["201"] = "Created">
	<cfset this.statusCodes["202"] = "Accepted">
	<cfset this.statusCodes["203"] = "Non-Authoritative Information"> <!--- 1.1 --->
	<cfset this.statusCodes["204"] = "No Content">
	<cfset this.statusCodes["205"] = "Reset Content">
	<cfset this.statusCodes["206"] = "Partial Content">
	<cfset this.statusCodes["207"] = "Multi-Status"> <!--- http://www.iana.org/go/rfc4918 --->
	<cfset this.statusCodes["208"] = "Already Reported"> <!--- http://www.iana.org/go/rfc5842 --->
	<cfset this.statusCodes["226"] = "IM Used"> <!--- 1.1; http://www.ietf.org/rfc/rfc3229.txt --->
	<!--- 3xx: Redirection --->
	<cfset this.statusCodes["300"] = "Multiple Choices">
	<cfset this.statusCodes["301"] = "Moved Permanently">
	<cfset this.statusCodes["302"] = "Found"> <!--- Formerly 'Moved Temporarily' --->
	<cfset this.statusCodes["303"] = "See Other"> <!--- 1.1 --->
	<cfset this.statusCodes["304"] = "Not Modified">
	<cfset this.statusCodes["305"] = "Use Proxy"> <!--- 1.1 --->
	<cfset this.statusCodes["306"] = "Switch Proxy"> <!--- No longer used --->
	<cfset this.statusCodes["307"] = "Temporary Redirect"> <!--- 1.1 --->
	<cfset this.statusCodes["308"] = "Permanent Redirect"> <!--- 1.1; Experimental; http://www.ietf.org/rfc/rfc7238.txt --->
	<!--- 4xx: Client error --->
	<cfset this.statusCodes["400"] = "Bad Request">
	<cfset this.statusCodes["401"] = "Unauthorized">
	<cfset this.statusCodes["402"] = "Payment Required">
	<cfset this.statusCodes["403"] = "Forbidden">
	<cfset this.statusCodes["404"] = "Not Found">
	<cfset this.statusCodes["405"] = "Method Not Allowed">
	<cfset this.statusCodes["406"] = "Not Acceptable">
	<cfset this.statusCodes["407"] = "Proxy Authentication Required">
	<cfset this.statusCodes["408"] = "Request Timeout">
	<cfset this.statusCodes["409"] = "Conflict">
	<cfset this.statusCodes["410"] = "Gone">
	<cfset this.statusCodes["411"] = "Length Required">
	<cfset this.statusCodes["412"] = "Precondition Failed">
	<cfset this.statusCodes["413"] = "Content Too Large"> <!--- https://www.iana.org/assignments/http-status-codes/http-status-codes.xml --->
	<cfset this.statusCodes["414"] = "URI Too Long"> <!--- https://www.iana.org/assignments/http-status-codes/http-status-codes.xml --->
	<cfset this.statusCodes["415"] = "Unsupported Media Type">
	<cfset this.statusCodes["416"] = "Requested Range Not Satisfiable">
	<cfset this.statusCodes["417"] = "Expectation Failed">
	<cfset this.statusCodes["418"] = "I'm a teapot"> <!--- April's Fools joke; http://www.ietf.org/rfc/rfc2324.txt --->
	<!--- 419 (Authentication Timeout) is a non-standard status code with unknown origin --->
	<cfset this.statusCodes["421"] = "Misdirected Request"> <!--- http://www.iana.org/go/rfc7540 Section 9.1.2 --->
	<cfset this.statusCodes["422"] = "Unprocessable Content"> <!--- https://www.iana.org/assignments/http-status-codes/http-status-codes.xml --->
	<cfset this.statusCodes["423"] = "Locked"> <!--- http://www.iana.org/go/rfc4918 --->
	<cfset this.statusCodes["424"] = "Failed Dependency"> <!--- http://www.iana.org/go/rfc4918 --->
	<cfset this.statusCodes["425"] = "Too Early"> <!--- https://datatracker.ietf.org/doc/draft-ietf-httpbis-replay/ --->
	<cfset this.statusCodes["426"] = "Upgrade Required">
	<cfset this.statusCodes["428"] = "Precondition Required"> <!--- 1.1; http://www.ietf.org/rfc/rfc6585.txt --->
	<cfset this.statusCodes["429"] = "Too Many Requests"> <!--- 1.1; http://www.ietf.org/rfc/rfc6585.txt --->
	<cfset this.statusCodes["431"] = "Request Header Fields Too Large"> <!--- 1.1; http://www.ietf.org/rfc/rfc6585.txt --->
	<cfset this.statusCodes["451"] = "Unavailable For Legal Reasons"> <!--- http://tools.ietf.org/html/rfc7725 --->
	<cfset this.statusCodes["499"] = "Client Closed Request"> <!--- http://lxr.nginx.org/source/src/http/ngx_http_request.h#L133 --->
	<!--- 5xx: Server error --->
	<cfset this.statusCodes["500"] = "Internal Server Error">
	<cfset this.statusCodes["501"] = "Not Implemented">
	<cfset this.statusCodes["502"] = "Bad Gateway">
	<cfset this.statusCodes["503"] = "Service Unavailable">
	<cfset this.statusCodes["504"] = "Gateway Timeout">
	<cfset this.statusCodes["505"] = "HTTP Version Not Supported">
	<cfset this.statusCodes["506"] = "Variant Also Negotiates"> <!--- 1.1; http://www.ietf.org/rfc/rfc2295.txt --->
	<cfset this.statusCodes["507"] = "Insufficient Storage"> <!--- http://www.iana.org/go/rfc4918 --->
	<cfset this.statusCodes["508"] = "Loop Detected"> <!--- http://www.iana.org/go/rfc5842 --->
	<cfset this.statusCodes["510"] = "Not Extended"> <!--- http://www.ietf.org/rfc/rfc2774.txt --->
	<cfset this.statusCodes["511"] = "Network Authentication Required"> <!--- http://www.ietf.org/rfc/rfc6585.txt --->
	<cfset this.statusCodes["599"] = "Network Connect Timeout Error"> <!--- https://httpstatuses.com/599 --->

	<!---
	 * The current reason phrase for this response.
	 * If empty string, will use the default provided for the status code.
	--->
	<cfset this.reason = "">

	<!---
	 * The current status code for this response.
	 * The status code is a 3-digit integer result code of the server's attempt
	 * to understand and satisfy the request.
	--->
	<cfset this.statusCode = 200>

	<!---
	 * If true, will not write output. Useful during testing.
	 *
	 * Named with an underscore, because pretend() is a method.
	--->
	<cfset this.pretend_ = false>

	<!---
	 * Constructor
	 *
	 * @param config
	--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="config" type="any" required="no" default="">

		<!---
		 Default to a non-caching page.
		 Also ensures that a Cache-control header exists.
		--->
		<cfset noCache()>

		<!--- Not ported yet: the CSP object and the cookie store --->

		<!--- Default to an HTML Content-Type. Devs can override if needed. --->
		<cfset setContentType("text/html")>

		<cfreturn this>
	</cffunction>

	<!---
	 * Turns "pretend" mode on or off to aid in testing.
	 *
	 * Note that this is not a part of the interface so
	 * should not be relied on outside of internal testing.
	--->
	<cffunction name="pretend" access="public" returntype="any" output="no">
		<cfargument name="pretend" type="boolean" required="no" default="true">

		<cfset this.pretend_ = arguments.pretend>

		<cfreturn this>
	</cffunction>

	<!---
	 * Gets the response status code.
	 *
	 * The status code is a 3-digit integer result code of the server's attempt
	 * to understand and satisfy the request.
	 *
	 * @return Status code.
	--->
	<cffunction name="getStatusCode" access="public" returntype="numeric" output="no">
		<cfif this.statusCode EQ 0>
			<cfthrow type="ColdIgniter.HTTP.Exceptions.HTTPException" message="HTTP Response is missing a status code">
		</cfif>

		<cfreturn this.statusCode>
	</cffunction>

	<!---
	 * Gets the response reason phrase associated with the status code.
	 *
	 * Because a reason phrase is not a required element in a response
	 * status line, the reason phrase value MAY be null. Implementations MAY
	 * choose to return the default RFC 7231 recommended reason phrase (or those
	 * listed in the IANA HTTP Status Code Registry) for the response's
	 * status code.
	 *
	 * @see http://tools.ietf.org/html/rfc7231#section-6
	 * @see http://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
	 *
	 * @return Reason phrase; must return an empty string if none present.
	--->
	<cffunction name="getReasonPhrase" access="public" returntype="string" output="no">
		<cfif this.reason EQ "">
			<cfif this.statusCode EQ 0>
				<cfreturn "">
			</cfif>

			<cfreturn this.statusCodes[JavaCast("string", this.statusCode)]>
		</cfif>

		<cfreturn this.reason>
	</cffunction>

	<!---
	 * Return an instance with the specified status code and, optionally, reason phrase.
	 *
	 * If no reason phrase is specified, will default recommended reason phrase for
	 * the response's status code.
	 *
	 * @see http://tools.ietf.org/html/rfc7231#section-6
	 * @see http://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
	 *
	 * @param code   The 3-digit integer result code to set.
	 * @param reason The reason phrase to use with the
	 *               provided status code; if none is provided, will
	 *               default to the IANA name.
	--->
	<cffunction name="setStatusCode" access="public" returntype="any" output="no">
		<cfargument name="code" type="numeric" required="yes">
		<cfargument name="reason" type="string" required="no" default="">

		<!--- Valid range? --->
		<cfif arguments.code LT 100 OR arguments.code GT 599>
			<cfthrow type="ColdIgniter.HTTP.Exceptions.HTTPException" message="#arguments.code# is not a valid HTTP return status code">
		</cfif>

		<!--- Unknown and no message? --->
		<cfif NOT StructKeyExists(this.statusCodes, JavaCast("string", arguments.code)) AND arguments.reason EQ "">
			<cfthrow type="ColdIgniter.HTTP.Exceptions.HTTPException" message="Unknown HTTP status code provided with no message: #arguments.code#">
		</cfif>

		<cfset this.statusCode = arguments.code>

		<cfif arguments.reason NEQ "">
			<cfset this.reason = arguments.reason>
		<cfelse>
			<cfset this.reason = this.statusCodes[JavaCast("string", arguments.code)]>
		</cfif>

		<cfreturn this>
	</cffunction>

	<!---
	 * Sets the Content Type header for this response with the mime type
	 * and, optionally, the charset.
	--->
	<cffunction name="setContentType" access="public" returntype="any" output="no">
		<cfargument name="mime" type="string" required="yes">
		<cfargument name="charset" type="string" required="no" default="UTF-8">

		<!--- add charset attribute if not already there and provided as parm --->
		<cfif Find("charset=", arguments.mime) LT 2 AND arguments.charset NEQ "">
			<cfset arguments.mime = arguments.mime & "; charset=" & arguments.charset>
		</cfif>

		<cfset removeHeader("Content-Type")> <!--- replace existing content type --->
		<cfset setHeader("Content-Type", arguments.mime)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Sets the appropriate headers to ensure this response
	 * is not cached by the browsers.
	--->
	<cffunction name="noCache" access="public" returntype="any" output="no">
		<cfset var value = ArrayNew(1)>

		<cfset ArrayAppend(value, "no-store")>
		<cfset ArrayAppend(value, "max-age=0")>
		<cfset ArrayAppend(value, "no-cache")>

		<cfset removeHeader("Cache-Control")>
		<cfset setHeader("Cache-Control", value)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Sends the output to the browser.
	--->
	<cffunction name="send" access="public" returntype="any" output="no">
		<!---
		 Not ported yet: the Content Security Policy and the cookies.
		 The policy is the one that takes the nonce tags out of the body
		 when it is turned off, so that part is done here.
		--->
		<cfif IsSimpleValue(this.body)>
			<cfset this.body = Replace(this.body, "{csp-style-nonce}", "", "all")>
			<cfset this.body = Replace(this.body, "{csp-script-nonce}", "", "all")>
		</cfif>

		<cfset sendHeaders()>
		<cfset sendBody()>

		<cfreturn this>
	</cffunction>

	<!---
	 * Sends the headers of this HTTP response to the browser.
	--->
	<cffunction name="sendHeaders" access="public" returntype="any" output="no">
		<cfset var headers = "">
		<cfset var name = "">

		<!--- Have the headers already been sent? --->
		<cfif this.pretend_>
			<cfreturn this>
		</cfif>

		<!--- Not ported yet: the Date header --->

		<!--- HTTP Status --->
		<cfheader statuscode="#getStatusCode()#" statustext="#getReasonPhrase()#">

		<!--- Send all of our headers --->
		<cfset headers = this.headers()>
		<cfloop collection="#headers#" item="name">
			<cfif name EQ "Content-Type">
				<cfcontent type="#headers[name]#">
			<cfelse>
				<cfheader name="#name#" value="#headers[name]#">
			</cfif>
		</cfloop>

		<cfreturn this>
	</cffunction>

	<!---
	 * Sends the Body of the message to the browser.
	--->
	<cffunction name="sendBody" access="public" returntype="any" output="no">
		<cfset request.ColdIgniter.output = request.ColdIgniter.output & this.body>

		<cfreturn this>
	</cffunction>

</cfcomponent>
