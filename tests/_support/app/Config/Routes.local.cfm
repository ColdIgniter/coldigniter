<!--- Routes used by the tests. The test runner copies this file into the scratch copy of the application. --->
<cfset routes.get("hello/(:segment)", "Test::hello/$1")>
<cfset routes.get("sum/(:num)/(:num)", "Test::sum/$1/$2")>
<cfset routes.get("info", "Test::info")>
<cfset routes.post("posted", "Test::posted")>
<cfset routes.get("resp", "Test::resp")>
<cfset routes.get("data", "Test::data")>
