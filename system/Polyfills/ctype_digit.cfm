<!---
 * Checks for numeric characters: true when the string is not empty and
 * has only the digits 0 to 9.
 *
 * Difference: a number is not accepted as it is in the original (an
 * integer between -128 and 255 is read as a character code); every value
 * is text here, so it is always checked as text.
--->
<cffunction name="ctype_digit" returntype="boolean" output="no" hint="Checks for numeric characters">
	<cfargument name="text" type="string" required="yes">

	<!--- one class with one quantifier, so a long string is read once --->
	<cfreturn Len(arguments.text) GT 0 AND REFind("^[0-9]+$", arguments.text) GT 0>
</cffunction>
