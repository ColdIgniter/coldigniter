<!---
 * An HTTP message
 *
 * A header is kept as its name and its value line here; the original
 * keeps a Header object for each.
 *
 * The checks of the Header class (validateName and validateValue) are
 * done here, in setHeader, as the Header constructor does them.
 *
 * Not ported yet: appendHeader, prependHeader, addHeader, the Header
 * class, and headers that have more than one value.
--->
<cfcomponent output="no" hint="An HTTP message">

	<!---
	 * List of all HTTP request headers.
	 *
	 * [name => value]
	 *
	 * Named with an underscore, because headers() is a method.
	--->
	<cfset this.headers_ = CreateObject("java", "java.util.LinkedHashMap").init()>

	<!---
	 * Holds a map of lower-case header names
	 * and their normal-case key as it is in headers.
	 * Used for case-insensitive header access.
	--->
	<cfset this.headerMap = CreateObject("java", "java.util.LinkedHashMap").init()>

	<!---
	 * Protocol version
	--->
	<cfset this.protocolVersion = "">

	<!---
	 * List of valid protocol versions
	--->
	<cfset this.validProtocolVersions = "1.0,1.1,2.0,3.0">

	<!---
	 * Message body
	--->
	<cfset this.body = "">

	<!---
	 * Returns the Message's body.
	--->
	<cffunction name="getBody" access="public" returntype="any" output="no">
		<cfreturn this.body>
	</cffunction>

	<!---
	 * Sets the body of the current message.
	--->
	<cffunction name="setBody" access="public" returntype="any" output="no">
		<cfargument name="data" type="any" required="yes">

		<cfset this.body = arguments.data>

		<cfreturn this>
	</cffunction>

	<!---
	 * Appends data to the body of the current message.
	--->
	<cffunction name="appendBody" access="public" returntype="any" output="no">
		<cfargument name="data" type="any" required="yes">

		<cfset this.body = this.body & arguments.data>

		<cfreturn this>
	</cffunction>

	<!---
	 * Populates the headers with the request headers.
	--->
	<cffunction name="populateHeaders" access="public" returntype="void" output="no">
		<cfset var headers = GetHttpRequestData().headers>
		<cfset var name = "">

		<cfloop collection="#headers#" item="name">
			<cfif IsSimpleValue(headers[name])>
				<cfset setHeader(name, headers[name])>
			</cfif>
		</cfloop>
	</cffunction>

	<!---
	 * Returns an array containing all Headers.
	 *
	 * @return An array of the headers, by name
	--->
	<cffunction name="headers" access="public" returntype="any" output="no">
		<cfreturn this.headers_>
	</cffunction>

	<!---
	 * Returns a single Header.
	 *
	 * @return The value line of the header, or an empty string if there is none
	--->
	<cffunction name="header" access="public" returntype="any" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfset var origName = getHeaderName(arguments.name)>

		<cfif StructKeyExists(this.headers_, origName)>
			<cfreturn this.headers_[origName]>
		</cfif>

		<cfreturn "">
	</cffunction>

	<!---
	 * Sets a header and it's value.
	--->
	<cffunction name="setHeader" access="public" returntype="any" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="value" type="any" required="yes">
		<cfset var origName = getHeaderName(arguments.name)>

		<cfif IsArray(arguments.value)>
			<cfset arguments.value = implode(", ", arguments.value)>
		</cfif>

		<cfset validateName(arguments.name)>
		<cfset validateValue(arguments.value)>

		<cfset this.headers_[origName] = arguments.value>
		<cfset this.headerMap[LCase(origName)] = origName>

		<cfreturn this>
	</cffunction>

	<!---
	 * Removes a header from the list of headers we track.
	--->
	<cffunction name="removeHeader" access="public" returntype="any" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfset var origName = getHeaderName(arguments.name)>

		<cfset StructDelete(this.headers_, origName)>
		<cfset StructDelete(this.headerMap, LCase(arguments.name))>

		<cfreturn this>
	</cffunction>

	<!---
	 * Determines whether a header exists.
	--->
	<cffunction name="hasHeader" access="public" returntype="boolean" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfset var origName = getHeaderName(arguments.name)>

		<cfreturn StructKeyExists(this.headers_, origName)>
	</cffunction>

	<!---
	 * Retrieves a comma-separated string of the values for a single header.
	--->
	<cffunction name="getHeaderLine" access="public" returntype="string" output="no">
		<cfargument name="name" type="string" required="yes">

		<cfreturn header(arguments.name)>
	</cffunction>

	<!---
	 * Returns the HTTP Protocol Version.
	--->
	<cffunction name="getProtocolVersion" access="public" returntype="string" output="no">
		<cfif this.protocolVersion EQ "">
			<cfreturn "1.1">
		</cfif>

		<cfreturn this.protocolVersion>
	</cffunction>

	<!---
	 * Sets the HTTP protocol version.
	--->
	<cffunction name="setProtocolVersion" access="public" returntype="any" output="no">
		<cfargument name="version" type="string" required="yes">

		<cfif NOT IsNumeric(arguments.version)>
			<cfset arguments.version = Mid(arguments.version, Find("/", arguments.version) + 1, Len(arguments.version))>
		</cfif>

		<!--- Make sure that version is in the correct format --->
		<cfset arguments.version = NumberFormat(arguments.version, "9.0")>
		<cfset arguments.version = Trim(arguments.version)>

		<cfif ListFind(this.validProtocolVersions, arguments.version) EQ 0>
			<cfthrow type="ColdIgniter.HTTP.Exceptions.HTTPException" message="Invalid HTTP Protocol Version. Must be one of: #this.validProtocolVersions#">
		</cfif>

		<cfset this.protocolVersion = arguments.version>

		<cfreturn this>
	</cffunction>

	<!---
	 * Takes a header name in any case, and returns the
	 * normal-case version of the header.
	--->
	<cffunction name="getHeaderName" access="private" returntype="string" output="no">
		<cfargument name="name" type="string" required="yes">

		<cfif StructKeyExists(this.headerMap, LCase(arguments.name))>
			<cfreturn this.headerMap[LCase(arguments.name)]>
		</cfif>

		<cfreturn arguments.name>
	</cffunction>

	<!---
	 * Validate header name.
	 *
	 * @see https://datatracker.ietf.org/doc/html/rfc7230#section-3.2
	 *
	 * @throws InvalidArgumentException
	--->
	<cffunction name="validateName" access="private" returntype="void" output="no">
		<cfargument name="name" type="string" required="yes">

		<cfif NOT JavaCast("string", arguments.name).matches("[a-zA-Z0-9'`##$%&*+.^_|~!-]+")>
			<cfthrow type="ColdIgniter.Exceptions.InvalidArgumentException" message="The header name is not valid as per RFC 7230.">
		</cfif>
	</cffunction>

	<!---
	 * Validate header value.
	 *
	 * The original checks the bytes of the value; a CFML string holds
	 * characters, so all characters from U+0080 up stand for the bytes
	 * \x80-\xFF of their UTF-8 form.
	 *
	 * @see https://datatracker.ietf.org/doc/html/rfc7230#section-3.2
	 *
	 * @throws InvalidArgumentException
	--->
	<cffunction name="validateValue" access="private" returntype="void" output="no">
		<cfargument name="value" type="any" required="yes">

		<!---
		 The original returns for an int. There is no int type here, and
		 the text of a number passes the check below anyway.
		--->

		<!--- The regular expression excludes obs-fold per RFC 7230#3.2.4 --->
		<cfif NOT JavaCast("string", arguments.value).matches("[\x20\x09\x21-\x7E\u0080-\uFFFF]*")>
			<cfthrow type="ColdIgniter.Exceptions.InvalidArgumentException" message="The header value is not valid as per RFC 7230.">
		</cfif>
	</cffunction>

</cfcomponent>
