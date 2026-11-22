<!---
 * Data exceptions.
 *
 * An exception is not an object here. The methods throw the exception
 * themselves, with the type "ColdIgniter.Database.Exceptions.DataException":
 *
 *     <cfset static_("ColdIgniter\Database\Exceptions\DataException").forEmptyDataset("insert")>
 *
 * The messages come from the language file Language/en/Database.cfm.
--->
<cfcomponent output="no" hint="Data exceptions">

	<!---
	 * Used by the Model's trigger() method when the callback cannot be found.
	--->
	<cffunction name="forInvalidMethodTriggered" access="public" returntype="void" output="no">
		<cfargument name="method" type="string" required="yes">

		<cfthrow type="ColdIgniter.Database.Exceptions.DataException" message="#lang('Database.invalidEvent', array_(arguments.method))#">
	</cffunction>

	<!---
	 * Used by Model's insert/update methods when there isn't
	 * any data to actually work with.
	--->
	<cffunction name="forEmptyDataset" access="public" returntype="void" output="no">
		<cfargument name="mode" type="string" required="yes">

		<cfthrow type="ColdIgniter.Database.Exceptions.DataException" message="#lang('Database.emptyDataset', array_(arguments.mode))#">
	</cffunction>

	<!---
	 * Used by Model's insert/update methods when there is no
	 * primary key defined and Model has option `useAutoIncrement`
	 * set to false.
	--->
	<cffunction name="forEmptyPrimaryKey" access="public" returntype="void" output="no">
		<cfargument name="mode" type="string" required="yes">

		<cfthrow type="ColdIgniter.Database.Exceptions.DataException" message="#lang('Database.emptyPrimaryKey', array_(arguments.mode))#">
	</cffunction>

	<!---
	 * Thrown when an argument for one of the Model's methods
	 * were empty or otherwise invalid, and they could not be
	 * to work correctly for that method.
	--->
	<cffunction name="forInvalidArgument" access="public" returntype="void" output="no">
		<cfargument name="argument" type="string" required="yes">

		<cfthrow type="ColdIgniter.Database.Exceptions.DataException" message="#lang('Database.invalidArgument', array_(arguments.argument))#">
	</cffunction>

	<!---
	 * Thrown by forInvalidAllowedFields.
	--->
	<cffunction name="forInvalidAllowedFields" access="public" returntype="void" output="no">
		<cfargument name="model" type="string" required="yes">

		<cfthrow type="ColdIgniter.Database.Exceptions.DataException" message="#lang('Database.invalidAllowedFields', array_(arguments.model))#">
	</cffunction>

	<!---
	 * Thrown by forTableNotFound.
	--->
	<cffunction name="forTableNotFound" access="public" returntype="void" output="no">
		<cfargument name="table" type="string" required="yes">

		<cfthrow type="ColdIgniter.Database.Exceptions.DataException" message="#lang('Database.tableNotFound', array_(arguments.table))#">
	</cffunction>

	<!---
	 * Thrown by forEmptyInputGiven.
	--->
	<cffunction name="forEmptyInputGiven" access="public" returntype="void" output="no">
		<cfargument name="argument" type="string" required="yes">

		<cfthrow type="ColdIgniter.Database.Exceptions.DataException" message="#lang('Database.forEmptyInputGiven', array_(arguments.argument))#">
	</cffunction>

	<!---
	 * Thrown by forFindColumnHaveMultipleColumns.
	--->
	<cffunction name="forFindColumnHaveMultipleColumns" access="public" returntype="void" output="no">

		<cfthrow type="ColdIgniter.Database.Exceptions.DataException" message="#lang('Database.forFindColumnHaveMultipleColumns')#">
	</cffunction>

</cfcomponent>
