<!---
 * Representation of an incoming, server-side HTTP request.
 *
 * Not ported yet: getIPAddress, getEnv, setGlobal, fetchGlobal and the
 * filters of getServer.
--->
<cfcomponent output="no" extends="OutgoingRequest" hint="Representation of an incoming, server-side HTTP request">

	<!---
	 * Constructor.
	 *
	 * @param config
	--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="config" type="any" required="no" default="">

		<cfif this.method EQ "">
			<cfset this.method = getServer("REQUEST_METHOD")>
			<cfif is_null(this.method)>
				<cfset this.method = "GET">
			</cfif>
		</cfif>

		<cfif is_null(this.uri)>
			<cfset this.uri = new_("ColdIgniter\HTTP\URI")>
		</cfif>

		<cfreturn this>
	</cffunction>

	<!---
	 * Sets the request method. Used when spoofing the request.
	--->
	<cffunction name="setMethod" access="public" returntype="any" output="no">
		<cfargument name="method" type="string" required="yes">

		<cfset this.method = arguments.method>

		<cfreturn this>
	</cffunction>

	<!---
	 * Fetch an item from the server array.
	 *
	 * @param index Index for item to be fetched from the server values
	--->
	<cffunction name="getServer" access="public" returntype="any" output="no">
		<cfargument name="index" type="string" required="yes">

		<cfreturn service("superglobals").server(arguments.index)>
	</cffunction>

</cfcomponent>
