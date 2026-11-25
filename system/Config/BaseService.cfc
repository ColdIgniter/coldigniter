<!---
 * Services Configuration file.
 *
 * Services are simply other classes/libraries that the system uses
 * to do its job. This is used by ColdIgniter to allow the core of the
 * framework to be swapped out easily without affecting the usage within
 * the rest of your application.
 *
 * This is used in place of a Dependency Injection container primarily
 * due to its simplicity, which allows a better long-term maintenance
 * of the applications built on top of ColdIgniter. A bonus side-effect
 * is that IDEs are able to determine what class you are calling
 * whereas with DI Containers there usually isn't a way for them to do this.
 *
 * Warning: To allow overrides by service providers do not use static calls,
 * instead call out to \Config\Services (imported as AppServices).
 *
 * The class is static in the original. Here it is used through
 * static_("Config\Services"), which is the AppServices of the original.
 *
 * Difference: the original finds a service in the Config\Services of every
 * namespace that has one (service discovery), and in
 * CodeIgniter\Config\Services. Here there is one object that has all the
 * services, static_("Config\Services") (the one of the application extends
 * the one of the system), so serviceExists() gives that class name.
 *
 * Not ported yet: service discovery in modules (buildServicesCache, it needs
 * the module list), reconnectCacheForWorkerMode() and
 * resetForWorkerMode() (no worker mode, no Config\WorkerMode).
--->
<cfcomponent output="no" hint="Services Configuration file">

	<!---
	 * Cache for instance of any services that
	 * have been requested as a "shared" instance.
	 * Keys should be lowercase service names.
	--->
	<cfset this.instances = StructNew()>

	<!---
	 * Factory method list.
	 *
	 * A map of lower-case service names to a callable: a list of two, the
	 * name of the class and the method.
	--->
	<cfset this.factories = StructNew()>

	<!---
	 * Mock objects for testing which are returned if exist.
	--->
	<cfset this.mocks = StructNew()>

	<!---
	 * Have we already discovered other Services?
	--->
	<cfset this.discovered = false>

	<!---
	 * A cache of other service classes we've found.
	 *
	 * Difference: private in the original, a property of the object here,
	 * as a component cannot have a private property.
	--->
	<cfset this.serviceNames = ArrayNew(1)>

	<!---
	 * Simple method to get an entry fast.
	 *
	 * @param key Identifier of the entry to look for.
	 *
	 * @return The entry, or an empty string if it does not exist.
	--->
	<cffunction name="get" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">

		<cfif StructKeyExists(this.instances, arguments.key)>
			<cfreturn this.instances[arguments.key]>
		</cfif>

		<cfreturn __callStatic(arguments.key, ArrayNew(1))>
	</cffunction>

	<!---
	 * Checks if a service instance has been created.
	 *
	 * @param key Identifier of the entry to check.
	--->
	<cffunction name="has" access="public" returntype="boolean" output="no">
		<cfargument name="key" type="string" required="yes">

		<cfreturn StructKeyExists(this.instances, arguments.key)>
	</cffunction>

	<!---
	 * Sets an entry.
	 *
	 * @param key   Identifier of the entry.
	 * @param value The entry.
	 *
	 * @throws InvalidArgumentException if the entry is already set.
	--->
	<cffunction name="set" access="public" returntype="void" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="value" type="any" required="yes">

		<cfif StructKeyExists(this.instances, arguments.key)>
			<cfthrow type="ColdIgniter.Exceptions.InvalidArgumentException" message="The entry for ""#arguments.key#"" is already set.">
		</cfif>

		<cfset this.instances[arguments.key] = arguments.value>
	</cffunction>

	<!---
	 * Overrides an existing entry.
	 *
	 * @param key   Identifier of the entry.
	 * @param value The entry.
	--->
	<cffunction name="override" access="public" returntype="void" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="value" type="any" required="yes">

		<cfset this.instances[arguments.key] = arguments.value>
	</cffunction>

	<!---
	 * Returns a shared instance of any of the class' services.
	 *
	 * getSharedInstance(key, param, param, ...)
	 *
	 * $key must be a name matching a service.
	--->
	<cffunction name="getSharedInstance" access="private" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfset var call = "">
		<cfset var i = 0>

		<cfset arguments.key = LCase(arguments.key)>

		<!--- Returns mock if exists --->
		<cfif StructKeyExists(this.mocks, arguments.key)>
			<cfreturn this.mocks[arguments.key]>
		</cfif>

		<cfif NOT StructKeyExists(this.instances, arguments.key)>
			<!--- Make sure $getShared is false --->
			<cfloop from="2" to="#ArrayLen(arguments)#" index="i">
				<cfset call = ListAppend(call, "arguments[#i#]")>
			</cfloop>
			<cfset call = ListAppend(call, "false")>

			<!--- Called through "this": a service named like a scope (request) cannot be called without it. --->
			<cfset this.instances[arguments.key] = Evaluate("this.#arguments.key#(#call#)")>
		</cfif>

		<cfreturn this.instances[arguments.key]>
	</cffunction>

	<!---
	 * The Autoloader class is the central class that handles our
	 * spl_autoload_register method, and helper methods.
	--->
	<cffunction name="autoloader" access="public" returntype="any" output="no">
		<cfargument name="getShared" type="boolean" required="no" default="true">

		<cfif arguments.getShared>
			<cfif NOT StructKeyExists(this.instances, "autoloader")>
				<cfset this.instances["autoloader"] = new_("ColdIgniter\Autoloader\Autoloader")>
			</cfif>

			<cfreturn this.instances["autoloader"]>
		</cfif>

		<cfreturn new_("ColdIgniter\Autoloader\Autoloader")>
	</cffunction>

	<!---
	 * The file locator provides utility methods for looking for non-classes
	 * within namespaced folders, as well as convenience methods for
	 * loading 'helpers', and awareness of the namespaces.
	 *
	 * The cached locator is used when Config\Optimize says so, as in the
	 * original: only a class file of that name makes the setting known.
	--->
	<cffunction name="locator" access="public" returntype="any" output="no">
		<cfargument name="getShared" type="boolean" required="no" default="true">
		<cfset var cacheEnabled = false>

		<cfif arguments.getShared>
			<cfif NOT StructKeyExists(this.instances, "locator")>
				<!--- nested, so the class is only created when it exists --->
				<cfif class_exists("Config\Optimize")>
					<cfset cacheEnabled = new_("Config\Optimize").locatorCacheEnabled>
				</cfif>

				<cfif cacheEnabled>
					<cfset this.instances["locator"] = new_("ColdIgniter\Autoloader\FileLocatorCached", new_("ColdIgniter\Autoloader\FileLocator", this.autoloader()))>
				<cfelse>
					<cfset this.instances["locator"] = new_("ColdIgniter\Autoloader\FileLocator", this.autoloader())>
				</cfif>
			</cfif>

			<cfreturn this.instances["locator"]>
		</cfif>

		<cfreturn new_("ColdIgniter\Autoloader\FileLocator", this.autoloader())>
	</cffunction>

	<!---
	 * Provides the ability to perform case-insensitive calling of service
	 * names.
	 *
	 * @return The service, or an empty string (null) if there is none of that name.
	--->
	<cffunction name="__callStatic" access="public" returntype="any" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="arguments_" type="array" required="yes">
		<cfset var service = "">
		<cfset var factory = "">
		<cfset var target = "">
		<cfset var call = "">
		<cfset var i = 0>

		<cfloop from="1" to="#ArrayLen(arguments.arguments_)#" index="i">
			<cfset call = ListAppend(call, "arguments.arguments_[#i#]")>
		</cfloop>

		<cfif StructKeyExists(this.factories, arguments.name)>
			<cfset factory = this.factories[arguments.name]>
			<cfset target = static_(factory[1])>

			<cfreturn Evaluate("target.#factory[2]#(#call#)")>
		</cfif>

		<cfset service = serviceExists(arguments.name)>

		<cfif is_null(service)>
			<cfreturn "">
		</cfif>

		<cfset target = static_(service)>

		<cfreturn Evaluate("target.#arguments.name#(#call#)")>
	</cffunction>

	<!---
	 * Check if the requested service is defined and return the declaring
	 * class. Return an empty string (null) on not found.
	 *
	 * @return The name of the class, or an empty string (null)
	--->
	<cffunction name="serviceExists" access="public" returntype="string" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfset var services = "">
		<cfset var service = "">
		<cfset var pair = "">
		<cfset var i = 0>

		<cfset buildServicesCache()>

		<!---
		 Difference: the original ends the list with CodeIgniter\Config\Services.
		 The one object that has all the services is Config\Services here, see
		 the top of this file.
		--->
		<cfset services = ArrayNew(1)>
		<cfloop from="1" to="#ArrayLen(this.serviceNames)#" index="i">
			<cfset ArrayAppend(services, this.serviceNames[i])>
		</cfloop>
		<cfset ArrayAppend(services, "Config\Services")>
		<cfset arguments.name = LCase(arguments.name)>

		<cfloop from="1" to="#ArrayLen(services)#" index="i">
			<cfset service = services[i]>

			<cfif method_exists(static_(service), arguments.name)>
				<cfset pair = ArrayNew(1)>
				<cfset ArrayAppend(pair, service)>
				<cfset ArrayAppend(pair, arguments.name)>
				<cfset this.factories[arguments.name] = pair>

				<cfreturn service>
			</cfif>
		</cfloop>

		<cfreturn "">
	</cffunction>

	<!---
	 * Reset shared instances and mocks for testing.
	 *
	 * @param initAutoloader Initialize autoloader after reset
	--->
	<cffunction name="reset" access="public" returntype="void" output="no">
		<cfargument name="initAutoloader" type="boolean" required="no" default="true">

		<cfset this.mocks = StructNew()>
		<cfset this.instances = StructNew()>
		<cfset this.factories = StructNew()>

		<cfif arguments.initAutoloader>
			<cfset autoloader().initialize_(new_("Config\Autoload"), new_("Config\Modules"))>
		</cfif>
	</cffunction>

	<!---
	 * Resets a single service.
	 *
	 * @param name The name of the service
	--->
	<cffunction name="resetSingle" access="public" returntype="void" output="no">
		<cfargument name="name" type="string" required="yes">

		<cfset arguments.name = LCase(arguments.name)>
		<cfset StructDelete(this.mocks, arguments.name)>
		<cfset StructDelete(this.instances, arguments.name)>
	</cffunction>

	<!---
	 * Inject mock object for testing.
	 *
	 * @param name The name of the service
	 * @param mock The mock
	--->
	<cffunction name="injectMock" access="public" returntype="void" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="mock" type="any" required="yes">

		<cfset arguments.name = LCase(arguments.name)>
		<cfset this.instances[arguments.name] = arguments.mock>
		<cfset this.mocks[arguments.name] = arguments.mock>
	</cffunction>

	<!---
	 * Resets the service cache.
	--->
	<cffunction name="resetServicesCache" access="public" returntype="void" output="no">
		<cfset this.serviceNames = ArrayNew(1)>
		<cfset this.discovered = false>
	</cffunction>

	<!---
	 * Builds the cache of the service classes of the modules.
	 *
	 * Not ported yet: the search for Config/Services in the namespaces
	 * (Modules::shouldDiscover("services") and the file locator). So no
	 * other service class is found, and the services are only the ones of
	 * Config\Services.
	--->
	<cffunction name="buildServicesCache" access="private" returntype="void" output="no">
		<cfif NOT this.discovered>
			<cfset this.discovered = true>
		</cfif>
	</cffunction>

</cfcomponent>
