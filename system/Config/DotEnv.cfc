<!---
 * Environment-specific configuration
 *
 * Where the values live: the original puts them in getenv(), $_ENV and
 * $_SERVER. There is no process environment to write to here, so the
 * values live in one struct, request.ColdIgniter.env, and env() and the
 * config classes read it. A name is not case-sensitive (like a name in the
 * environment of Windows), which a struct does by itself.
 *
 * Difference: the original also writes putenv(). Not ported yet: a value
 * that is set in the environment of the server process is not read.
 *
 * Difference: an exception is a thrown error here. The error of an
 * unquoted value with spaces has the type
 * "ColdIgniter.Exceptions.InvalidArgumentException".
 *
 * Difference: there is no null, so a variable that is not set and a
 * variable with an empty value are the same to a nested ${name}.
--->
<cfcomponent output="no" hint="Environment-specific configuration">

	<!---
	 * The directory where the .env file can be located.
	 *
	 * @var string
	--->
	<cfset this.path = "">

	<!---
	 * Builds the path to our file.
	--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfargument name="file" type="string" required="no" default=".env">

		<cfset this.path = rtrim_(arguments.path, request.DIRECTORY_SEPARATOR) & request.DIRECTORY_SEPARATOR & arguments.file>

		<cfreturn this>
	</cffunction>

	<!---
	 * The main entry point, will load the .env file and process it
	 * so that we end up with all settings in the environment values
	 * (request.ColdIgniter.env, see the top of this file)
	--->
	<cffunction name="load" access="public" returntype="boolean" output="no">
		<cfset var vars = parse()>

		<cfreturn NOT is_null(vars)>
	</cffunction>

	<!---
	 * Parse the .env file into a map of key => value
	 *
	 * @return A map, or an empty string when there is no file
	--->
	<cffunction name="parse" access="public" returntype="any" output="no">
		<cfset var content = "">
		<cfset var lines = ArrayNew(1)>
		<cfset var vars = "">
		<cfset var parts = "">
		<cfset var line = "">
		<cfset var i = 0>

		<!--- We don't want to enforce the presence of a .env file, they should be optional. --->
		<cfif NOT is_file(this.path)>
			<cfreturn "">
		</cfif>

		<cftry>
			<cffile action="read" file="#this.path#" variable="content" charset="utf-8">

			<cfcatch type="any">
				<cfthrow type="ColdIgniter.Exceptions.InvalidArgumentException" message="The .env file is not readable: #this.path#">
			</cfcatch>
		</cftry>

		<!--- FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES --->
		<cfset lines = explode(Chr(10), Replace(content, Chr(13), "", "all"))>

		<cfset vars = array_()>

		<cfloop from="1" to="#ArrayLen(lines)#" index="i">
			<cfset line = lines[i]>

			<!--- Is it a comment? An empty line is skipped like one. --->
			<cfif line NEQ "" AND Left(trim_(line), 1) NEQ "##">
				<!--- If there is an equal sign, then we know we are assigning a variable. --->
				<cfif Find("=", line) GT 0>
					<cfset parts = normaliseVariable(line)>
					<cfset vars[parts[1]] = parts[2]>
					<cfset setVariable_(parts[1], parts[2])>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn vars>
	</cffunction>

	<!---
	 * Sets the variable into the environment. Will parse the string
	 * first to look for {name}={value} pattern, ensure that nested
	 * variables are handled, and strip it of single and double quotes.
	 *
	 * Not ported yet: putenv()
	--->
	<cffunction name="setVariable_" access="private" returntype="void" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="value" type="string" required="no" default="">

		<!--- $_ENV and $_SERVER are one struct here --->
		<cfif NOT StructKeyExists(request.ColdIgniter.env, arguments.name) OR request.ColdIgniter.env[arguments.name] EQ "" OR request.ColdIgniter.env[arguments.name] EQ "0">
			<cfset request.ColdIgniter.env[arguments.name] = arguments.value>
		</cfif>
	</cffunction>

	<!---
	 * Parses for assignment, cleans the $name and $value, and ensures
	 * that nested variables are handled.
	 *
	 * @return A list of two: the name and the value
	--->
	<cffunction name="normaliseVariable" access="public" returntype="array" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="value" type="string" required="no" default="">
		<cfset var parts = ArrayNew(1)>
		<cfset var result = ArrayNew(1)>

		<!--- Split our compound string into its parts. --->
		<cfif Find("=", arguments.name) GT 0>
			<cfset parts = explode("=", arguments.name, 2)>
			<cfset arguments.name = parts[1]>
			<cfset arguments.value = parts[2]>
		</cfif>

		<cfset arguments.name = trim_(arguments.name)>
		<cfset arguments.value = trim_(arguments.value)>

		<!--- Sanitize the name --->
		<cfset arguments.name = JavaCast("string", arguments.name).replaceAll("^export[ \t]++(\S+)", "$1")>
		<cfset arguments.name = Replace(Replace(arguments.name, "'", "", "all"), """", "", "all")>

		<!--- Sanitize the value --->
		<cfset arguments.value = sanitizeValue(arguments.value)>
		<cfset arguments.value = resolveNestedVariables(arguments.value)>

		<cfset ArrayAppend(result, arguments.name)>
		<cfset ArrayAppend(result, arguments.value)>

		<cfreturn result>
	</cffunction>

	<!---
	 * Strips quotes from the environment variable value.
	 *
	 * This was borrowed from the excellent dotenv library by vlucas with very few changes.
	 *
	 * @throws InvalidArgumentException
	--->
	<cffunction name="sanitizeValue" access="private" returntype="string" output="no">
		<cfargument name="value" type="string" required="yes">
		<cfset var quote = "">
		<cfset var regexPattern = "">
		<cfset var parts = ArrayNew(1)>

		<cfif arguments.value EQ "">
			<cfreturn arguments.value>
		</cfif>

		<!--- Does it begin with a quote? --->
		<cfif Find(Left(arguments.value, 1), "'""") GT 0>
			<!--- value starts with a quote --->
			<cfset quote = Left(arguments.value, 1)>

			<!---
			 The pattern of the original, without its comments:
			 a quote at the start, then any character other than a quote
			 or backslash, or two backslashes together, or an escaped quote,
			 as many as match, then the closing quote, and any string after
			 the closing quote is discarded.
			--->
			<cfset regexPattern = "^" & quote & "((?:[^" & quote & "\\]|\\\\|\\" & quote & ")*)" & quote & ".*$">

			<cfset arguments.value = JavaCast("string", arguments.value).replaceAll(regexPattern, "$1")>
			<cfset arguments.value = Replace(arguments.value, "\" & quote, quote, "all")>
			<cfset arguments.value = Replace(arguments.value, "\\", "\", "all")>
		<cfelse>
			<cfset parts = explode(" ##", arguments.value, 2)>
			<cfset arguments.value = trim_(parts[1])>

			<!--- Unquoted values cannot contain whitespace --->
			<cfif REFind("[[:space:]]", arguments.value) GT 0>
				<cfthrow type="ColdIgniter.Exceptions.InvalidArgumentException" message=".env values containing spaces must be surrounded by quotes.">
			</cfif>
		</cfif>

		<cfreturn arguments.value>
	</cffunction>

	<!---
	 *  Resolve the nested variables.
	 *
	 * Look for ${varname} patterns in the variable value and replace with an existing
	 * environment variable.
	 *
	 * This was borrowed from the excellent dotenv library by vlucas with very few changes.
	--->
	<cffunction name="resolveNestedVariables" access="private" returntype="string" output="no">
		<cfargument name="value" type="string" required="yes">
		<cfset var result = "">
		<cfset var position = 1>
		<cfset var found = "">
		<cfset var matchedName = "">
		<cfset var nestedVariable = "">

		<cfif Find("$", arguments.value) EQ 0>
			<cfreturn arguments.value>
		</cfif>

		<!--- preg_replace_callback --->
		<cfloop condition="true">
			<cfset found = REFind("\$\{([a-zA-Z0-9_.]+)\}", arguments.value, position, true)>

			<cfif found.pos[1] EQ 0>
				<cfbreak>
			</cfif>

			<cfset result = result & Mid(arguments.value, position, found.pos[1] - position)>
			<cfset matchedName = Mid(arguments.value, found.pos[2], found.len[2])>
			<cfset nestedVariable = getVariable(matchedName)>

			<cfif is_null(nestedVariable)>
				<cfset result = result & Mid(arguments.value, found.pos[1], found.len[1])>
			<cfelse>
				<cfset result = result & nestedVariable>
			</cfif>

			<cfset position = found.pos[1] + found.len[1]>
		</cfloop>

		<cfreturn result & Mid(arguments.value, position, Len(arguments.value) - position + 1)>
	</cffunction>

	<!---
	 * Search the different places for environment variables and return first value found.
	 *
	 * This was borrowed from the excellent dotenv library by vlucas with very few changes.
	 *
	 * Not ported yet: $_SERVER and getenv() are the same struct as $_ENV here.
	 *
	 * @return The value, or an empty string
	--->
	<cffunction name="getVariable" access="private" returntype="string" output="no">
		<cfargument name="name" type="string" required="yes">

		<cfif StructKeyExists(request.ColdIgniter.env, arguments.name)>
			<cfreturn request.ColdIgniter.env[arguments.name]>
		</cfif>

		<cfreturn "">
	</cffunction>

</cfcomponent>
