<!---
 * Format exceptions.
 *
 * An exception is not an object here. The methods throw the exception
 * themselves, with the type "ColdIgniter.Format.Exceptions.FormatException":
 *
 *     <cfset static_("ColdIgniter\Format\Exceptions\FormatException").forInvalidMime(mime)>
 *
 * The messages come from the language file Language/en/Format.cfm.
 *
 * Not ported yet: DebugTraceableTrait.
--->
<cfcomponent output="no" hint="Format exceptions">

	<cffunction name="forInvalidFormatter" access="public" returntype="void" output="no">
		<cfargument name="class" type="string" required="yes">

		<cfthrow type="ColdIgniter.Format.Exceptions.FormatException" errorcode="500" message="#lang('Format.invalidFormatter', array_(arguments.class))#">
	</cffunction>

	<cffunction name="forInvalidJSON" access="public" returntype="void" output="no">
		<cfargument name="error" type="any" required="no" default="">

		<cfthrow type="ColdIgniter.Format.Exceptions.FormatException" errorcode="500" message="#lang('Format.invalidJSON', array_(arguments.error))#">
	</cffunction>

	<cffunction name="forInvalidMime" access="public" returntype="void" output="no">
		<cfargument name="mime" type="string" required="yes">

		<cfthrow type="ColdIgniter.Format.Exceptions.FormatException" errorcode="500" message="#lang('Format.invalidMime', array_(arguments.mime))#">
	</cffunction>

	<cffunction name="forInvalidXMLValue" access="public" returntype="void" output="no">
		<cfargument name="type" type="string" required="yes">

		<cfthrow type="ColdIgniter.Format.Exceptions.FormatException" errorcode="500" message="#lang('Format.invalidXMLValue', array_(arguments.type))#">
	</cffunction>

	<cffunction name="forMissingExtension" access="public" returntype="void" output="no">

		<cfthrow type="ColdIgniter.Format.Exceptions.FormatException" errorcode="500" message="#lang('Format.missingExtension')#">
	</cffunction>

</cfcomponent>
