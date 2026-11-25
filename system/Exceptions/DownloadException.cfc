<!---
 * Class DownloadException
 *
 * An exception is not an object here. The methods throw the exception
 * themselves, with the type "ColdIgniter.Exceptions.DownloadException":
 *
 *     <cfset static_("ColdIgniter\Exceptions\DownloadException").forCannotSetBinary()>
 *
 * Difference: the original extends RuntimeException, so a catch of that
 * type finds it; here the type is its own. DebugTraceableTrait is not
 * needed (see that file).
--->
<cfcomponent output="no" hint="Class DownloadException">

	<cffunction name="forCannotSetFilePath" access="public" returntype="void" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfset var parameters = ArrayNew(1)>

		<cfset ArrayAppend(parameters, arguments.path)>
		<cfthrow type="ColdIgniter.Exceptions.DownloadException" message="#lang('HTTP.cannotSetFilepath', parameters)#">
	</cffunction>

	<cffunction name="forCannotSetBinary" access="public" returntype="void" output="no">

		<cfthrow type="ColdIgniter.Exceptions.DownloadException" message="#lang('HTTP.cannotSetBinary')#">
	</cffunction>

	<cffunction name="forNotFoundDownloadSource" access="public" returntype="void" output="no">

		<cfthrow type="ColdIgniter.Exceptions.DownloadException" message="#lang('HTTP.notFoundDownloadSource')#">
	</cffunction>

	<!---
	 * @deprecated Since v4.5.6
	--->
	<cffunction name="forCannotSetCache" access="public" returntype="void" output="no">

		<cfthrow type="ColdIgniter.Exceptions.DownloadException" message="#lang('HTTP.cannotSetCache')#">
	</cffunction>

	<cffunction name="forCannotSetStatusCode" access="public" returntype="void" output="no">
		<cfargument name="code" type="numeric" required="yes">
		<cfargument name="reason" type="string" required="yes">
		<cfset var parameters = ArrayNew(1)>

		<cfset ArrayAppend(parameters, arguments.code)>
		<cfset ArrayAppend(parameters, arguments.reason)>
		<cfthrow type="ColdIgniter.Exceptions.DownloadException" message="#lang('HTTP.cannotSetStatusCode', parameters)#">
	</cffunction>

</cfcomponent>
