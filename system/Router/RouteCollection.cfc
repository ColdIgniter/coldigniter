<!---
 * Class RouteCollection
 *
 * Not ported yet: route groups, match,
 * map, redirects, group filters, priority,
 * hostname and subdomain limits, the offset option, closures as
 * handlers, route discovery in modules, and environment().
--->
<cfcomponent output="no" hint="Class RouteCollection">

	<!---
	 * The namespace to be added to any Controllers.
	 * Defaults to the global namespaces (\).
	 *
	 * This must have a trailing backslash (\).
	--->
	<cfset this.defaultNamespace = "\">

	<!---
	 * The name of the default controller to use
	 * when no other controller is specified.
	 *
	 * Not used here. Pass by reference to Router class.
	--->
	<cfset this.defaultController = "Home">

	<!---
	 * The name of the default method to use
	 * when no other method has been specified.
	 *
	 * Not used here. Pass by reference to Router class.
	--->
	<cfset this.defaultMethod = "index">

	<!---
	 * The placeholder used when routing 'resources'
	 * when no other placeholder has been specified.
	--->
	<cfset this.defaultPlaceholder = "any">

	<!---
	 * Whether to convert dashes to underscores in URI.
	 *
	 * Not used here. Pass by reference to Router class.
	--->
	<cfset this.translateURIDashes = false>

	<!---
	 * Whether to match URI against Controllers
	 * when it doesn't match defined routes.
	 *
	 * Not used here. Pass by reference to Router class.
	--->
	<cfset this.autoRoute = false>

	<!---
	 * A callable that will be shown
	 * when the route cannot be matched.
	--->
	<cfset this.override404 = "">

	<!---
	 * An array of files that would contain route definitions.
	--->
	<cfset this.routeFiles = ArrayNew(1)>

	<!---
	 * Defined placeholders that can be used
	 * within the
	--->
	<cfset this.placeholders = CreateObject("java", "java.util.LinkedHashMap").init()>
	<cfset this.placeholders["any"] = ".*">
	<cfset this.placeholders["segment"] = "[^/]+">
	<cfset this.placeholders["alphanum"] = "[a-zA-Z0-9]+">
	<cfset this.placeholders["num"] = "[0-9]+">
	<cfset this.placeholders["alpha"] = "[a-zA-Z]+">
	<cfset this.placeholders["hash"] = "[^/]+">

	<!---
	 * An array of all routes and their mappings.
	 *
	 * [
	 *     verb => [
	 *         routeKey(regex) => [
	 *             'name'    => routeName
	 *             'handler' => handler
	 *             'from'    => from
	 *         ],
	 *     ],
	 *     // redirect route
	 *     '*' => [
	 *          routeKey(regex)(from) => [
	 *             'name'     => routeName
	 *             'handler'  => [routeKey(regex)(to) => handler]
	 *             'from'     => from
	 *             'redirect' => statusCode
	 *         ],
	 *     ],
	 * ]
	--->
	<cfset this.routes = CreateObject("java", "java.util.LinkedHashMap").init()>

	<!---
	 * Array of routes names
	 *
	 * [
	 *     verb => [
	 *         routeName => routeKey(regex)
	 *     ],
	 * ]
	--->
	<cfset this.routesNames = CreateObject("java", "java.util.LinkedHashMap").init()>

	<!---
	 * Array of routes options
	 *
	 * [
	 *     verb => [
	 *         routeKey(regex) => [
	 *             key => value,
	 *         ]
	 *     ],
	 * ]
	--->
	<cfset this.routesOptions = CreateObject("java", "java.util.LinkedHashMap").init()>

	<!---
	 * Flag that limits the routes with a {locale} placeholder
	 * to the supported locales of the App config.
	--->
	<cfset this.useSupportedLocalesOnly = false>

	<!---
	 * The HTTP methods of the Router (Router::HTTP_METHODS).
	--->
	<cfset this.defaultHTTPMethods = ListToArray("GET,HEAD,POST,PATCH,PUT,DELETE,OPTIONS,TRACE,CONNECT,CLI")>

	<cfloop list="*,GET,HEAD,POST,PATCH,PUT,DELETE,OPTIONS,TRACE,CONNECT,CLI" index="verb">
		<cfset this.routes[verb] = CreateObject("java", "java.util.LinkedHashMap").init()>
		<cfset this.routesNames[verb] = CreateObject("java", "java.util.LinkedHashMap").init()>
	</cfloop>

	<!---
	 * The current method that the script is being called by.
	 *
	 * HTTP verb like `GET`,`POST` or `*` or `CLI`
	--->
	<cfset this.HTTPVerb = "*">

	<!---
	 * The current hostname from the server HTTP_HOST value.
	--->
	<cfset this.httpHost = "">

	<!---
	 * Flag for sorting routes by priority.
	--->
	<cfset this.prioritize = false>

	<!---
	 * Handle to the file locator to use.
	--->
	<cfset this.fileLocator = "">

	<!---
	 * Handle to the modules config.
	--->
	<cfset this.moduleConfig = "">

	<!---
	 * Flag for whether we've already discovered routes.
	--->
	<cfset this.didDiscover = false>

	<!---
	 * Constructor
	--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="locator" type="any" required="yes">
		<cfargument name="moduleConfig" type="any" required="yes">
		<cfargument name="routing" type="any" required="yes">
		<cfset var routeKey = 0>
		<cfset var realpath_ = "">

		<cfset this.fileLocator = arguments.locator>
		<cfset this.moduleConfig = arguments.moduleConfig>

		<cfset this.httpHost = service("request").getServer("HTTP_HOST")>

		<!--- Setup based on config file. Let routes file override. --->
		<cfset this.defaultNamespace = REReplace(arguments.routing.defaultNamespace, "\\+$", "") & "\">
		<cfset this.defaultController = arguments.routing.defaultController>
		<cfset this.defaultMethod = arguments.routing.defaultMethod>
		<cfset this.translateURIDashes = arguments.routing.translateURIDashes>
		<cfset this.override404 = arguments.routing.override404>
		<cfset this.autoRoute = arguments.routing.autoRoute>
		<cfset this.routeFiles = arguments.routing.routeFiles>
		<cfset this.prioritize = arguments.routing.prioritize>

		<!--- Normalize the path string in routeFiles array. --->
		<cfloop from="1" to="#ArrayLen(this.routeFiles)#" index="routeKey">
			<cfset realpath_ = realpath(this.routeFiles[routeKey])>
			<cfif realpath_ NEQ "">
				<cfset this.routeFiles[routeKey] = realpath_>
			</cfif>
		</cfloop>

		<cfreturn this>
	</cffunction>

	<!---
	 * Loads main routes file and discover routes.
	 *
	 * Loads only once unless reset.
	 *
	 * @return this
	--->
	<cffunction name="loadRoutes" access="public" returntype="any" output="no">
		<cfargument name="routesFile" type="string" required="no" default="#request.APPPATH#Config/Routes.cfm">
		<cfset var realpath_ = "">
		<cfset var routeFiles = "">
		<cfset var routes = "">
		<cfset var i = 0>

		<cfif this.didDiscover>
			<cfreturn this>
		</cfif>

		<!--- Normalize the path string in routesFile --->
		<cfset realpath_ = realpath(arguments.routesFile)>
		<cfif realpath_ NEQ "">
			<cfset arguments.routesFile = realpath_>
		</cfif>

		<!---
		 Include the passed in routesFile if it doesn't exist.
		 Only keeping that around for BC purposes for now.
		--->
		<cfset routeFiles = this.routeFiles>
		<cfif NOT in_array(arguments.routesFile, routeFiles)>
			<cfset ArrayAppend(routeFiles, arguments.routesFile)>
		</cfif>

		<!---
		 We need this var in local scope
		 so route files can access it.
		--->
		<cfset routes = this>

		<cfloop from="1" to="#ArrayLen(routeFiles)#" index="i">
			<cfif NOT is_file(routeFiles[i])>
				<cfset log_message("warning", "Routes file not found: """ & routeFiles[i] & """")>
			<cfelse>
				<cfinclude template="#includePath(routeFiles[i])#">
			</cfif>
		</cfloop>

		<cfset discoverRoutes()>

		<cfreturn this>
	</cffunction>

	<!---
	 * Will attempt to discover any additional routes, either through
	 * the local PSR4 namespaces, or through selected Composer packages.
	 *
	 * Not ported yet: the search for Config/Routes files in modules.
	--->
	<cffunction name="discoverRoutes" access="private" returntype="void" output="no">
		<cfif this.didDiscover>
			<cfreturn>
		</cfif>

		<cfset this.didDiscover = true>
	</cffunction>

	<!---
	 * Sets the default namespace to use for Controllers when no other
	 * namespace has been specified.
	--->
	<cffunction name="setDefaultNamespace" access="public" returntype="any" output="no">
		<cfargument name="value" type="string" required="yes">

		<cfset this.defaultNamespace = HTMLEditFormat(strip_tags(arguments.value))>
		<cfset this.defaultNamespace = REReplace(this.defaultNamespace, "\\+$", "") & "\">

		<cfreturn this>
	</cffunction>

	<!---
	 * Sets the default constraint to be used in the system. Typically
	 * for use with the 'resource' method.
	--->
	<cffunction name="setDefaultConstraint" access="public" returntype="any" output="no">
		<cfargument name="placeholder" type="string" required="yes">

		<cfif StructKeyExists(this.placeholders, arguments.placeholder)>
			<cfset this.defaultPlaceholder = arguments.placeholder>
		</cfif>

		<cfreturn this>
	</cffunction>

	<!---
	 * Sets the default controller to use when no other controller has been
	 * specified.
	--->
	<cffunction name="setDefaultController" access="public" returntype="any" output="no">
		<cfargument name="value" type="string" required="yes">

		<cfset this.defaultController = HTMLEditFormat(strip_tags(arguments.value))>

		<cfreturn this>
	</cffunction>

	<!---
	 * Sets the default method to call on the controller when no other
	 * method has been set in the route.
	--->
	<cffunction name="setDefaultMethod" access="public" returntype="any" output="no">
		<cfargument name="value" type="string" required="yes">

		<cfset this.defaultMethod = HTMLEditFormat(strip_tags(arguments.value))>

		<cfreturn this>
	</cffunction>

	<!---
	 * Tells the system whether to convert dashes in URI strings into
	 * underscores. In some search engines, including Google, dashes
	 * create more meaning and make it easier for the search engine to
	 * find words and meaning in the URI for better SEO. But it
	 * doesn't work well with class names.
	--->
	<cffunction name="setTranslateURIDashes" access="public" returntype="any" output="no">
		<cfargument name="value" type="boolean" required="yes">

		<cfset this.translateURIDashes = arguments.value>

		<cfreturn this>
	</cffunction>

	<!---
	 * Sets the class/method that should be called if routing doesn't
	 * find a match. It can be either a closure or the controller/method
	 * name exactly like a route is defined: Users::index
	 *
	 * This setting is passed to the Router class and handled there.
	--->
	<cffunction name="set404Override" access="public" returntype="any" output="no">
		<cfargument name="callable" type="any" required="no" default="">

		<cfset this.override404 = arguments.callable>

		<cfreturn this>
	</cffunction>

	<!---
	 * Returns the 404 Override setting, which can be an empty string, a closure
	 * or the controller/string.
	--->
	<cffunction name="get404Override" access="public" returntype="any" output="no">
		<cfreturn this.override404>
	</cffunction>

	<!---
	 * Returns the name of the default controller. With Namespace.
	--->
	<cffunction name="getDefaultController" access="public" returntype="string" output="no">
		<cfreturn this.defaultController>
	</cffunction>

	<!---
	 * Returns the name of the default method to use within the controller.
	--->
	<cffunction name="getDefaultMethod" access="public" returntype="string" output="no">
		<cfreturn this.defaultMethod>
	</cffunction>

	<!---
	 * Returns the default namespace as set in the Routes config file.
	--->
	<cffunction name="getDefaultNamespace" access="public" returntype="string" output="no">
		<cfreturn this.defaultNamespace>
	</cffunction>

	<!---
	 * Returns the current value of the translateURIDashes setting.
	--->
	<cffunction name="shouldTranslateURIDashes" access="public" returntype="boolean" output="no">
		<cfreturn this.translateURIDashes>
	</cffunction>

	<!---
	 * Returns the flag that tells whether to autoRoute URI against Controllers.
	--->
	<cffunction name="shouldAutoRoute" access="public" returntype="boolean" output="no">
		<cfreturn this.autoRoute>
	</cffunction>

	<!---
	 * Returns the raw array of available routes.
	 *
	 * @param verb            HTTP verb like `GET`,`POST` or `*` or `CLI`.
	 * @param includeWildcard Whether to include '*' routes.
	--->
	<cffunction name="getRoutes" access="public" returntype="any" output="no">
		<cfargument name="verb" type="string" required="no" default="">
		<cfargument name="includeWildcard" type="boolean" required="no" default="true">
		<cfset var routes = array_()>
		<cfset var collection = "">
		<cfset var routeKey = "">

		<cfif arguments.verb EQ "">
			<cfset arguments.verb = getHTTPVerb()>
		</cfif>

		<!---
		 Since this is the entry point for the Router,
		 take a moment to do any route discovery
		 we might need to do.
		--->
		<cfset discoverRoutes()>

		<cfif StructKeyExists(this.routes, arguments.verb)>
			<!---
			 Keep current verb's routes at the beginning, so they're matched
			 before any of the generic, "add" routes.
			--->
			<cfset collection = this.routes[arguments.verb]>
			<cfloop collection="#collection#" item="routeKey">
				<cfset routes[routeKey] = collection[routeKey]["handler"]>
			</cfloop>

			<cfif arguments.includeWildcard>
				<cfset collection = this.routes["*"]>
				<cfloop collection="#collection#" item="routeKey">
					<cfif NOT StructKeyExists(routes, routeKey)>
						<cfset routes[routeKey] = collection[routeKey]["handler"]>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>

		<!--- Not ported yet: sorting routes by priority --->

		<cfreturn routes>
	</cffunction>

	<!---
	 * Returns one or all routes options
	 *
	 * @param verb HTTP verb like `GET`,`POST` or `*` or `CLI`.
	--->
	<cffunction name="getRoutesOptions" access="public" returntype="any" output="no">
		<cfargument name="from" type="string" required="no" default="">
		<cfargument name="verb" type="string" required="no" default="">
		<cfset var options = loadRoutesOptions(arguments.verb)>

		<cfif arguments.from NEQ "">
			<cfif StructKeyExists(options, arguments.from)>
				<cfreturn options[arguments.from]>
			</cfif>

			<cfreturn array_()>
		</cfif>

		<cfreturn options>
	</cffunction>

	<!---
	 * Returns the current HTTP Verb being used.
	--->
	<cffunction name="getHTTPVerb" access="public" returntype="string" output="no">
		<cfreturn this.HTTPVerb>
	</cffunction>

	<!---
	 * Sets the current HTTP verb.
	 * Used primarily for testing.
	 *
	 * @param verb HTTP verb
	--->
	<cffunction name="setHTTPVerb" access="public" returntype="any" output="no">
		<cfargument name="verb" type="string" required="yes">

		<cfset this.HTTPVerb = UCase(arguments.verb)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Adds a single route to the collection.
	 *
	 * Example:
	 *      <cfset routes.add("news", "Posts::index")>
	--->
	<cffunction name="add" access="public" returntype="any" output="no">
		<cfargument name="from" type="string" required="yes">
		<cfargument name="to" type="any" required="yes">
		<cfargument name="options" type="any" required="no" default="">

		<cfset create("*", arguments.from, arguments.to, arguments.options)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Determines if the route is a redirecting route.
	 *
	 * @param routeKey routeKey or route name
	--->
	<cffunction name="isRedirect" access="public" returntype="boolean" output="no">
		<cfargument name="routeKey" type="string" required="yes">

		<cfif StructKeyExists(this.routes["*"], arguments.routeKey) AND StructKeyExists(this.routes["*"][arguments.routeKey], "redirect")>
			<cfreturn true>
		</cfif>

		<cfreturn false>
	</cffunction>

	<!---
	 * Specifies a route that is only available to GET requests.
	--->
	<cffunction name="get" access="public" returntype="any" output="no">
		<cfargument name="from" type="string" required="yes">
		<cfargument name="to" type="any" required="yes">
		<cfargument name="options" type="any" required="no" default="">

		<cfset create("GET", arguments.from, arguments.to, arguments.options)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Specifies a route that is only available to POST requests.
	--->
	<cffunction name="post" access="public" returntype="any" output="no">
		<cfargument name="from" type="string" required="yes">
		<cfargument name="to" type="any" required="yes">
		<cfargument name="options" type="any" required="no" default="">

		<cfset create("POST", arguments.from, arguments.to, arguments.options)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Specifies a route that is only available to PUT requests.
	--->
	<cffunction name="put" access="public" returntype="any" output="no">
		<cfargument name="from" type="string" required="yes">
		<cfargument name="to" type="any" required="yes">
		<cfargument name="options" type="any" required="no" default="">

		<cfset create("PUT", arguments.from, arguments.to, arguments.options)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Specifies a route that is only available to DELETE requests.
	--->
	<cffunction name="delete" access="public" returntype="any" output="no">
		<cfargument name="from" type="string" required="yes">
		<cfargument name="to" type="any" required="yes">
		<cfargument name="options" type="any" required="no" default="">

		<cfset create("DELETE", arguments.from, arguments.to, arguments.options)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Specifies a route that is only available to PATCH requests.
	--->
	<cffunction name="patch" access="public" returntype="any" output="no">
		<cfargument name="from" type="string" required="yes">
		<cfargument name="to" type="any" required="yes">
		<cfargument name="options" type="any" required="no" default="">

		<cfset create("PATCH", arguments.from, arguments.to, arguments.options)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Specifies a route that is only available to HEAD requests.
	--->
	<cffunction name="head" access="public" returntype="any" output="no">
		<cfargument name="from" type="string" required="yes">
		<cfargument name="to" type="any" required="yes">
		<cfargument name="options" type="any" required="no" default="">

		<cfset create("HEAD", arguments.from, arguments.to, arguments.options)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Specifies a route that is only available to OPTIONS requests.
	--->
	<cffunction name="options" access="public" returntype="any" output="no">
		<cfargument name="from" type="string" required="yes">
		<cfargument name="to" type="any" required="yes">
		<cfargument name="options" type="any" required="no" default="">

		<cfset create("OPTIONS", arguments.from, arguments.to, arguments.options)>

		<cfreturn this>
	</cffunction>

	<!---
	 * Creates a collection of HTTP-verb based routes for a controller.
	 *
	 * Possible Options:
	 *      'controller'    - Customize the name of the controller used in the 'to' route
	 *      'placeholder'   - The regex used by the Router. Defaults to '(:any)'
	 *      'websafe'       - '1' if only GET and POST HTTP verbs are supported
	 *      'only'          - Limit the routes to these methods (list or array)
	 *      'except'        - Leave out these methods (list or array)
	 *
	 * Example:
	 *
	 *      <cfset routes.resource("photos")>
	 *
	 *      // Generates the following routes:
	 *      HTTP Verb | Path        | Action        | Used for...
	 *      ----------+-------------+---------------+-----------------
	 *      GET         /photos             index           an array of photo objects
	 *      GET         /photos/new         new             an empty photo object, with default properties
	 *      GET         /photos/{id}/edit   edit            a specific photo object, editable properties
	 *      GET         /photos/{id}        show            a specific photo object, all properties
	 *      POST        /photos             create          a new photo object, to add to the resource
	 *      DELETE      /photos/{id}        delete          deletes the specified photo object
	 *      PUT/PATCH   /photos/{id}        update          replacement properties for existing photo
	 *
	 *  If 'websafe' option is present, the following paths are also available:
	 *
	 *      POST		/photos/{id}/delete delete
	 *      POST        /photos/{id}        update
	 *
	 * Difference: the methods are kept in a list, which ListFind() checks
	 * in one call, where the original searches an array for each route.
	 *
	 * @param name    The name of the resource/controller to route to.
	 * @param options A list of possible ways to customize the routing.
	--->
	<cffunction name="resource" access="public" returntype="any" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="options" type="any" required="no" default="">
		<cfset var newName = "">
		<cfset var id = "">
		<cfset var methods = "index,show,create,update,delete,new,edit">
		<cfset var except = "">
		<cfset var kept = "">
		<cfset var method = "">
		<cfset var parts = "">
		<cfset var i = 0>

		<cfif NOT IsStruct(arguments.options)>
			<cfset arguments.options = array_()>
		</cfif>

		<!---
		 In order to allow customization of the route the
		 resources are sent to, we need to have a new name
		 to store the values in.
		--->
		<cfset parts = explode("/", arguments.name)>
		<cfloop from="1" to="#ArrayLen(parts)#" index="i">
			<cfset parts[i] = ucfirst(parts[i])>
		</cfloop>
		<cfset newName = implode("\", parts)>

		<!---
		 If a new controller is specified, then we replace the
		 name value with the name of the new controller.
		--->
		<cfif StructKeyExists(arguments.options, "controller")>
			<cfset newName = ucfirst(esc(strip_tags(arguments.options["controller"])))>
		</cfif>

		<!---
		 In order to allow customization of allowed id values
		 we need someplace to store them.
		--->
		<cfif StructKeyExists(arguments.options, "placeholder")>
			<cfset id = arguments.options["placeholder"]>
		<cfelseif StructKeyExists(this.placeholders, this.defaultPlaceholder)>
			<cfset id = this.placeholders[this.defaultPlaceholder]>
		<cfelse>
			<cfset id = "(:segment)">
		</cfif>

		<!--- Make sure we capture back-references --->
		<cfset id = "(" & trim_(id, "()") & ")">

		<cfif StructKeyExists(arguments.options, "only")>
			<cfif IsArray(arguments.options["only"])>
				<cfset methods = ArrayToList(arguments.options["only"])>
			<cfelse>
				<cfset methods = arguments.options["only"]>
			</cfif>
		</cfif>

		<cfif StructKeyExists(arguments.options, "except")>
			<cfif IsArray(arguments.options["except"])>
				<cfset except = ArrayToList(arguments.options["except"])>
			<cfelse>
				<cfset except = arguments.options["except"]>
			</cfif>

			<cfloop list="#methods#" index="method">
				<cfif NOT ListFind(except, method)>
					<cfset kept = ListAppend(kept, method)>
				</cfif>
			</cfloop>
			<cfset methods = kept>
		</cfif>

		<cfif ListFind(methods, "index")>
			<cfset get(arguments.name, newName & "::index", arguments.options)>
		</cfif>
		<cfif ListFind(methods, "new")>
			<cfset get(arguments.name & "/new", newName & "::new", arguments.options)>
		</cfif>
		<cfif ListFind(methods, "edit")>
			<cfset get(arguments.name & "/" & id & "/edit", newName & "::edit/$1", arguments.options)>
		</cfif>
		<cfif ListFind(methods, "show")>
			<cfset get(arguments.name & "/" & id, newName & "::show/$1", arguments.options)>
		</cfif>
		<cfif ListFind(methods, "create")>
			<cfset post(arguments.name, newName & "::create", arguments.options)>
		</cfif>
		<cfif ListFind(methods, "update")>
			<cfset put(arguments.name & "/" & id, newName & "::update/$1", arguments.options)>
			<cfset patch(arguments.name & "/" & id, newName & "::update/$1", arguments.options)>
		</cfif>
		<cfif ListFind(methods, "delete")>
			<cfset delete(arguments.name & "/" & id, newName & "::delete/$1", arguments.options)>
		</cfif>

		<!--- Web Safe? delete needs checking before update because of method name --->
		<cfif StructKeyExists(arguments.options, "websafe")>
			<cfif ListFind(methods, "delete")>
				<cfset post(arguments.name & "/" & id & "/delete", newName & "::delete/$1", arguments.options)>
			</cfif>
			<cfif ListFind(methods, "update")>
				<cfset post(arguments.name & "/" & id, newName & "::update/$1", arguments.options)>
			</cfif>
		</cfif>

		<cfreturn this>
	</cffunction>

	<!---
	 * Creates a collections of HTTP-verb based routes for a presenter controller.
	 *
	 * Possible Options:
	 *      'controller'    - Customize the name of the controller used in the 'to' route
	 *      'placeholder'   - The regex used by the Router. Defaults to '(:any)'
	 *      'only'          - Limit the routes to these methods (list or array)
	 *      'except'        - Leave out these methods (list or array)
	 *
	 * Example:
	 *
	 *      <cfset routes.presenter("photos")>
	 *
	 *      // Generates the following routes:
	 *      HTTP Verb | Path        | Action        | Used for...
	 *      ----------+-------------+---------------+-----------------
	 *      GET         /photos             index           showing all array of photo objects
	 *      GET         /photos/show/{id}   show            showing a specific photo object, all properties
	 *      GET         /photos/new         new             showing a form for an empty photo object, with default properties
	 *      POST        /photos/create      create          processing the form for a new photo
	 *      GET         /photos/edit/{id}   edit            show an editing form for a specific photo object, editable properties
	 *      POST        /photos/update/{id} update          process the editing form data
	 *      GET         /photos/remove/{id} remove          show a form to confirm deletion of a specific photo object
	 *      POST        /photos/delete/{id} delete          deleting the specified photo object
	 *
	 * Difference: the methods are kept in a list, which ListFind() checks
	 * in one call, where the original searches an array for each route.
	 *
	 * @param name    The name of the controller to route to.
	 * @param options A list of possible ways to customize the routing.
	--->
	<cffunction name="presenter" access="public" returntype="any" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="options" type="any" required="no" default="">
		<cfset var newName = "">
		<cfset var id = "">
		<cfset var methods = "index,show,new,create,edit,update,remove,delete">
		<cfset var except = "">
		<cfset var kept = "">
		<cfset var method = "">
		<cfset var parts = "">
		<cfset var i = 0>

		<cfif NOT IsStruct(arguments.options)>
			<cfset arguments.options = array_()>
		</cfif>

		<!---
		 In order to allow customization of the route the
		 resources are sent to, we need to have a new name
		 to store the values in.
		--->
		<cfset parts = explode("/", arguments.name)>
		<cfloop from="1" to="#ArrayLen(parts)#" index="i">
			<cfset parts[i] = ucfirst(parts[i])>
		</cfloop>
		<cfset newName = implode("\", parts)>

		<!---
		 If a new controller is specified, then we replace the
		 name value with the name of the new controller.
		--->
		<cfif StructKeyExists(arguments.options, "controller")>
			<cfset newName = ucfirst(esc(strip_tags(arguments.options["controller"])))>
		</cfif>

		<!---
		 In order to allow customization of allowed id values
		 we need someplace to store them.
		--->
		<cfif StructKeyExists(arguments.options, "placeholder")>
			<cfset id = arguments.options["placeholder"]>
		<cfelseif StructKeyExists(this.placeholders, this.defaultPlaceholder)>
			<cfset id = this.placeholders[this.defaultPlaceholder]>
		<cfelse>
			<cfset id = "(:segment)">
		</cfif>

		<!--- Make sure we capture back-references --->
		<cfset id = "(" & trim_(id, "()") & ")">

		<cfif StructKeyExists(arguments.options, "only")>
			<cfif IsArray(arguments.options["only"])>
				<cfset methods = ArrayToList(arguments.options["only"])>
			<cfelse>
				<cfset methods = arguments.options["only"]>
			</cfif>
		</cfif>

		<cfif StructKeyExists(arguments.options, "except")>
			<cfif IsArray(arguments.options["except"])>
				<cfset except = ArrayToList(arguments.options["except"])>
			<cfelse>
				<cfset except = arguments.options["except"]>
			</cfif>

			<cfloop list="#methods#" index="method">
				<cfif NOT ListFind(except, method)>
					<cfset kept = ListAppend(kept, method)>
				</cfif>
			</cfloop>
			<cfset methods = kept>
		</cfif>

		<cfif ListFind(methods, "index")>
			<cfset get(arguments.name, newName & "::index", arguments.options)>
		</cfif>
		<cfif ListFind(methods, "show")>
			<cfset get(arguments.name & "/show/" & id, newName & "::show/$1", arguments.options)>
		</cfif>
		<cfif ListFind(methods, "new")>
			<cfset get(arguments.name & "/new", newName & "::new", arguments.options)>
		</cfif>
		<cfif ListFind(methods, "create")>
			<cfset post(arguments.name & "/create", newName & "::create", arguments.options)>
		</cfif>
		<cfif ListFind(methods, "edit")>
			<cfset get(arguments.name & "/edit/" & id, newName & "::edit/$1", arguments.options)>
		</cfif>
		<cfif ListFind(methods, "update")>
			<cfset post(arguments.name & "/update/" & id, newName & "::update/$1", arguments.options)>
		</cfif>
		<cfif ListFind(methods, "remove")>
			<cfset get(arguments.name & "/remove/" & id, newName & "::remove/$1", arguments.options)>
		</cfif>
		<cfif ListFind(methods, "delete")>
			<cfset post(arguments.name & "/delete/" & id, newName & "::delete/$1", arguments.options)>
		</cfif>
		<cfif ListFind(methods, "show")>
			<cfset get(arguments.name & "/" & id, newName & "::show/$1", arguments.options)>
		</cfif>
		<cfif ListFind(methods, "create")>
			<cfset post(arguments.name, newName & "::create", arguments.options)>
		</cfif>

		<cfreturn this>
	</cffunction>

	<!---
	 * Returns true if the route has a filter option set (the "filter"
	 * option of the route).
	 *
	 * @param search The route key, as it is in the routes
	 * @param verb   HTTP verb like `GET`,`POST` or `*` or `CLI`; empty for the current one
	--->
	<cffunction name="isFiltered" access="public" returntype="boolean" output="no">
		<cfargument name="search" type="string" required="yes">
		<cfargument name="verb" type="string" required="no" default="">
		<cfset var options = loadRoutesOptions(arguments.verb)>

		<cfreturn StructKeyExists(options, arguments.search) AND IsStruct(options[arguments.search]) AND StructKeyExists(options[arguments.search], "filter")>
	</cffunction>

	<!---
	 * Returns the filters that should be applied for a single route, along
	 * with any parameters it might have. Parameters are found by splitting
	 * the parameter name on a colon to separate the filter name from the parameter list,
	 * and the splitting the result on commas. So:
	 *
	 *    "role:admin,manager"
	 *
	 * has a filter of "role", with parameters of ["admin", "manager"].
	 *
	 * @param search The route key, as it is in the routes
	 * @param verb   HTTP verb like `GET`,`POST` or `*` or `CLI`; empty for the current one
	 *
	 * @return A list of filter names (with their parameters).
	--->
	<cffunction name="getFiltersForRoute" access="public" returntype="array" output="no">
		<cfargument name="search" type="string" required="yes">
		<cfargument name="verb" type="string" required="no" default="">
		<cfset var options = loadRoutesOptions(arguments.verb)>
		<cfset var result = ArrayNew(1)>

		<cfif NOT StructKeyExists(options, arguments.search) OR NOT IsStruct(options[arguments.search]) OR NOT StructKeyExists(options[arguments.search], "filter")>
			<cfreturn result>
		</cfif>

		<cfif IsSimpleValue(options[arguments.search]["filter"])>
			<cfset ArrayAppend(result, options[arguments.search]["filter"])>

			<cfreturn result>
		</cfif>

		<cfreturn options[arguments.search]["filter"]>
	</cffunction>

	<!---
	 * Does the heavy lifting of creating an actual route. You must specify
	 * the request method(s) that this route will work for. They can be separated
	 * by a pipe character "|" if there is more than one.
	--->
	<cffunction name="create" access="private" returntype="void" output="no">
		<cfargument name="verb" type="string" required="yes">
		<cfargument name="from" type="string" required="yes">
		<cfargument name="to" type="any" required="yes">
		<cfargument name="options" type="any" required="no" default="">
		<cfset var overwrite = false>
		<cfset var prefix = "">
		<cfset var routeKey = "">
		<cfset var tag = "">
		<cfset var namespace = "">
		<cfset var name = "">
		<cfset var routeKeyExists = false>

		<!--- Not ported yet: the group prefix --->

		<cfset arguments.from = HTMLEditFormat(strip_tags(prefix & arguments.from))>

		<!---
		 While we want to add a route within a group of '/',
		 it doesn't work with matching, so remove them...
		--->
		<cfif arguments.from NEQ "/">
			<cfset arguments.from = trim_(arguments.from, "/")>
		</cfif>

		<cfif is_null(arguments.options)>
			<cfset arguments.options = array_()>
		</cfif>

		<!--- Not ported yet: group filters, priority, hostname, subdomain, offset --->

		<cfset routeKey = arguments.from>

		<!---
		 Replace our regex pattern placeholders with the actual thing
		 so that the Router doesn't need to know about any of this.
		--->
		<cfloop collection="#this.placeholders#" item="tag">
			<cfset routeKey = ReplaceNoCase(routeKey, ":" & tag, this.placeholders[tag], "all")>
		</cfloop>

		<!--- If is redirect, No processing --->
		<cfif NOT StructKeyExists(arguments.options, "redirect") AND IsSimpleValue(arguments.to)>
			<!--- If no namespace found, add the default namespace --->
			<cfif Find("\", arguments.to) NEQ 1>
				<cfif StructKeyExists(arguments.options, "namespace")>
					<cfset namespace = arguments.options["namespace"]>
				<cfelse>
					<cfset namespace = this.defaultNamespace>
				</cfif>
				<cfset arguments.to = REReplace(namespace, "^\\+|\\+$", "", "all") & "\" & arguments.to>
			</cfif>

			<!---
			 Always ensure that we escape our namespace so we're not pointing to
			 \ColdIgniter\Routes\Controller::method.
			--->
			<cfset arguments.to = "\" & REReplace(arguments.to, "^\\+", "")>
		</cfif>

		<cfif StructKeyExists(arguments.options, "as")>
			<cfset name = arguments.options["as"]>
		<cfelse>
			<cfset name = routeKey>
		</cfif>

		<!---
		 Don't overwrite any existing 'froms' so that auto-discovered routes
		 do not overwrite any app/Config/Routes settings. The app
		 routes should always be the "source of truth".
		 this works only because discovered routes are added just prior
		 to attempting to route the request.
		--->
		<cfset routeKeyExists = StructKeyExists(this.routes[arguments.verb], routeKey)>
		<cfif (StructKeyExists(this.routesNames[arguments.verb], name) OR routeKeyExists) AND NOT overwrite>
			<cfreturn>
		</cfif>

		<cfset this.routes[arguments.verb][routeKey] = array_(
			"name", name,
			"handler", arguments.to,
			"from", arguments.from
		)>

		<cfif NOT StructKeyExists(this.routesOptions, arguments.verb)>
			<cfset this.routesOptions[arguments.verb] = array_()>
		</cfif>
		<cfset this.routesOptions[arguments.verb][routeKey] = arguments.options>
		<cfset this.routesNames[arguments.verb][name] = routeKey>

		<!--- Not ported yet: redirect routes --->
	</cffunction>

	<!---
	 * Load routes options based on verb
	 *
	 * @param verb HTTP verb like `GET`,`POST` or `*` or `CLI`.
	--->
	<cffunction name="loadRoutesOptions" access="private" returntype="any" output="no">
		<cfargument name="verb" type="string" required="no" default="">
		<cfset var options = array_()>
		<cfset var routeKey = "">

		<cfif arguments.verb EQ "">
			<cfset arguments.verb = getHTTPVerb()>
		</cfif>

		<cfif StructKeyExists(this.routesOptions, arguments.verb)>
			<cfset options = array_merge(this.routesOptions[arguments.verb])>
		</cfif>

		<cfif StructKeyExists(this.routesOptions, "*")>
			<cfloop collection="#this.routesOptions["*"]#" item="routeKey">
				<cfif NOT StructKeyExists(options, routeKey)>
					<cfset options[routeKey] = this.routesOptions["*"][routeKey]>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn options>
	</cffunction>

	<!---
	 * Adds a placeholder, or a map of them.
	 *
	 * @param placeholder A name, or a map of names and patterns (see array_())
	 * @param pattern     The pattern, when a name is given
	--->
	<cffunction name="addPlaceholder" access="public" returntype="any" output="no">
		<cfargument name="placeholder" type="any" required="yes">
		<cfargument name="pattern" type="string" required="no" default="">
		<cfset var name = "">

		<cfif IsSimpleValue(arguments.placeholder)>
			<cfset this.placeholders[arguments.placeholder] = arguments.pattern>
		<cfelse>
			<cfloop collection="#arguments.placeholder#" item="name">
				<cfset this.placeholders[name] = arguments.placeholder[name]>
			</cfloop>
		</cfif>

		<cfreturn this>
	</cffunction>

	<!---
	 * For `spark routes`
	 *
	 * @internal
	--->
	<cffunction name="getPlaceholders" access="public" returntype="any" output="no">
		<cfreturn this.placeholders>
	</cffunction>

	<cffunction name="setAutoRoute" access="public" returntype="any" output="no">
		<cfargument name="value" type="boolean" required="yes">

		<cfset this.autoRoute = arguments.value>

		<cfreturn this>
	</cffunction>

	<!---
	 * Reset the routes, so that a test case can provide the
	 * explicit ones needed for it.
	--->
	<cffunction name="resetRoutes" access="public" returntype="void" output="no">
		<cfset var verb = "">
		<cfset var i = 0>

		<cfset this.routes = CreateObject("java", "java.util.LinkedHashMap").init()>
		<cfset this.routesNames = CreateObject("java", "java.util.LinkedHashMap").init()>
		<cfset this.routes["*"] = CreateObject("java", "java.util.LinkedHashMap").init()>
		<cfset this.routesNames["*"] = CreateObject("java", "java.util.LinkedHashMap").init()>

		<cfloop from="1" to="#ArrayLen(this.defaultHTTPMethods)#" index="i">
			<cfset verb = this.defaultHTTPMethods[i]>
			<cfset this.routes[verb] = CreateObject("java", "java.util.LinkedHashMap").init()>
			<cfset this.routesNames[verb] = CreateObject("java", "java.util.LinkedHashMap").init()>
		</cfloop>

		<cfset this.routesOptions = CreateObject("java", "java.util.LinkedHashMap").init()>

		<!--- Not ported yet: prioritizeDetected, as the priority option is not ported --->
		<cfset this.didDiscover = false>
	</cffunction>

	<!---
	 * Get all controllers in Route Handlers
	 *
	 * @param verb HTTP verb like `GET`,`POST` or `*` or `CLI`.
	 *             `'*'` returns all controllers in any verb.
	 *
	 * @return A list of controller names
	 *
	 * @internal
	 *
	 * Not ported yet: the deprecation notice for a lowercase verb
	 * (trigger_error() has no stand-in).
	--->
	<cffunction name="getRegisteredControllers" access="public" returntype="array" output="no">
		<cfargument name="verb" type="string" required="no" default="*">
		<cfset var controllers = ArrayNew(1)>
		<cfset var controller = "">
		<cfset var routes = "">
		<cfset var collection = "">
		<cfset var key = "">
		<cfset var i = 0>

		<cfset arguments.verb = UCase(arguments.verb)>

		<cfif arguments.verb EQ "*">
			<cfloop from="1" to="#ArrayLen(this.defaultHTTPMethods)#" index="i">
				<cfset collection = this.routes[this.defaultHTTPMethods[i]]>

				<cfloop collection="#collection#" item="key">
					<cfset controller = getControllerName(collection[key]["handler"])>
					<cfif controller NEQ "">
						<cfset ArrayAppend(controllers, controller)>
					</cfif>
				</cfloop>
			</cfloop>
		<cfelse>
			<cfset routes = getRoutes(arguments.verb)>

			<cfloop collection="#routes#" item="key">
				<cfset controller = getControllerName(routes[key])>
				<cfif controller NEQ "">
					<cfset ArrayAppend(controllers, controller)>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn array_unique(controllers)>
	</cffunction>

	<!---
	 * @param handler Handler
	 *
	 * @return Controller classname, or an empty string for a handler that is not a string
	 *
	 * Difference: there is no null here, so an empty string stands in for it (a),
	 * as in is_null().
	--->
	<cffunction name="getControllerName" access="private" returntype="string" output="no">
		<cfargument name="handler" type="any" required="yes">
		<cfset var parts = "">

		<cfif NOT IsSimpleValue(arguments.handler)>
			<cfreturn "">
		</cfif>

		<cfset parts = explode("::", arguments.handler, 2)>

		<cfreturn parts[1]>
	</cffunction>

	<!---
	 * Set The flag that limit or not the routes with {locale} placeholder to App::$supportedLocales
	--->
	<cffunction name="useSupportedLocalesOnly" access="public" returntype="any" output="no">
		<cfargument name="useOnly" type="boolean" required="yes">

		<cfset this.useSupportedLocalesOnly = arguments.useOnly>

		<cfreturn this>
	</cffunction>

	<cffunction name="shouldUseSupportedLocalesOnly" access="public" returntype="boolean" output="no">
		<cfreturn this.useSupportedLocalesOnly>
	</cffunction>

	<!---
	 * Returns the route for a name or a handler, with the parameters put in
	 * the back-references. The parameters are the arguments after the
	 * first one; the last of them may be the locale.
	 *
	 * @param search A route name or a handler (Controller::method)
	 *
	 * @return The route, or false when there is none
	 *
	 * Difference: the original takes the parameters as "...$params". Here they
	 * are the extra arguments, arguments[2] and on (a).
	--->
	<cffunction name="reverseRoute" access="public" returntype="any" output="no">
		<cfargument name="search" type="string" required="yes">
		<cfset var params = ArrayNew(1)>
		<cfset var verb = "">
		<cfset var collection = "">
		<cfset var routeKey = "">
		<cfset var from = "">
		<cfset var namespace = "">
		<cfset var route = "">
		<cfset var to = "">
		<cfset var i = 0>

		<cfloop from="2" to="#ArrayLen(arguments)#" index="i">
			<cfset ArrayAppend(params, arguments[i])>
		</cfloop>

		<cfif arguments.search EQ "">
			<cfreturn false>
		</cfif>

		<!--- Named routes get higher priority. --->
		<cfloop collection="#this.routesNames#" item="verb">
			<cfset collection = this.routesNames[verb]>

			<cfif StructKeyExists(collection, arguments.search)>
				<cfset routeKey = collection[arguments.search]>

				<cfset from = this.routes[verb][routeKey]["from"]>

				<cfreturn buildReverseRoute(from, params)>
			</cfif>
		</cfloop>

		<!--- Add the default namespace if needed. --->
		<cfset namespace = trim_(this.defaultNamespace, "\") & "\">
		<cfif NOT str_starts_with(arguments.search, "\")
			AND NOT str_starts_with(arguments.search, namespace)>
			<cfset arguments.search = namespace & arguments.search>
		</cfif>

		<!---
		 If it's not a named route, then loop over
		 all routes to find a match.
		--->
		<cfloop collection="#this.routes#" item="verb">
			<cfset collection = this.routes[verb]>

			<cfloop collection="#collection#" item="routeKey">
				<cfset route = collection[routeKey]>
				<cfset to = route["handler"]>
				<cfset from = route["from"]>

				<!--- Difference: there is no cfcontinue, so the rest of the loop body is inside cfif tags (a). --->

				<!--- ignore closures --->
				<cfif IsSimpleValue(to)>
					<!---
					 Lose any namespace slash at beginning of strings
					 to ensure more consistent match.
					--->
					<cfset to = ltrim_(to, "\")>
					<cfset arguments.search = ltrim_(arguments.search, "\")>

					<!---
					 If there's any chance of a match, then it will
					 be with search at the beginning of the to string.
					 Ensure that the number of params given here
					 matches the number of back-references in the route
					--->
					<cfif str_starts_with(to, arguments.search)
						AND Len(to) - Len(Replace(to, "$", "", "all")) EQ ArrayLen(params)>
						<cfreturn buildReverseRoute(from, params)>
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>

		<!--- If we're still here, then we did not find a match. --->
		<cfreturn false>
	</cffunction>

	<!---
	 * Replaces the {locale} tag with the current application locale
	 *
	 * @deprecated Unused.
	--->
	<cffunction name="localizeRoute" access="private" returntype="string" output="no">
		<cfargument name="route" type="string" required="yes">

		<cfreturn strtr(arguments.route, array_("{locale}", service("request").getLocale_()))>
	</cffunction>

	<!---
	 * Given a route and its params, puts the params in the back-references.
	 *
	 * @param params A list of values (an array)
	 *
	 * @deprecated Unused. Now uses buildReverseRoute().
	 *
	 * Difference: preg_match_all() is a loop of a java.util.regex.Matcher,
	 * and substr_replace() is Left() and Mid() (a).
	--->
	<cffunction name="fillRouteParams" access="private" returntype="string" output="no">
		<cfargument name="from" type="string" required="yes">
		<cfargument name="params" type="any" required="no" default="">
		<cfset var patterns = ArrayNew(1)>
		<cfset var matcher = CreateObject("java", "java.util.regex.Pattern").compile("\(([^)]+)\)").matcher(JavaCast("string", arguments.from))>
		<cfset var pattern = "">
		<cfset var pos = 0>
		<cfset var index = 0>

		<!--- Find all of our back-references in the original route --->
		<cfloop condition="matcher.find()">
			<cfset ArrayAppend(patterns, matcher.group())>
		</cfloop>

		<cfif ArrayLen(patterns) EQ 0>
			<cfreturn "/" & ltrim_(arguments.from, "/")>
		</cfif>

		<!---
		 Build our resulting string, inserting the params in
		 the appropriate places.
		--->
		<cfloop from="1" to="#ArrayLen(patterns)#" index="index">
			<cfset pattern = patterns[index]>

			<cfif preg_match("##^" & pattern & "$##u", arguments.params[index]) NEQ 1>
				<cfset static_("ColdIgniter\Router\Exceptions\RouterException").forInvalidParameterType()>
			</cfif>

			<!---
			 Ensure that the param we're inserting matches
			 the expected param type.
			--->
			<cfset pos = Find(pattern, arguments.from)>
			<cfset arguments.from = Left(arguments.from, pos - 1) & arguments.params[index] & Mid(arguments.from, pos + Len(pattern), Len(arguments.from))>
		</cfloop>

		<cfreturn "/" & ltrim_(arguments.from, "/")>
	</cffunction>

	<!---
	 * Builds reverse route
	 *
	 * @param params One or more parameters to be passed to the route.
	 *               The last parameter allows you to set the locale.
	 *
	 * Difference: preg_match_all() is a loop of a java.util.regex.Matcher,
	 * and substr_replace() is Left() and Mid() (a). A missing locale is an
	 * empty string, as the original casts it to a string before it looks.
	--->
	<cffunction name="buildReverseRoute" access="private" returntype="string" output="no">
		<cfargument name="from" type="string" required="yes">
		<cfargument name="params" type="array" required="yes">
		<cfset var locale = "">
		<cfset var matches = ArrayNew(1)>
		<cfset var matcher = CreateObject("java", "java.util.regex.Pattern").compile("\(([^)]+)\)").matcher(JavaCast("string", arguments.from))>
		<cfset var placeholderCount = 0>
		<cfset var placeholder = "">
		<cfset var placeholderName = "">
		<cfset var pattern = "">
		<cfset var pos = 0>
		<cfset var index = 0>

		<!--- Find all of our back-references in the original route --->
		<cfloop condition="matcher.find()">
			<cfset ArrayAppend(matches, matcher.group())>
		</cfloop>

		<cfif ArrayLen(matches) EQ 0>
			<cfif Find("{locale}", arguments.from) GT 0 AND ArrayLen(arguments.params) GT 0>
				<cfset locale = arguments.params[1]>
			</cfif>

			<cfset arguments.from = replaceLocale(arguments.from, locale)>

			<cfreturn "/" & ltrim_(arguments.from, "/")>
		</cfif>

		<!--- Locale is passed? --->
		<cfset placeholderCount = ArrayLen(matches)>
		<cfif ArrayLen(arguments.params) GT placeholderCount>
			<cfset locale = arguments.params[placeholderCount + 1]>
		</cfif>

		<!---
		 Build our resulting string, inserting the params in
		 the appropriate places.
		--->
		<cfloop from="1" to="#ArrayLen(matches)#" index="index">
			<cfset placeholder = matches[index]>

			<cfif index GT ArrayLen(arguments.params)>
				<cfthrow type="InvalidArgumentException" message="Missing argument for ""#placeholder#"" in route ""#arguments.from#"".">
			</cfif>

			<!--- Remove `(:` and `)` when placeholder is a placeholder. --->
			<cfset placeholderName = Mid(placeholder, 3, Len(placeholder) - 3)>
			<!--- or maybe placeholder is not a placeholder, but a regex. --->
			<cfif StructKeyExists(this.placeholders, placeholderName)>
				<cfset pattern = this.placeholders[placeholderName]>
			<cfelse>
				<cfset pattern = placeholder>
			</cfif>

			<cfif preg_match("##^" & pattern & "$##u", arguments.params[index]) NEQ 1>
				<cfset static_("ColdIgniter\Router\Exceptions\RouterException").forInvalidParameterType()>
			</cfif>

			<!---
			 Ensure that the param we're inserting matches
			 the expected param type.
			--->
			<cfset pos = Find(placeholder, arguments.from)>
			<cfset arguments.from = Left(arguments.from, pos - 1) & arguments.params[index] & Mid(arguments.from, pos + Len(placeholder), Len(arguments.from))>
		</cfloop>

		<cfset arguments.from = replaceLocale(arguments.from, locale)>

		<cfreturn "/" & ltrim_(arguments.from, "/")>
	</cffunction>

	<!---
	 * Replaces the {locale} tag with the locale
	 *
	 * Difference: a missing locale is an empty string (a), as the original
	 * casts it to a string before it looks.
	--->
	<cffunction name="replaceLocale" access="private" returntype="string" output="no">
		<cfargument name="route" type="string" required="yes">
		<cfargument name="locale" type="string" required="no" default="">
		<cfset var appConfig = "">

		<cfif Find("{locale}", arguments.route) EQ 0>
			<cfreturn arguments.route>
		</cfif>

		<!--- Check invalid locale --->
		<cfif arguments.locale NEQ "">
			<cfset appConfig = config("Config\App")>
			<cfif NOT in_array(arguments.locale, appConfig.supportedLocales)>
				<cfset arguments.locale = "">
			</cfif>
		</cfif>

		<cfif arguments.locale EQ "">
			<cfset arguments.locale = service("request").getLocale_()>
		</cfif>

		<cfreturn strtr(arguments.route, array_("{locale}", arguments.locale))>
	</cffunction>

</cfcomponent>
