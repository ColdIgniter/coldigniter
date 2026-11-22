<!---
 * Database Configuration
 *
 * Difference: the original extends CodeIgniter\Database\Config, which is
 * the connection manager. Here the class takes BaseConfig, which reads the
 * environment, and the manager is static_("ColdIgniter\Database\Config").
 *
 * Difference: each connection group is a map (see array_()), and a null is
 * an empty string. A boolean is the text "true" or "false".
 *
 * Difference: the original constructor sets defaultGroup to "tests" when
 * the environment is "testing". The constructor of BaseConfig cannot be
 * called from a constructor of this class, so connect() of the manager
 * does it: it picks the group "tests" when the environment is "testing".
 *
 * Not ported yet: the sample connections for the other drivers (the
 * comments of the original), as no driver is ported.
--->
<cfcomponent output="no" parent="ColdIgniter\Config\BaseConfig" hint="Database Configuration">

	<!---
	 * The directory that holds the Migrations and Seeds directories.
	--->
	<cfset this.filesPath = request.APPPATH & "Database" & request.DIRECTORY_SEPARATOR>

	<!---
	 * Lets you choose which connection group to use if no other is specified.
	--->
	<cfset this.defaultGroup = "default">

	<!---
	 * The default database connection.
	 *
	 * @var array<string, mixed>
	--->
	<cfset this.default = array_(
		"DSN", "",
		"hostname", "localhost",
		"username", "",
		"password", "",
		"database", "",
		"DBDriver", "MySQLi",
		"DBPrefix", "",
		"pConnect", false,
		"DBDebug", true,
		"charset", "utf8mb4",
		"DBCollat", "utf8mb4_general_ci",
		"swapPre", "",
		"encrypt", false,
		"compress", false,
		"strictOn", false,
		"failover", ArrayNew(1),
		"port", 3306,
		"numberNative", false,
		"foundRows", false,
		"dateFormat", array_(
			"date", "Y-m-d",
			"datetime", "Y-m-d H:i:s",
			"time", "H:i:s"
		)
	)>

	<!---
	 * This database connection is used when running the automated database tests.
	 *
	 * @var array<string, mixed>
	--->
	<cfset this.tests = array_(
		"DSN", "",
		"hostname", "127.0.0.1",
		"username", "",
		"password", "",
		"database", ":memory:",
		"DBDriver", "SQLite3",
		"DBPrefix", "db_",
		"pConnect", false,
		"DBDebug", true,
		"charset", "utf8",
		"DBCollat", "",
		"swapPre", "",
		"encrypt", false,
		"compress", false,
		"strictOn", true,
		"failover", ArrayNew(1),
		"port", 3306,
		"foreignKeys", true,
		"busyTimeout", 1000,
		"synchronous", "",
		"dateFormat", array_(
			"date", "Y-m-d",
			"datetime", "Y-m-d H:i:s",
			"time", "H:i:s"
		)
	)>

</cfcomponent>
