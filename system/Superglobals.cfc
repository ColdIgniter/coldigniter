<!---
 * Superglobals manipulation.
 *
 * Provides a clean API for accessing and manipulating the request
 * values, with automatic synchronization of state.
 *
 * The server values are read from the CGI scope, which cannot be
 * changed: a value set here is kept in this object only.
 *
 * Difference: a request header can supply a server variable, so the CGI
 * scope is read through server_value() (see Common.cfm): only the real
 * server variables and the HTTP_* names, and not a server variable that a
 * header has supplied.
 *
 * The get, post and cookie values stand in for the three arrays of the
 * original. They are read from the query string, from a urlencoded
 * body and from the cookie header, so that the names keep the case they
 * were sent in (the url, form and cookie scopes upper-case them).
 *
 * Not ported yet: the files array (file uploads), and the names of a
 * multipart/form-data body, which come from the form scope in upper case.
--->
<cfcomponent output="no" hint="Superglobals manipulation">

	<!--- The server array. Named with an underscore, because server() is a method. --->
	<cfset this.server_ = StructNew()>

	<!--- The get array. Named with an underscore, because get() is a method. --->
	<cfset this.get_ = CreateObject("java", "java.util.LinkedHashMap").init()>

	<!--- The post array. Named with an underscore, because post() is a method. --->
	<cfset this.post_ = CreateObject("java", "java.util.LinkedHashMap").init()>

	<!--- The cookie array. Named with an underscore, because cookie() is a method. --->
	<cfset this.cookie_ = CreateObject("java", "java.util.LinkedHashMap").init()>

	<!--- The files array. --->
	<cfset this.files = CreateObject("java", "java.util.LinkedHashMap").init()>

	<!--- The request array. Named with an underscore, because request() is a method. --->
	<cfset this.request_ = CreateObject("java", "java.util.LinkedHashMap").init()>

	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="server" type="any" required="no" default="">
		<cfargument name="get" type="any" required="no" default="">
		<cfargument name="post" type="any" required="no" default="">
		<cfargument name="cookie" type="any" required="no" default="">
		<cfargument name="files" type="any" required="no" default="">
		<cfargument name="request_" type="any" required="no" default="">

		<cfif NOT is_null(arguments.server)>
			<cfset setServerArray(arguments.server)>
		</cfif>

		<!--- The scopes stand in for the superglobals, where the original reads $_GET, $_POST and $_COOKIE. --->
		<cfif is_null(arguments.get)>
			<cfset arguments.get = parse_str(server_value("QUERY_STRING"))>
		</cfif>
		<cfif is_null(arguments.post)>
			<cfset arguments.post = readPost()>
		</cfif>
		<cfif is_null(arguments.cookie)>
			<cfset arguments.cookie = readCookie()>
		</cfif>
		<cfif is_null(arguments.files)>
			<cfset arguments.files = CreateObject("java", "java.util.LinkedHashMap").init()>
		</cfif>

		<cfset setGetArray(arguments.get)>
		<cfset setPostArray(arguments.post)>
		<cfset setCookieArray(arguments.cookie)>
		<cfset setFilesArray(arguments.files)>

		<cfif is_null(arguments.request_)>
			<cfset arguments.request_ = getRequestData()>
		</cfif>

		<cfset setRequestArray(arguments.request_)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Get a server value
	 *
	 * @return The value, or the default (an empty string) if there is none
	--->
	<cffunction name="server" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="default" type="any" required="no" default="">
		<cfset var value = "">

		<cfif StructKeyExists(this.server_, arguments.key)>
			<cfreturn this.server_[arguments.key]>
		</cfif>

		<cfset value = server_value(arguments.key)>

		<!--- The web server gives the path without the query string. --->
		<cfif arguments.key EQ "REQUEST_URI">
			<cfif value EQ "">
				<cfset value = server_value("PATH_INFO")>
			</cfif>
			<cfif server_value("QUERY_STRING") NEQ "">
				<cfset value = value & "?" & server_value("QUERY_STRING")>
			</cfif>
		</cfif>

		<cfif value EQ "">
			<cfreturn arguments.default>
		</cfif>

		<cfreturn value>
	</cffunction>

	<!---
	 * Set a server value
	--->
	<cffunction name="setServer" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="value" type="any" required="yes">

		<cfset this.server_[arguments.key] = arguments.value>

		<cfreturn this>
	</cffunction>

	<!---
	 * Remove a server value
	--->
	<cffunction name="unsetServer" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">

		<cfset StructDelete(this.server_, arguments.key)>

		<cfreturn this>
	</cffunction>


	<!---
	 * Get all server values.
	 *
	 * The CGI scope has no values that are empty, and a value set with
	 * setServer() comes last.
	--->
	<cffunction name="getServerArray" access="public" returntype="any" output="no">
		<cfset var result = CreateObject("java", "java.util.LinkedHashMap").init()>
		<cfset var key = "">
		<cfset var value = "">

		<cfloop collection="#CGI#" item="key">
			<cfset value = server_value(key)>

			<cfif value NEQ "">
				<cfset result[key] = value>
			</cfif>
		</cfloop>

		<cfset result["REQUEST_URI"] = this.server("REQUEST_URI")>

		<cfloop collection="#this.server_#" item="key">
			<cfset result[key] = this.server_[key]>
		</cfloop>

		<cfreturn result>
	</cffunction>

	<!---
	 * Set the entire server array.
	 *
	 * Difference: a key that is not in it is still read from the CGI scope.
	--->
	<cffunction name="setServerArray" access="public" returntype="any" output="no">
		<cfargument name="array" type="any" required="yes">

		<cfset this.server_ = arguments.array>

		<cfreturn this>
	</cffunction>

	<!---
	 * Get a value from GET.
	 *
	 * @return The value, or the default (an empty string) if there is none
	--->
	<cffunction name="get" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="default" type="any" required="no" default="">

		<cfif StructKeyExists(this.get_, arguments.key)>
			<cfreturn this.get_[arguments.key]>
		</cfif>

		<cfreturn arguments.default>
	</cffunction>

	<!---
	 * Set a value in GET.
	--->
	<cffunction name="setGet" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="value" type="any" required="yes">

		<cfset this.get_[arguments.key] = arguments.value>

		<cfreturn this>
	</cffunction>

	<!---
	 * Remove a key from GET.
	--->
	<cffunction name="unsetGet" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">

		<cfset this.get_.remove(arguments.key)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Get all GET values.
	--->
	<cffunction name="getGetArray" access="public" returntype="any" output="no">
		<cfreturn this.get_>
	</cffunction>

	<!---
	 * Set the entire GET array.
	--->
	<cffunction name="setGetArray" access="public" returntype="any" output="no">
		<cfargument name="array" type="any" required="yes">

		<cfset this.get_ = arguments.array>

		<cfreturn this>
	</cffunction>

	<!---
	 * Get a value from POST.
	 *
	 * @return The value, or the default (an empty string) if there is none
	--->
	<cffunction name="post" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="default" type="any" required="no" default="">

		<cfif StructKeyExists(this.post_, arguments.key)>
			<cfreturn this.post_[arguments.key]>
		</cfif>

		<cfreturn arguments.default>
	</cffunction>

	<!---
	 * Set a value in POST.
	--->
	<cffunction name="setPost" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="value" type="any" required="yes">

		<cfset this.post_[arguments.key] = arguments.value>

		<cfreturn this>
	</cffunction>

	<!---
	 * Remove a key from POST.
	--->
	<cffunction name="unsetPost" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">

		<cfset this.post_.remove(arguments.key)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Get all POST values.
	--->
	<cffunction name="getPostArray" access="public" returntype="any" output="no">
		<cfreturn this.post_>
	</cffunction>

	<!---
	 * Set the entire POST array.
	--->
	<cffunction name="setPostArray" access="public" returntype="any" output="no">
		<cfargument name="array" type="any" required="yes">

		<cfset this.post_ = arguments.array>

		<cfreturn this>
	</cffunction>

	<!---
	 * Get a value from COOKIE.
	 *
	 * @return The value, or the default (an empty string) if there is none
	--->
	<cffunction name="cookie" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="default" type="any" required="no" default="">

		<cfif StructKeyExists(this.cookie_, arguments.key)>
			<cfreturn this.cookie_[arguments.key]>
		</cfif>

		<cfreturn arguments.default>
	</cffunction>

	<!---
	 * Set a value in COOKIE.
	--->
	<cffunction name="setCookie" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="value" type="any" required="yes">

		<cfset this.cookie_[arguments.key] = arguments.value>

		<cfreturn this>
	</cffunction>

	<!---
	 * Remove a key from COOKIE.
	--->
	<cffunction name="unsetCookie" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">

		<cfset this.cookie_.remove(arguments.key)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Get all COOKIE values.
	--->
	<cffunction name="getCookieArray" access="public" returntype="any" output="no">
		<cfreturn this.cookie_>
	</cffunction>

	<!---
	 * Set the entire COOKIE array.
	--->
	<cffunction name="setCookieArray" access="public" returntype="any" output="no">
		<cfargument name="array" type="any" required="yes">

		<cfset this.cookie_ = arguments.array>

		<cfreturn this>
	</cffunction>

	<!---
	 * Get a value from REQUEST.
	 *
	 * @return The value, or the default (an empty string) if there is none
	--->
	<cffunction name="request" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="default" type="any" required="no" default="">

		<cfif StructKeyExists(this.request_, arguments.key)>
			<cfreturn this.request_[arguments.key]>
		</cfif>

		<cfreturn arguments.default>
	</cffunction>

	<!---
	 * Set a value in REQUEST.
	--->
	<cffunction name="setRequest" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="value" type="any" required="yes">

		<cfset this.request_[arguments.key] = arguments.value>

		<cfreturn this>
	</cffunction>

	<!---
	 * Remove a key from REQUEST.
	--->
	<cffunction name="unsetRequest" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">

		<cfset this.request_.remove(arguments.key)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Get all REQUEST values.
	--->
	<cffunction name="getRequestArray" access="public" returntype="any" output="no">
		<cfreturn this.request_>
	</cffunction>

	<!---
	 * Set the entire REQUEST array.
	--->
	<cffunction name="setRequestArray" access="public" returntype="any" output="no">
		<cfargument name="array" type="any" required="yes">

		<cfset this.request_ = arguments.array>

		<cfreturn this>
	</cffunction>

	<!---
	 * Returns the merged GET, POST, and COOKIE data according to the
	 * `request_order` (or `variables_order`) ini setting, without mutating
	 * the request array.
	 *
	 * The request array is filled only once at the start of the request.
	 * When the get array is modified later (e.g. by SiteURIFactory), it
	 * becomes stale. This method returns the current merged values so
	 * callers can read up-to-date request data without relying on the
	 * stale request array.
	 *
	 * @param requestOrder Overrides the `request_order` ini setting.
	 *                     Useful for testing, since the ini setting
	 *                     cannot be changed at runtime.
	--->
	<cffunction name="getRequestData" access="public" returntype="any" output="no">
		<cfargument name="requestOrder" type="string" required="no" default="">
		<cfset var merged = CreateObject("java", "java.util.LinkedHashMap").init()>
		<cfset var seen = "">
		<cfset var type = "">
		<cfset var i = 0>

		<cfif is_null(arguments.requestOrder)>
			<cfset arguments.requestOrder = ini_get("request_order")>
		</cfif>

		<cfif arguments.requestOrder EQ "">
			<cfset arguments.requestOrder = ini_get("variables_order")>
		</cfif>

		<cfif arguments.requestOrder EQ "">
			<cfset arguments.requestOrder = "GP">
		</cfif>

		<cfset arguments.requestOrder = UCase(arguments.requestOrder)>

		<cfloop from="1" to="#Len(arguments.requestOrder)#" index="i">
			<cfset type = Mid(arguments.requestOrder, i, 1)>

			<!--- Every letter counts once (array_unique) --->
			<cfif Find(type, seen) EQ 0>
				<cfset seen = seen & type>

				<!--- array_replace_recursive() matches the merge of the request array: array values are merged recursively. --->
				<cfif type EQ "G">
					<cfset merged = array_replace_recursive(merged, this.get_)>
				<cfelseif type EQ "P">
					<cfset merged = array_replace_recursive(merged, this.post_)>
				<cfelseif type EQ "C">
					<cfset merged = array_replace_recursive(merged, this.cookie_)>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn merged>
	</cffunction>

	<!---
	 * Get all files values.
	--->
	<cffunction name="getFilesArray" access="public" returntype="any" output="no">
		<cfreturn this.files>
	</cffunction>

	<!---
	 * Set the entire files array.
	--->
	<cffunction name="setFilesArray" access="public" returntype="any" output="no">
		<cfargument name="array" type="any" required="yes">

		<cfset this.files = arguments.array>

		<cfreturn this>
	</cffunction>

	<!---
	 * Get a superglobal array by name.
	 *
	 * @param name The superglobal name (server, get, post, cookie, files, request)
	 *
	 * @throws InvalidArgumentException If the superglobal name is invalid
	--->
	<cffunction name="getGlobalArray" access="public" returntype="any" output="no">
		<cfargument name="name" type="string" required="yes">

		<cfswitch expression="#arguments.name#">
			<cfcase value="server"><cfreturn getServerArray()></cfcase>
			<cfcase value="get"><cfreturn getGetArray()></cfcase>
			<cfcase value="post"><cfreturn getPostArray()></cfcase>
			<cfcase value="cookie"><cfreturn getCookieArray()></cfcase>
			<cfcase value="files"><cfreturn getFilesArray()></cfcase>
			<cfcase value="request"><cfreturn getRequestArray()></cfcase>
			<cfdefaultcase>
				<cfthrow type="ColdIgniter.Exceptions.InvalidArgumentException" message="Invalid superglobal name '#arguments.name#'. Must be one of: server, get, post, cookie, files, request.">
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<!---
	 * Set a superglobal array by name.
	 *
	 * @param name  The superglobal name (server, get, post, cookie, files, request)
	 * @param array The array to set
	 *
	 * @throws InvalidArgumentException If the superglobal name is invalid
	--->
	<cffunction name="setGlobalArray" access="public" returntype="void" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="array" type="any" required="yes">

		<cfswitch expression="#arguments.name#">
			<cfcase value="server"><cfset setServerArray(arguments.array)></cfcase>
			<cfcase value="get"><cfset setGetArray(arguments.array)></cfcase>
			<cfcase value="post"><cfset setPostArray(arguments.array)></cfcase>
			<cfcase value="cookie"><cfset setCookieArray(arguments.array)></cfcase>
			<cfcase value="files"><cfset setFilesArray(arguments.array)></cfcase>
			<cfcase value="request"><cfset setRequestArray(arguments.array)></cfcase>
			<cfdefaultcase>
				<cfthrow type="ColdIgniter.Exceptions.InvalidArgumentException" message="Invalid superglobal name '#arguments.name#'. Must be one of: server, get, post, cookie, files, request.">
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<!---
	 * The post values of this request. These stand in for the post array
	 * the web server fills in the original.
	 *
	 * A urlencoded body is parsed from the body itself, to keep the names
	 * as they were sent. For multipart/form-data the form scope is all
	 * there is, so the names are upper case and several values of a name
	 * come joined by commas.
	--->
	<cffunction name="readPost" access="private" returntype="any" output="no">
		<cfset var contentType = LCase(CGI.CONTENT_TYPE)>
		<cfset var content = "">
		<cfset var query = "">
		<cfset var key = "">

		<cfif server_value("REQUEST_METHOD") NEQ "POST">
			<cfreturn CreateObject("java", "java.util.LinkedHashMap").init()>
		</cfif>

		<cfif Find("application/x-www-form-urlencoded", contentType) GT 0>
			<cfset content = http_request_data().content>

			<cfif IsBinary(content)>
				<cfset content = ToString(content)>
			</cfif>

			<cfreturn parse_str(content)>
		</cfif>

		<cfif Find("multipart/form-data", contentType) GT 0>
			<cfloop collection="#form#" item="key">
				<cfif key NEQ "FIELDNAMES" AND IsSimpleValue(form[key])>
					<cfset query = query & "&" & URLEncodedFormat(key) & "=" & URLEncodedFormat(form[key])>
				</cfif>
			</cfloop>

			<cfreturn parse_str(query)>
		</cfif>

		<cfreturn CreateObject("java", "java.util.LinkedHashMap").init()>
	</cffunction>

	<!---
	 * The cookies of this request, read from the cookie header, because
	 * the cookie scope upper-cases the names. These stand in for the
	 * cookie array the web server fills in the original.
	--->
	<cffunction name="readCookie" access="private" returntype="any" output="no">
		<cfset var pairs = explode(";", CGI.HTTP_COOKIE)>
		<cfset var query = "">
		<cfset var seen = CreateObject("java", "java.util.HashMap").init()>
		<cfset var name = "">
		<cfset var position = 0>
		<cfset var isElement = false>
		<cfset var i = 0>

		<cfloop from="1" to="#ArrayLen(pairs)#" index="i">
			<cfif Trim(pairs[i]) NEQ "">
				<!--- a name that repeats keeps its first value (an array element appends) --->
				<cfset name = Trim(pairs[i])>
				<cfset position = Find("=", name)>
				<cfif position GT 0>
					<cfset name = Left(name, position - 1)>
				</cfif>

				<!--- the name as parse_str() keys it: cut at a NUL, decoded, left-trimmed, dots and spaces replaced --->
				<cfset position = FindNoCase("%00", name)>
				<cfif position GT 0>
					<cfset name = Left(name, position - 1)>
				</cfif>
				<cfset name = LTrim(parse_str_decode(name))>
				<cfset position = Find("[", name)>
				<cfset isElement = position GT 0 AND Find("]", name, position) GT 0>
				<cfset name = parse_str_key(name)>

				<cfif isElement OR NOT seen.containsKey(name)>
					<cfset seen.put(name, "")>

					<!--- a cookie value is not form-encoded: keep a plus and an ampersand --->
					<cfset query = query & "&" & Replace(Replace(Trim(pairs[i]), "+", "%2B", "all"), "&", "%26", "all")>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn parse_str(query)>
	</cffunction>

</cfcomponent>
