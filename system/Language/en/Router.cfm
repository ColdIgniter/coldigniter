<!---
 * Router language settings
 *
 * A language file is included by the Language component, and has to
 * set the variable "lines" to a map (see array_()); that stands in for
 * the "return [...]" of the original. The keys keep their order.
--->
<cfset lines = array_()>

<cfset lines["invalidParameter"] = "A parameter does not match the expected type.">
<cfset lines["missingDefaultRoute"] = "Unable to determine what should be displayed. A default route has not been specified in the routing file.">
<cfset lines["invalidDynamicController"] = "A dynamic controller is not allowed for security reasons. Route handler: ""{0}""">
<cfset lines["invalidControllerName"] = "The namespace delimiter is a backslash (\), not a slash (/). Route handler: ""{0}""">
