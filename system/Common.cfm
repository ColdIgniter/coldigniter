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
 * Not ported yet: arrays as data, the "js" and "css" contexts and the
 * encoding (the Escaper library is not ported).
 *
 * @param data     The string
 * @param context  'attr', 'html', 'raw' or 'url'
--->
<cffunction name="esc" returntype="any" output="no" hint="Performs simple auto-escaping of data for security reasons">
	<cfargument name="data" type="any" required="yes">
	<cfargument name="context" type="string" required="no" default="html">
	<cfargument name="encoding" type="string" required="no" default="">

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
		<cfif NOT ListFind("html,attr,url", arguments.context)>
			<cfthrow type="ColdIgniter.InvalidArgumentException" message="Invalid escape context provided.">
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
