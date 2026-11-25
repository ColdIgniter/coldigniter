<!---
 * Expected behavior for an exception handler
 *
 * There are no interfaces on 6.1, so this is a base component with the
 * one method, which only throws. A handler defines handle().
--->
<cfcomponent output="no" hint="Expected behavior for an exception handler">

	<!---
	 * Determines the correct way to display the error.
	 *
	 * @param exception The cfcatch struct
	 * @param request_  The IncomingRequest
	--->
	<cffunction name="handle" access="public" returntype="void" output="no">
		<cfargument name="exception" type="any" required="yes">
		<cfargument name="request_" type="any" required="yes">
		<cfargument name="response" type="any" required="yes">
		<cfargument name="statusCode" type="numeric" required="yes">
		<cfargument name="exitCode" type="numeric" required="yes">

		<cfthrow type="ColdIgniter.Exceptions.LogicException" message="The handler does not define handle().">
	</cffunction>

</cfcomponent>
