<!---
 * An HTTP message
 *
 * A header is kept as its name and its value line here; the original
 * keeps a Header object for each.
 *
 * The checks of the Header class (validateName and validateValue) are
 * done here, in setHeader, as the Header constructor does them.
 *
 * Difference: there is no Header class. The values of one header are kept
 * as one line, joined with ", " (what getValueLine() gives). Several
 * headers of the same name (addHeader) are a list of such lines.
 * appendHeader does not add a value that the line has already.
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
		<cfset var headers = http_request_data().headers>
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
		<cfset var origName = "">

		<cfset checkMultipleHeaders(arguments.name)>

		<cfset origName = getHeaderName(arguments.name)>

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
	 * Returns an array containing all Headers.
	 *
	 * @return An array of the headers, by name
	--->
	<cffunction name="getHeaders" access="public" returntype="any" output="no">
		<cfreturn headers()>
	</cffunction>

	<!---
	 * Returns a single Header. If multiple headers with the same
	 * name exist, then will return a list of them.
	--->
	<cffunction name="getHeader" access="public" returntype="any" output="no">
		<cfargument name="name" type="string" required="yes">

		<cfreturn header(arguments.name)>
	</cffunction>

	<cffunction name="hasMultipleHeaders" access="private" returntype="boolean" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfset var origName = getHeaderName(arguments.name)>

		<cfreturn StructKeyExists(this.headers_, origName) AND IsArray(this.headers_[origName])>
	</cffunction>

	<cffunction name="checkMultipleHeaders" access="private" returntype="void" output="no">
		<cfargument name="name" type="string" required="yes">

		<cfif hasMultipleHeaders(arguments.name)>
			<cfthrow type="ColdIgniter.Exceptions.InvalidArgumentException" message="The header ""#arguments.name#"" already has multiple headers. You cannot change them. If you really need to change, remove the header first.">
		</cfif>
	</cffunction>

	<!---
	 * Adds an additional header value to any headers that accept
	 * multiple values.
	 *
	 * A value that is an empty string stands for null: nothing is added to
	 * a header that exists.
	--->
	<cffunction name="appendHeader" access="public" returntype="any" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="value" type="any" required="no" default="">
		<cfset var origName = "">
		<cfset var line = "">

		<cfset checkMultipleHeaders(arguments.name)>

		<cfset origName = getHeaderName(arguments.name)>

		<cfif NOT StructKeyExists(this.headers_, origName)>
			<cfset setHeader(arguments.name, arguments.value)>
			<cfreturn this>
		</cfif>

		<cfif is_null(arguments.value)>
			<cfreturn this>
		</cfif>

		<cfset validateValue(arguments.value)>

		<cfset line = this.headers_[origName]>

		<!--- a value that the line has already is not added again --->
		<cfif Find(", " & arguments.value & ", ", ", " & line & ", ") EQ 0>
			<cfset this.headers_[origName] = line & ", " & arguments.value>
		</cfif>

		<cfreturn this>
	</cffunction>

	<!---
	 * Adds a header (not a header value) with the same name.
	 * Use this only when you set multiple headers with the same name,
	 * typically, for `Set-Cookie`.
	--->
	<cffunction name="addHeader" access="public" returntype="any" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="value" type="string" required="yes">
		<cfset var origName = getHeaderName(arguments.name)>
		<cfset var line = "">

		<cfif NOT StructKeyExists(this.headers_, origName)>
			<cfset setHeader(arguments.name, arguments.value)>
			<cfreturn this>
		</cfif>

		<cfset validateValue(arguments.value)>

		<cfif NOT hasMultipleHeaders(arguments.name)>
			<cfset line = this.headers_[origName]>
			<cfset this.headers_[origName] = ArrayNew(1)>
			<cfset ArrayAppend(this.headers_[origName], line)>
		</cfif>

		<cfset ArrayAppend(this.headers_[origName], arguments.value)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Adds a value in front of the values of a header.
	 *
	 * Difference: a header that does not exist is set (the original
	 * fails on a missing header).
	--->
	<cffunction name="prependHeader" access="public" returntype="any" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="value" type="string" required="yes">
		<cfset var origName = "">

		<cfset checkMultipleHeaders(arguments.name)>

		<cfset origName = getHeaderName(arguments.name)>

		<cfif NOT StructKeyExists(this.headers_, origName)>
			<cfset setHeader(arguments.name, arguments.value)>
			<cfreturn this>
		</cfif>

		<cfset validateValue(arguments.value)>

		<cfset this.headers_[origName] = arguments.value & ", " & this.headers_[origName]>

		<cfreturn this>
	</cffunction>

	<!---
	 * Retrieves a comma-separated string of the values for a single header.
	--->
	<cffunction name="getHeaderLine" access="public" returntype="string" output="no">
		<cfargument name="name" type="string" required="yes">

		<cfif hasMultipleHeaders(arguments.name)>
			<cfthrow type="ColdIgniter.Exceptions.InvalidArgumentException" message="The header ""#arguments.name#"" already has multiple headers. You cannot use getHeaderLine().">
		</cfif>

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
