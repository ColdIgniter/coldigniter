<!---
 * Cache exceptions.
 *
 * An exception is not an object here. The methods throw the exception
 * themselves, with the type "ColdIgniter.Cache.Exceptions.CacheException":
 *
 *     <cfset static_("ColdIgniter\Cache\Exceptions\CacheException").forUnableToWrite(path)>
 *
 * The messages come from the language file Language/en/Cache.cfm.
 *
 * Not ported yet: DebugTraceableTrait.
--->
<cfcomponent output="no" hint="Cache exceptions">

	<cffunction name="forUnableToWrite" access="public" returntype="void" output="no">
		<cfargument name="path" type="string" required="yes">

		<cfthrow type="ColdIgniter.Cache.Exceptions.CacheException" errorcode="500" message="#lang('Cache.unableToWrite', array_(arguments.path))#">
	</cffunction>

	<cffunction name="forInvalidHandlers" access="public" returntype="void" output="no">

		<cfthrow type="ColdIgniter.Cache.Exceptions.CacheException" errorcode="500" message="#lang('Cache.invalidHandlers')#">
	</cffunction>

	<cffunction name="forNoBackup" access="public" returntype="void" output="no">

		<cfthrow type="ColdIgniter.Cache.Exceptions.CacheException" errorcode="500" message="#lang('Cache.noBackup')#">
	</cffunction>

	<cffunction name="forHandlerNotFound" access="public" returntype="void" output="no">

		<cfthrow type="ColdIgniter.Cache.Exceptions.CacheException" errorcode="500" message="#lang('Cache.handlerNotFound')#">
	</cffunction>

</cfcomponent>
