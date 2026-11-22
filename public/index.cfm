<cfsetting enablecfoutputonly="yes">
<!---
 *---------------------------------------------------------------
 * CHECK COLDFUSION VERSION
 *---------------------------------------------------------------
--->
<cfset productVersion = Server.ColdFusion.ProductVersion>
<cfset majorVersion = Val(ListFirst(productVersion))>
<cfset minorVersion = 0>
<cfif ListLen(productVersion) GTE 2>
	<cfset minorVersion = Val(ListGetAt(productVersion, 2))>
</cfif>
<cfif majorVersion LT 6 OR (majorVersion EQ 6 AND minorVersion LT 1)>
	<cfheader statuscode="503" statustext="Service Unavailable">
	<cfoutput>Your ColdFusion version must be 6.1 or higher to run ColdIgniter. Current version: #productVersion#</cfoutput>
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
