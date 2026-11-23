<!---
 * History collector
 *
 * Difference: the history files are listed with cfdirectory, and a file
 * that is not valid JSON is skipped (the original tests json_last_error()).
 * The date is made with java.text.SimpleDateFormat in UTC.
 *
 * Difference: the fields read from each file are kept in the server scope,
 * by folder and by file name, size and date, so a file is decoded only once
 * and not on every request. The cache of a folder holds only the files
 * listed on the last call.
--->
<cfcomponent output="no" extends="BaseCollector" hint="History collector">

	<!---
	 * Whether this collector has data that can
	 * be displayed in the Timeline.
	--->
	<cfset this.hasTimeline = false>

	<!---
	 * Whether this collector needs to display
	 * content in a tab or not.
	--->
	<cfset this.hasTabContent = true>

	<!---
	 * Whether this collector needs to display
	 * a label or not.
	--->
	<cfset this.hasLabel = true>

	<!---
	 * The 'title' of this Collector.
	 * Used to name things in the toolbar HTML.
	--->
	<cfset this.title = "History">

	<!---
	 * A list of maps with the keys time, datetime, active, status, method,
	 * url, isAJAX and contentType.
	--->
	<cfset this.files = ArrayNew(1)>

	<!---
	 * Specify time limit & file count for debug history.
	 *
	 * @param current Current history time
	 * @param limit   Max history files
	--->
	<cffunction name="setFiles" access="public" returntype="void" output="no">
		<cfargument name="current" type="string" required="yes">
		<cfargument name="limit" type="numeric" required="no" default="20">
		<cfset var filenames = "">
		<cfset var files = ArrayNew(1)>
		<cfset var counter = 0>
		<cfset var filename = "">
		<cfset var contents = "">
		<cfset var decoded = "">
		<cfset var stamp = "">
		<cfset var format = "">
		<cfset var zone = "">
		<cfset var calendar = "">
		<cfset var seconds = "">
		<cfset var micro = "">
		<cfset var valid = true>
		<cfset var i = 0>
		<cfset var folder = request.WRITEPATH & "debugbar">
		<cfset var cache = StructNew()>
		<cfset var fresh = StructNew()>
		<cfset var cacheKey = "">
		<cfset var entry = "">

		<cfdirectory action="list" directory="#folder#" name="filenames" filter="debugbar_*.json" sort="name asc">

		<cflock name="ColdIgniterHistory" type="readonly" timeout="10">
			<cfif StructKeyExists(server, "ColdIgniterHistory") AND StructKeyExists(server.ColdIgniterHistory, folder)>
				<cfset cache = server.ColdIgniterHistory[folder]>
			</cfif>
		</cflock>

		<cfset format = CreateObject("java", "java.text.SimpleDateFormat").init("yyyy-MM-dd HH:mm:ss")>
		<cfset zone = CreateObject("java", "java.util.TimeZone").getTimeZone("UTC")>
		<cfset format.setTimeZone(zone)>

		<!--- the original lists the oldest first and walks the list backwards --->
		<cfloop from="#filenames.RecordCount#" to="1" step="-1" index="i">
			<cfset counter = counter + 1>
			<cfset filename = request.WRITEPATH & "debugbar" & request.DIRECTORY_SEPARATOR & filenames.name[i]>

			<!--- Oldest files will be deleted --->
			<cfif arguments.limit GTE 0 AND counter GT arguments.limit>
				<!---
				 Difference: another request at the same time may have deleted the
				 file already, which is not an error.
				--->
				<cftry>
					<cffile action="delete" file="#filename#">
					<cfcatch type="any">
						<cfif FileExists(filename)>
							<cfrethrow>
						</cfif>
					</cfcatch>
				</cftry>
			<cfelse>
				<!--- Get the contents of this specific history request --->
				<cfset valid = true>
				<cfset cacheKey = filenames.name[i] & "|" & filenames.size[i] & "|" & filenames.datelastmodified[i]>
				<cftry>
					<cfif StructKeyExists(cache, cacheKey)>
						<cfset entry = cache[cacheKey]>
					<cfelse>
						<cfset contents = file_get_contents(filename)>
						<cfset entry = StructNew()>
						<cftry>
							<cfset decoded = json_decode(contents)>
							<cfset entry["status"] = decoded["vars"]["response"]["statusCode"]>
							<cfset entry["method"] = decoded["method"]>
							<cfset entry["url"] = decoded["url"]>
							<cfset entry["isAJAX"] = iif(decoded["isAJAX"] IS true, de("Yes"), de("No"))>
							<cfset entry["contentType"] = decoded["vars"]["response"]["contentType"]>
							<cfset entry["valid"] = true>
							<cfcatch type="any">
								<cfset entry["valid"] = false>
							</cfcatch>
						</cftry>
					</cfif>
					<cfset fresh[cacheKey] = entry>
					<cfif NOT entry["valid"]>
						<cfthrow type="ColdIgniter.HistoryException" message="Not a history file">
					</cfif>
					<cfset stamp = REReplace(filenames.name[i], "^debugbar_(.*)\.json$", "\1")>
					<cfif NOT REFind("^[0-9]+\.[0-9]+$", stamp)>
						<cfset stamp = "0.000000">
					</cfif>
					<cfset seconds = ListFirst(stamp, ".")>
					<cfset micro = ListLast(stamp, ".") & "000000">
					<cfset micro = Left(micro, 6)>
					<cfset stamp = seconds & "." & micro>

					<!---
					 Difference: JavaCast("long") cannot take a value larger than an integer, so the
					 date is the epoch plus the seconds (an integer, it fits until the year 2038).
					--->
					<cfset calendar = CreateObject("java", "java.util.Calendar").getInstance(zone)>
					<cfset calendar.clear()>
					<cfset calendar.set(JavaCast("int", 1970), JavaCast("int", 0), JavaCast("int", 1))>
					<cfset calendar.add(JavaCast("int", 13), JavaCast("int", seconds))>

					<!--- Debugbar files shown in History Collector --->
					<cfset ArrayAppend(files, array_(
						"time", stamp,
						"datetime", format.format(calendar.getTime()) & "." & micro,
						"active", JavaCast("boolean", Compare(stamp, arguments.current) EQ 0),
						"status", entry["status"],
						"method", entry["method"],
						"url", entry["url"],
						"isAJAX", entry["isAJAX"],
						"contentType", entry["contentType"]
					))>
					<cfcatch type="any">
						<cfset valid = false>
					</cfcatch>
				</cftry>
			</cfif>
		</cfloop>

		<cflock name="ColdIgniterHistory" type="exclusive" timeout="10">
			<cfif NOT StructKeyExists(server, "ColdIgniterHistory")>
				<cfset server.ColdIgniterHistory = StructNew()>
			</cfif>
			<cfset server.ColdIgniterHistory[folder] = fresh>
		</cflock>

		<cfset this.files = files>
	</cffunction>

	<!---
	 * Returns the data of this collector to be formatted in the toolbar
	 *
	 * @return A map with the key files
	--->
	<cffunction name="display" access="public" returntype="any" output="no">
		<cfreturn array_("files", this.files)>
	</cffunction>

	<!---
	 * Displays the number of included files as a badge in the tab button.
	--->
	<cffunction name="getBadgeValue" access="public" returntype="any" output="no">
		<cfreturn ArrayLen(this.files)>
	</cffunction>

	<!---
	 * Return true if there are no history files.
	--->
	<cffunction name="isEmpty" access="public" returntype="boolean" output="no">
		<cfreturn ArrayLen(this.files) EQ 0>
	</cffunction>

	<!---
	 * Display the icon.
	 *
	 * Icon from https://icons8.com - 1em package
	--->
	<cffunction name="icon" access="public" returntype="string" output="no">
		<cfreturn "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAJySURBVEhL3ZU7aJNhGIVTpV6i4qCIgkIHxcXLErS4FBwUFNwiCKGhuTYJGaIgnRoo4qRu6iCiiIuIXXTTIkIpuqoFwaGgonUQlC5KafU5ycmNP0lTdPLA4fu+8573/a4/f6hXpFKpwUwmc9fDfweKbk+n07fgEv33TLSbtt/hvwNFT1PsG/zdTE0Gp+GFfD6/2fbVIxqNrqPIRbjg4t/hY8aztcngfDabHXbKyiiXy2vcrcPH8oDCry2FKDrA+Ar6L01E/ypyXzXaARjDGGcoeNxSDZXE0dHRA5VRE5LJ5CFy5jzJuOX2wHRHRnjbklZ6isQ3tIctBaAd4vlK3jLtkOVWqABBXd47jGHLmjTmSScttQV5J+SjfcUweFQEbsjAas5aqoCLXutJl7vtQsAzpRowYqkBinyCC8Vicb2lOih8zoldd0F8RD7qTFiqAnGrAy8stUAvi/hbqDM+YzkAFrLPdR5ZqoLXsd+Bh5YCIH7JniVdquUWxOPxDfboHhrI5XJ7HHhiqQXox+APe/Qk64+gGYVCYZs8cMpSFQj9JOoFzVqqo7k4HIvFYpscCoAjOmLffUsNUGRaQUwDlmofUa34ecsdgXdcXo4wbakBgiUFafXJV8A4DJ/2UrxUKm3E95H8RbjLcgOJRGILhnmCP+FBy5XvwN2uIPcy1AJvWgqC4xm2aU4Xb3lF4I+Tpyf8hRe5w3J7YLymSeA8Z3nSclv4WLRyFdfOjzrUFX0klJUEtZtntCNc+F69cz/FiDzEPtjzmcUMOr83kDQEX6pAJxJfpL3OX22n01YN7SZCoQnaSdoZ+Jz+PZihH3wt/xlCoT9M6nEtmRSPCQAAAABJRU5ErkJggg==">
	</cffunction>

</cfcomponent>
