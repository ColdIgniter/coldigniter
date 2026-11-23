<cfsetting enablecfoutputonly="yes">
<!---
 *---------------------------------------------------------------
 * SET THE CURRENT DIRECTORY
 *---------------------------------------------------------------
--->

<!--- Path to the front controller (this file) --->
<cfset request.FCPATH = GetDirectoryFromPath(GetCurrentTemplatePath())>

<!---
 *---------------------------------------------------------------
 * BOOTSTRAP THE APPLICATION
 *---------------------------------------------------------------
 * This process sets up the path constants, loads and registers
 * our autoloader, loads our constants and fires up an
 * environment-specific bootstrapping.
--->

<!--- LOAD OUR PATHS CONFIG FILE --->
<!--- This is the line that might need to be changed, depending on your folder structure. --->
<cfinclude template="../app/Config/Paths.cfm">
<!--- ^^^ Change this line if you move your application folder --->

<!--- cfinclude only takes a relative path, so the system folder is reached from the top of the drive. --->
<cfset rootDirectory = RepeatString("../", ListLen(REReplace(request.FCPATH, "^[A-Za-z]:", ""), "\/"))>
<cfset systemDirectory = rootDirectory & REReplace(Replace(paths.systemDirectory, "\", "/", "all"), "^([A-Za-z]:)?/", "")>

<!---
 *---------------------------------------------------------------
 * CHECK CFML VERSION
 *---------------------------------------------------------------
--->
<cfinclude template="#systemDirectory#/Polyfills/version_compare.cfm">

<cfset minCfmlVersion = "6.1">
<cfset cfmlVersion = Replace(Server.ColdFusion.ProductVersion, ",", ".", "all")>
<cfif version_compare(cfmlVersion, minCfmlVersion, "lt")>
	<cfset message = "Your CFML version must be #minCfmlVersion# or higher to run ColdIgniter. Current version: #cfmlVersion#">

	<cfheader statuscode="503" statustext="Service Unavailable">
	<cfoutput>#message#</cfoutput>

	<cfabort>
</cfif>

<!--- LOAD THE FRAMEWORK BOOTSTRAP FILE --->
<cfinclude template="#systemDirectory#/Boot.cfm">

<cfset Boot.bootWeb(paths)>

<!---
 Not in the original. The page buffer holds 8 KB, and a longer body leaves
 in many small parts, which is slow (over a second for 125 KB). The buffer
 is made as large as the body, so the body leaves in one part.
--->
<cftry>
	<cfif Len(request.ColdIgniter.output) GT GetPageContext().getResponse().getBufferSize()>
		<cfset GetPageContext().getResponse().setBufferSize(JavaCast("int", Len(request.ColdIgniter.output) + 4096))>
	</cfif>

	<cfcatch type="any"></cfcatch>
</cftry>

<!--- No output can leave a method, so the response leaves the body here to be written. --->
<cfoutput>#request.ColdIgniter.output#</cfoutput>
