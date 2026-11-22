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

<!--- TEMPORARY: shows that the boot ran. Goes away when the rest of bootWeb() is ported. --->
<cfcontent type="text/plain">
<cfoutput>ColdIgniter boot ok#Chr(10)#</cfoutput>
<cfoutput>FCPATH     #request.FCPATH##Chr(10)#</cfoutput>
<cfoutput>APPPATH    #request.APPPATH##Chr(10)#</cfoutput>
<cfoutput>ROOTPATH   #request.ROOTPATH##Chr(10)#</cfoutput>
<cfoutput>SYSTEMPATH #request.SYSTEMPATH##Chr(10)#</cfoutput>
<cfoutput>WRITEPATH  #request.WRITEPATH##Chr(10)#</cfoutput>
<cfoutput>TESTPATH   #request.TESTPATH##Chr(10)#</cfoutput>
<cfoutput>ENVIRONMENT #request.ENVIRONMENT#, CI_DEBUG #request.CI_DEBUG#, APP_NAMESPACE #request.APP_NAMESPACE#, DAY #request.DAY#, EXIT__AUTO_MAX #request.EXIT__AUTO_MAX##Chr(10)#</cfoutput>
