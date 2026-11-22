<!---
 * Security exceptions.
 *
 * Not ported yet: the methods of the original that are not listed below
 * (the CSRF ones and the others), and the messages come from the language
 * files in the original; they are written out here until the language
 * service is ported.
 *
 * An exception is not an object here. The methods throw the exception
 * themselves, with the type "ColdIgniter.Security.Exceptions.SecurityException":
 *
 *     <cfset static_("ColdIgniter\Security\Exceptions\SecurityException").forInvalidControlChars(source, string)>
--->
<cfcomponent output="no" hint="Security exceptions">

	<!---
	 * HTTP status code
	--->
	<cfset this.code = 400>

	<!---
	 * Thrown when the string is not valid UTF-8.
	--->
	<cffunction name="forInvalidUTF8Chars" access="public" returntype="void" output="no">
		<cfargument name="source" type="string" required="yes">
		<cfargument name="string" type="string" required="yes">

		<cfthrow type="ColdIgniter.Security.Exceptions.SecurityException" errorcode="#this.code#" message="Invalid UTF-8 characters in #arguments.source#: #arguments.string#">
	</cffunction>

	<!---
	 * Thrown when the string has control characters other than line breaks and tabs.
	--->
	<cffunction name="forInvalidControlChars" access="public" returntype="void" output="no">
		<cfargument name="source" type="string" required="yes">
		<cfargument name="string" type="string" required="yes">

		<cfthrow type="ColdIgniter.Security.Exceptions.SecurityException" errorcode="#this.code#" message="Invalid Control characters in #arguments.source#: #arguments.string#">
	</cffunction>

</cfcomponent>
