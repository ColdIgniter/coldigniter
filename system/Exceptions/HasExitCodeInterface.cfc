<!---
 * Interface for Exceptions that has exception code as exit code.
 *
 * There are no interfaces on 6.1, so this is a base component with the
 * one method, which only throws. An exception is not an object here, so
 * nothing extends it: the components of the types that implement it in
 * the original define getExitCode(), and Debug/Exceptions.cfc
 * determineCodes() lists the types and calls it.
--->
<cfcomponent output="no" hint="Interface for Exceptions that has exception code as exit code">

	<!---
	 * Returns exit status code.
	--->
	<cffunction name="getExitCode" access="public" returntype="numeric" output="no">
		<cfthrow type="ColdIgniter.Exceptions.LogicException" message="The exception does not define getExitCode().">
	</cffunction>

</cfcomponent>
