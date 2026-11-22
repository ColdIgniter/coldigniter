<!---
 * Web Page Caching
 *
 * Difference: the response is stored as the JSON text of a map {headers,
 * output, status, reason} and not as serialize(); every value comes back
 * as a string. A response header is a single value line here (there are
 * no Header objects), so a header is saved and set as that line.
 *
 * Difference: a cached empty string reads as a miss, as it does in the
 * cache handlers.
 *
 * Not ported yet: the CLI request (CLIRequest), so only IncomingRequest.
--->
<cfcomponent output="no" hint="Web Page Caching">

	<!---
	 * Whether to take the URL query string into consideration when generating
	 * output cache files. Valid options are:
	 *
	 *    false      = Disabled
	 *    true       = Enabled, take all query parameters into account.
	 *                 Please be aware that this may result in numerous cache
	 *                 files generated for the same page over and over again.
	 *    array('q') = Enabled, but only take into account the specified list
	 *                 of query parameters.
	 *
	 * @var boolean|array
	--->
	<cfset this.cacheQueryString = false>

	<!---
	 * Cache time to live (TTL) in seconds.
	--->
	<cfset this.ttl = 0>

	<!---
	 * The cache handler.
	--->
	<cfset this.cache = "">

	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="config" type="any" required="yes">
		<cfargument name="cache" type="any" required="yes">

		<cfset this.cache = arguments.cache>
		<cfset this.cacheQueryString = arguments.config.cacheQueryString>

		<cfreturn this>
	</cffunction>

	<cffunction name="setTtl" access="public" returntype="any" output="no">
		<cfargument name="ttl" type="numeric" required="yes">

		<cfset this.ttl = arguments.ttl>

		<cfreturn this>
	</cffunction>

	<!---
	 * Generates the cache key to use from the current request.
	 *
	 * Difference: the query is taken from the raw query string and not
	 * parsed and built again, so its encoding is kept as it came. When the
	 * option is a list, the pairs are kept in the order of the list, and the
	 * last pair of a name is the one that counts.
	 *
	 * @internal for testing purposes only
	--->
	<cffunction name="generateCacheKey" access="public" returntype="string" output="no">
		<cfargument name="request_" type="any" required="yes">
		<cfset var uri = arguments.request_.getUri()>
		<cfset var query = "">
		<cfset var pairs = "">
		<cfset var i = 0>
		<cfset var j = 0>
		<cfset var found = "">

		<cfif IsArray(this.cacheQueryString)>
			<cfif ArrayLen(this.cacheQueryString) GT 0>
				<cfset pairs = ListToArray(uri.getQuery(), "&")>

				<cfloop index="i" from="1" to="#ArrayLen(this.cacheQueryString)#">
					<cfset found = "">

					<cfloop index="j" from="1" to="#ArrayLen(pairs)#">
						<cfif Compare(ListFirst(pairs[j], "="), this.cacheQueryString[i]) EQ 0>
							<cfset found = pairs[j]>
						</cfif>
					</cfloop>

					<cfif Compare(found, "") NEQ 0>
						<cfset query = ListAppend(query, found, "&")>
					</cfif>
				</cfloop>
			</cfif>
		<cfelseif Compare(this.cacheQueryString, "true") EQ 0>
			<cfset query = uri.getQuery()>
		</cfif>

		<cfreturn md5(arguments.request_.getMethod() & ":" & uri.createURIString(uri.getScheme(), uri.getAuthority(), uri.getPath(), query, ""))>
	</cffunction>

	<!---
	 * Caches the response.
	--->
	<cffunction name="make" access="public" returntype="boolean" output="no">
		<cfargument name="request_" type="any" required="yes">
		<cfargument name="response" type="any" required="yes">
		<cfset var headers = CreateObject("java", "java.util.LinkedHashMap").init()>
		<cfset var all = arguments.response.headers()>
		<cfset var name = "">
		<cfset var contents = CreateObject("java", "java.util.LinkedHashMap").init()>

		<cfif this.ttl EQ 0>
			<cfreturn true>
		</cfif>

		<cfloop collection="#all#" item="name">
			<cfset headers.put(name, all[name])>
		</cfloop>

		<cfset contents.put("headers", headers)>
		<cfset contents.put("output", arguments.response.getBody())>
		<cfset contents.put("status", JavaCast("string", arguments.response.getStatusCode()))>
		<cfset contents.put("reason", arguments.response.getReasonPhrase())>

		<cfreturn this.cache.save(generateCacheKey(arguments.request_), json_encode(contents), this.ttl)>
	</cffunction>

	<!---
	 * Gets the cached response for the request.
	 *
	 * @return The response, or an empty string (null)
	--->
	<cffunction name="get" access="public" returntype="any" output="no">
		<cfargument name="request_" type="any" required="yes">
		<cfargument name="response" type="any" required="yes">
		<cfset var cachedResponse = this.cache.get(generateCacheKey(arguments.request_))>
		<cfset var ok = true>
		<cfset var headers = "">
		<cfset var current = "">
		<cfset var keys = "">
		<cfset var i = 0>
		<cfset var name = "">
		<cfset var status = 200>
		<cfset var reason = "">

		<cfif NOT IsSimpleValue(cachedResponse) OR Compare(cachedResponse, "") EQ 0>
			<cfreturn "">
		</cfif>

		<cftry>
			<cfset cachedResponse = json_decode(cachedResponse)>

			<cfcatch type="any">
				<cfset ok = false>
			</cfcatch>
		</cftry>

		<cfif NOT ok OR NOT IsStruct(cachedResponse) OR NOT StructKeyExists(cachedResponse, "output") OR NOT StructKeyExists(cachedResponse, "headers") OR NOT IsStruct(cachedResponse["headers"])>
			<cfthrow type="ColdIgniter.Exceptions.RuntimeException" errorcode="500" message="Error unserializing page cache">
		</cfif>

		<cfset headers = cachedResponse["headers"]>

		<cfif StructKeyExists(cachedResponse, "status")>
			<cfset status = cachedResponse["status"]>
		</cfif>

		<cfif StructKeyExists(cachedResponse, "reason")>
			<cfset reason = cachedResponse["reason"]>
		</cfif>

		<!--- Clear all default headers --->
		<cfset current = arguments.response.headers()>
		<cfset keys = CreateObject("java", "java.util.ArrayList").init(current.keySet())>

		<cfloop index="i" from="0" to="#keys.size() - 1#">
			<cfset arguments.response.removeHeader(keys.get(JavaCast("int", i)))>
		</cfloop>

		<!--- Set cached headers --->
		<cfloop collection="#headers#" item="name">
			<cfset arguments.response.setHeader(name, headers[name])>
		</cfloop>

		<cfset arguments.response.setBody(cachedResponse["output"])>
		<cfset arguments.response.setStatusCode(status, reason)>

		<cfreturn arguments.response>
	</cffunction>

</cfcomponent>
