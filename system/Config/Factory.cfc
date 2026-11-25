<!---
 * Factories Configuration file.
 *
 * Provides overriding directives for how
 * Factories should handle discovery and
 * instantiation of specific components.
 * Each property should correspond to the
 * lowercase, plural component name.
 *
 * The arrays are structs, read and written with brackets.
 *
 * Difference: platform. A struct cannot hold null, so the options that are
 * null in the original (component, path, instanceOf) are an empty string.
--->
<cfcomponent output="no" extends="BaseConfig" hint="Factories Configuration file">

	<!---
	 * Supplies a default set of options to merge for
	 * all unspecified factory components.
	 *
	 * The property is static in the original ($default); it is read as
	 * static_("ColdIgniter\Config\Factory")["default"].
	--->
	<cfset this["default"] = StructNew()>
	<cfset this["default"]["component"] = "">
	<cfset this["default"]["path"] = "">
	<cfset this["default"]["instanceOf"] = "">
	<cfset this["default"]["getShared"] = true>
	<cfset this["default"]["preferApp"] = true>

	<!---
	 * Specifies that Models should always favor child
	 * classes to allow easy extension of module Models.
	--->
	<cfset this.models = StructNew()>
	<cfset this.models["preferApp"] = true>

</cfcomponent>
