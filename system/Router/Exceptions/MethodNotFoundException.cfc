<!---
 * MethodNotFoundException
 *
 * @internal
 *
 * An exception is not an object here. AutoRouterImproved throws it with
 * the type "ColdIgniter.Router.Exceptions.MethodNotFoundException" and
 * catches it by that type.
--->
<cfcomponent output="no" hint="MethodNotFoundException">

	<cffunction name="forMethodNotFound" access="public" returntype="void" output="no">
		<cfthrow type="ColdIgniter.Router.Exceptions.MethodNotFoundException" errorcode="500" message="Method not found.">
	</cffunction>

</cfcomponent>
