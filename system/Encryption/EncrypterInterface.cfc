<!---
 * Expected behavior of an Encryption handler.
 *
 * There are no interfaces on 6.1, so this is a base component. A handler
 * extends it, and the methods here only throw; a class that extends it has
 * to define them.
 *
 * Difference: binary data is a Java byte array (the engine drops the NUL
 * character from a string, see random_bytes()). Data given to encrypt()
 * is text (UTF-8) or a byte array; what encrypt() returns is a byte array
 * for raw data and text otherwise, and decrypt() takes the same and
 * returns the text (UTF-8) that was encrypted.
--->
<cfcomponent output="no" hint="Expected behavior of an Encryption handler">

	<!---
	 * Encrypt - convert plaintext into ciphertext
	 *
	 * @param data   Input data, text or a byte array
	 * @param params Overridden parameters, the key as text or a byte array, or a map with the member "key"; an empty string (null) for none
	 *
	 * @return The ciphertext, a byte array for raw data
	 *
	 * @throws EncryptionException
	--->
	<cffunction name="encrypt" access="public" returntype="any" output="no">
		<cfargument name="data" type="any" required="yes">
		<cfargument name="params" type="any" required="no" default="">

		<cfthrow type="ColdIgniter.Exceptions.FrameworkException" errorcode="500" message="Method not implemented by the encryption handler.">
	</cffunction>

	<!---
	 * Decrypt - convert ciphertext into plaintext
	 *
	 * @param data   Encrypted data, a byte array for raw data
	 * @param params Overridden parameters, the key as text or a byte array, or a map with the member "key"; an empty string (null) for none
	 *
	 * @return The plaintext, as text
	 *
	 * @throws EncryptionException
	--->
	<cffunction name="decrypt" access="public" returntype="any" output="no">
		<cfargument name="data" type="any" required="yes">
		<cfargument name="params" type="any" required="no" default="">

		<cfthrow type="ColdIgniter.Exceptions.FrameworkException" errorcode="500" message="Method not implemented by the encryption handler.">
	</cffunction>

</cfcomponent>
