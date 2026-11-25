<!---
 * Exception thrown if an error which can only be found on runtime occurs.
 *
 * An exception is not an object here. Code that throws the original
 * "new RuntimeException(message)" writes, instead:
 *
 *     <cfthrow type="ColdIgniter.Exceptions.RuntimeException" message="#message#">
 *
 * Difference: the original extends \RuntimeException and implements ExceptionInterface, so a catch of that type finds it;
 * here the type is its own, and the component is kept for the file list
 * of the original (CFML cannot express it).
--->
<cfcomponent output="no" hint="Exception thrown if an error which can only be found on runtime occurs.">

</cfcomponent>
