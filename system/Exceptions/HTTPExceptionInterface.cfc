<!---
 * Interface for Exceptions that has exception code as HTTP status code.
 *
 * There are no interfaces on 6.1, so this is an empty base component. An
 * exception is not an object here, so nothing extends it: the types that
 * implement it in the original are listed in Debug/Exceptions.cfc
 * determineCodes(), and their error code is the status code.
--->
<cfcomponent output="no" hint="Interface for Exceptions that has exception code as HTTP status code">

</cfcomponent>
