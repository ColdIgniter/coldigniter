<!---
 * Class BaseConfig
 *
 * Not completely abstract, but should be used as the base class for
 * any config code.
 *
 * Not intended to be used on its own, this class will attempt to
 * automatically populate the child class' properties with values
 * from the environment.
 *
 * These can be set within the .env file. The values live in
 * request.ColdIgniter.env (see Config/DotEnv.cfc), where $_ENV and
 * $_SERVER of the original are one struct.
 *
 * Difference: the properties of the object are found by looping over
 * "this", which gives every name in upper case. A name from the .env file
 * is matched without regard to case, so this does not matter. A function
 * is not a property and is skipped, so are the names that start with "__".
 *
 * Difference: there is no null, so getEnvValue() returns a list that is
 * empty when there is no value, and has the value as its only element.
 *
 * Difference: the prefix is the name of the class as the server knows it,
 * for a class of the application "Config\Logger".
 *
 * Not ported yet: the registrars (registrars, override, didDiscovery,
 * registerProperties, setModules and reset), the config cache
 * (__set_state), and the keys of an Encryption class (parseEncryptionKey
 * with the hex2bin: and base64: prefixes), the Encryption config is not
 * ported yet.
--->
<cfcomponent output="no" hint="The base class for any config code">

	<!---
	 * An optional array of classes that will act as Registrars
	 * for rapidly setting config class properties.
	 *
	 * Not ported yet: the registrars
	--->

	<!---
	 * Will attempt to get environment variables with names
	 * that match the properties of the child class.
	 *
	 * The "shortPrefix" is the lowercase-only config class name.
	--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfset var properties = ArrayNew(1)>
		<cfset var property = "">
		<cfset var prefix = this.__class>
		<cfset var shortPrefix = LCase(ListLast(prefix, "\"))>
		<cfset var i = 0>

		<!--- Not ported yet: static::$moduleConfig and registerProperties() --->

		<cfloop collection="#this#" item="property">
			<cfif Compare(Left(property, 2), "__") NEQ 0 AND NOT IsCustomFunction(this[property])>
				<cfset ArrayAppend(properties, property)>
			</cfif>
		</cfloop>

		<cfloop from="1" to="#ArrayLen(properties)#" index="i">
			<cfset this[properties[i]] = initEnvValue(this[properties[i]], properties[i], prefix, shortPrefix)>

			<!--- Not ported yet: the keys of an Encryption class, parseEncryptionKey() --->
		</cfloop>

		<cfreturn this>
	</cffunction>

	<!---
	 * Initialization an environment-specific configuration setting
	 *
	 * Difference: there are no references, so the new value of the
	 * property is returned, and the caller assigns it.
	 *
	 * @param property A string, a number, a boolean, or a list or map of them
	 *
	 * @return The property, with the value of the environment when there is one
	--->
	<cffunction name="initEnvValue" access="private" returntype="any" output="no">
		<cfargument name="property" type="any" required="yes">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="prefix" type="string" required="yes">
		<cfargument name="shortPrefix" type="string" required="yes">
		<cfset var key = "">
		<cfset var keys = ArrayNew(1)>
		<cfset var found = "">
		<cfset var value = "">
		<cfset var list = ArrayNew(1)>
		<cfset var i = 0>

		<cfif IsArray(arguments.property)>
			<!--- an array is not copied on the way in, so a new one is built --->
			<cfloop from="1" to="#ArrayLen(arguments.property)#" index="i">
				<cfset ArrayAppend(list, initEnvValue(arguments.property[i], arguments.name & "." & (i - 1), arguments.prefix, arguments.shortPrefix))>
			</cfloop>

			<cfreturn list>
		</cfif>

		<cfif IsStruct(arguments.property)>
			<cfloop collection="#arguments.property#" item="key">
				<cfset ArrayAppend(keys, key)>
			</cfloop>

			<cfloop from="1" to="#ArrayLen(keys)#" index="i">
				<cfset arguments.property[keys[i]] = initEnvValue(arguments.property[keys[i]], arguments.name & "." & keys[i], arguments.prefix, arguments.shortPrefix)>
			</cfloop>

			<cfreturn arguments.property>
		</cfif>

		<cfset found = getEnvValue(arguments.name, arguments.prefix, arguments.shortPrefix)>

		<cfif ArrayLen(found) EQ 0>
			<cfreturn arguments.property>
		</cfif>

		<cfset value = found[1]>

		<!--- Difference: Compare() is used, since CFML equality treats "yes" as true and "no" as false --->
		<cfif Compare(value, "false") EQ 0>
			<cfreturn false>
		<cfelseif Compare(value, "true") EQ 0>
			<cfreturn true>
		</cfif>

		<cfset value = trim_(value, "'""")>

		<!--- is_int() and is_float() --->
		<cfif IsNumeric(arguments.property) AND arguments.property.getClass().getName() NEQ "java.lang.Boolean">
			<cfif Int(arguments.property) EQ arguments.property>
				<cfset value = Int(Val(value))>
			<cfelse>
				<cfset value = Val(value)>
			</cfif>
		</cfif>

		<cfreturn value>
	</cffunction>

	<!---
	 * Retrieve an environment-specific configuration setting
	 *
	 * @return A list with the value, or an empty list
	--->
	<cffunction name="getEnvValue" access="private" returntype="array" output="no">
		<cfargument name="property" type="string" required="yes">
		<cfargument name="prefix" type="string" required="yes">
		<cfargument name="shortPrefix" type="string" required="yes">
		<cfset var result = ArrayNew(1)>
		<cfset var underscoreProperty = Replace(arguments.property, ".", "_", "all")>
		<cfset var candidates = ArrayNew(1)>
		<cfset var i = 0>

		<cfset arguments.shortPrefix = ltrim_(arguments.shortPrefix, "\")>

		<!--- $_ENV and $_SERVER are the same struct, so each name is looked up once --->
		<cfset ArrayAppend(candidates, arguments.shortPrefix & "." & arguments.property)>
		<cfset ArrayAppend(candidates, arguments.shortPrefix & "_" & underscoreProperty)>
		<cfset ArrayAppend(candidates, arguments.prefix & "." & arguments.property)>
		<cfset ArrayAppend(candidates, arguments.prefix & "_" & underscoreProperty)>

		<cfloop from="1" to="#ArrayLen(candidates)#" index="i">
			<cfif StructKeyExists(request.ColdIgniter.env, candidates[i])>
				<cfset ArrayAppend(result, request.ColdIgniter.env[candidates[i]])>

				<cfreturn result>
			</cfif>
		</cfloop>

		<cfreturn result>
	</cffunction>

</cfcomponent>
