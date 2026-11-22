<!---
 * Superglobals manipulation.
 *
 * Provides a clean API for accessing and manipulating the request
 * values, with automatic synchronization of state.
 *
 * The server values are read from the CGI scope, which cannot be
 * changed: a value set here is kept in this object only.
 *
 * Not ported yet: the get, post, cookie, files and request arrays.
--->
<cfcomponent output="no" hint="Superglobals manipulation">

	<!--- The server array. Named with an underscore, because server() is a method. --->
	<cfset this.server_ = StructNew()>

	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="server" type="any" required="no" default="">
		<cfargument name="get" type="any" required="no" default="">
		<cfargument name="post" type="any" required="no" default="">
		<cfargument name="cookie" type="any" required="no" default="">
		<cfargument name="files" type="any" required="no" default="">
		<cfargument name="request_" type="any" required="no" default="">

		<cfif NOT is_null(arguments.server)>
			<cfset this.server_ = arguments.server>
		</cfif>

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

		<cfset value = CGI[arguments.key]>

		<!--- The web server gives the path without the query string. --->
		<cfif arguments.key EQ "REQUEST_URI">
			<cfif value EQ "">
				<cfset value = CGI.PATH_INFO>
			</cfif>
			<cfif CGI.QUERY_STRING NEQ "">
				<cfset value = value & "?" & CGI.QUERY_STRING>
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

</cfcomponent>
