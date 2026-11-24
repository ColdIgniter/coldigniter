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
 *
 * Difference: load() keeps the values that the file gave in a file in
 * WRITEPATH/cache, with the time the .env file was last changed and its
 * size. The original reads and parses the .env file on every request, and
 * here that is only done when the time or the size is not the one that
 * was kept. The values are kept as data and are never run as code. They
 * are only kept when no environment value is set yet, as a value that is
 * already set changes what the file gives. parse() always reads the file.
 * Two cases are not seen: a change of the .env file that leaves both its
 * time and its size as they were (the time is compared to 10
 * milliseconds), and a .env file that can no longer be read while it
 * still has its time and size, where parse() would throw.
 *
 * The file that is kept is encrypted (AES, 128 bit, CBC) and signed
 * (HMAC-SHA1 of the vector and the encrypted text, the strongest the
 * Java of the server has). The two keys are random and are only in the
 * memory of the server (server.ColdIgniterDotEnvKeys), never on disk, so
 * both parts are needed: the file is of no use without the memory of the
 * running server, and the keys alone hold no value of the .env file. A
 * file that was not written with the keys, or that was changed, is not
 * used. After a restart of the server the keys are new, the old file
 * cannot be read any more, and it is written again from the .env file.
 *
 * Each server has its own file. The name has a hash of the host name and
 * the root directory of ColdFusion (kept next to the keys), so servers
 * behind a load balancer that share one writable/ folder do not
 * overwrite each other's file and parse the .env file again on every
 * request. The name is the same after a restart, so the old file is
 * overwritten and files do not pile up. When the host name cannot be
 * read, only the root directory is used.
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
		<cfset var vars = "">
		<cfset var file = CreateObject("java", "java.io.File").init(this.path)>
		<cfset var cacheFile = "">
		<cfset var stamp = "">

		<!--- See the top of this file: the values that are kept. --->
		<cfif StructIsEmpty(request.ColdIgniter.env) AND StructKeyExists(request, "WRITEPATH") AND file.isFile()>
			<cfset stamp = file.lastModified() & "|" & file.length()>
			<cfset cacheFile = request.WRITEPATH & "cache" & request.DIRECTORY_SEPARATOR & "dotenv_" & LCase(Hash(this.path & "|" & keptKeys().id))>

			<cfif readKept(cacheFile, stamp)>
				<cfreturn true>
			</cfif>
		</cfif>

		<cfset vars = parse()>

		<cfif cacheFile NEQ "" AND NOT is_null(vars)>
			<cfset writeKept(cacheFile, stamp)>
		</cfif>

		<cfreturn NOT is_null(vars)>
	</cffunction>

	<!---
	 * Not in the original. The two keys of the file that is kept: made at
	 * random the first time, and from then on in the memory of the server.
	 * It also holds id, a hash of the identity of the server.
	--->
	<cffunction name="keptKeys" access="private" returntype="struct" output="no">
		<cfset var keys = "">
		<cfset var generator = "">
		<cfset var host = "">

		<cfif NOT StructKeyExists(server, "ColdIgniterDotEnvKeys")>
			<cflock name="ColdIgniterDotEnvKeys" type="exclusive" timeout="10">
				<cfif NOT StructKeyExists(server, "ColdIgniterDotEnvKeys")>
					<cfset keys = StructNew()>
					<cfset generator = CreateObject("java", "javax.crypto.KeyGenerator").getInstance("AES")>
					<cfset generator.init(JavaCast("int", 128))>
					<cfset keys.cipher = generator.generateKey()>
					<cfset keys.mac = CreateObject("java", "javax.crypto.KeyGenerator").getInstance("HmacSHA1").generateKey()>
					<!--- the identity of this server, for the name of the file --->
					<cftry>
						<cfset host = CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName()>
						<cfcatch type="any">
							<cfset host = "">
						</cfcatch>
					</cftry>
					<cfset keys.id = LCase(Hash(host & "|" & server.coldfusion.rootdir))>
					<cfset server.ColdIgniterDotEnvKeys = keys>
				</cfif>
			</cflock>
		</cfif>

		<cfreturn server.ColdIgniterDotEnvKeys>
	</cffunction>

	<!---
	 * Not in the original. Sets the environment values from the file that
	 * is kept. False when there is no file, when it was not written with
	 * the keys of this server, or when the .env file has changed since.
	--->
	<cffunction name="readKept" access="private" returntype="boolean" output="no">
		<cfargument name="cacheFile" type="string" required="yes">
		<cfargument name="stamp" type="string" required="yes">
		<cfset var keys = "">
		<cfset var packet = "">
		<cfset var parts = "">
		<cfset var vector = "">
		<cfset var encrypted = "">
		<cfset var mac = "">
		<cfset var cipher = "">
		<cfset var kept = "">
		<cfset var i = 0>

		<cfif NOT FileExists(arguments.cacheFile)>
			<cfreturn false>
		</cfif>

		<!--- A file that cannot be read, or that another request is writing, is the same as no file. --->
		<cftry>
			<cfset keys = keptKeys()>
			<cffile action="read" file="#arguments.cacheFile#" variable="packet" charset="utf-8">
			<cfset parts = ListToArray(packet, "|")>

			<cfif ArrayLen(parts) NEQ 3>
				<cfreturn false>
			</cfif>

			<cfset vector = ToBinary(parts[1])>
			<cfset encrypted = ToBinary(parts[2])>

			<!--- The signature is checked before anything is decrypted. --->
			<cfset mac = CreateObject("java", "javax.crypto.Mac").getInstance("HmacSHA1")>
			<cfset mac.init(keys.mac)>
			<cfset mac.update(vector)>

			<cfif NOT hash_equals(ToBase64(mac.doFinal(encrypted)), parts[3])>
				<cfreturn false>
			</cfif>

			<cfset cipher = CreateObject("java", "javax.crypto.Cipher").getInstance("AES/CBC/PKCS5Padding")>
			<cfset cipher.init(cipher.DECRYPT_MODE, keys.cipher, CreateObject("java", "javax.crypto.spec.IvParameterSpec").init(vector))>
			<cfset packet = CreateObject("java", "java.lang.String").init(cipher.doFinal(encrypted), "UTF-8")>
			<cfwddx action="wddx2cfml" input="#packet#" output="kept">

			<cfif Compare(kept.path, this.path) NEQ 0 OR Compare(kept.stamp, arguments.stamp) NEQ 0 OR ArrayLen(kept.names) NEQ ArrayLen(kept.values)>
				<cfreturn false>
			</cfif>

			<cfloop from="1" to="#ArrayLen(kept.names)#" index="i">
				<cfset request.ColdIgniter.env[kept.names[i]] = kept.values[i]>
			</cfloop>

			<cfreturn true>

			<cfcatch type="any">
				<cfset StructClear(request.ColdIgniter.env)>
			</cfcatch>
		</cftry>

		<cfreturn false>
	</cffunction>

	<!---
	 * Not in the original. Keeps the environment values, encrypted and
	 * signed. The names and the values are two arrays, so that the case of
	 * a name stays as it is.
	--->
	<cffunction name="writeKept" access="private" returntype="void" output="no">
		<cfargument name="cacheFile" type="string" required="yes">
		<cfargument name="stamp" type="string" required="yes">
		<cfset var keys = "">
		<cfset var kept = StructNew()>
		<cfset var packet = "">
		<cfset var cipher = "">
		<cfset var vector = "">
		<cfset var encrypted = "">
		<cfset var mac = "">
		<cfset var i = 0>

		<cfset kept.path = this.path>
		<cfset kept.stamp = arguments.stamp>
		<cfset kept.names = StructKeyArray(request.ColdIgniter.env)>
		<cfset kept.values = ArrayNew(1)>

		<cfloop from="1" to="#ArrayLen(kept.names)#" index="i">
			<cfset ArrayAppend(kept.values, request.ColdIgniter.env[kept.names[i]])>
		</cfloop>

		<!--- The file is a help only: when it cannot be written, the request goes on. --->
		<cftry>
			<cfset keys = keptKeys()>
			<cfwddx action="cfml2wddx" input="#kept#" output="packet">

			<!--- The cipher makes a new random vector for every file. --->
			<cfset cipher = CreateObject("java", "javax.crypto.Cipher").getInstance("AES/CBC/PKCS5Padding")>
			<cfset cipher.init(cipher.ENCRYPT_MODE, keys.cipher)>
			<cfset vector = cipher.getIV()>
			<cfset encrypted = cipher.doFinal(JavaCast("string", packet).getBytes("UTF-8"))>

			<cfset mac = CreateObject("java", "javax.crypto.Mac").getInstance("HmacSHA1")>
			<cfset mac.init(keys.mac)>
			<cfset mac.update(vector)>

			<cffile action="write" file="#arguments.cacheFile#" output="#ToBase64(vector)#|#ToBase64(encrypted)#|#ToBase64(mac.doFinal(encrypted))#" charset="utf-8" addnewline="no">

			<cfcatch type="any"></cfcatch>
		</cftry>
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
			<cfif Compare(line, "") NEQ 0 AND Compare(Left(trim_(line), 1), "##") NEQ 0>
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
		<cfif NOT StructKeyExists(request.ColdIgniter.env, arguments.name) OR Compare(request.ColdIgniter.env[arguments.name], "") EQ 0 OR Compare(request.ColdIgniter.env[arguments.name], "0") EQ 0>
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

		<cfif Compare(arguments.value, "") EQ 0>
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
