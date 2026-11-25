<!---
 * Exception that represents error in the program logic.
 *
 * An exception is not an object here. Code that throws the original
 * "new LogicException(message)" writes, instead:
 *
 *     <cfthrow type="ColdIgniter.Exceptions.LogicException" message="#message#">
 *
 * Difference: the original extends \LogicException and implements ExceptionInterface, so a catch of that type finds it;
 * here the type is its own, and the component is kept for the file list
 * of the original (CFML cannot express it).
--->
<cfcomponent output="no" hint="Exception that represents error in the program logic.">

</cfcomponent>
