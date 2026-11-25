<!---
 * Factories for creating instances.
 *
 * Factories allow dynamic loading of components by their path
 * and name. The "shared instance" implementation provides a
 * large performance boost and helps keep code clean of lengthy
 * instantiation checks.
 *
 * The class is static in the original. Here it is used through
 * static_("ColdIgniter\Config\Factories").
 *
 * The arrays of options are structs, read and written with brackets
 * (options["instanceOf"]).
 *
 * Difference: platform. A function cannot return null, so an empty string
 * stands in for it (see is_null()): __callStatic(), get() and
 * locateClass() return an empty string when the class is not found, and an
 * option that is null is an empty string.
 *
 * Difference: platform. The keys of a struct are not case-sensitive, so
 * two aliases that differ only in case are one alias.
 *
 * Difference: platform. The original keeps its static properties private;
 * here they are the properties of the object (this.options and so on).
 *
 * Difference: platform. $conn of Factories::models() is passed by reference
 * in the original, so that a connection made by the model is written back.
 * That cannot be expressed here: a connection is only passed in, as one of
 * the arguments of the constructor.
 *
 * Not ported yet: the factories cache (FactoriesCache) and the locator
 * (see search()).
--->
<cfcomponent output="no" hint="Factories for creating instances">

	<!---
	 * Store of component-specific options, usually
	 * from ColdIgniter\Config\Factory.
	 *
	 * [component => [option => value]]
	--->
	<cfset this.options = StructNew()>

	<!---
	 * Explicit options for the Config
	 * component to prevent logic loops.
	--->
	<cfset this.configOptions = StructNew()>
	<cfset this.configOptions["component"] = "config">
	<cfset this.configOptions["path"] = "Config">
	<cfset this.configOptions["instanceOf"] = "">
	<cfset this.configOptions["getShared"] = true>
	<cfset this.configOptions["preferApp"] = true>

	<!---
	 * Mapping of class aliases to their true Fully Qualified Class Name (FQCN).
	 *
	 * Class aliases can be:
	 *     - FQCN. E.g., 'App\Lib\SomeLib'
	 *     - short classname. E.g., 'SomeLib'
	 *     - short classname with sub-directories. E.g., 'Sub/SomeLib'
	 *
	 * [component => [alias => FQCN]]
	--->
	<cfset this.aliases = StructNew()>

	<!---
	 * Store for instances of any component that
	 * has been requested as "shared".
	 *
	 * A multi-dimensional array with components as
	 * keys to the array of name-indexed instances.
	 *
	 * [component => [FQCN => instance]]
	--->
	<cfset this.instances = StructNew()>

	<!---
	 * Whether the component instances are updated?
	 *
	 * [component => true]
	 *
	 * For caching only
	--->
	<cfset this.updated = StructNew()>

	<!---
	 * Define the class to load. You can *override* the concrete class.
	 *
	 * @param component Lowercase, plural component name
	 * @param alias     Class alias. See the aliases property.
	 * @param classname FQCN to be loaded
	--->
	<cffunction name="define" access="public" returntype="void" output="no">
		<cfargument name="component" type="string" required="yes">
		<cfargument name="alias" type="string" required="yes">
		<cfargument name="classname" type="string" required="yes">

		<cfset arguments.component = LCase(arguments.component)>

		<cfif StructKeyExists(this.aliases, arguments.component) AND StructKeyExists(this.aliases[arguments.component], arguments.alias)>
			<cfif Compare(this.aliases[arguments.component][arguments.alias], arguments.classname) EQ 0>
				<cfreturn>
			</cfif>

			<cfthrow type="ColdIgniter.Exceptions.InvalidArgumentException" message="Already defined in Factories: #arguments.component# #arguments.alias# -> #this.aliases[arguments.component][arguments.alias]#">
		</cfif>

		<cfif NOT class_exists(arguments.classname)>
			<cfthrow type="ColdIgniter.Exceptions.InvalidArgumentException" message="No such class: #arguments.classname#">
		</cfif>

		<!--- Force a configuration to exist for this component. Otherwise, getOptions() will reset the component. --->
		<cfset getOptions(arguments.component)>

		<cfif NOT StructKeyExists(this.aliases, arguments.component)>
			<cfset this.aliases[arguments.component] = StructNew()>
		</cfif>

		<cfset this.aliases[arguments.component][arguments.alias] = arguments.classname>
		<cfset this.updated[arguments.component] = true>
	</cffunction>

	<!---
	 * Loads instances based on the method component name. Either
	 * creates a new instance or returns an existing shared instance.
	 *
	 * The first item of the arguments is the class alias, the second the
	 * options, and the rest go to the constructor of the class.
	 *
	 * @return The instance, or an empty string if the class is not found
	--->
	<cffunction name="__callStatic" access="public" returntype="any" output="no">
		<cfargument name="component" type="string" required="yes">
		<cfargument name="arguments_" type="array" required="yes">
		<cfset var alias = "">
		<cfset var given = StructNew()>
		<cfset var options = "">
		<cfset var instance = "">
		<cfset var class = "">

		<cfset arguments.component = LCase(arguments.component)>

		<!--- First argument is the class alias, second is options --->
		<cfset alias = trim_(arguments.arguments_[1], "\ ")>
		<cfset ArrayDeleteAt(arguments.arguments_, 1)>

		<cfif ArrayLen(arguments.arguments_) GT 0>
			<cfif IsStruct(arguments.arguments_[1])>
				<cfset given = arguments.arguments_[1]>
			</cfif>

			<cfset ArrayDeleteAt(arguments.arguments_, 1)>
		</cfif>

		<!---
		 * Determine the component-specific options
		 *
		 * Difference: performance. With no options given the stored options
		 * are used as they are: nothing here changes them, so no copy is made.
		--->
		<cfif StructIsEmpty(given)>
			<cfset options = getOptions(arguments.component)>
		<cfelse>
			<cfset options = StructCopy(getOptions(arguments.component))>
			<cfset StructAppend(options, given, true)>
		</cfif>

		<cfif NOT boolval(options["getShared"])>
			<cfif StructKeyExists(this.aliases, options["component"]) AND StructKeyExists(this.aliases[options["component"]], alias)>
				<cfset class = this.aliases[options["component"]][alias]>

				<cfreturn newClass(class, arguments.arguments_)>
			</cfif>

			<!--- Try to locate the class --->
			<cfset class = locateClass(options, alias)>
			<cfif class NEQ "">
				<cfreturn newClass(class, arguments.arguments_)>
			</cfif>

			<cfreturn "">
		</cfif>

		<!--- Check for an existing definition --->
		<cfset instance = getDefinedInstance(options, alias, arguments.arguments_)>
		<cfif IsObject(instance)>
			<cfreturn instance>
		</cfif>

		<!--- Try to locate the class --->
		<cfset class = locateClass(options, alias)>
		<cfif class EQ "">
			<cfreturn "">
		</cfif>

		<cfset createInstance(options["component"], class, arguments.arguments_)>
		<cfset setAlias(options["component"], alias, class)>

		<cfreturn this.instances[options["component"]][class]>
	</cffunction>

	<!---
	 * Simple method to get the shared instance fast.
	 *
	 * @return The instance, or an empty string if the class is not found
	--->
	<cffunction name="get" access="public" returntype="any" output="no">
		<cfargument name="component" type="string" required="yes">
		<cfargument name="alias" type="string" required="yes">
		<cfset var class = "">
		<cfset var arguments_ = ArrayNew(1)>

		<cfif StructKeyExists(this.aliases, arguments.component) AND StructKeyExists(this.aliases[arguments.component], arguments.alias)>
			<cfset class = this.aliases[arguments.component][arguments.alias]>

			<cfif StructKeyExists(this.instances, arguments.component) AND StructKeyExists(this.instances[arguments.component], class)>
				<cfreturn this.instances[arguments.component][class]>
			</cfif>
		</cfif>

		<cfset ArrayAppend(arguments_, arguments.alias)>

		<cfreturn __callStatic(arguments.component, arguments_)>
	</cffunction>

	<!---
	 * Gets the defined instance. If not exists, creates new one.
	 *
	 * @param options    The struct of component-specific directives
	 * @param alias      Class alias. See the aliases property.
	 * @param arguments_ A list of the arguments of the constructor
	 *
	 * @return The instance, or an empty string
	--->
	<cffunction name="getDefinedInstance" access="private" returntype="any" output="no">
		<cfargument name="options" type="struct" required="yes">
		<cfargument name="alias" type="string" required="yes">
		<cfargument name="arguments_" type="array" required="yes">
		<cfset var class = "">

		<!--- The alias is already defined. --->
		<cfif StructKeyExists(this.aliases, arguments.options["component"]) AND StructKeyExists(this.aliases[arguments.options["component"]], arguments.alias)>
			<cfset class = this.aliases[arguments.options["component"]][arguments.alias]>

			<!--- Need to verify if the shared instance matches the request --->
			<cfif verifyInstanceOf(arguments.options, class)>
				<!--- Check for an existing instance --->
				<cfif StructKeyExists(this.instances, arguments.options["component"]) AND StructKeyExists(this.instances[arguments.options["component"]], class)>
					<cfreturn this.instances[arguments.options["component"]][class]>
				</cfif>

				<cfset createInstance(arguments.options["component"], class, arguments.arguments_)>

				<cfreturn this.instances[arguments.options["component"]][class]>
			</cfif>
		</cfif>

		<!--- Try to locate the class --->
		<cfset class = locateClass(arguments.options, arguments.alias)>
		<cfif class EQ "">
			<cfreturn "">
		</cfif>

		<!--- Check for an existing instance for the class --->
		<cfif StructKeyExists(this.instances, arguments.options["component"]) AND StructKeyExists(this.instances[arguments.options["component"]], class)>
			<cfset setAlias(arguments.options["component"], arguments.alias, class)>

			<cfreturn this.instances[arguments.options["component"]][class]>
		</cfif>

		<cfreturn "">
	</cffunction>

	<!---
	 * Creates the shared instance.
	 *
	 * @param arguments_ A list of the arguments of the constructor
	--->
	<cffunction name="createInstance" access="private" returntype="void" output="no">
		<cfargument name="component" type="string" required="yes">
		<cfargument name="class" type="string" required="yes">
		<cfargument name="arguments_" type="array" required="yes">

		<cfif NOT StructKeyExists(this.instances, arguments.component)>
			<cfset this.instances[arguments.component] = StructNew()>
		</cfif>

		<cfset this.instances[arguments.component][arguments.class] = newClass(arguments.class, arguments.arguments_)>
		<cfset this.updated[arguments.component] = true>
	</cffunction>

	<!---
	 * Sets alias
	--->
	<cffunction name="setAlias" access="private" returntype="void" output="no">
		<cfargument name="component" type="string" required="yes">
		<cfargument name="alias" type="string" required="yes">
		<cfargument name="class" type="string" required="yes">

		<cfif NOT StructKeyExists(this.aliases, arguments.component)>
			<cfset this.aliases[arguments.component] = StructNew()>
		</cfif>

		<cfset this.aliases[arguments.component][arguments.alias] = arguments.class>
		<cfset this.updated[arguments.component] = true>

		<!--- If a short classname is specified, also register FQCN to share the instance. --->
		<cfif NOT StructKeyExists(this.aliases[arguments.component], arguments.class) AND NOT isNamespaced(arguments.alias)>
			<cfset this.aliases[arguments.component][arguments.class] = arguments.class>
		</cfif>
	</cffunction>

	<!---
	 * Is the component Config?
	 *
	 * @param component Lowercase, plural component name
	--->
	<cffunction name="isConfig" access="private" returntype="boolean" output="no">
		<cfargument name="component" type="string" required="yes">

		<cfreturn Compare(arguments.component, "config") EQ 0>
	</cffunction>

	<!---
	 * Finds a component class
	 *
	 * @param options The struct of component-specific directives
	 * @param alias   Class alias. See the aliases property.
	 *
	 * @return The class name, or an empty string if it is not found
	--->
	<cffunction name="locateClass" access="private" returntype="string" output="no">
		<cfargument name="options" type="struct" required="yes">
		<cfargument name="alias" type="string" required="yes">
		<cfset var exists = class_exists(arguments.alias)>
		<cfset var basename = "">
		<cfset var appname = "">
		<cfset var files = "">
		<cfset var class = "">
		<cfset var i = 0>

		<!---
		 * Check for low-hanging fruit
		 *
		 * Difference: platform and performance. class_exists() cannot be told
		 * not to load the class (the second argument of the original is
		 * false), and it is asked once for all the checks below.
		--->
		<cfif exists AND verifyPreferApp(arguments.options, arguments.alias) AND verifyInstanceOf(arguments.options, arguments.alias)>
			<cfreturn arguments.alias>
		</cfif>

		<!--- Determine the relative class names we need --->
		<cfset basename = getBasename(arguments.alias)>
		<cfif isConfig(arguments.options["component"])>
			<cfset appname = "Config\" & basename>
		<cfelse>
			<cfset appname = rtrim_(request.APP_NAMESPACE, "\") & "\" & arguments.options["path"] & "\" & basename>
		</cfif>

		<!--- If an App version was requested then see if it verifies --->
		<!--- preferApp is used only for no namespaced class. --->
		<cfif NOT isNamespaced(arguments.alias) AND boolval(arguments.options["preferApp"]) AND class_exists(appname) AND verifyInstanceOf(arguments.options, arguments.alias)>
			<cfreturn appname>
		</cfif>

		<!--- If we have ruled out an App version and the class exists then try it --->
		<cfif exists AND verifyInstanceOf(arguments.options, arguments.alias)>
			<cfreturn arguments.alias>
		</cfif>

		<!--- Have to do this the hard way... --->
		<cfset files = search(arguments.options, arguments.alias)>

		<cfif ArrayLen(files) EQ 0>
			<cfreturn "">
		</cfif>

		<!--- Check all files for a valid class --->
		<cfloop from="1" to="#ArrayLen(files)#" index="i">
			<cfset class = files[i]>

			<cfif verifyInstanceOf(arguments.options, class)>
				<cfreturn class>
			</cfif>
		</cfloop>

		<cfreturn "">
	</cffunction>

	<!---
	 * Is the class alias namespaced or not?
	 *
	 * @param alias Class alias. See the aliases property.
	--->
	<cffunction name="isNamespaced" access="private" returntype="boolean" output="no">
		<cfargument name="alias" type="string" required="yes">

		<cfreturn Find("\", arguments.alias) GT 0>
	</cffunction>

	<!---
	 * Verifies that a class & config satisfy the "preferApp" option
	 *
	 * @param options The struct of component-specific directives
	 * @param alias   Class alias. See the aliases property.
	--->
	<cffunction name="verifyPreferApp" access="private" returntype="boolean" output="no">
		<cfargument name="options" type="struct" required="yes">
		<cfargument name="alias" type="string" required="yes">

		<!--- Anything without that restriction passes --->
		<cfif NOT boolval(arguments.options["preferApp"])>
			<cfreturn true>
		</cfif>

		<!--- Special case for Config since its App namespace is actually \Config --->
		<cfif isConfig(arguments.options["component"])>
			<cfreturn str_starts_with(arguments.alias, "Config")>
		</cfif>

		<cfreturn str_starts_with(arguments.alias, request.APP_NAMESPACE)>
	</cffunction>

	<!---
	 * Verifies that a class & config satisfy the "instanceOf" option
	 *
	 * Difference: platform. is_a() on a class name has no counterpart: the
	 * class must exist, and an object of it (static_()) is asked, see
	 * instanceof_().
	 *
	 * @param options The struct of component-specific directives
	 * @param alias   Class alias. See the aliases property.
	--->
	<cffunction name="verifyInstanceOf" access="private" returntype="boolean" output="no">
		<cfargument name="options" type="struct" required="yes">
		<cfargument name="alias" type="string" required="yes">

		<!--- Anything without that restriction passes --->
		<cfif NOT boolval(arguments.options["instanceOf"])>
			<cfreturn true>
		</cfif>

		<cfif NOT class_exists(arguments.alias)>
			<cfreturn false>
		</cfif>

		<cfreturn instanceof_(static_(arguments.alias), arguments.options["instanceOf"])>
	</cffunction>

	<!---
	 * Returns the component-specific configuration
	 *
	 * @param component Lowercase, plural component name
	 *
	 * For testing only
	--->
	<cffunction name="getOptions" access="public" returntype="struct" output="no">
		<cfargument name="component" type="string" required="yes">
		<cfset var values = "">
		<cfset var factory = "">

		<cfset arguments.component = LCase(arguments.component)>

		<!--- Check for a stored version --->
		<cfif StructKeyExists(this.options, arguments.component)>
			<cfreturn this.options[arguments.component]>
		</cfif>

		<cfif isConfig(arguments.component)>
			<!--- Handle Config as a special case to prevent logic loops --->
			<cfset values = this.configOptions>
		<cfelse>
			<!--- Load values from the best Factory configuration (will include Registrars) --->
			<cfset values = StructNew()>
			<cfset factory = config("Factory")>

			<cfif IsObject(factory) AND StructKeyExists(factory, arguments.component) AND IsStruct(factory[arguments.component])>
				<cfset values = factory[arguments.component]>
			</cfif>
		</cfif>

		<!--- The setOptions() reset the component. So getOptions() may reset the component. --->
		<cfreturn setOptions(arguments.component, values)>
	</cffunction>

	<!---
	 * Normalizes, stores, and returns the configuration for a specific component
	 *
	 * @param component Lowercase, plural component name
	 * @param values    Option values
	 *
	 * @return The result after applying defaults and normalization
	--->
	<cffunction name="setOptions" access="public" returntype="struct" output="no">
		<cfargument name="component" type="string" required="yes">
		<cfargument name="values" type="struct" required="yes">
		<cfset var normalized = StructCopy(arguments.values)>
		<cfset var factory = static_("ColdIgniter\Config\Factory")>
		<cfset var result = "">

		<cfset arguments.component = LCase(arguments.component)>

		<!--- Allow the config to replace the component name, to support "aliases" --->
		<cfif StructKeyExists(normalized, "component") AND NOT is_null(normalized["component"])>
			<cfset normalized["component"] = LCase(normalized["component"])>
		<cfelse>
			<cfset normalized["component"] = arguments.component>
		</cfif>

		<!--- Reset this component so instances can be rediscovered with the updated config --->
		<cfset reset(normalized["component"])>

		<!--- If no path was available then use the component --->
		<cfif StructKeyExists(normalized, "path") AND NOT is_null(normalized["path"])>
			<cfset normalized["path"] = trim_(normalized["path"], "\ ")>
		<cfelse>
			<cfset normalized["path"] = trim_(ucfirst(normalized["component"]), "\ ")>
		</cfif>

		<!--- Add defaults for any missing values --->
		<cfset result = StructCopy(factory["default"])>
		<cfset StructAppend(result, normalized, true)>

		<!--- Store the result to the supplied name and potential alias --->
		<cfset this.options[arguments.component] = result>
		<cfset this.options[result["component"]] = result>

		<cfreturn result>
	</cffunction>

	<!---
	 * Resets the static arrays, optionally just for one component
	 *
	 * @param component Lowercase, plural component name, or nothing
	--->
	<cffunction name="reset" access="public" returntype="void" output="no">
		<cfargument name="component" type="string" required="no">

		<cfif StructKeyExists(arguments, "component")>
			<cfset StructDelete(this.options, arguments.component)>
			<cfset StructDelete(this.aliases, arguments.component)>
			<cfset StructDelete(this.instances, arguments.component)>
			<cfset StructDelete(this.updated, arguments.component)>

			<cfreturn>
		</cfif>

		<cfset this.options = StructNew()>
		<cfset this.aliases = StructNew()>
		<cfset this.instances = StructNew()>
		<cfset this.updated = StructNew()>
	</cffunction>

	<!---
	 * Helper method for injecting mock instances
	 *
	 * @param component Lowercase, plural component name
	 * @param alias     Class alias. See the aliases property.
	 *
	 * For testing only
	--->
	<cffunction name="injectMock" access="public" returntype="void" output="no">
		<cfargument name="component" type="string" required="yes">
		<cfargument name="alias" type="string" required="yes">
		<cfargument name="instance" type="any" required="yes">
		<cfset var class = "">

		<cfset arguments.component = LCase(arguments.component)>

		<!--- Force a configuration to exist for this component --->
		<cfset getOptions(arguments.component)>

		<!--- Difference: platform. The autoloader keeps the class of an object in __class (the original has $instance::class). --->
		<cfset class = arguments.instance.__class>

		<cfif NOT StructKeyExists(this.instances, arguments.component)>
			<cfset this.instances[arguments.component] = StructNew()>
		</cfif>

		<cfif NOT StructKeyExists(this.aliases, arguments.component)>
			<cfset this.aliases[arguments.component] = StructNew()>
		</cfif>

		<cfset this.instances[arguments.component][class] = arguments.instance>
		<cfset this.aliases[arguments.component][arguments.alias] = class>

		<cfif isConfig(arguments.component)>
			<cfif isNamespaced(arguments.alias)>
				<cfset this.aliases[arguments.component][getBasename(arguments.alias)] = class>
			<cfelse>
				<cfset this.aliases[arguments.component]["Config\" & arguments.alias] = class>
			</cfif>
		</cfif>
	</cffunction>

	<!---
	 * Gets a basename from a class alias, namespaced or not.
	 *
	 * For testing only
	--->
	<cffunction name="getBasename" access="public" returntype="string" output="no">
		<cfargument name="alias" type="string" required="yes">
		<cfset var position = Find("\", Reverse(arguments.alias))>

		<!--- Determine the basename --->
		<cfif position GT 0>
			<!--- Right() does not take a length of 0 --->
			<cfif position EQ 1>
				<cfreturn "">
			</cfif>

			<cfreturn Right(arguments.alias, position - 1)>
		</cfif>

		<cfreturn arguments.alias>
	</cffunction>

	<!---
	 * Gets component data for caching.
	 *
	 * @return A struct with the keys options, aliases and instances
	 *
	 * For caching only
	--->
	<cffunction name="getComponentInstances" access="public" returntype="struct" output="no">
		<cfargument name="component" type="string" required="yes">
		<cfset var data = StructNew()>

		<cfif NOT StructKeyExists(this.aliases, arguments.component)>
			<cfset data["options"] = StructNew()>
			<cfset data["aliases"] = StructNew()>
			<cfset data["instances"] = StructNew()>

			<cfreturn data>
		</cfif>

		<cfset data["options"] = this.options[arguments.component]>
		<cfset data["aliases"] = this.aliases[arguments.component]>
		<cfset data["instances"] = this.instances[arguments.component]>

		<cfreturn data>
	</cffunction>

	<!---
	 * Sets component data
	 *
	 * @param data A struct with the keys options, aliases and instances
	 *
	 * For caching only
	--->
	<cffunction name="setComponentInstances" access="public" returntype="void" output="no">
		<cfargument name="component" type="string" required="yes">
		<cfargument name="data" type="struct" required="yes">

		<cfset this.options[arguments.component] = arguments.data["options"]>
		<cfset this.aliases[arguments.component] = arguments.data["aliases"]>
		<cfset this.instances[arguments.component] = arguments.data["instances"]>

		<cfset StructDelete(this.updated, arguments.component)>
	</cffunction>

	<!---
	 * Whether the component instances are updated?
	 *
	 * For caching only
	--->
	<cffunction name="isUpdated" access="public" returntype="boolean" output="no">
		<cfargument name="component" type="string" required="yes">

		<cfreturn StructKeyExists(this.updated, arguments.component)>
	</cffunction>

	<!---
	 * Not in the original. Creates an object of a class with a list of
	 * arguments for its constructor (new $class(...$arguments)).
	 *
	 * Difference: platform. new_() takes its arguments by position, so a
	 * list of them is passed through a call that is built as text.
	--->
	<cffunction name="newClass" access="private" returntype="any" output="no">
		<cfargument name="class" type="string" required="yes">
		<cfargument name="arguments_" type="array" required="yes">
		<cfset var call = "">
		<cfset var i = 0>

		<cfif ArrayLen(arguments.arguments_) EQ 0>
			<cfreturn new_(arguments.class)>
		</cfif>

		<cfloop from="1" to="#ArrayLen(arguments.arguments_)#" index="i">
			<cfset call = call & ", arguments.arguments_[#i#]">
		</cfloop>

		<cfreturn Evaluate("new_(arguments.class" & call & ")")>
	</cffunction>

	<!---
	 * Not in the original. The search of locateClass() through the locator
	 * (locateFile(), search() and findQualifiedNameFromPath()): it returns
	 * the classes found, as a list. A namespaced alias is the class itself
	 * when it exists. Any other alias is looked for in the path of the
	 * component in every namespace of the autoloader, the ColdIgniter
	 * namespace last, as the locator does.
	 *
	 * Not ported yet: this switches to service("locator") when
	 * system/Autoloader/FileLocator.cfc is ported.
	--->
	<cffunction name="search" access="private" returntype="array" output="no">
		<cfargument name="options" type="struct" required="yes">
		<cfargument name="alias" type="string" required="yes">
		<cfset var files = ArrayNew(1)>
		<cfset var namespaces = request.ColdIgniter.autoloader.getNamespace()>
		<cfset var names = ArrayNew(1)>
		<cfset var namespace = "">
		<cfset var relative = "">
		<cfset var class = "">
		<cfset var i = 0>

		<cfif isNamespaced(arguments.alias)>
			<cfif class_exists(arguments.alias)>
				<cfset ArrayAppend(files, arguments.alias)>
			</cfif>

			<cfreturn files>
		</cfif>

		<cfloop collection="#namespaces#" item="namespace">
			<cfif Compare(namespace, "ColdIgniter") NEQ 0>
				<cfset ArrayAppend(names, namespace)>
			</cfif>
		</cfloop>

		<cfif StructKeyExists(namespaces, "ColdIgniter")>
			<cfset ArrayAppend(names, "ColdIgniter")>
		</cfif>

		<cfset relative = arguments.options["path"] & "\" & Replace(arguments.alias, "/", "\", "all")>

		<cfloop from="1" to="#ArrayLen(names)#" index="i">
			<cfset class = names[i] & "\" & relative>

			<cfif class_exists(class)>
				<cfset ArrayAppend(files, class)>
			</cfif>
		</cfloop>

		<cfreturn files>
	</cffunction>

</cfcomponent>
