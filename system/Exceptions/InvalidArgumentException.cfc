<!---
 * Exception thrown if an argument is not of the expected type.
 *
 * An exception is not an object here. Code that throws the original
 * "new InvalidArgumentException(message)" writes, instead:
 *
 *     <cfthrow type="ColdIgniter.Exceptions.InvalidArgumentException" message="#message#">
 *
 * Difference: the original extends \InvalidArgumentException and implements ExceptionInterface, so a catch of that type finds it;
 * here the type is its own, and the component is kept for the file list
 * of the original (CFML cannot express it).
--->
<cfcomponent output="no" hint="Exception thrown if an argument is not of the expected type.">

</cfcomponent>
