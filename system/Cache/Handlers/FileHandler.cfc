<!---
 * File system cache handler.
 *
 * Difference: the stored file holds a map {time, ttl, data} as a Java
 * object stream (ObjectOutputStream) and not serialize(). It is the form
 * the server writes and reads fastest, and a value comes back as it went
 * in: a string, a number, a map (a struct, which keeps its kind and so
 * the order of its keys), an array and a query. A component cannot be
 * cached, also not inside a map or an array: save() returns false. The
 * file is read with readObject(), so, as with unserialize(), the cache
 * directory must be writable by the application only.
 *
 * Difference: a file is read, written and deleted under a named exclusive
 * lock (cflock) of its full path. A file is not written to a temporary name
 * and renamed, as a rename over an existing file fails on Windows with the
 * Java of the server, so a file that is cut short by a crash is read as a
 * miss (the stream cannot be read). A file of an earlier version (JSON
 * text) is a miss too.
 *
 * Difference: a key that the file system could not take as a file name
 * (a character of * ? " < > | / \ : or below a space, a name of "." or "..", a
 * trailing period or space, or a device name such as CON or NUL) is stored
 * under the md5 of the prefixed key, as a key that is too long is.
 *
 * Difference: the cache directory is created when it does not exist.
 *
 * Not ported yet: the option mode and chmod (there is no chmod).
--->
<cfcomponent output="no" extends="BaseHandler" hint="File system cache handler">

	<!---
	 * Maximum key length.
	 *
	 * @var int
	--->
	<cfset this.MAX_KEY_LENGTH = 255>

	<!---
	 * Where to store cached files on the disk.
	 *
	 * @var string
	--->
	<cfset this.path = "">

	<!---
	 * Note: Use `CacheFactory::getHandler()` to instantiate.
	 *
	 * @throws CacheException
	--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="config" type="any" required="yes">
		<cfset var dir = "">
		<cfset var path = request.WRITEPATH & "cache/">
		<cfset var last = "">

		<cfif StructKeyExists(arguments.config.file_, "storePath") AND Compare(arguments.config.file_["storePath"], "") NEQ 0>
			<cfset path = arguments.config.file_["storePath"]>
		</cfif>

		<!--- rtrim($path, '\\/') . '/' --->
		<cfloop condition="Len(path) GT 0">
			<cfset last = Right(path, 1)>

			<cfif Compare(last, "/") NEQ 0 AND Compare(last, "\") NEQ 0>
				<cfbreak>
			</cfif>

			<cfset path = Left(path, Len(path) - 1)>
		</cfloop>

		<cfset this.path = path & "/">

		<cfset dir = CreateObject("java", "java.io.File").init(this.path)>

		<cfif NOT dir.isDirectory() AND NOT dir.mkdirs()>
			<cfset static_("ColdIgniter\Cache\Exceptions\CacheException").forUnableToWrite(this.path)>
		</cfif>

		<cfif NOT dir.canWrite()>
			<cfset static_("ColdIgniter\Cache\Exceptions\CacheException").forUnableToWrite(this.path)>
		</cfif>

		<cfset this.prefix = arguments.config.prefix>

		<cfreturn this>
	</cffunction>

	<cffunction name="initialize_" access="public" returntype="void" output="no">
		<!--- Not implemented --->
		<cfreturn>
	</cffunction>

	<cffunction name="get" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfset var data = "">

		<cfset arguments.key = fileKey(arguments.key)>
		<cfset data = getItem(arguments.key)>

		<cfif IsStruct(data)>
			<cfreturn data["data"]>
		</cfif>

		<cfreturn "">
	</cffunction>

	<cffunction name="save" access="public" returntype="boolean" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="value" type="any" required="yes">
		<cfargument name="ttl" type="numeric" required="no" default="60">
		<cfset var contents = CreateObject("java", "java.util.LinkedHashMap").init()>

		<cfif IsObject(arguments.value)>
			<cfreturn false>
		</cfif>

		<cfset arguments.key = fileKey(arguments.key)>

		<cfset contents.put("time", JavaCast("string", Int(time())))>
		<cfset contents.put("ttl", JavaCast("string", Int(arguments.ttl)))>
		<cfset contents.put("data", arguments.value)>

		<cfreturn writeFile(this.path & arguments.key, contents)>
	</cffunction>

	<cffunction name="delete" access="public" returntype="boolean" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfset var file_ = "">
		<cfset var result = false>

		<cfset arguments.key = fileKey(arguments.key)>
		<cfset file_ = CreateObject("java", "java.io.File").init(this.path & arguments.key)>

		<cflock name="ColdIgniterCache#md5(this.path & arguments.key)#" type="exclusive" timeout="10">
			<cfif file_.isFile()>
				<cfset result = file_.delete()>
			</cfif>
		</cflock>

		<cfreturn result>
	</cffunction>

	<!---
	 * The pattern is matched against file names only and never becomes part
	 * of a path, so it cannot reach files outside the cache directory.
	 * A wildcard does not match a leading period of a name.
	 *
	 * @param pattern A shell wildcard pattern, see fnmatch()
	 *
	 * @return The number of files deleted
	--->
	<cffunction name="deleteMatching" access="public" returntype="numeric" output="no">
		<cfargument name="pattern" type="string" required="yes">
		<cfset var directory = CreateObject("java", "java.io.File").init(this.path)>
		<cfset var files = "">
		<cfset var deleted = 0>
		<cfset var i = 0>
		<cfset var file_ = "">

		<cfif NOT directory.isDirectory()>
			<cfreturn 0>
		</cfif>

		<cfset files = directory.list()>

		<cfif NOT IsDefined("files")>
			<cfreturn 0>
		</cfif>

		<cfloop index="i" from="1" to="#ArrayLen(files)#">
			<!--- FNM_PERIOD keeps glob() semantics: wildcards don't match a leading dot. --->
			<cfif fnmatch(arguments.pattern, files[i], true)>
				<cfset file_ = CreateObject("java", "java.io.File").init(this.path & files[i])>

				<cflock name="ColdIgniterCache#md5(this.path & files[i])#" type="exclusive" timeout="10">
					<cfif file_.isFile() AND file_.delete()>
						<cfset deleted = deleted + 1>
					</cfif>
				</cflock>
			</cfif>
		</cfloop>

		<cfreturn deleted>
	</cffunction>

	<cffunction name="increment" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="offset" type="numeric" required="no" default="1">
		<cfset var prefixedKey = fileKey(arguments.key)>
		<cfset var tmp = getItem(prefixedKey)>
		<cfset var value = "">
		<cfset var ttl = "">

		<cfif NOT IsStruct(tmp)>
			<cfset tmp = CreateObject("java", "java.util.LinkedHashMap").init()>
			<cfset tmp.put("data", "0")>
			<cfset tmp.put("ttl", "60")>
		</cfif>

		<cfset value = tmp["data"]>
		<cfset ttl = tmp["ttl"]>

		<!---
		 if (! is_int($value))
		 Difference: a string of digits such as "5" counts as an integer
		 here, as a number and its text are the same value in CFML.
		--->
		<cfif NOT IsSimpleValue(value) OR NOT CreateObject("java", "java.lang.String").init(JavaCast("string", value)).matches("-?[0-9]+")>
			<cfreturn false>
		</cfif>

		<cfset value = Int(Val(value) + arguments.offset)>

		<cfif save(arguments.key, value, Val(ttl))>
			<cfreturn value>
		</cfif>

		<cfreturn false>
	</cffunction>

	<cffunction name="decrement" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="offset" type="numeric" required="no" default="1">

		<cfreturn increment(arguments.key, -arguments.offset)>
	</cffunction>

	<!---
	 * Difference: the files that are kept are index.html, index.htm,
	 * .htaccess and web.config.
	--->
	<cffunction name="clean" access="public" returntype="boolean" output="no">
		<cfreturn deleteFiles(this.path, false, true)>
	</cffunction>

	<cffunction name="getCacheInfo" access="public" returntype="any" output="no">
		<cfreturn getDirFileInfo(this.path)>
	</cffunction>

	<cffunction name="getMetaData_" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfset var data = "">
		<cfset var result = CreateObject("java", "java.util.LinkedHashMap").init()>
		<cfset var file_ = "">

		<cfset arguments.key = fileKey(arguments.key)>
		<cfset data = getItem(arguments.key)>

		<cfif NOT IsStruct(data)>
			<cfreturn "">
		</cfif>

		<cfset file_ = CreateObject("java", "java.io.File").init(this.path & arguments.key)>

		<cfif Val(data["ttl"]) GT 0>
			<cfset result.put("expire", Val(data["time"]) + Val(data["ttl"]))>
		<cfelse>
			<cfset result.put("expire", "")>
		</cfif>

		<cfset result.put("mtime", Int(file_.lastModified() / 1000))>
		<cfset result.put("data", data["data"])>

		<cfreturn result>
	</cffunction>

	<cffunction name="isSupported" access="public" returntype="boolean" output="no">
		<cfreturn CreateObject("java", "java.io.File").init(this.path).canWrite()>
	</cffunction>

	<!---
	 * Validates the key and makes it a name the file system takes.
	 *
	 * Difference: this method is not in the original, see the Difference
	 * at the top of the file.
	 *
	 * @param key The key without a prefix
	--->
	<cffunction name="fileKey" access="private" returntype="string" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfset var name = validateKey(arguments.key, this.prefix)>
		<cfset var i = 0>
		<cfset var code = 0>
		<cfset var base = "">
		<cfset var bad = false>
		<cfset var last = "">

		<cfif Compare(name, ".") EQ 0 OR Compare(name, "..") EQ 0>
			<cfset bad = true>
		</cfif>

		<cfif NOT bad>
			<cfloop index="i" from="1" to="#Len(name)#">
				<cfset code = Asc(Mid(name, i, 1))>

				<cfif code LT 32 OR code EQ 127 OR Find(Mid(name, i, 1), "*?""<>|/\:") GT 0>
					<cfset bad = true>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>

		<cfif NOT bad>
			<cfset last = Right(name, 1)>

			<cfif Compare(last, ".") EQ 0 OR Compare(last, " ") EQ 0>
				<cfset bad = true>
			</cfif>
		</cfif>

		<!--- a device name, also with an extension --->
		<cfif NOT bad>
			<cfset base = UCase(RTrim(ListFirst(Replace(name, ".", Chr(1), "all"), Chr(1))))>

			<cfif CreateObject("java", "java.lang.String").init(base).matches("CON|PRN|AUX|NUL|CLOCK\$|CONIN\$|CONOUT\$|COM[1-9]|LPT[1-9]")>
				<cfset bad = true>
			</cfif>
		</cfif>

		<cfif bad>
			<cfreturn md5(name)>
		</cfif>

		<cfreturn name>
	</cffunction>

	<!---
	 * Does the heavy lifting of actually retrieving the file and
	 * verifying its age.
	 *
	 * @return A map {data, ttl, time}, or false
	--->
	<cffunction name="getItem" access="private" returntype="any" output="no">
		<cfargument name="filename" type="string" required="yes">
		<cfset var file_ = CreateObject("java", "java.io.File").init(this.path & arguments.filename)>
		<cfset var raw = "">
		<cfset var data = "">
		<cfset var ok = true>
		<cfset var integer = CreateObject("java", "java.lang.String")>

		<cfif NOT file_.isFile()>
			<cfreturn false>
		</cfif>

		<cftry>
			<cflock name="ColdIgniterCache#md5(this.path & arguments.filename)#" type="exclusive" timeout="10">
				<cfset raw = CreateObject("java", "java.io.FileInputStream").init(this.path & arguments.filename)>

				<!--- There is no finally: the file is closed in both ways out. --->
				<cftry>
					<cfset data = CreateObject("java", "java.io.ObjectInputStream").init(
						CreateObject("java", "java.io.BufferedInputStream").init(raw)
					).readObject()>
					<cfset raw.close()>

					<cfcatch type="any">
						<cfset raw.close()>
						<cfrethrow>
					</cfcatch>
				</cftry>
			</cflock>

			<cfcatch type="any">
				<cfset ok = false>
			</cfcatch>
		</cftry>

		<cfif NOT ok OR NOT IsStruct(data)>
			<cfreturn false>
		</cfif>

		<cfif NOT StructKeyExists(data, "ttl") OR NOT IsSimpleValue(data["ttl"]) OR NOT integer.init(data["ttl"]).matches("-?[0-9]+")>
			<cfreturn false>
		</cfif>

		<cfif NOT StructKeyExists(data, "time") OR NOT IsSimpleValue(data["time"]) OR NOT integer.init(data["time"]).matches("-?[0-9]+")>
			<cfreturn false>
		</cfif>

		<cfif NOT StructKeyExists(data, "data")>
			<cfreturn false>
		</cfif>

		<cfif Val(data["ttl"]) GT 0 AND time() GT Val(data["time"]) + Val(data["ttl"])>
			<cflock name="ColdIgniterCache#md5(this.path & arguments.filename)#" type="exclusive" timeout="10">
				<cfset file_.delete()>
			</cflock>

			<cfreturn false>
		</cfif>

		<cfreturn data>
	</cffunction>

	<!---
	 * Writes a file to disk, or returns false if not successful.
	 *
	 * @param path Path to the file
	 * @param data The value to write (Difference: not text, see the header)
	 * @param mode Not used, the file is always written whole
	--->
	<cffunction name="writeFile" access="private" returntype="boolean" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfargument name="data" type="any" required="yes">
		<cfargument name="mode" type="string" required="no" default="wb">
		<cfset var ok = true>
		<cfset var raw = "">
		<cfset var out = "">

		<cftry>
			<cflock name="ColdIgniterCache#md5(arguments.path)#" type="exclusive" timeout="10">
				<cfset raw = CreateObject("java", "java.io.FileOutputStream").init(arguments.path)>

				<!---
				 There is no finally: the file is closed in both ways out.
				 A file with a part of the value (a component inside it
				 cannot be written) is of no use, so it is deleted.
				--->
				<cftry>
					<cfset out = CreateObject("java", "java.io.ObjectOutputStream").init(
						CreateObject("java", "java.io.BufferedOutputStream").init(raw)
					)>
					<cfset out.writeObject(arguments.data)>
					<cfset out.close()>

					<cfcatch type="any">
						<cfset raw.close()>
						<cfset CreateObject("java", "java.io.File").init(arguments.path).delete()>
						<cfrethrow>
					</cfcatch>
				</cftry>
			</cflock>

			<cfcatch type="any">
				<cfset ok = false>
			</cfcatch>
		</cftry>

		<cfreturn ok>
	</cffunction>

	<!---
	 * Deletes all files contained in the supplied directory path.
	 * Files must be writable or owned by the system in order to be deleted.
	 * If the second parameter is set to TRUE, any directories contained
	 * within the supplied base directory will be nuked as well.
	 *
	 * @param path    File path
	 * @param delDir  Whether to delete any directories found in the path
	 * @param htdocs  Whether to skip deleting .htaccess and index page files
	 * @param level   Internal variable to determine recursion status - do not use in calls
	--->
	<cffunction name="deleteFiles" access="private" returntype="boolean" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfargument name="delDir" type="boolean" required="no" default="false">
		<cfargument name="htdocs" type="boolean" required="no" default="false">
		<cfargument name="level_" type="numeric" required="no" default="0">
		<cfset var directory = "">
		<cfset var files = "">
		<cfset var i = 0>
		<cfset var filename = "">
		<cfset var entry = "">
		<cfset var dirPath = arguments.path>

		<!--- Trim the trailing slash --->
		<cfloop condition="Len(dirPath) GT 0 AND (Compare(Right(dirPath, 1), '/') EQ 0 OR Compare(Right(dirPath, 1), '\') EQ 0)">
			<cfset dirPath = Left(dirPath, Len(dirPath) - 1)>
		</cfloop>

		<cfset directory = CreateObject("java", "java.io.File").init(dirPath)>

		<cfif NOT directory.isDirectory()>
			<cfreturn false>
		</cfif>

		<cfset files = directory.list()>

		<cfif NOT IsDefined("files")>
			<cfreturn false>
		</cfif>

		<cfloop index="i" from="1" to="#ArrayLen(files)#">
			<cfset filename = files[i]>
			<cfset entry = CreateObject("java", "java.io.File").init(dirPath & "/" & filename)>

			<cfif entry.isDirectory() AND Compare(Left(filename, 1), ".") NEQ 0>
				<cfset deleteFiles(dirPath & "/" & filename, arguments.delDir, arguments.htdocs, arguments.level_ + 1)>
			<cfelseif entry.isFile() AND (NOT arguments.htdocs OR NOT CreateObject("java", "java.lang.String").init(LCase(filename)).matches("\.htaccess|index\.(html|htm)|web\.config"))>
				<!--- a folder is left, as unlink() of the original fails on one --->
				<cflock name="ColdIgniterCache#md5(dirPath & '/' & filename)#" type="exclusive" timeout="10">
					<cfset entry.delete()>
				</cflock>
			</cfif>
		</cfloop>

		<cfif arguments.delDir AND arguments.level_ GT 0>
			<cfreturn directory.delete()>
		</cfif>

		<cfreturn true>
	</cffunction>

	<!---
	 * Reads the specified directory and builds a map containing the filenames,
	 * filesize, dates, and permissions
	 *
	 * Any sub-folders contained within the specified path are read as well.
	 *
	 * @param sourceDir    Path to source
	 * @param topLevelOnly Look only at the top level directory specified?
	 * @param recursion_   Internal variable to determine recursion status - do not use in calls
	 *
	 * @return A map of filename -> {name, server_path, size, date, relative_path}
	--->
	<cffunction name="getDirFileInfo" access="private" returntype="any" output="no">
		<cfargument name="sourceDir" type="string" required="yes">
		<cfargument name="topLevelOnly" type="boolean" required="no" default="true">
		<cfargument name="fileData_" type="any" required="no" default="">
		<cfset var relativePath = arguments.sourceDir>
		<cfset var fileData = arguments.fileData_>
		<cfset var directory = "">
		<cfset var files = "">
		<cfset var i = 0>
		<cfset var file_ = "">
		<cfset var info = "">
		<cfset var dirPath = arguments.sourceDir>

		<!--- reset the map and make sure sourceDir has a trailing slash on the initial call --->
		<cfif NOT IsStruct(fileData)>
			<cfset fileData = CreateObject("java", "java.util.LinkedHashMap").init()>

			<cfloop condition="Len(dirPath) GT 0 AND (Compare(Right(dirPath, 1), '/') EQ 0 OR Compare(Right(dirPath, 1), '\') EQ 0)">
				<cfset dirPath = Left(dirPath, Len(dirPath) - 1)>
			</cfloop>

			<cfset dirPath = dirPath & "/">
		</cfif>

		<cfset directory = CreateObject("java", "java.io.File").init(dirPath)>

		<cfif NOT directory.isDirectory()>
			<cfreturn CreateObject("java", "java.util.LinkedHashMap").init()>
		</cfif>

		<cfset files = directory.list()>

		<cfif NOT IsDefined("files")>
			<cfreturn CreateObject("java", "java.util.LinkedHashMap").init()>
		</cfif>

		<cfloop index="i" from="1" to="#ArrayLen(files)#">
			<cfset file_ = CreateObject("java", "java.io.File").init(dirPath & files[i])>

			<cfif file_.isDirectory() AND Compare(Left(files[i], 1), ".") NEQ 0 AND NOT arguments.topLevelOnly>
				<cfset getDirFileInfo(dirPath & files[i] & "/", arguments.topLevelOnly, fileData)>
			<cfelseif Compare(Left(files[i], 1), ".") NEQ 0>
				<cfset info = getFileInfo(dirPath & files[i])>

				<cfif IsStruct(info)>
					<cfset info.put("relative_path", relativePath)>
					<cfset fileData.put(files[i], info)>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn fileData>
	</cffunction>

	<!---
	 * Get File Info
	 *
	 * Given a file and path, returns the name, path, size, date modified
	 *
	 * Difference: the second argument of the original (the values to
	 * return) is not ported, the four values name, server_path, size and
	 * date are always returned. Returns false when the file cannot be
	 * found, where the original returns null.
	 *
	 * @param file_ Path to file
	--->
	<cffunction name="getFileInfo" access="private" returntype="any" output="no">
		<cfargument name="file_" type="string" required="yes">
		<cfset var handle = CreateObject("java", "java.io.File").init(arguments.file_)>
		<cfset var info = "">

		<cfif NOT handle.isFile()>
			<cfreturn false>
		</cfif>

		<cfset info = CreateObject("java", "java.util.LinkedHashMap").init()>

		<cfset info.put("name", handle.getName())>
		<cfset info.put("server_path", arguments.file_)>
		<cfset info.put("size", handle.length())>
		<cfset info.put("date", Int(handle.lastModified() / 1000))>

		<cfreturn info>
	</cffunction>

</cfcomponent>
