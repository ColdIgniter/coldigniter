<!---
 * An extendable controller to provide a UI for a resource.
--->
<cfcomponent output="no" extends="BaseResource" hint="An extendable controller to provide a UI for a resource">

	<!---
	 * Return an array of resource objects, themselves in array format.
	--->
	<cffunction name="index" access="public" returntype="any" output="no">
		<cfset var args = ArrayNew(1)>

		<cfset ArrayAppend(args, "index")>

		<cfreturn lang("RESTful.notImplemented", args)>
	</cffunction>

	<!---
	 * Return the properties of a resource object.
	 *
	 * @param id The id of the resource; an empty string (null) for none
	--->
	<cffunction name="show" access="public" returntype="any" output="no">
		<cfargument name="id" type="any" required="no" default="">
		<cfset var args = ArrayNew(1)>

		<cfset ArrayAppend(args, "show")>

		<cfreturn lang("RESTful.notImplemented", args)>
	</cffunction>

	<!---
	 * Return a new resource object, with default properties.
	--->
	<cffunction name="new" access="public" returntype="any" output="no">
		<cfset var args = ArrayNew(1)>

		<cfset ArrayAppend(args, "new")>

		<cfreturn lang("RESTful.notImplemented", args)>
	</cffunction>

	<!---
	 * Create a new resource object, from "posted" parameters.
	--->
	<cffunction name="create" access="public" returntype="any" output="no">
		<cfset var args = ArrayNew(1)>

		<cfset ArrayAppend(args, "create")>

		<cfreturn lang("RESTful.notImplemented", args)>
	</cffunction>

	<!---
	 * Return the editable properties of a resource object.
	 *
	 * @param id The id of the resource; an empty string (null) for none
	--->
	<cffunction name="edit" access="public" returntype="any" output="no">
		<cfargument name="id" type="any" required="no" default="">
		<cfset var args = ArrayNew(1)>

		<cfset ArrayAppend(args, "edit")>

		<cfreturn lang("RESTful.notImplemented", args)>
	</cffunction>

	<!---
	 * Add or update a model resource, from "posted" properties.
	 *
	 * @param id The id of the resource; an empty string (null) for none
	--->
	<cffunction name="update" access="public" returntype="any" output="no">
		<cfargument name="id" type="any" required="no" default="">
		<cfset var args = ArrayNew(1)>

		<cfset ArrayAppend(args, "update")>

		<cfreturn lang("RESTful.notImplemented", args)>
	</cffunction>

	<!---
	 * Present a view to confirm the deletion of a resource object.
	 *
	 * @param id The id of the resource; an empty string (null) for none
	--->
	<cffunction name="remove" access="public" returntype="any" output="no">
		<cfargument name="id" type="any" required="no" default="">
		<cfset var args = ArrayNew(1)>

		<cfset ArrayAppend(args, "remove")>

		<cfreturn lang("RESTful.notImplemented", args)>
	</cffunction>

	<!---
	 * Delete the designated resource object from the model.
	 *
	 * @param id The id of the resource; an empty string (null) for none
	--->
	<cffunction name="delete" access="public" returntype="any" output="no">
		<cfargument name="id" type="any" required="no" default="">
		<cfset var args = ArrayNew(1)>

		<cfset ArrayAppend(args, "delete")>

		<cfreturn lang("RESTful.notImplemented", args)>
	</cffunction>

</cfcomponent>
