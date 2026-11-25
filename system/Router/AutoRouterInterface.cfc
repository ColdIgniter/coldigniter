<!---
 * Expected behavior of a AutoRouter.
 *
 * Difference: there are no interfaces; this component holds the method,
 * which throws, and AutoRouterImproved extends it (a), as in
 * SessionInterface.
--->
<cfcomponent output="no" hint="Expected behavior of a AutoRouter">

	<!---
	 * Returns the directory name, controller name, controller method, and any parameters for the given URI and HTTP verb.
	 *
	 * @param httpVerb HTTP verb like `GET`,`POST`
	 *
	 * @return An array of the directory ("" for none), the controller, the method and the parameters (an array)
	--->
	<cffunction name="getRoute" access="public" returntype="array" output="no">
		<cfargument name="uri" type="string" required="yes">
		<cfargument name="httpVerb" type="string" required="yes">

		<cfthrow type="ColdIgniter.Exceptions.FrameworkException" errorcode="500" message="Method not implemented by the auto router.">
	</cffunction>

</cfcomponent>
