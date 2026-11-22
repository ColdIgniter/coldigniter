<!---
 * Class BaseConfig
 *
 * Not completely abstract, but should be used as the base class for
 * any config code.
 *
 * Not ported yet: values from the environment (.env), registrars,
 * and the config cache (__set_state).
--->
<cfcomponent output="no" hint="The base class for any config code">

	<!---
	 * Will attempt to get environment variables with names
	 * that match the properties of the child class.
	 *
	 * The "shortPrefix" is the lowercase-only config class name.
	--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfreturn this>
	</cffunction>

</cfcomponent>
