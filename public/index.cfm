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
 * LOAD OUR PATHS CONFIG FILE
 *---------------------------------------------------------------
 * No ColdFusion mapping is needed: the folders are found by plain
 * relative paths.
--->

<!--- This is the line that might need to be changed, depending on your folder structure. --->
<cfset appDirectory = "../app">
<!--- ^^^ Change this line if you move your application folder --->

<cfinclude template="#appDirectory#/Config/Paths.cfm">
<cfset systemDirectory = "#appDirectory#/Config/#paths.systemDirectory#">

<!---
 *---------------------------------------------------------------
 * CHECK CFML VERSION
 *---------------------------------------------------------------
 * This comes after the paths, because version_compare() is not
 * built in and has to be loaded from the system folder.
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

<!---
 *---------------------------------------------------------------
 * BOOTSTRAP THE APPLICATION
 *---------------------------------------------------------------
 * This process sets up the path values and hands over to the
 * framework.
--->

<!--- LOAD THE FRAMEWORK BOOTSTRAP FILE --->
<cfinclude template="#systemDirectory#/Boot.cfm">
