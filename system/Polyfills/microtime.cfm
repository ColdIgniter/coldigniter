<!---
 * Returns the current Unix timestamp with fractions, in seconds.
 *
 * Difference: only the form that gives a float (true) exists, and the
 * resolution is a millisecond, the finest clock of the platform.
--->
<cffunction name="microtime" returntype="numeric" output="no" hint="Returns the current Unix timestamp with fractions">
	<cfargument name="asFloat" type="any" required="no" default="true">

	<cfreturn CreateObject("java", "java.lang.System").currentTimeMillis() / 1000>
</cffunction>
