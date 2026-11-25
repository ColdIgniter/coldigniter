<!---
 * Error: Critical conditions, like component unavailable, etc.
 *
 * An exception is not an object here. Code that throws the original
 * "new CriticalError(message)" writes, instead:
 *
 *     <cfthrow type="ColdIgniter.Exceptions.CriticalError" message="#message#">
 *
 * Difference: the original extends RuntimeException, so a catch of that type finds it;
 * here the type is its own, and the component is kept for the file list
 * of the original (CFML cannot express it).
--->
<cfcomponent output="no" hint="Error: Critical conditions, like component unavailable, etc.">

</cfcomponent>
