<!---
 * Returns the one object that stands in for a class with static
 * members: static_("Config\Services").autoloader() stands in for
 * Services::autoloader().
 *
 * The object is created once per request, without __construct().
--->
<cffunction name="static_" returntype="any" output="no" hint="Returns the one object that stands in for a class with static members">
	<cfargument name="class" type="string" required="yes">
	<cfset var key = REReplace(arguments.class, "^\\+", "")>

	<cfif NOT StructKeyExists(request.CodeIgniter.statics, key)>
		<cfset request.CodeIgniter.statics[key] = request.CodeIgniter.autoloader.instantiate(key)>
	</cfif>

	<cfreturn request.CodeIgniter.statics[key]>
</cffunction>
