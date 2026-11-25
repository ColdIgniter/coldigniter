<!---
 * Expected behavior of a Throttler
 *
 * There are no interfaces on 6.1, so this is a base component. A throttler
 * extends it (Throttler does), and it has to define the methods. The methods
 * here only throw.
--->
<cfcomponent output="no" hint="Expected behavior of a Throttler">

	<!---
	 * Restricts the number of requests made by a single key within
	 * a set number of seconds.
	 *
	 * Example:
	 *
	 *  if (NOT throttler.checkIPAddress(request.ipAddress(), 60, MINUTE))
	 * {
	 *      abort;
	 * }
	 *
	 * @param key      The name to use as the "bucket" name.
	 * @param capacity The number of requests the "bucket" can hold
	 * @param seconds  The time it takes the "bucket" to completely refill
	 * @param cost     The number of tokens this action uses.
	--->
	<cffunction name="check" access="public" returntype="boolean" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="capacity" type="numeric" required="yes">
		<cfargument name="seconds" type="numeric" required="yes">
		<cfargument name="cost" type="numeric" required="yes">

		<cfthrow type="ColdIgniter.LogicException" message="The throttler does not define check().">
	</cffunction>

	<!---
	 * Returns the number of seconds until the next available token will
	 * be released for usage.
	--->
	<cffunction name="getTokenTime" access="public" returntype="numeric" output="no">
		<cfthrow type="ColdIgniter.LogicException" message="The throttler does not define getTokenTime().">
	</cffunction>

</cfcomponent>
