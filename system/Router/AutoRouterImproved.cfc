<!---
 * New Secure Router for Auto-Routing
 *
 * Difference: CFML on MX 6.1 has no null (a). Where the original has null, an
 * empty string stands in: the directory when there is none, and the positions
 * of the controller, the method and the parameters (tested with IsNumeric()).
 *
 * Difference: CFML on MX 6.1 has no reflection and no get_declared_classes()
 * or get_class_methods() (a). A method is found with method_exists() on the
 * object of the controller class (static_()), and what the original reads
 * with ReflectionMethod comes from the functions in GetMetaData() of the
 * object and of the components it extends: the name as it was written, and
 * the array of parameters of the method. Two results follow:
 *
 *   - method_exists() sees public methods only, so a private method is
 *     "not found" at once, where the original finds it and answers with
 *     MethodNotFoundException a little later. The answer to the visitor is
 *     the same, a 404 from forControllerNotFound().
 *   - CFML has no variadic parameters that GetMetaData() can see, so the
 *     count of the parameters is the count of the cfargument tags.
 *
 * Difference: the original asks get_declared_classes() for the class name as
 * it was written, because a file system that ignores case loads
 * "Blogcontroller" for the file BlogController. Here the names of the
 * folders and of the file of the class, below the namespace of the
 * controllers, are read from a listing of the folder (cfdirectory) and
 * compared with Compare() (a). That is done only when translateUriToCamelCase
 * is on, as in the original, and costs one listing for each segment of
 * the class name.
 *
 * Difference: checkParameters() does not look for the class again (b); the
 * class was found by class_exists() a moment before, and the object of
 * static_() is kept for the request.
--->
<cfcomponent output="no" extends="AutoRouterInterface" hint="New Secure Router for Auto-Routing">

	<!---
	 * Sub-directory that contains the requested controller class.
	--->
	<cfset this.directory = "">

	<!---
	 * The name of the controller class.
	--->
	<cfset this.controller = "">

	<!---
	 * The name of the method to use.
	--->
	<cfset this.method = "">

	<!---
	 * An array of params to the controller method.
	--->
	<cfset this.params = ArrayNew(1)>

	<!---
	 * Whether to translate dashes in URIs for controller/method to CamelCase.
	 * E.g., blog-controller -> BlogController
	--->
	<cfset this.translateUriToCamelCase = false>

	<!---
	 * The namespace for controllers.
	--->
	<cfset this.namespace = "">

	<!---
	 * Map of URI segments and namespaces.
	 *
	 * The key is the first URI segment. The value is the controller namespace.
	 *
	 *   ['blog' => 'Acme\Blog\Controllers']
	--->
	<cfset this.moduleRoutes = "">

	<!---
	 * The URI segments.
	--->
	<cfset this.segments = ArrayNew(1)>

	<!---
	 * The position of the Controller in the URI segments.
	 * Empty for the default controller.
	--->
	<cfset this.controllerPos = "">

	<!---
	 * The position of the Method in the URI segments.
	 * Empty for the default method.
	--->
	<cfset this.methodPos = "">

	<!---
	 * The position of the first Parameter in the URI segments.
	 * Empty for the no parameters.
	--->
	<cfset this.paramPos = "">

	<!---
	 * The current URI
	--->
	<cfset this.uri = "">

	<!---
	 * List of controllers in Defined Routes that should not be accessed via this Auto-Routing.
	--->
	<cfset this.protectedControllers = ArrayNew(1)>

	<!---
	 * Short classname of the default controller.
	--->
	<cfset this.defaultController = "">

	<!---
	 * The name of the default method without HTTP verb prefix.
	--->
	<cfset this.defaultMethod = "">

	<!---
	 * Whether dashes in URI's should be converted
	 * to underscores when determining method names.
	--->
	<cfset this.translateURIDashes = false>

	<!---
	 * @param protectedControllers A list of class names
	 * @param defaultController    Short classname
--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="protectedControllers" type="array" required="yes">
		<cfargument name="namespace" type="string" required="yes">
		<cfargument name="defaultController" type="string" required="yes">
		<cfargument name="defaultMethod" type="string" required="yes">
		<cfargument name="translateURIDashes" type="boolean" required="yes">
		<cfset var routingConfig = config("Config\Routing")>

		<cfset this.protectedControllers = arguments.protectedControllers>
		<cfset this.defaultController = arguments.defaultController>
		<cfset this.defaultMethod = arguments.defaultMethod>
		<cfset this.translateURIDashes = arguments.translateURIDashes>

		<cfset this.namespace = rtrim_(arguments.namespace, "\")>

		<cfset this.moduleRoutes = routingConfig.moduleRoutes>
		<cfset this.translateUriToCamelCase = routingConfig.translateUriToCamelCase>

		<!--- Set the default values --->
		<cfset this.controller = this.defaultController>

		<cfreturn this>
	</cffunction>

	<!---
	 * @return A list of strings
	--->
	<cffunction name="createSegments" access="private" returntype="array" output="no">
		<cfargument name="uri" type="string" required="yes">
		<cfset var segments = explode("/", arguments.uri)>
		<cfset var result = ArrayNew(1)>
		<cfset var i = 0>

		<!--- array_filter and array_values: the empty segments go, with no gaps --->
		<cfloop from="1" to="#ArrayLen(segments)#" index="i">
			<cfif segments[i] NEQ "">
				<cfset ArrayAppend(result, segments[i])>
			</cfif>
		</cfloop>

		<cfreturn result>
	</cffunction>

	<!---
	 * Search for the first controller corresponding to the URI segment.
	 *
	 * If there is a controller corresponding to the first segment, the search
	 * ends there. The remaining segments are parameters to the controller.
	 *
	 * @return true if a controller class is found.
	--->
	<cffunction name="searchFirstController" access="private" returntype="boolean" output="no">
		<cfset var segments = this.segments>
		<cfset var controller = "\" & this.namespace>
		<cfset var controllerPos = -1>
		<cfset var segment = "">
		<cfset var class = "">

		<cfloop condition="ArrayLen(segments) GT 0">
			<cfset segment = segments[1]>
			<cfset ArrayDeleteAt(segments, 1)>
			<cfset controllerPos = controllerPos + 1>

			<cfset class = translateURI(segment)>

			<!--- as soon as we encounter any segment that is not PSR-4 compliant, stop searching --->
			<cfif NOT isValidSegment(class)>
				<cfreturn false>
			</cfif>

			<cfset controller = controller & "\" & class>

			<cfif class_exists(controller)>
				<cfset this.controller = controller>
				<cfset this.controllerPos = controllerPos>

				<cfset checkUriForController(controller)>

				<!--- The first item may be a method name. --->
				<cfset this.params = segments>
				<cfif ArrayLen(segments) GT 0>
					<cfset this.paramPos = this.controllerPos + 1>
				</cfif>

				<cfreturn true>
			</cfif>
		</cfloop>

		<cfreturn false>
	</cffunction>

	<!---
	 * Search for the last default controller corresponding to the URI segments.
	 *
	 * @return true if a controller class is found.
	--->
	<cffunction name="searchLastDefaultController" access="private" returntype="boolean" output="no">
		<cfset var segments = this.segments>
		<cfset var segmentCount = ArrayLen(this.segments)>
		<cfset var paramPos = "">
		<cfset var params = ArrayNew(1)>
		<cfset var namespaces = ArrayNew(1)>
		<cfset var controller = "">
		<cfset var i = 0>
		<cfset var valid = true>

		<cfloop condition="ArrayLen(segments) GT 0">
			<cfif segmentCount GT ArrayLen(segments)>
				<cfset paramPos = ArrayLen(segments)>
			</cfif>

			<cfset namespaces = ArrayNew(1)>
			<cfset valid = true>
			<cfloop from="1" to="#ArrayLen(segments)#" index="i">
				<cfset ArrayAppend(namespaces, translateURI(segments[i]))>
				<cfif NOT isValidSegment(namespaces[i])>
					<cfset valid = false>
				</cfif>
			</cfloop>

			<cfset controller = "\" & this.namespace
				& "\" & implode("\", namespaces)
				& "\" & this.defaultController>

			<!---
			 Difference: class_exists() here is a file check, so "." or ".." in
			 a segment would resolve to a real file in another folder. A class name
			 can never hold them, so the check is skipped for invalid segments.
			--->
			<cfif valid AND class_exists(controller)>
				<cfset this.controller = controller>
				<cfset this.params = params>

				<cfif ArrayLen(params) GT 0>
					<cfset this.paramPos = paramPos>
				</cfif>

				<cfreturn true>
			</cfif>

			<!--- Prepend the last element in segments to the beginning of params. --->
			<cfif ArrayLen(params) EQ 0>
				<!--- Difference: ArrayInsertAt cannot insert into an empty array. --->
				<cfset ArrayAppend(params, segments[ArrayLen(segments)])>
			<cfelse>
				<cfset ArrayInsertAt(params, 1, segments[ArrayLen(segments)])>
			</cfif>
			<cfset ArrayDeleteAt(segments, ArrayLen(segments))>
		</cfloop>

		<!--- Check for the default controller in Controllers directory. --->
		<cfset controller = "\" & this.namespace
			& "\" & this.defaultController>

		<cfif class_exists(controller)>
			<cfset this.controller = controller>
			<cfset this.params = params>

			<cfif ArrayLen(params) GT 0>
				<cfset this.paramPos = 0>
			</cfif>

			<cfreturn true>
		</cfif>

		<cfreturn false>
	</cffunction>

	<cffunction name="getRoute" access="public" returntype="array" output="no">
		<cfargument name="uri" type="string" required="yes">
		<cfargument name="httpVerb" type="string" required="yes">
		<cfset var defaultMethod = "">
		<cfset var uriSegment = "">
		<cfset var baseControllerName = "">
		<cfset var params = ArrayNew(1)>
		<cfset var methodParam = "">
		<cfset var hasMethodParam = false>
		<cfset var methodFound = false>
		<cfset var method = "">
		<cfset var route = ArrayNew(1)>

		<cfset this.uri = arguments.uri>
		<cfset arguments.httpVerb = LCase(arguments.httpVerb)>

		<!--- Reset Controller method params. --->
		<cfset this.params = ArrayNew(1)>

		<cfset defaultMethod = arguments.httpVerb & ucfirst(this.defaultMethod)>
		<cfset this.method = defaultMethod>

		<cfset this.segments = createSegments(arguments.uri)>

		<!--- Check for Module Routes. --->
		<cfif ArrayLen(this.segments) GT 0
			AND StructKeyExists(this.moduleRoutes, this.segments[1])>
			<cfset uriSegment = this.segments[1]>
			<cfset ArrayDeleteAt(this.segments, 1)>
			<cfset this.namespace = rtrim_(this.moduleRoutes[uriSegment], "\")>
		</cfif>

		<cfif searchFirstController()>
			<!--- Controller is found. --->
			<cfset baseControllerName = ListLast(this.controller, "\")>

			<!--- Prevent access to default controller path --->
			<cfif Compare(LCase(baseControllerName), LCase(this.defaultController)) EQ 0>
				<cfset static_("ColdIgniter\Exceptions\PageNotFoundException").forPageNotFound(
					'Cannot access the default controller "' & this.controller & '" with the controller name URI path.'
				)>
			</cfif>
		<cfelseif searchLastDefaultController()>
			<!--- The default Controller is found. --->
			<cfset baseControllerName = ListLast(this.controller, "\")>
		<cfelse>
			<!--- No Controller is found. --->
			<cfset static_("ColdIgniter\Exceptions\PageNotFoundException").forPageNotFound("No controller is found for: " & arguments.uri)>
		</cfif>

		<!--- The first item may be a method name. --->
		<cfset params = this.params>

		<cfif ArrayLen(params) GT 0>
			<cfset hasMethodParam = true>
			<cfset methodParam = params[1]>
			<cfset ArrayDeleteAt(params, 1)>
		</cfif>

		<cfif hasMethodParam>
			<cfset method = arguments.httpVerb & translateURI(methodParam)>

			<cfset checkUriForMethod(method)>

			<cfset methodFound = method_exists(static_(this.controller), method)>
		</cfif>

		<cfif methodFound>
			<!--- Method is found. --->
			<cfset this.method = method>
			<cfset this.params = params>

			<!--- Update the positions. --->
			<cfset this.methodPos = this.paramPos>
			<cfif ArrayLen(params) EQ 0>
				<cfset this.paramPos = "">
			</cfif>
			<cfif IsNumeric(this.paramPos)>
				<cfset this.paramPos = this.paramPos + 1>
			</cfif>

			<!--- Prevent access to default controller's method --->
			<cfif Compare(LCase(baseControllerName), LCase(this.defaultController)) EQ 0>
				<cfset static_("ColdIgniter\Exceptions\PageNotFoundException").forPageNotFound(
					'Cannot access the default controller "' & this.controller & "::" & this.method & '"'
				)>
			</cfif>

			<!--- Prevent access to default method path --->
			<cfif Compare(LCase(this.method), LCase(defaultMethod)) EQ 0>
				<cfset static_("ColdIgniter\Exceptions\PageNotFoundException").forPageNotFound(
					'Cannot access the default method "' & this.method & '" with the method name URI path.'
				)>
			</cfif>
		<cfelseif method_exists(static_(this.controller), defaultMethod)>
			<!--- The default method is found. --->
			<cfset this.method = defaultMethod>
		<cfelse>
			<!--- No method is found. --->
			<cfset static_("ColdIgniter\Exceptions\PageNotFoundException").forControllerNotFound(this.controller, method)>
		</cfif>

		<!--- Ensure the controller is not defined in routes. --->
		<cfset protectDefinedRoutes()>

		<!--- Ensure the controller does not have _remap() method. --->
		<cfset checkRemap()>

		<!---
		 Ensure the URI segments for the controller and method do not contain
		 underscores when translateURIDashes is true.
		--->
		<cfset checkUnderscore()>

		<!--- Check parameter count --->
		<cftry>
			<cfset checkParameters()>

			<cfcatch type="ColdIgniter.Router.Exceptions.MethodNotFoundException">
				<cfset static_("ColdIgniter\Exceptions\PageNotFoundException").forControllerNotFound(this.controller, this.method)>
			</cfcatch>
		</cftry>

		<cfset setDirectory()>

		<cfset ArrayAppend(route, this.directory)>
		<cfset ArrayAppend(route, this.controller)>
		<cfset ArrayAppend(route, this.method)>
		<cfset ArrayAppend(route, this.params)>

		<cfreturn route>
	</cffunction>

	<!---
	 * @internal For test purpose only.
	 *
	 * @return A map of the positions (see array_()); an empty string is null
	--->
	<cffunction name="getPos" access="public" returntype="any" output="no">
		<cfreturn array_(
			"controller", this.controllerPos,
			"method", this.methodPos,
			"params", this.paramPos
		)>
	</cffunction>

	<!---
	 * Get the directory path from the controller and set it to the property.
	--->
	<cffunction name="setDirectory" access="private" returntype="void" output="no">
		<cfset var segments = explode("\", trim_(this.controller, "\"))>
		<cfset var namespaces = "">
		<cfset var dir = "">

		<!--- Remove short classname. --->
		<cfset ArrayDeleteAt(segments, ArrayLen(segments))>

		<cfset namespaces = implode("\", segments)>

		<cfset dir = Replace(
			ltrim_(substr(namespaces, Len(this.namespace)), "\"),
			"\",
			"/",
			"all"
		)>

		<cfif dir NEQ "">
			<cfset this.directory = dir & "/">
		</cfif>
	</cffunction>

	<cffunction name="protectDefinedRoutes" access="private" returntype="void" output="no">
		<cfset var controller = LCase(this.controller)>
		<cfset var controllerInRoutes = "">
		<cfset var routeLowerCase = "">
		<cfset var i = 0>

		<cfloop from="1" to="#ArrayLen(this.protectedControllers)#" index="i">
			<cfset controllerInRoutes = this.protectedControllers[i]>
			<cfset routeLowerCase = LCase(controllerInRoutes)>

			<cfif Compare(routeLowerCase, controller) EQ 0>
				<cfset static_("ColdIgniter\Exceptions\PageNotFoundException").forPageNotFound(
					"Cannot access the controller in Defined Routes. Controller: " & controllerInRoutes
				)>
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="checkParameters" access="private" returntype="void" output="no">
		<cfset var info = methodInfo(this.method)>
		<cfset var refParams = "">

		<!---
		 Not found, or not public: methodInfo() sees public methods only,
		 so one answer stands in for both of the original.
		--->
		<cfif NOT IsStruct(info)>
			<cfset static_("ColdIgniter\Router\Exceptions\MethodNotFoundException").forMethodNotFound()>
		</cfif>

		<cfif StructKeyExists(info, "parameters")>
			<cfset refParams = info.parameters>
		<cfelse>
			<cfset refParams = ArrayNew(1)>
		</cfif>

		<cfif ArrayLen(refParams) LT ArrayLen(this.params)>
			<cfset static_("ColdIgniter\Exceptions\PageNotFoundException").forPageNotFound(
				"The param count in the URI are greater than the controller method params."
				& " Handler:" & this.controller & "::" & this.method
				& ", URI:" & this.uri
			)>
		</cfif>
	</cffunction>

	<cffunction name="checkRemap" access="private" returntype="void" output="no">
		<cfif method_exists(static_(this.controller), "_remap")>
			<cfset static_("ColdIgniter\Exceptions\PageNotFoundException").forPageNotFound(
				"AutoRouterImproved does not support `_remap()` method."
				& " Controller:" & this.controller
			)>
		</cfif>
	</cffunction>

	<cffunction name="checkUnderscore" access="private" returntype="void" output="no">
		<cfset var paramPos = 0>
		<cfset var i = 0>

		<cfif this.translateURIDashes EQ false>
			<cfreturn>
		</cfif>

		<cfif IsNumeric(this.paramPos)>
			<cfset paramPos = this.paramPos>
		<cfelse>
			<cfset paramPos = ArrayLen(this.segments)>
		</cfif>

		<cfloop from="0" to="#paramPos - 1#" index="i">
			<cfif Find("_", this.segments[i + 1]) GT 0>
				<cfset static_("ColdIgniter\Exceptions\PageNotFoundException").forPageNotFound(
					"AutoRouterImproved prohibits access to the URI"
					& ' containing underscores ("' & this.segments[i + 1] & '")'
					& " when $translateURIDashes is enabled."
					& " Please use the dash."
					& " Handler:" & this.controller & "::" & this.method
					& ", URI:" & this.uri
				)>
			</cfif>
		</cfloop>
	</cffunction>

	<!---
	 * Check URI for controller for translateUriToCamelCase
	 *
	 * @param classname Controller classname that is generated from URI.
	 *                  The case may be a bit incorrect.
	--->
	<cffunction name="checkUriForController" access="private" returntype="void" output="no">
		<cfargument name="classname" type="string" required="yes">

		<cfif this.translateUriToCamelCase EQ false>
			<cfreturn>
		</cfif>

		<cfif NOT isDeclared(arguments.classname)>
			<cfset static_("ColdIgniter\Exceptions\PageNotFoundException").forPageNotFound(
				'"' & arguments.classname & '" is not found.'
			)>
		</cfif>
	</cffunction>

	<!---
	 * Check URI for method for translateUriToCamelCase
	 *
	 * @param method Controller method name that is generated from URI.
	 *               The case may be a bit incorrect.
	--->
	<cffunction name="checkUriForMethod" access="private" returntype="void" output="no">
		<cfargument name="method" type="string" required="yes">
		<cfset var info = "">

		<cfif this.translateUriToCamelCase EQ false>
			<cfreturn>
		</cfif>

		<!---
		 For example, if `getSomeMethod()` exists in the controller, only
		 the URI `controller/some-method` should be accessible. But if a
		 visitor navigates to the URI `controller/somemethod`, `getSomemethod()`
		 will be checked, and method_exists() will return true because
		 method names are case-insensitive.
		--->
		<cfset info = methodInfo(arguments.method)>

		<!--- But we do not permit `controller/somemethod`, so check the exact method name. --->
		<cfif IsStruct(info) AND Compare(info.name, arguments.method) NEQ 0>
			<cfset static_("ColdIgniter\Exceptions\PageNotFoundException").forPageNotFound(
				'"' & this.controller & "::" & arguments.method & '()" is not found.'
			)>
		</cfif>
	</cffunction>

	<!---
	 * Returns true if the supplied segment string represents a valid PSR-4 compliant namespace/directory segment
	 *
	 * The regex is the rule for the name of a variable in the original language.
	--->
	<cffunction name="isValidSegment" access="private" returntype="boolean" output="no">
		<cfargument name="segment" type="string" required="yes">

		<cfreturn preg_match("/^[a-zA-Z_\x80-\xff][a-zA-Z0-9_\x80-\xff]*$/", arguments.segment, true) EQ 1>
	</cffunction>

	<!---
	 * Translates URI segment to CamelCase or replaces `-` with `_`.
	--->
	<cffunction name="translateURI" access="private" returntype="string" output="no">
		<cfargument name="segment" type="string" required="yes">

		<cfif this.translateUriToCamelCase>
			<cfif Compare(LCase(arguments.segment), arguments.segment) NEQ 0>
				<cfset static_("ColdIgniter\Exceptions\PageNotFoundException").forPageNotFound(
					"AutoRouterImproved prohibits access to the URI"
					& ' containing uppercase letters ("' & arguments.segment & '")'
					& " when $translateUriToCamelCase is enabled."
					& " Please use the dash."
					& " URI:" & this.uri
				)>
			</cfif>

			<cfif Find("--", arguments.segment) GT 0>
				<cfset static_("ColdIgniter\Exceptions\PageNotFoundException").forPageNotFound(
					"AutoRouterImproved prohibits access to the URI"
					& ' containing double dash ("' & arguments.segment & '")'
					& " when $translateUriToCamelCase is enabled."
					& " Please use the single dash."
					& " URI:" & this.uri
				)>
			</cfif>

			<cfreturn Replace(
				ucwords(REReplace(arguments.segment, "-+", " ", "all")),
				" ",
				"",
				"all"
			)>
		</cfif>

		<cfset arguments.segment = ucfirst(arguments.segment)>

		<cfif this.translateURIDashes>
			<cfreturn Replace(arguments.segment, "-", "_", "all")>
		</cfif>

		<cfreturn arguments.segment>
	</cffunction>

	<!---
	 * Not in the original. Stands in for method_exists() and ReflectionMethod
	 * on the class of the controller (see the header).
	 *
	 * @param method The method name
	 *
	 * @return The metadata of the method (name and parameters), or an empty string when there is no public method of that name
	--->
	<cffunction name="methodInfo" access="private" returntype="any" output="no">
		<cfargument name="method" type="string" required="yes">
		<cfset var object = static_(this.controller)>
		<cfset var meta = "">
		<cfset var i = 0>

		<cfif NOT method_exists(object, arguments.method)>
			<cfreturn "">
		</cfif>

		<!---
		 The functions of the component and of the components it extends, as
		 GetMetaData() of the object lists them. A method that the framework
		 copied into the object is not listed, so it is not routable.
		--->
		<cfset meta = GetMetaData(object)>

		<cfloop condition="IsStruct(meta)">
			<cfif StructKeyExists(meta, "functions")>
				<cfloop from="1" to="#ArrayLen(meta.functions)#" index="i">
					<cfif CompareNoCase(meta.functions[i].name, arguments.method) EQ 0>
						<cfreturn meta.functions[i]>
					</cfif>
				</cfloop>
			</cfif>

			<cfif StructKeyExists(meta, "extends")>
				<cfset meta = meta.extends>
			<cfelse>
				<cfset meta = "">
			</cfif>
		</cfloop>

		<cfreturn "">
	</cffunction>

	<!---
	 * Not in the original. Stands in for the test with get_declared_classes()
	 * (see the header): the folders and the file of the class, below the
	 * namespace of the controllers, must be written as the class name is.
	 *
	 * @param classname The class name made from the URI
	 *
	 * @return Whether the class is declared with that name
	--->
	<cffunction name="isDeclared" access="private" returntype="boolean" output="no">
		<cfargument name="classname" type="string" required="yes">
		<cfset var path = Replace(GetMetaData(static_(arguments.classname)).path, "\", "/", "all")>
		<cfset var segments = explode("\", substr(ltrim_(arguments.classname, "\"), Len(this.namespace)))>
		<cfset var expected = "">
		<cfset var dir = "">
		<cfset var entries = "">
		<cfset var i = 0>

		<!--- segments[1] is empty: the rest of the class name starts with a backslash --->
		<cfloop from="#ArrayLen(segments)#" to="2" step="-1" index="i">
			<cfset expected = segments[i]>
			<cfif i EQ ArrayLen(segments)>
				<cfset expected = expected & ".cfc">
			</cfif>

			<cfset dir = Left(path, Len(path) - Len(ListLast(path, "/")))>

			<cfdirectory action="list" directory="#dir#" name="entries" filter="#expected#">

			<cfif entries.RecordCount EQ 0 OR Compare(entries.name, expected) NEQ 0>
				<cfreturn false>
			</cfif>

			<!--- one level up: the folder without its trailing slash --->
			<cfset path = Left(dir, Len(dir) - 1)>
		</cfloop>

		<cfreturn true>
	</cffunction>

</cfcomponent>
