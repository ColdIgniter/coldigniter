<!---
 * Exception thrown when there is an error with the test code.
 *
 * An exception is not an object here. The method throws the exception
 * itself, with the type "ColdIgniter.Exceptions.TestException":
 *
 *     <cfset static_("ColdIgniter\Exceptions\TestException").forInvalidMockClass(name)>
 *
 * Difference: the original extends LogicException, so a catch of that
 * type finds it; here the type is its own. DebugTraceableTrait is not
 * needed (see that file).
--->
<cfcomponent output="no" hint="Exception thrown when there is an error with the test code">

	<cffunction name="forInvalidMockClass" access="public" returntype="void" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfset var parameters = ArrayNew(1)>

		<cfset ArrayAppend(parameters, arguments.name)>
		<cfthrow type="ColdIgniter.Exceptions.TestException" message="#lang('Test.invalidMockClass', parameters)#">
	</cffunction>

</cfcomponent>
