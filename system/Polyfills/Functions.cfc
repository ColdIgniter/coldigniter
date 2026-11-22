<!---
 * Holds the global functions.
 *
 * A function only exists in the file or object it was included in,
 * so the global functions are kept here and copied into every object
 * that new_() and static_() create.
--->
<cfcomponent output="no" hint="Holds the global functions">

	<cfinclude template="Polyfills.cfm">

	<cfset variables.__table = StructNew()>

	<!---
	 * Returns the global functions by name.
	--->
	<cffunction name="__functions" access="public" returntype="struct" output="no">
		<cfset var name = "">

		<cfif StructIsEmpty(variables.__table)>
			<cfloop collection="#variables#" item="name">
				<cfif Left(name, 2) NEQ "__" AND IsCustomFunction(variables[name])>
					<cfset variables.__table[name] = variables[name]>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn variables.__table>
	</cffunction>

	<!---
	 * Makes the functions in a file global. The file is run in an
	 * object of its own, so a function that already exists is kept
	 * and is not an error.
	--->
	<cffunction name="__require" access="public" returntype="void" output="no">
		<cfargument name="file" type="string" required="yes">
		<cfset var holder = CreateObject("component", "Functions")>

		<cfset holder.__include(arguments.file)>
		<cfset StructAppend(__functions(), holder.__functions(), false)>
	</cffunction>

	<cffunction name="__include" access="public" returntype="void" output="no">
		<cfargument name="file" type="string" required="yes">

		<cfinclude template="#includePath(arguments.file)#">
	</cffunction>

	<!---
	 * Returns the Variables scope of the object it is called on.
	--->
	<cffunction name="__variables" access="public" returntype="struct" output="no">
		<cfreturn variables>
	</cffunction>

	<!---
	 * Returns a member of the object it is called on, by name. This
	 * also reaches a private function the object inherits, which is
	 * not in its Variables scope.
	--->
	<cffunction name="__member" access="public" returntype="any" output="no">
		<cfargument name="name" type="string" required="yes">

		<cfreturn Evaluate(arguments.name)>
	</cffunction>

	<!---
	 * Copies the global functions into an object. A function the
	 * object already has is kept.
	--->
	<cffunction name="__inject" access="public" returntype="any" output="no">
		<cfargument name="object" type="any" required="yes">

		<cfset arguments.object.__variables = variables.__variables>
		<cfset arguments.object.__member = variables.__member>
		<cfset StructAppend(arguments.object.__variables(), __functions(), false)>

		<cfreturn arguments.object>
	</cffunction>

</cfcomponent>
