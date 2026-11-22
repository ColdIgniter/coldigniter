<!---
 * Session configuration.
 *
 * Not ported yet: the Database, Memcached and Redis handlers (the driver
 * list names the ones that exist), and so DBGroup, lockRetryInterval and
 * lockMaxRetries, which only those handlers use.
--->
<cfcomponent output="no" parent="ColdIgniter\Config\BaseConfig" hint="Session configuration">

	<!---
	 * --------------------------------------------------------------------------
	 * Session Driver
	 * --------------------------------------------------------------------------
	 *
	 * The session storage driver to use:
	 * - `ColdIgniter\Session\Handlers\ArrayHandler` (for testing)
	 * - `ColdIgniter\Session\Handlers\FileHandler`
	 *
	 * @var class-string<BaseHandler>
	--->
	<cfset this.driver = "ColdIgniter\Session\Handlers\FileHandler">

	<!---
	 * --------------------------------------------------------------------------
	 * Session Cookie Name
	 * --------------------------------------------------------------------------
	 *
	 * The session cookie name, must contain only [0-9a-z_-] characters
	 *
	 * @var string
	--->
	<cfset this.cookieName = "ci_session">

	<!---
	 * --------------------------------------------------------------------------
	 * Session Expiration
	 * --------------------------------------------------------------------------
	 *
	 * The number of SECONDS you want the session to last.
	 * Setting to 0 (zero) means expire when the browser is closed.
	 *
	 * @var int
	--->
	<cfset this.expiration = 7200>

	<!---
	 * --------------------------------------------------------------------------
	 * Session Save Path
	 * --------------------------------------------------------------------------
	 *
	 * The location to save sessions to and is driver dependent.
	 *
	 * For the 'files' driver, it's a path to a writable directory.
	 * WARNING: Only absolute paths are supported!
	 *
	 * IMPORTANT: You are REQUIRED to set a valid save path!
	 *
	 * @var string
	--->
	<cfset this.savePath = request.WRITEPATH & "session">

	<!---
	 * --------------------------------------------------------------------------
	 * Session Match IP
	 * --------------------------------------------------------------------------
	 *
	 * Whether to match the user's IP address when reading the session data.
	 *
	 * @var bool
	--->
	<cfset this.matchIP = false>

	<!---
	 * --------------------------------------------------------------------------
	 * Session Time to Update
	 * --------------------------------------------------------------------------
	 *
	 * How many seconds between ColdIgniter regenerating the session ID.
	 *
	 * @var int
	--->
	<cfset this.timeToUpdate = 300>

	<!---
	 * --------------------------------------------------------------------------
	 * Session Regenerate Destroy
	 * --------------------------------------------------------------------------
	 *
	 * Whether to destroy session data associated with the old session ID
	 * when auto-regenerating the session ID. When set to FALSE, the data
	 * will be later deleted by the garbage collector.
	 *
	 * @var bool
	--->
	<cfset this.regenerateDestroy = false>

</cfcomponent>
