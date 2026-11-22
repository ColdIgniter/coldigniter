<!---
 * Common Functions
 *
 * Several application-wide utility methods.
 *
 * Not ported yet: every function that is not listed below.
--->

<!---
 * A convenience method to clean paths for
 * a nicer looking output. Useful for exception
 * handling, error logging, etc.
 *
 * Not ported yet: VENDORPATH
--->
<cffunction name="clean_path" returntype="string" output="no" hint="A convenience method to clean paths for a nicer looking output">
	<cfargument name="path" type="string" required="yes">
	<cfset var resolved = "">

	<!--- Resolve relative paths --->
	<cfset resolved = realpath(arguments.path)>
	<cfif resolved NEQ "">
		<cfset arguments.path = resolved>
	</cfif>

	<cfif Compare(Left(arguments.path, Len(request.APPPATH)), request.APPPATH) EQ 0>
		<cfreturn "APPPATH" & request.DIRECTORY_SEPARATOR & Mid(arguments.path, Len(request.APPPATH) + 1, Len(arguments.path))>
	<cfelseif Compare(Left(arguments.path, Len(request.SYSTEMPATH)), request.SYSTEMPATH) EQ 0>
		<cfreturn "SYSTEMPATH" & request.DIRECTORY_SEPARATOR & Mid(arguments.path, Len(request.SYSTEMPATH) + 1, Len(arguments.path))>
	<cfelseif Compare(Left(arguments.path, Len(request.FCPATH)), request.FCPATH) EQ 0>
		<cfreturn "FCPATH" & request.DIRECTORY_SEPARATOR & Mid(arguments.path, Len(request.FCPATH) + 1, Len(arguments.path))>
	<cfelseif Compare(Left(arguments.path, Len(request.ROOTPATH)), request.ROOTPATH) EQ 0>
		<cfreturn "ROOTPATH" & request.DIRECTORY_SEPARATOR & Mid(arguments.path, Len(request.ROOTPATH) + 1, Len(arguments.path))>
	</cfif>

	<cfreturn arguments.path>
</cffunction>

<!---
 * More simple way of getting config instances from Factories
 *
 * @param name     The config class name
 * @param getShared Whether to return the shared instance
 *
 * @return The config instance, or an empty string if it is not found
--->
<cffunction name="config" returntype="any" output="no" hint="More simple way of getting config instances from Factories">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="getShared" type="boolean" required="no" default="true">
	<cfset var arguments_ = ArrayNew(1)>
	<cfset var options = StructNew()>

	<cfif arguments.getShared>
		<cfreturn static_("ColdIgniter\Config\Factories").get("config", arguments.name)>
	</cfif>

	<cfset options["getShared"] = arguments.getShared>
	<cfset ArrayAppend(arguments_, arguments.name)>
	<cfset ArrayAppend(arguments_, options)>

	<cfreturn static_("ColdIgniter\Config\Factories").__callStatic("config", arguments_)>
</cffunction>

<!---
 * Performs simple auto-escaping of data for security reasons.
 * Might consider making this more complex at a later date.
 *
 * If data is a string, then it simply escapes and returns it.
 *
 * Not ported yet: arrays as data, the "css" context and the encoding
 * (the Escaper library is not ported). The "js" context is a small
 * stand-in for Escaper::escapeJs().
 *
 * @param data     The string
 * @param context  'attr', 'css', 'html', 'js', 'raw' or 'url'
--->
<cffunction name="esc" returntype="any" output="no" hint="Performs simple auto-escaping of data for security reasons">
	<cfargument name="data" type="any" required="yes">
	<cfargument name="context" type="string" required="no" default="html">
	<cfargument name="encoding" type="string" required="no" default="">
	<cfset var escaped = "">
	<cfset var char = "">
	<cfset var code = 0>
	<cfset var i = 0>

	<cfset arguments.context = LCase(arguments.context)>

	<!---
	 Provide a way to NOT escape data since
	 this could be called automatically by
	 the View library.
	--->
	<cfif arguments.context EQ "raw">
		<cfreturn arguments.data>
	</cfif>

	<cfif IsSimpleValue(arguments.data)>
		<cfif NOT ListFind("html,js,attr,url", arguments.context)>
			<cfthrow type="ColdIgniter.InvalidArgumentException" message="Invalid escape context provided.">
		</cfif>

		<!--- Everything but letters, digits and ",._" becomes \xHH or \uHHHH. --->
		<cfif arguments.context EQ "js">
			<cfloop from="1" to="#Len(arguments.data)#" index="i">
				<cfset char = Mid(arguments.data, i, 1)>
				<cfif REFind("[A-Za-z0-9,._]", char) GT 0>
					<cfset escaped = escaped & char>
				<cfelse>
					<cfset code = Asc(char)>
					<cfif code LT 256>
						<cfset escaped = escaped & "\x" & UCase(Right("0" & FormatBaseN(code, 16), 2))>
					<cfelse>
						<cfset escaped = escaped & "\u" & UCase(Right("000" & FormatBaseN(code, 16), 4))>
					</cfif>
				</cfif>
			</cfloop>

			<cfreturn escaped>
		</cfif>

		<cfif arguments.context EQ "url">
			<cfreturn URLEncodedFormat(arguments.data)>
		</cfif>

		<cfset arguments.data = HTMLEditFormat(arguments.data)>
		<cfif arguments.context EQ "attr">
			<cfset arguments.data = Replace(arguments.data, "'", "&##39;", "all")>
		</cfif>
	</cfif>

	<cfreturn arguments.data>
</cffunction>

<!---
 * Loads a helper file into memory. Supports namespaced helpers,
 * both in and out of the 'Helpers' directory of a namespaced directory.
 *
 * Will load ALL helpers of the matching name, in the following order:
 *   1. app/Helpers
 *   2. {namespace}/Helpers
 *   3. system/Helpers
 *
 * Not ported yet: the file locator, so only app/Helpers and
 * system/Helpers are searched and a namespaced name is never found.
 *
 * The functions of a helper file become global (see require_once) and
 * the first definition of a name wins, which is how an app helper
 * overrides a system one. The caller gets the functions at once, also
 * when another object loaded the file earlier.
 *
 * @param filenames Array of names, or one name
 *
 * @throws FileNotFoundException
--->
<cffunction name="helper" returntype="void" output="no" hint="Loads a helper file into memory">
	<cfargument name="filenames" type="any" required="yes">
	<cfset var loaded = request.ColdIgniter.helpers>

	<!--- Store a list of all files to include... --->
	<cfset var includes = ArrayNew(1)>
	<cfset var filename = "">
	<cfset var systemHelper = "">
	<cfset var appHelper = "">
	<cfset var i = 0>

	<!--- Not ported yet: loader = service("locator") --->

	<cfif NOT IsArray(arguments.filenames)>
		<cfset filename = arguments.filenames>
		<cfset arguments.filenames = ArrayNew(1)>
		<cfset ArrayAppend(arguments.filenames, filename)>
	</cfif>

	<cfloop from="1" to="#ArrayLen(arguments.filenames)#" index="i">
		<cfset filename = arguments.filenames[i]>

		<!---
		 Store our system and application helper
		 versions so that we can control the load ordering.
		--->
		<cfset systemHelper = "">
		<cfset appHelper = "">

		<cfif Find("_helper", filename) EQ 0>
			<cfset filename = filename & "_helper">
		</cfif>

		<!--- Check if this helper has already been loaded --->
		<cfif NOT StructKeyExists(loaded, filename)>
			<!---
			 If the file is namespaced, we'll just grab that
			 file and not search for any others
			--->
			<cfif Find("\", filename) GT 0>
				<!--- Not ported yet: loader.locateFile(filename, "Helpers"), so the file is never found --->
				<cfthrow type="ColdIgniter.Files.Exceptions.FileNotFoundException" message="File not found: ""#filename#""">
			<cfelse>
				<!--- No namespaces, so search in all available locations --->
				<!--- Not ported yet: loader.search("Helpers/" & filename), and the namespace locations --->
				<cfif is_file(request.APPPATH & "Helpers" & request.DIRECTORY_SEPARATOR & filename & ".cfm")>
					<cfset appHelper = request.APPPATH & "Helpers" & request.DIRECTORY_SEPARATOR & filename & ".cfm">
				</cfif>
				<cfif is_file(request.SYSTEMPATH & "Helpers" & request.DIRECTORY_SEPARATOR & filename & ".cfm")>
					<cfset systemHelper = request.SYSTEMPATH & "Helpers" & request.DIRECTORY_SEPARATOR & filename & ".cfm">
				</cfif>

				<!--- App-level helpers should override all others --->
				<cfif appHelper NEQ "">
					<cfset ArrayAppend(includes, appHelper)>
					<cfset loaded[filename] = true>
				</cfif>

				<!--- And the system default one should be added in last. --->
				<cfif systemHelper NEQ "">
					<cfset ArrayAppend(includes, systemHelper)>
					<cfset loaded[filename] = true>
				</cfif>
			</cfif>
		</cfif>
	</cfloop>

	<!--- Now actually include all of the files --->
	<cfloop from="1" to="#ArrayLen(includes)#" index="i">
		<cfset require_once(includes[i])>
	</cfloop>

	<!--- The functions are global: this object gets them too --->
	<cfset StructAppend(variables, request.ColdIgniter.functions.__functions(), false)>
</cffunction>

<!---
 * Convenience method that works with the current global request and
 * router instances to redirect using named/reverse-routed routes
 * to determine the URL to go to.
 *
 * If more control is needed, you must use response.redirect explicitly.
 *
 * @param route Route name or Controller::method
--->
<cffunction name="redirect" returntype="any" output="no" hint="Convenience method that works with the current global request and router instances to redirect">
	<cfargument name="route" type="string" required="no" default="">
	<cfset var response = service("redirectresponse")>

	<cfif arguments.route NEQ "">
		<cfreturn response.route(arguments.route)>
	</cfif>

	<cfreturn response>
</cffunction>

<!---
 * Returns the shared Request.
 *
 * Named with an underscore, because "request" is a scope.
 *
 * @return CLIRequest|IncomingRequest
--->
<cffunction name="request_" returntype="any" output="no" hint="Returns the shared Request">
	<cfreturn service("request")>
</cffunction>

<!---
 * Given a route name or controller/method string and any params,
 * will attempt to build the relative URL to the
 * matching route.
 *
 * NOTE: This requires the controller/method to
 * have a route defined in the routes Config file.
 *
 * Not ported yet: RouteCollection::reverseRoute, so no route is found.
 *
 * @param method Route name or Controller::method
 * @param params One or more parameters to be passed to the route.
 *               The last parameter allows you to set the locale.
 *
 * @return false|string The route (URI path relative to baseURL) or false if not found.
--->
<cffunction name="route_to" returntype="any" output="no" hint="Builds the relative URL to a route name or controller method">
	<cfargument name="method" type="string" required="yes">

	<!--- Not ported yet: service("routes").reverseRoute(method, params) --->
	<cfreturn false>
</cffunction>

<!---
 * Allows cleaner access to the Services Config file.
 * Always returns a SHARED instance of the class, so
 * calling the function multiple times should always
 * return the same instance.
 *
 * These are equal:
 *  - timer = service("timer")
 *  - timer = static_("ColdIgniter\Config\Services").timer()
 *
 * service(name, param, param, ...)
--->
<cffunction name="service" returntype="any" output="no" hint="Allows cleaner access to the Services Config file">
	<cfargument name="name" type="string" required="yes">
	<cfset var params = ArrayNew(1)>
	<cfset var i = 0>

	<cfloop from="2" to="#ArrayLen(arguments)#" index="i">
		<cfset ArrayAppend(params, arguments[i])>
	</cfloop>

	<cfif ArrayLen(params) EQ 0>
		<cfreturn static_("Config\Services").get(arguments.name)>
	</cfif>

	<cfreturn static_("Config\Services").__callStatic(arguments.name, params)>
</cffunction>

<!---
 * Stringify attributes for use in HTML tags.
 *
 * Helper function used to convert a string, array, or object
 * of attributes to a string.
 *
 * An array with string keys is made with array_() (or a struct, which
 * has no order).
 *
 * @param attributes Struct, array (map) or string
--->
<cffunction name="stringify_attributes" returntype="string" output="no" hint="Stringify attributes for use in HTML tags">
	<cfargument name="attributes" type="any" required="yes">
	<cfargument name="js" type="boolean" required="no" default="false">
	<cfset var atts = "">
	<cfset var key = "">

	<cfif IsSimpleValue(arguments.attributes) AND arguments.attributes EQ "">
		<cfreturn atts>
	</cfif>

	<cfif IsSimpleValue(arguments.attributes)>
		<cfreturn " " & arguments.attributes>
	</cfif>

	<cfif IsStruct(arguments.attributes)>
		<cfloop collection="#arguments.attributes#" item="key">
			<cfif arguments.js>
				<cfset atts = atts & key & "=" & esc(arguments.attributes[key], "js") & ",">
			<cfelse>
				<cfset atts = atts & " " & key & "=""" & esc(arguments.attributes[key]) & """">
			</cfif>
		</cfloop>
	<cfelse>
		<cfloop from="1" to="#ArrayLen(arguments.attributes)#" index="key">
			<cfif arguments.js>
				<cfset atts = atts & (key - 1) & "=" & esc(arguments.attributes[key], "js") & ",">
			<cfelse>
				<cfset atts = atts & " " & (key - 1) & "=""" & esc(arguments.attributes[key]) & """">
			</cfif>
		</cfloop>
	</cfif>

	<cfreturn rtrim_(atts, ",")>
</cffunction>

<!---
 * Grabs the current RendererInterface-compatible class
 * and tells it to render the specified view. Simply provides
 * a convenience method that can be used in Controllers,
 * libraries, and routed closures.
 *
 * NOTE: Does not provide any escaping of the data, so that must
 * all be handled manually by the developer.
 *
 * @param options Options for saveData or third-party extensions.
--->
<cffunction name="view" returntype="string" output="no" hint="Renders the specified view">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="data" type="any" required="no" default="#StructNew()#">
	<cfargument name="options" type="any" required="no" default="#StructNew()#">
	<cfset var renderer = service("renderer")>

	<cfset var config = variables.config("Config\View")>
	<cfset var saveData = config.saveData>

	<cfif StructKeyExists(arguments.options, "saveData")>
		<cfset saveData = arguments.options["saveData"] IS true>
		<cfset StructDelete(arguments.options, "saveData")>
	</cfif>

	<cfreturn renderer.setData(arguments.data, "raw").render(arguments.name, arguments.options, saveData)>
</cffunction>
