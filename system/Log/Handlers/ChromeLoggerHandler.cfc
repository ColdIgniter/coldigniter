<!---
 * Allows for logging items to the Chrome console for debugging.
 * Requires the ChromeLogger extension installed in your browser.
 *
 * @see https://craig.is/writing/chrome-logger
 *
 * Difference: the original takes the file and the line of the caller from
 * debug_backtrace() (backtraceLevel). CFML has no backtrace that can be
 * read at a call, so the backtrace of each row is always "unknown".
--->
<cfcomponent output="no" extends="BaseHandler" hint="Allows for logging items to the Chrome console for debugging">

	<!---
	 * Version of this library - for ChromeLogger use.
	--->
	<cfset this.VERSION = JavaCast("double", 1)>

	<!---
	 * The number of track frames returned from the backtrace.
	 *
	 * @var int
	 *
	 * Not ported yet: the backtrace (see the top of the file)
	--->
	<cfset this.backtraceLevel = 0>

	<!---
	 * The final data that is sent to the browser.
	 *
	 * A map, with version, columns, rows and request_uri. It is made in
	 * the constructor, as a map cannot be a default of a property.
	--->
	<cfset this.json = "">

	<!---
	 * The header used to pass the data.
	 *
	 * @var string
	--->
	<cfset this.header = "X-ChromeLogger-Data">

	<!---
	 * Maps the log levels to the ChromeLogger types.
	 *
	 * @var array<string, string>
	--->
	<cfset this.levels = array_(
		"emergency", "error",
		"alert", "error",
		"critical", "error",
		"error", "error",
		"warning", "warn",
		"notice", "warn",
		"info", "info",
		"debug", "info"
	)>

	<!---
	 * @param config A map: handles
	--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="config" type="any" required="no" default="">
		<cfset var columns = ArrayNew(1)>

		<cfif is_null(arguments.config)>
			<cfset arguments.config = array_()>
		</cfif>

		<cfset super.__construct(arguments.config)>

		<cfset ArrayAppend(columns, "log")>
		<cfset ArrayAppend(columns, "backtrace")>
		<cfset ArrayAppend(columns, "type")>

		<cfset this.json = array_(
			"version", this.VERSION,
			"columns", columns,
			"rows", ArrayNew(1)
		)>

		<cfset helper("url")>

		<cfset this.json["request_uri"] = current_url()>

		<cfreturn this>
	</cffunction>

	<!---
	 * Handles logging the message.
	 * If the handler returns false, then execution of handlers
	 * will stop. Any handlers that have not run, yet, will not
	 * be run.
	 *
	 * @param level   string
	 * @param message object|string
	--->
	<cffunction name="handle" access="public" returntype="boolean" output="no">
		<cfargument name="level" type="string" required="yes">
		<cfargument name="message" type="any" required="yes">
		<cfset var backtraceMessage = "unknown">
		<cfset var type = "">
		<cfset var row = ArrayNew(1)>
		<cfset var log = ArrayNew(1)>

		<cfset arguments.message = format(arguments.message)>

		<!--- Not ported yet: the file and the line of the backtrace (see the top of the file) --->

		<!--- Default to 'log' type. --->
		<cfif array_key_exists(arguments.level, this.levels)>
			<cfset type = this.levels[arguments.level]>
		</cfif>

		<cfset ArrayAppend(log, arguments.message)>
		<cfset ArrayAppend(row, log)>
		<cfset ArrayAppend(row, backtraceMessage)>
		<cfset ArrayAppend(row, type)>

		<cfset ArrayAppend(this.json["rows"], row)>

		<cfset sendLogs()>

		<cfreturn true>
	</cffunction>

	<!---
	 * Converts the object to display nicely in the Chrome Logger UI.
	 *
	 * @param object object|string
	 *
	 * @return A map, or a string
	--->
	<cffunction name="format" access="private" returntype="any" output="no">
		<cfargument name="object" type="any" required="yes">
		<cfset var objectArray = "">
		<cfset var key = "">

		<cfif NOT IsObject(arguments.object)>
			<cfreturn arguments.object>
		</cfif>

		<!--- @todo Modify formatting of objects once we can view them in browser. --->
		<cfset objectArray = array_()>

		<cfif IsStruct(arguments.object)>
			<cfloop collection="#arguments.object#" item="key">
				<cfif NOT IsCustomFunction(arguments.object[key])>
					<cfset objectArray[key] = arguments.object[key]>
				</cfif>
			</cfloop>
		</cfif>

		<cfset objectArray["___class_name"] = Replace(GetMetaData(arguments.object).name, ".", "\", "all")>

		<cfreturn objectArray>
	</cffunction>

	<!---
	 * Attaches the header and the content to the passed in response object.
	 *
	 * Difference: the original takes the response by reference, so the
	 * caller sees the one that was made. CFML cannot, so the response is
	 * returned.
	 *
	 * @param response The Response, or an empty string for the shared one
	--->
	<cffunction name="sendLogs" access="public" returntype="any" output="no">
		<cfargument name="response" type="any" required="no" default="">
		<cfset var data = "">

		<cfif NOT instanceof_(arguments.response, "ColdIgniter\HTTP\ResponseInterface")>
			<cfset arguments.response = service("response", "", true)>
		</cfif>

		<!--- mb_convert_encoding() to UTF-8: a CFML string is Unicode, so it is encoded to bytes --->
		<cfset data = ToBase64(JavaCast("string", json_encode(this.json)).getBytes("UTF-8"))>

		<cfset arguments.response.setHeader(this.header, data)>

		<cfreturn arguments.response>
	</cffunction>

</cfcomponent>
