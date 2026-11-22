<!---
 * URI for the application site
 *
 * Not ported yet: baseUrl() and siteUrl().
--->
<cfcomponent output="no" extends="URI" hint="URI for the application site">

	<!---
	 * The current baseURL.
	--->
	<cfset this.baseURL = "">

	<!---
	 * The path part of baseURL.
	 *
	 * The baseURL "http://example.com/" => "/"
	 * The baseURL "http://localhost:8888/ci431/public/" => "/ci431/public/"
	--->
	<cfset this.basePathWithoutIndexPage = "">

	<!---
	 * The Index File.
	--->
	<cfset this.indexPage = "">

	<!---
	 * List of URI segments in baseURL and indexPage.
	 *
	 * If the URI is "http://localhost:8888/ci431/public/index.cfm/test?a=b",
	 * and the baseURL is "http://localhost:8888/ci431/public/", then:
	 *   array(
	 *     1 => 'ci431',
	 *     2 => 'public',
	 *     3 => 'index.cfm',
	 *   );
	--->
	<cfset this.baseSegments = ArrayNew(1)>

	<!---
	 * URI path relative to baseURL.
	 *
	 * If the baseURL contains sub folders, this value will be different from
	 * the current URI path.
	 *
	 * This value never starts with '/'.
	--->
	<cfset this.routePath = "">

	<!---
	 * @param relativePath URI path relative to baseURL. May include
	 *                     queries or fragments.
	 * @param host         Optional current hostname.
	 * @param scheme       Optional scheme. 'http' or 'https'.
	--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="configApp" type="any" required="yes">
		<cfargument name="relativePath" type="string" required="no" default="">
		<cfargument name="host" type="string" required="no" default="">
		<cfargument name="scheme" type="string" required="no" default="">
		<cfset var relative = "">
		<cfset var routePath = "">
		<cfset var query = "">
		<cfset var fragment = "">
		<cfset var indexPageRoutePath = "">
		<cfset var uri = "">
		<cfset var parts = "">

		<cfset this.indexPage = arguments.configApp.indexPage>

		<cfset this.baseURL = determineBaseURL(arguments.configApp, arguments.host, arguments.scheme)>

		<cfset setBasePath()>

		<!--- Fix routePath, query, fragment --->
		<cfset relative = parseRelativePath(arguments.relativePath)>
		<cfset routePath = relative[1]>
		<cfset query = relative[2]>
		<cfset fragment = relative[3]>

		<!--- Fix indexPage and routePath --->
		<cfset indexPageRoutePath = getIndexPageRoutePath(routePath)>

		<!--- Fix the current URI --->
		<cfset uri = this.baseURL.__toString() & indexPageRoutePath>

		<!--- applyParts --->
		<cfset parts = parse_url(uri)>
		<cfif StructCount(parts) EQ 0>
			<cfthrow type="ColdIgniter.HTTP.Exceptions.HTTPException" message="Unable to parse URI: ""#uri#""">
		</cfif>
		<cfset parts["query"] = query>
		<cfset parts["fragment"] = fragment>
		<cfset applyParts(parts)>

		<cfset setRoutePath(routePath)>

		<cfreturn this>
	</cffunction>

	<cffunction name="parseRelativePath" access="private" returntype="array" output="no">
		<cfargument name="relativePath" type="string" required="yes">
		<cfset var parts = parse_url("http://dummy/" & arguments.relativePath)>
		<cfset var result = ArrayNew(1)>

		<cfif StructCount(parts) EQ 0>
			<cfthrow type="ColdIgniter.HTTP.Exceptions.HTTPException" message="Unable to parse URI: ""#arguments.relativePath#""">
		</cfif>

		<cfif arguments.relativePath EQ "/">
			<cfset ArrayAppend(result, "/")>
		<cfelse>
			<cfset ArrayAppend(result, REReplace(parts["path"], "^/+", ""))>
		</cfif>

		<cfif StructKeyExists(parts, "query")>
			<cfset ArrayAppend(result, parts["query"])>
		<cfelse>
			<cfset ArrayAppend(result, "")>
		</cfif>

		<cfif StructKeyExists(parts, "fragment")>
			<cfset ArrayAppend(result, parts["fragment"])>
		<cfelse>
			<cfset ArrayAppend(result, "")>
		</cfif>

		<cfreturn result>
	</cffunction>

	<cffunction name="determineBaseURL" access="private" returntype="any" output="no">
		<cfargument name="configApp" type="any" required="yes">
		<cfargument name="host" type="string" required="no" default="">
		<cfargument name="scheme" type="string" required="no" default="">
		<cfset var baseURL = normalizeBaseURL(arguments.configApp)>

		<cfset var uri = new_("ColdIgniter\HTTP\URI", baseURL)>

		<!--- Update scheme --->
		<cfif arguments.scheme NEQ "">
			<cfset uri.setScheme(arguments.scheme)>
		<cfelseif arguments.configApp.forceGlobalSecureRequests>
			<cfset uri.setScheme("https")>
		</cfif>

		<!--- Update host --->
		<cfif NOT is_null(arguments.host)>
			<cfset uri.setHost(arguments.host)>
		</cfif>

		<cfreturn uri>
	</cffunction>

	<cffunction name="getIndexPageRoutePath" access="private" returntype="string" output="no">
		<cfargument name="routePath" type="string" required="yes">
		<cfset var indexPage = "">
		<cfset var indexPageRoutePath = "">

		<!--- Remove starting slash unless it is `/`. --->
		<cfif arguments.routePath NEQ "" AND Left(arguments.routePath, 1) EQ "/" AND arguments.routePath NEQ "/">
			<cfset arguments.routePath = REReplace(arguments.routePath, "^/+", "")>
		</cfif>

		<!--- Check for an index page --->
		<cfif this.indexPage NEQ "">
			<cfset indexPage = this.indexPage>

			<!--- Check if we need a separator --->
			<cfif arguments.routePath NEQ "" AND Left(arguments.routePath, 1) NEQ "/" AND Left(arguments.routePath, 1) NEQ "?">
				<cfset indexPage = indexPage & "/">
			</cfif>
		</cfif>

		<cfset indexPageRoutePath = indexPage & arguments.routePath>

		<cfif indexPageRoutePath EQ "/">
			<cfset indexPageRoutePath = "">
		</cfif>

		<cfreturn indexPageRoutePath>
	</cffunction>

	<cffunction name="normalizeBaseURL" access="private" returntype="string" output="no">
		<cfargument name="configApp" type="any" required="yes">

		<!---
		 It's possible the user forgot a trailing slash on their
		 baseURL, so let's help them out.
		--->
		<cfset var baseURL = REReplace(arguments.configApp.baseURL, "[/ ]+$", "") & "/">

		<!--- Validate baseURL --->
		<cfif REFind("^[A-Za-z][A-Za-z0-9+.-]*://[^/ ]+/", baseURL) EQ 0>
			<cfthrow type="ColdIgniter.Config.Exceptions.ConfigException" message="Config\App::baseURL ""#baseURL#"" is not a valid URL.">
		</cfif>

		<cfreturn baseURL>
	</cffunction>

	<!---
	 * Sets basePathWithoutIndexPage and baseSegments.
	--->
	<cffunction name="setBasePath" access="private" returntype="void" output="no">
		<cfset this.basePathWithoutIndexPage = this.baseURL.getPath()>

		<cfset this.baseSegments = convertToSegments(this.basePathWithoutIndexPage)>

		<cfif this.indexPage NEQ "">
			<cfset ArrayAppend(this.baseSegments, this.indexPage)>
		</cfif>
	</cffunction>

	<!---
	 * Returns the baseURL.
	--->
	<cffunction name="getBaseURL" access="public" returntype="string" output="no">
		<cfreturn this.baseURL.__toString()>
	</cffunction>

	<!---
	 * Returns the URI path relative to baseURL.
	 *
	 * @return The Route path.
	--->
	<cffunction name="getRoutePath" access="public" returntype="string" output="no">
		<cfreturn this.routePath>
	</cffunction>

	<!---
	 * Sets the route path (and segments).
	--->
	<cffunction name="setRoutePath" access="private" returntype="void" output="no">
		<cfargument name="routePath" type="string" required="yes">
		<cfset var indexPageRoutePath = "">

		<cfset arguments.routePath = filterPath(arguments.routePath)>

		<cfset indexPageRoutePath = getIndexPageRoutePath(arguments.routePath)>

		<cfset this.path = this.basePathWithoutIndexPage & indexPageRoutePath>

		<cfset this.routePath = REReplace(arguments.routePath, "^/+", "")>

		<cfset this.segments = convertToSegments(this.routePath)>
	</cffunction>

	<!---
	 * Converts path to segments
	--->
	<cffunction name="convertToSegments" access="private" returntype="array" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfset var tempPath = REReplace(arguments.path, "^/+|/+$", "", "all")>

		<cfif tempPath EQ "">
			<cfreturn ArrayNew(1)>
		</cfif>

		<cfreturn explode("/", tempPath)>
	</cffunction>

</cfcomponent>
