<!---
 * The controller used by the tests. The test runner copies this file
 * into the scratch copy of the application.
--->
<cfcomponent output="no" extends="BaseController">

	<cffunction name="hello" access="public" returntype="string" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfreturn "hello [" & arguments.name & "]">
	</cffunction>

	<cffunction name="sum" access="public" returntype="string" output="no">
		<cfargument name="a" type="numeric" required="yes">
		<cfargument name="b" type="numeric" required="yes">
		<cfreturn "sum=" & (arguments.a + arguments.b)>
	</cffunction>

	<cffunction name="info" access="public" returntype="string" output="no">
		<cfset var uri = this.request_.getUri()>
		<cfreturn "method=" & this.request_.getMethod() & " path=[" & this.request_.getPath() & "] uri=[" & uri.__toString() & "] base=[" & uri.getBaseURL() & "] query=[" & uri.getQuery() & "] segments=" & ArrayLen(uri.getSegments()) & " ua=[" & this.request_.getHeaderLine("user-agent") & "] proto=" & this.request_.getProtocolVersion() & " locale=" & this.request_.getLocale_()>
	</cffunction>

	<cffunction name="posted" access="public" returntype="string" output="no">
		<cfreturn "posted " & this.request_.getMethod()>
	</cffunction>

	<cffunction name="resp" access="public" returntype="any" output="no">
		<cfreturn this.response.setStatusCode(201).setHeader("X-Test", "yes").setContentType("text/plain").setBody("made")>
	</cffunction>

	<cffunction name="data" access="public" returntype="string" output="no">
		<cfreturn view("test_data", array_("title", "A title", "items", ListToArray("a,b,c")))>
	</cffunction>

	<cffunction name="_hidden" access="public" returntype="string" output="no">
		<cfreturn "hidden">
	</cffunction>

</cfcomponent>
