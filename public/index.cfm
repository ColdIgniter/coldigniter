<cfsetting enablecfoutputonly="yes">
<!---
 *---------------------------------------------------------------
 * CHECK COLDFUSION VERSION
 *---------------------------------------------------------------
--->
<cfset minCfVersion = "6.1">
<cfset cfVersion = Replace(Server.ColdFusion.ProductVersion, ",", ".", "all")>
<cfif Val(cfVersion) LT Val(minCfVersion)>
	<cfset message = "Your ColdFusion version must be #minCfVersion# or higher to run ColdIgniter. Current version: #cfVersion#">

	<cfheader statuscode="503" statustext="Service Unavailable">
	<cfoutput>#message#</cfoutput>

	<cfabort>
</cfif>

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
 * This process sets up the path values and hands over to the
 * framework. No ColdFusion mapping is needed: the two folders
 * are found by plain relative paths.
--->

<!--- LOAD OUR PATHS CONFIG FILE --->
<!--- This is the line that might need to be changed, depending on your folder structure. --->
<cfset appDirectory = "../app">
<!--- ^^^ Change this line if you move your application folder --->

<cfinclude template="#appDirectory#/Config/Paths.cfm">

<!--- LOAD THE FRAMEWORK BOOTSTRAP FILE --->
<cfinclude template="#appDirectory#/Config/#paths.systemDirectory#/Boot.cfm">
