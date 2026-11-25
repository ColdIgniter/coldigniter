<!---
 * Test language settings
 *
 * A language file is included by the Language component, and has to
 * set the variable "lines" to a map (see array_()); that stands in for
 * the "return [...]" of the original.
--->
<cfset lines = array_()>

<cfset lines["invalidMockClass"] = """{0}"" is not a valid Mock class">
