<!---
 * Log error messages to file system
 *
 * Difference: the file is written with cffile action="append", under a
 * lock with a name, in UTF-8, without the newline that the tag adds. A
 * file or folder that cannot be written is not an error: handle() returns
 * false, as the original does when fopen() fails.
 *
 * Difference: the original puts a line that stops the script at the top of
 * a new log file with the extension of its own scripting language, which
 * is enough there because the file is never compiled again as a whole
 * once the line has run. That cannot be done here: the server compiles
 * the whole template before it runs the first tag, so a later line of the
 * log with tag-like text makes the file fail to compile, and the error
 * page shows that line (verified on the server; a first line with the
 * cfabort tag did not prevent it). A log file that the server would run
 * (the extensions cfm, cfml and cfc, in any case) cannot be protected by
 * a header, so handle() returns false for them and writes nothing.
 *
 * Difference: the extension is used as it is in the original. Here an
 * extension that holds a slash, a backslash, a colon or two dots in a row
 * is refused the same way (handle() returns false), so the file cannot be
 * written outside of the log folder.
 *
 * Not ported yet: the file permissions (chmod) of a new file.
--->
<cfcomponent output="no" extends="BaseHandler" hint="Log error messages to file system">

	<!---
	 * Folder to hold logs
	 *
	 * @var string
	--->
	<cfset this.path = "">

	<!---
	 * Extension to use for log files
	 *
	 * @var string
	--->
	<cfset this.fileExtension = "">

	<!---
	 * Permissions for new log files
	 *
	 * @var int
	--->
	<cfset this.filePermissions = 0>

	<!---
	 * @param config A map: handles, path, fileExtension, filePermissions
	--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="config" type="any" required="no" default="">
		<cfset var defaults = array_("path", request.WRITEPATH & "logs/", "fileExtension", "log", "filePermissions", 420)>

		<cfif is_null(arguments.config)>
			<cfset arguments.config = array_()>
		</cfif>

		<cfset super.__construct(arguments.config)>

		<cfset arguments.config = array_merge(defaults, arguments.config)>

		<cfif Compare(arguments.config["path"], "") EQ 0>
			<cfset this.path = defaults["path"]>
		<cfelse>
			<cfset this.path = arguments.config["path"]>
		</cfif>

		<cfif Compare(arguments.config["fileExtension"], "") EQ 0>
			<cfset this.fileExtension = defaults["fileExtension"]>
		<cfelse>
			<cfset this.fileExtension = ltrim_(arguments.config["fileExtension"], ".")>
		</cfif>

		<cfset this.filePermissions = arguments.config["filePermissions"]>

		<cfreturn this>
	</cffunction>

	<!---
	 * Handles logging the message.
	 * If the handler returns false, then execution of handlers
	 * will stop. Any handlers that have not run, yet, will not
	 * be run.
	 *
	 * @param level   string
	 * @param message string
	--->
	<cffunction name="handle" access="public" returntype="boolean" output="no">
		<cfargument name="level" type="string" required="yes">
		<cfargument name="message" type="string" required="yes">
		<cfset var filepath = this.path & "log-" & date("Y-m-d") & "." & this.fileExtension>
		<cfset var msg = "">
		<cfset var written = true>
		<cfset var extension = LCase(this.fileExtension)>

		<!--- Files that the server runs cannot be protected with a header (see above) --->
		<cfif ListFindNoCase("cfm,cfml,cfc", extension) GT 0>
			<cfreturn false>
		</cfif>

		<!--- An extension must not leave the log folder --->
		<cfif REFind("[/\\:]", extension) GT 0 OR Find("..", extension) GT 0>
			<cfreturn false>
		</cfif>

		<cfset msg = msg & UCase(arguments.level) & " - " & date(this.dateFormat) & " --> " & arguments.message & Chr(10)>

		<cftry>
			<cflock name="ColdIgniterFileHandler" type="exclusive" timeout="10">
				<cffile action="append" file="#filepath#" output="#msg#" addnewline="no" charset="utf-8">
			</cflock>

			<cfcatch type="any">
				<cfset written = false>
			</cfcatch>
		</cftry>

		<!--- Not ported yet: chmod() of a new file with filePermissions --->

		<cfreturn written>
	</cffunction>

</cfcomponent>
