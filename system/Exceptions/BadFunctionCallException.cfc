<!---
 * Exception thrown if a function is called in the wrong way, or the function does not exist.
 *
 * An exception is not an object here. Code that throws the original
 * "new BadFunctionCallException(message)" writes, instead:
 *
 *     <cfthrow type="ColdIgniter.Exceptions.BadFunctionCallException" message="#message#">
 *
 * Difference: the original extends \BadFunctionCallException and implements ExceptionInterface, so a catch of that type finds it;
 * here the type is its own, and the component is kept for the file list
 * of the original (CFML cannot express it).
--->
<cfcomponent output="no" hint="Exception thrown if a function is called in the wrong way, or the function does not exist.">

</cfcomponent>
