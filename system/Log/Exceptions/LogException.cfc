<!---
 * Class LogException
 *
 * Not ported yet: the messages come from the language files in the
 * original (Log.invalidLogLevel and Log.invalidMessageType); they are
 * written out here until the language service is ported.
 *
 * An exception is not an object here. The methods throw the exception
 * themselves, with the type "ColdIgniter.Log.Exceptions.LogException":
 *
 *     <cfset static_("ColdIgniter\Log\Exceptions\LogException").forInvalidLogLevel(level)>
 *
 * Difference: forNoHandlers() is the method of FrameworkException, which
 * this class extends, and throws that type.
--->
<cfcomponent output="no" parent="ColdIgniter\Exceptions\FrameworkException" hint="Log exceptions">

	<cffunction name="forInvalidLogLevel" access="public" returntype="void" output="no">
		<cfargument name="level" type="string" required="yes">

		<cfthrow type="ColdIgniter.Log.Exceptions.LogException" errorcode="500" message="""#arguments.level#"" is an invalid log level.">
	</cffunction>

	<cffunction name="forInvalidMessageType" access="public" returntype="void" output="no">
		<cfargument name="messageType" type="string" required="yes">

		<cfthrow type="ColdIgniter.Log.Exceptions.LogException" errorcode="500" message="The given message type ""#arguments.messageType#"" is not supported.">
	</cffunction>

</cfcomponent>
