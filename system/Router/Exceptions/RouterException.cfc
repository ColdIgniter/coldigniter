<!---
 * RouterException
 *
 * An exception is not an object here. The methods throw the exception
 * themselves, with the type "ColdIgniter.Router.Exceptions.RouterException":
 *
 *     <cfset static_("ColdIgniter\Router\Exceptions\RouterException").forInvalidRoute(route)>
 *
 * stands in for "throw RouterException::forInvalidRoute($route)".
 *
 * Difference: the original extends FrameworkException and makes an
 * exception of the class it is called on ("static"). CFML on MX 6.1 has
 * no exception classes, so the type is always the one of this class,
 * as in FrameworkException.
--->
<cfcomponent output="no" hint="RouterException">

	<!---
	 * Thrown when the actual parameter type does not match
	 * the expected types.
	--->
	<cffunction name="forInvalidParameterType" access="public" returntype="void" output="no">
		<cfthrow type="ColdIgniter.Router.Exceptions.RouterException" errorcode="500" message="#lang("Router.invalidParameter")#">
	</cffunction>

	<!---
	 * Thrown when a default route is not set.
	--->
	<cffunction name="forMissingDefaultRoute" access="public" returntype="void" output="no">
		<cfthrow type="ColdIgniter.Router.Exceptions.RouterException" errorcode="500" message="#lang("Router.missingDefaultRoute")#">
	</cffunction>

	<!---
	 * Throw when controller or its method is not found.
	--->
	<cffunction name="forControllerNotFound" access="public" returntype="void" output="no">
		<cfargument name="controller" type="string" required="yes">
		<cfargument name="method" type="string" required="yes">
		<cfset var args = ArrayNew(1)>

		<cfset ArrayAppend(args, arguments.controller)>
		<cfset ArrayAppend(args, arguments.method)>

		<cfthrow type="ColdIgniter.Router.Exceptions.RouterException" errorcode="500" message="#lang("HTTP.controllerNotFound", args)#">
	</cffunction>

	<!---
	 * Throw when route is not valid.
	--->
	<cffunction name="forInvalidRoute" access="public" returntype="void" output="no">
		<cfargument name="route" type="string" required="yes">
		<cfset var args = ArrayNew(1)>

		<cfset ArrayAppend(args, arguments.route)>

		<cfthrow type="ColdIgniter.Router.Exceptions.RouterException" errorcode="500" message="#lang("HTTP.invalidRoute", args)#">
	</cffunction>

	<!---
	 * Throw when dynamic controller.
	--->
	<cffunction name="forDynamicController" access="public" returntype="void" output="no">
		<cfargument name="handler" type="string" required="yes">
		<cfset var args = ArrayNew(1)>

		<cfset ArrayAppend(args, arguments.handler)>

		<cfthrow type="ColdIgniter.Router.Exceptions.RouterException" errorcode="500" message="#lang("Router.invalidDynamicController", args)#">
	</cffunction>

	<!---
	 * Throw when controller name has `/`.
	--->
	<cffunction name="forInvalidControllerName" access="public" returntype="void" output="no">
		<cfargument name="handler" type="string" required="yes">
		<cfset var args = ArrayNew(1)>

		<cfset ArrayAppend(args, arguments.handler)>

		<cfthrow type="ColdIgniter.Router.Exceptions.RouterException" errorcode="500" message="#lang("Router.invalidControllerName", args)#">
	</cffunction>

</cfcomponent>
