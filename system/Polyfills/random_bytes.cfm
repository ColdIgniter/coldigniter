<!---
 * Generates cryptographically secure random bytes, as a byte array (see
 * bin2hex()). The bytes come from java.security.SecureRandom.
--->
<cffunction name="random_bytes" returntype="any" output="no" hint="Generates cryptographically secure random bytes">
	<cfargument name="length" type="numeric" required="yes">
	<cfset var random = CreateObject("java", "java.security.SecureRandom").init()>
	<cfset var bytes = "">

	<cfif arguments.length LT 1>
		<cfthrow type="ColdIgniter.ValueError" message="random_bytes(): Argument ##1 ($length) must be greater than 0">
	</cfif>

	<!--- an array of the right size to fill; the string holds ASCII only --->
	<cfset bytes = JavaCast("string", RepeatString("x", arguments.length)).getBytes()>
	<cfset random.nextBytes(bytes)>

	<cfreturn bytes>
</cffunction>
