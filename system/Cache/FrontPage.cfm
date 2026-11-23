<!---
 * Difference: not in the original. Serves a page of the page cache from
 * the memory of the server before the framework starts.
 *
 * The front controller includes this file first. A page gets here after
 * the framework has served it from the page cache once (see keepFront()
 * of ColdIgniter\Cache\ResponseCache, and the option frontPages of
 * Config\Cache). It is kept in application.ColdIgniter.frontPages, a
 * synchronized java.util.HashMap, under the values of the server that make
 * the URL of the request. The item points at the entry that the file
 * handler of the cache keeps for the file of the page, so it is served
 * only while that file is unchanged and the page has not expired.
 *
 * For a page that is served here nothing of the framework runs: no
 * events, no filters, no controller.
 *
 * Sets request.ColdIgniterFront {signature, start}. The signature is
 * empty when the request can not be served or kept this way.
--->
<cfset request.ColdIgniterFront = StructNew()>
<cfset request.ColdIgniterFront.signature = "">
<cfset request.ColdIgniterFront.start = GetTickCount()>

<cfset frontServe = false>

<cftry>
	<cfif Compare(CGI.REQUEST_METHOD, "GET") EQ 0>
		<!---
		 * A request header can take the place of a value of the server (see
		 * server_value() in Common.cfm, which then gives an empty value).
		 * Such a request goes to the framework. The list has the names of
		 * server_names() with everything but letters and digits removed.
		--->
		<cfset frontNames = "APPLMDPATH,APPLPHYSICALPATH,AUTHTYPE,AUTHUSER,CERTCOOKIE,CERTFLAGS,CERTISSUER,CERTKEYSIZE,CERTSECRETKEYSIZE,CERTSERIALNUMBER,CERTSERVERISSUER,CERTSERVERSUBJECT,CERTSUBJECT,CFTEMPLATEPATH,CONTENTLENGTH,CONTENTTYPE,CONTEXTPATH,GATEWAYINTERFACE,HTTPS,HTTPSKEYSIZE,HTTPSSECRETKEYSIZE,HTTPSSERVERISSUER,HTTPSSERVERSUBJECT,INSTANCEID,LOCALADDR,PATHINFO,PATHTRANSLATED,QUERYSTRING,REMOTEADDR,REMOTEHOST,REMOTEPORT,REMOTEUSER,REQUESTMETHOD,REQUESTURI,SCRIPTNAME,SERVERNAME,SERVERPORT,SERVERPORTSECURE,SERVERPROTOCOL,SERVERSOFTWARE">
		<cfset frontHeaders = GetHttpRequestData().headers>
		<cfset frontSafe = true>

		<cfloop collection="#frontHeaders#" item="frontName">
			<cfif ListFind(frontNames, REReplace(UCase(frontName), "[^A-Z0-9]", "", "all")) GT 0>
				<cfset frontSafe = false>
				<cfbreak>
			</cfif>
		</cfloop>

		<cfif frontSafe>
			<!--- The application scope, made here when no template has made it (the file handler of the cache uses the same name). --->
			<cftry>
				<cfset frontReady = StructKeyExists(application, "ColdIgniter")>

				<cfcatch type="any">
					<cfapplication name="ColdIgniter#LCase(Hash(request.FCPATH))#">
				</cfcatch>
			</cftry>

			<cfset frontLine = Chr(10)>
			<cfset request.ColdIgniterFront.signature = CGI.REQUEST_METHOD & frontLine & CGI.HTTP_HOST & frontLine & CGI.SERVER_NAME & frontLine & CGI.SERVER_PORT & frontLine & CGI.SERVER_PORT_SECURE & frontLine & CGI.HTTPS & frontLine & CGI.SCRIPT_NAME & frontLine & CGI.PATH_INFO & frontLine & CGI.QUERY_STRING & frontLine & CGI.REQUEST_URI>

			<cfif StructKeyExists(application, "ColdIgniter") AND StructKeyExists(application.ColdIgniter, "frontPages")>
				<cfset frontPage = application.ColdIgniter.frontPages.get(request.ColdIgniterFront.signature)>

				<!--- No item gives a null, which leaves the variable undefined. --->
				<cfif IsDefined("frontPage")>
					<cfset frontEntry = frontPage["entry"]>

					<cfif frontEntry["file"].lastModified() EQ frontEntry["modified"]
						AND (frontPage["expires"] EQ 0 OR Int(CreateObject("java", "java.lang.System").currentTimeMillis() / 1000) LTE frontPage["expires"])>
						<cfset frontServe = true>
					<cfelse>
						<!--- changed, deleted or expired: the framework makes the page again --->
						<cfset application.ColdIgniter.frontPages.remove(request.ColdIgniterFront.signature)>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
	</cfif>

	<cfcatch type="any">
		<cfset frontServe = false>
		<cfset request.ColdIgniterFront.signature = "">
	</cfcatch>
</cftry>

<cfif frontServe>
	<cfheader statuscode="#frontPage["status"]#" statustext="#frontPage["reason"]#">

	<cfif Len(frontPage["contentType"]) GT 0>
		<cfcontent type="#frontPage["contentType"]#">
	</cfif>

	<cfset frontHeaderNames = frontPage["names"]>
	<cfset frontHeaderValues = frontPage["values"]>

	<cfloop index="frontIndex" from="0" to="#frontHeaderNames.size() - 1#">
		<cfheader name="#frontHeaderNames.get(JavaCast("int", frontIndex))#" value="#frontHeaderValues.get(JavaCast("int", frontIndex))#">
	</cfloop>

	<cfset frontOutput = frontPage["output"]>

	<!--- The two tags that the framework replaces in the body of each response. --->
	<cfif frontPage["elapsed"]>
		<cfset frontOutput = Replace(frontOutput, "{elapsed_time}", NumberFormat((GetTickCount() - request.ColdIgniterFront.start) / 1000, "0.0000"), "all")>
	</cfif>

	<cfif frontPage["memory"]>
		<cfset frontRuntime = CreateObject("java", "java.lang.Runtime").getRuntime()>
		<cfset frontOutput = Replace(frontOutput, "{memory_usage}", NumberFormat((frontRuntime.totalMemory() - frontRuntime.freeMemory()) / 1024 / 1024, "0.000"), "all")>
	</cfif>

	<!--- The page buffer is made as large as the body, see the front controller. --->
	<cftry>
		<cfif Len(frontOutput) GT GetPageContext().getResponse().getBufferSize()>
			<cfset GetPageContext().getResponse().setBufferSize(JavaCast("int", Min(Len(frontOutput) + 4096, 1048576)))>
		</cfif>

		<cfcatch type="any"></cfcatch>
	</cftry>

	<cfoutput>#frontOutput#</cfoutput>

	<cfabort>
</cfif>
