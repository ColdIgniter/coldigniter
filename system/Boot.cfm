<!---
 * Entry point of the framework, included by the front controller.
 *
 * A component can only be created by name from a file in its own folder
 * (or above it), so this small file sits beside Boot.cfc and creates it.
 *
 * Expects from the front controller:
 *   request.FCPATH         folder of the front controller
 *   variables.appDirectory path from the front controller to the app folder
 *   variables.paths        the struct set in app/Config/Paths.cfm
--->
<cftry>
	<cfset CreateObject("component", "Boot").bootWeb(paths, request.FCPATH & appDirectory & "/Config")>
	<cfcatch type="ci.boot">
		<cfheader statuscode="503" statustext="Service Unavailable">
		<cfoutput>#cfcatch.message#</cfoutput>
		<cfabort>
	</cfcatch>
</cftry>

<!--- TEMPORARY: shows that the boot ran. Goes away when CodeIgniter.run() is ported. --->
<cfcontent type="text/plain">
<cfoutput>ColdIgniter boot ok#Chr(10)#</cfoutput>
<cfoutput>FCPATH     #request.FCPATH##Chr(10)#</cfoutput>
<cfoutput>APPPATH    #request.APPPATH##Chr(10)#</cfoutput>
<cfoutput>ROOTPATH   #request.ROOTPATH##Chr(10)#</cfoutput>
<cfoutput>SYSTEMPATH #request.SYSTEMPATH##Chr(10)#</cfoutput>
<cfoutput>WRITEPATH  #request.WRITEPATH##Chr(10)#</cfoutput>
<cfoutput>TESTPATH   #request.TESTPATH##Chr(10)#</cfoutput>
