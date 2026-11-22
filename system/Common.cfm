<!---
 * Common Functions
 *
 * Several application-wide utility methods.
 *
 * Not ported yet: every function that is not listed below.
--->

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
