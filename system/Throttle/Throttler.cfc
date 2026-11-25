<!---
 * Class Throttler
 *
 * Uses an implementation of the Token Bucket algorithm to implement a
 * "rolling window" type of throttling that can be used for rate limiting
 * an API or any other request.
 *
 * Each "token" in the "bucket" is equivalent to a single request
 * for the purposes of this implementation.
 *
 * @see https://en.wikipedia.org/wiki/Token_bucket
 *
 * Difference: null is an empty string (CFML cannot express it), so a
 * missing item is told by IsNumeric(), as a stored zero is not an empty
 * string (EQ "" cannot tell them apart safely). The cache
 * gives "" for a missing item, and testTime is "" until setTestTime() is
 * called. The time of a bucket that is missing is 0, as null is 0 in the
 * arithmetic of the original.
 *
 * Difference: the types int of the original are numeric, as CFML has no int
 * type (a platform limit). The result of
 * round() is positive here ((1 - tokens) * refresh is above 0, as tokens is
 * below 1), so Round() and (int) give the same number.
--->
<cfcomponent output="no" extends="ThrottlerInterface" hint="Token bucket throttler">

	<!---
	 * Container for throttle counters.
	 *
	 * @var CacheInterface
	--->
	<cfset this.cache = "">

	<!---
	 * The number of seconds until the next token is available.
	 *
	 * @var int
	--->
	<cfset this.tokenTime = 0>

	<!---
	 * The prefix applied to all keys to
	 * minimize potential conflicts.
	 *
	 * @var string
	--->
	<cfset this.prefix = "throttler_">

	<!---
	 * Timestamp to use (during testing)
	 *
	 * @var int|null
	--->
	<cfset this.testTime = "">

	<!---
	 * Constructor.
	--->
	<cffunction name="__construct" access="public" returntype="any" output="no">
		<cfargument name="cache" type="any" required="yes">

		<cfset this.cache = arguments.cache>

		<cfreturn this>
	</cffunction>

	<!---
	 * Returns the number of seconds until the next available token will
	 * be released for usage.
	--->
	<cffunction name="getTokenTime" access="public" returntype="numeric" output="no">
		<cfreturn this.tokenTime>
	</cffunction>

	<!---
	 * Restricts the number of requests made by a single IP address within
	 * a set number of seconds.
	 *
	 * Example:
	 *
	 *  if (NOT throttler.check(request.ipAddress(), 60, MINUTE)) {
	 *      abort;
	 *  }
	 *
	 * @param key      The name to use as the "bucket" name.
	 * @param capacity The number of requests the "bucket" can hold
	 * @param seconds  The time it takes the "bucket" to completely refill
	 * @param cost     The number of tokens this action uses.
	--->
	<cffunction name="check" access="public" returntype="boolean" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="capacity" type="numeric" required="yes">
		<cfargument name="seconds" type="numeric" required="yes">
		<cfargument name="cost" type="numeric" required="no" default="1">
		<cfset var tokenName = this.prefix & arguments.key>
		<cfset var rate = 0>
		<cfset var refresh = 0>
		<cfset var tokens = "">
		<cfset var throttleTime = "">
		<cfset var elapsed = 0>
		<cfset var newTokenAvailable = 0>

		<!--- Number of tokens to add back per second --->
		<cfset rate = arguments.capacity / arguments.seconds>
		<!--- Number of seconds to get one token --->
		<cfset refresh = 1 / rate>

		<cfset tokens = this.cache.get(tokenName)>

		<!--- Check to see if the bucket has even been created yet. --->
		<cfif NOT IsNumeric(tokens)>
			<!--- If it hasn't been created, then we'll set it to the maximum capacity - 1, and save it to the cache. --->
			<cfset tokens = arguments.capacity - arguments.cost>
			<cfset this.cache.save(tokenName, tokens, arguments.seconds)>
			<cfset this.cache.save(tokenName & "Time", this.time(), arguments.seconds)>

			<cfset this.tokenTime = 0>

			<cfreturn true>
		</cfif>

		<!--- If tokens > 0, then we need to replenish the bucket based on how long it's been since the last update. --->
		<cfset throttleTime = this.cache.get(tokenName & "Time")>
		<cfif NOT IsNumeric(throttleTime)>
			<cfset throttleTime = 0>
		</cfif>
		<cfset elapsed = this.time() - throttleTime>

		<!--- Add tokens based up on number per second that should be refilled, then checked against capacity to be sure the bucket didn't overflow. --->
		<cfset tokens = tokens + rate * elapsed>
		<cfset tokens = Min(tokens, arguments.capacity)>

		<!--- If tokens >= 1, then we are safe to perform the action, but we need to decrement the number of available tokens. --->
		<cfif tokens GTE 1>
			<cfset tokens = tokens - arguments.cost>
			<cfset this.cache.save(tokenName, tokens, arguments.seconds)>
			<cfset this.cache.save(tokenName & "Time", this.time(), arguments.seconds)>

			<cfset this.tokenTime = 0>

			<cfreturn true>
		</cfif>

		<!--- How many seconds till a new token is available. We must have a minimum wait of 1 second for a new token. Primarily stored to allow devs to report back to users. --->
		<cfset newTokenAvailable = Round((1 - tokens) * refresh)>
		<cfset this.tokenTime = Max(1, newTokenAvailable)>

		<cfreturn false>
	</cffunction>

	<!---
	 * @param key The name of the bucket
	--->
	<cffunction name="remove" access="public" returntype="any" output="no">
		<cfargument name="key" type="string" required="yes">
		<cfset var tokenName = this.prefix & arguments.key>

		<cfset this.cache.delete(tokenName)>
		<cfset this.cache.delete(tokenName & "Time")>

		<cfreturn this>
	</cffunction>

	<!---
	 * Used during testing to set the current timestamp to use.
	 *
	 * @return $this
	--->
	<cffunction name="setTestTime" access="public" returntype="any" output="no">
		<cfargument name="time" type="numeric" required="yes">

		<cfset this.testTime = arguments.time>

		<cfreturn this>
	</cffunction>

	<!---
	 * Return the test time, defaulting to current.
	 *
	 * @TODO should be private
	--->
	<cffunction name="time" access="public" returntype="numeric" output="no">
		<cfif IsNumeric(this.testTime)>
			<cfreturn this.testTime>
		</cfif>

		<cfreturn static_("ColdIgniter\I18n\Time").now_().getTimestamp()>
	</cffunction>

</cfcomponent>
