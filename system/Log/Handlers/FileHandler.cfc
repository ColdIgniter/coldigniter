<!---
 * Log error messages to file system
 *
 * Difference: the file is written with cffile action="append", under a
 * lock with a name, in UTF-8, without the newline that the tag adds. A
 * file or folder that cannot be written is not an error: handle() returns
 * false, as the original does when fopen() fails.
 *
 * Not ported yet: the file permissions (chmod) of a new file, and the
 * header that protects a log file with the extension of the scripting
 * language, which makes no sense for a plain text file.
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

		<!--- Not ported yet: the protection of a log file with a script extension --->

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
