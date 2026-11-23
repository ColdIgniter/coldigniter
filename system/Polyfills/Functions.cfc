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

	<!--- The functions that are here at the first call of __functions() (those of Polyfills.cfm): what a file that require_once() runs starts with. --->
	<cfset variables.__base = StructNew()>

	<!--- The files that __require() ran in this request, and the files that were looked at in this request (see __subset()). --->
	<cfset variables.__required = ArrayNew(1)>
	<cfset variables.__checked = StructNew()>

	<!---
	 * Returns the global functions by name.
	--->
	<cffunction name="__functions" access="public" returntype="struct" output="no">
		<cfset var name = "">

		<cfif StructIsEmpty(variables.__table)>
			<cfloop collection="#variables#" item="name">
				<cfif Left(name, 2) NEQ "__" AND IsCustomFunction(variables[name])>
					<cfset variables.__table[name] = variables[name]>
					<cfset variables.__base[name] = variables[name]>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn variables.__table>
	</cffunction>

	<!---
	 * Makes the functions in a file global. The file is run in an
	 * object of its own, so a function that already exists is kept
	 * and is not an error.
	 *
	 * That object is an empty Holder, which is given the functions of
	 * Polyfills.cfm that are already loaded. Creating another Functions
	 * object would include all of Polyfills.cfm again for each file.
	--->
	<cffunction name="__require" access="public" returntype="void" output="no">
		<cfargument name="file" type="string" required="yes">
		<cfset var holder = CreateObject("component", "Holder")>
		<cfset var table = __functions()>
		<cfset var scope = holder.__variables()>
		<cfset var name = "">

		<cfset StructAppend(scope, variables.__base, false)>
		<cfset holder.__include(arguments.file)>
		<cfset ArrayAppend(variables.__required, arguments.file)>

		<cfloop collection="#scope#" item="name">
			<cfif Left(name, 2) NEQ "__" AND NOT StructKeyExists(table, name) AND IsCustomFunction(scope[name])>
				<cfset table[name] = scope[name]>
			</cfif>
		</cfloop>
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

	<!---
	 * Gives the global functions that the objects of one class need.
	 *
	 * Copying every global function into an object is the slow part of
	 * making an object, and the time goes with the number of functions.
	 * A class calls few of them. A global function runs in the object
	 * that calls it, so an object needs the functions that are named in
	 * the file of its class, in the files of the classes it extends and
	 * in its parent class, and the functions that those functions call
	 * in turn. Each file is split into words, and the words that are
	 * names of global functions are kept. A word that is only in a
	 * comment or in a text counts too, which gives a function too many
	 * and never one too few.
	 *
	 * A class gets every function when its file (or one of the others)
	 * includes another file, because that file is not read here, or when
	 * the caller says so. A function that is called by a name that is put
	 * together at run time cannot be seen: such a class has to be marked
	 * (see instantiate() of the Autoloader).
	 *
	 * What is found is kept in the memory of the server
	 * (server.ColdIgniterFunctions), so a file is read once and not once
	 * per request. Only file paths and names of global functions are
	 * kept, never another word of a file. Other applications on the same
	 * server can read it. Every file is read again when a helper brings a
	 * function name that was not known before. Outside production a file
	 * is also read again when its time or size has changed. In production
	 * what is kept is used until the server is restarted, like the class
	 * map of the Autoloader: after a class file or a file of functions is
	 * changed, restart the server or run
	 * StructDelete(server, "ColdIgniterFunctions"). A value in that memory is
	 * complete before it is stored and is never changed afterwards.
	 *
	 * @param files  The paths of the class file and of the files it extends
	 * @param parent What this function gave for the parent class, an empty string when there is none
	 * @param all    Whether the class is to get every function
	 *
	 * @return "table" (the functions by name), "size", "all", "names",
	 *         "id", "count" (the number of global functions there were)
	 *         and "missing" (the number of names that are no function in
	 *         this request: a helper that is loaded later can bring them)
	--->
	<cffunction name="__subset" access="public" returntype="struct" output="no">
		<cfargument name="files" type="array" required="yes">
		<cfargument name="parent" type="any" required="yes">
		<cfargument name="all" type="boolean" required="yes">
		<cfset var table = __functions()>
		<cfset var state = __state(table)>
		<cfset var classes = __store().classes>
		<cfset var result = StructNew()>
		<cfset var entries = ArrayNew(1)>
		<cfset var entry = "">
		<cfset var kept = "">
		<cfset var names = "">
		<cfset var todo = "">
		<cfset var next = "">
		<cfset var sig = state.depsId>
		<cfset var name = "">
		<cfset var dep = "">
		<cfset var i = 0>

		<cfset result.count = StructCount(table)>
		<cfset result.all = arguments.all>
		<cfset result.id = "all">
		<cfset result.names = StructNew()>

		<cfif IsStruct(arguments.parent)>
			<cfif arguments.parent.all>
				<cfset result.all = true>
			</cfif>

			<cfset sig = sig & "," & arguments.parent.id>
		</cfif>

		<cfif NOT result.all>
			<cfloop from="1" to="#ArrayLen(arguments.files)#" index="i">
				<cfset entry = __classFile(arguments.files[i], state)>
				<cfset ArrayAppend(entries, entry)>
				<cfset sig = sig & "," & entry.id>

				<cfif entry.all>
					<cfset result.all = true>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>

		<cfif NOT result.all>
			<!--- What was worked out before holds as long as it was made from the same files, the same parent and the same functions. --->
			<cfif StructKeyExists(classes, arguments.files[1])>
				<cfset kept = classes[arguments.files[1]]>
			</cfif>

			<cfif NOT IsStruct(kept) OR kept.sig NEQ sig>
				<cfset names = StructNew()>

				<cfloop from="1" to="#ArrayLen(entries)#" index="i">
					<cfset StructAppend(names, entries[i].names)>
				</cfloop>

				<cfif IsStruct(arguments.parent)>
					<cfset StructAppend(names, arguments.parent.names)>
				</cfif>

				<!---
				 * The functions that those functions call. A name that is not
				 * a function in this request needs nothing. A function whose
				 * file was not read should not exist: then the class gets
				 * every function.
				--->
				<cfset kept = StructNew()>
				<cfset kept.all = false>
				<cfset todo = StructCopy(names)>

				<cfloop condition="NOT StructIsEmpty(todo) AND NOT kept.all">
					<cfset next = StructNew()>

					<cfloop collection="#todo#" item="name">
						<cfif StructKeyExists(state.deps, name)>
							<cfloop collection="#state.deps[name]#" item="dep">
								<cfif NOT StructKeyExists(names, dep)>
									<cfset names[dep] = true>
									<cfset next[dep] = true>
								</cfif>
							</cfloop>
						<cfelseif StructKeyExists(table, name)>
							<cfset kept.all = true>
						</cfif>
					</cfloop>

					<cfset todo = next>
				</cfloop>

				<cfset kept.sig = sig>
				<cfset kept.id = CreateUUID()>
				<cfset kept.names = names>
				<cfset classes[arguments.files[1]] = kept>
			</cfif>

			<cfset result.all = kept.all>
			<cfset result.id = kept.id>
			<cfset result.names = kept.names>
		</cfif>

		<cfif result.all>
			<cfset result.id = "all">
			<cfset result.table = table>
		<cfelse>
			<cfset result.table = StructNew()>

			<cfloop collection="#result.names#" item="name">
				<cfif StructKeyExists(table, name)>
					<cfset result.table[name] = table[name]>
				</cfif>
			</cfloop>
		</cfif>

		<cfset result.size = StructCount(result.table)>
		<cfset result.missing = StructCount(result.names) - result.size>

		<cfif result.all>
			<cfset result.missing = 0>
		</cfif>

		<cfreturn result>
	</cffunction>

	<!---
	 * The memory of the server that __subset() keeps its findings in:
	 * "files" (by path) and "classes" (by the path of the class file).
	--->
	<cffunction name="__store" access="private" returntype="struct" output="no">
		<cfset var store = "">

		<cfif NOT StructKeyExists(server, "ColdIgniterFunctions")>
			<cflock name="ColdIgniterFunctions" type="exclusive" timeout="10">
				<cfif NOT StructKeyExists(server, "ColdIgniterFunctions")>
					<cfset store = StructNew()>
					<cfset store.files = StructNew()>
					<cfset store.classes = StructNew()>
					<cfset server.ColdIgniterFunctions = store>
				</cfif>
			</cflock>
		</cfif>

		<cfreturn server.ColdIgniterFunctions>
	</cffunction>

	<!---
	 * Gives what is known about the global functions on this server:
	 * "known" (every name that was seen, which the words of a file are
	 * held against), "version" (changes when a name is added, and then
	 * every file is read again), "deps" (by function, the functions it
	 * names), "sources" (the files "deps" was made from) and "depsId"
	 * (changes with "deps").
	 *
	 * Two requests can store at the same time, and then one of them is
	 * lost. So each request looks whether its own files are in "sources"
	 * and puts them in again when they are not.
	--->
	<cffunction name="__state" access="private" returntype="struct" output="no">
		<cfargument name="table" type="struct" required="yes">
		<cfset var store = __store()>
		<cfset var state = "">
		<cfset var known = "">
		<cfset var old = "">
		<cfset var added = StructNew()>
		<cfset var entry = "">
		<cfset var path = "">
		<cfset var total = ArrayLen(variables.__required)>
		<cfset var name = "">
		<cfset var names = "">
		<cfset var i = 0>

		<cfif StructKeyExists(variables, "__merged") AND variables.__merged EQ StructCount(arguments.table) & "," & total>
			<cfreturn variables.__stateKept>
		</cfif>

		<cfif NOT StructKeyExists(variables, "__trust")>
			<cfset variables.__trust = StructKeyExists(request, "ENVIRONMENT") AND request.ENVIRONMENT EQ "production">
		</cfif>

		<cfif StructKeyExists(store, "state")>
			<cfset state = store.state>
		</cfif>

		<cfif NOT IsStruct(state) OR NOT state.known.containsAll(arguments.table.keySet())>
			<cfset known = CreateObject("java", "java.util.HashSet").init(arguments.table.keySet())>

			<cfif IsStruct(state)>
				<cfset known.addAll(state.known)>
			</cfif>

			<cfset state = StructNew()>
			<cfset state.version = CreateUUID()>
			<cfset state.known = known>
			<cfset state.depsId = CreateUUID()>
			<cfset state.deps = StructNew()>
			<cfset state.sources = StructNew()>
			<cfset store.state = state>
		</cfif>

		<!--- The files the global functions of this request come from: this folder and each file that __require() ran. --->
		<cfloop from="0" to="#total#" index="i">
			<cfif i EQ 0>
				<cfset path = GetDirectoryFromPath(GetCurrentTemplatePath())>
			<cfelse>
				<cfset path = variables.__required[i]>
			</cfif>

			<cfset entry = __sourceFile(path, state, i EQ 0)>

			<cfif NOT StructKeyExists(state.sources, path) OR state.sources[path] NEQ entry.id>
				<cfset added[path] = entry>
			</cfif>
		</cfloop>

		<cfif NOT StructIsEmpty(added)>
			<cfset old = state>
			<cfset state = StructNew()>
			<cfset state.version = old.version>
			<cfset state.known = old.known>
			<cfset state.depsId = CreateUUID()>
			<cfset state.deps = StructCopy(old.deps)>
			<cfset state.sources = StructCopy(old.sources)>

			<!--- A function that two files have gets the names of both: too many, never too few. --->
			<cfloop collection="#added#" item="path">
				<cfset entry = added[path]>
				<cfset state.sources[path] = entry.id>

				<cfloop collection="#entry.functions#" item="name">
					<cfif StructKeyExists(state.deps, name)>
						<cfset names = StructCopy(state.deps[name])>
						<cfset StructAppend(names, entry.functions[name])>
						<cfset state.deps[name] = names>
					<cfelse>
						<cfset state.deps[name] = entry.functions[name]>
					</cfif>
				</cfloop>
			</cfloop>

			<cfset store.state = state>
		</cfif>

		<!--- Looked at once for each size of the table: the files it comes from only change when a helper is loaded. --->
		<cfset variables.__merged = StructCount(arguments.table) & "," & total>
		<cfset variables.__stateKept = state>

		<cfreturn state>
	</cffunction>

	<!---
	 * Gives what a class file says about global functions: "names" (the
	 * ones it names) and "all" (it includes another file).
	--->
	<cffunction name="__classFile" access="private" returntype="struct" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfargument name="state" type="struct" required="yes">
		<cfset var files = __store().files>
		<cfset var entry = "">
		<cfset var stamp = "">
		<cfset var text = "">

		<cfif StructKeyExists(variables.__checked, arguments.path) AND variables.__checked[arguments.path].version EQ arguments.state.version>
			<cfreturn variables.__checked[arguments.path]>
		</cfif>

		<cfif StructKeyExists(files, arguments.path)>
			<cfset entry = files[arguments.path]>
		</cfif>

		<cfif IsStruct(entry) AND variables.__trust AND entry.version EQ arguments.state.version AND StructKeyExists(entry, "names")>
			<cfset stamp = entry.stamp>
		<cfelse>
			<cfset stamp = __stamp(arguments.path)>
		</cfif>

		<cfif NOT IsStruct(entry) OR entry.version NEQ arguments.state.version OR entry.stamp NEQ stamp OR NOT StructKeyExists(entry, "names")>
			<cffile action="read" file="#arguments.path#" variable="text">

			<cfset entry = StructNew()>
			<cfset entry.id = CreateUUID()>
			<cfset entry.version = arguments.state.version>
			<cfset entry.stamp = stamp>
			<cfset entry.all = FindNoCase(Chr(60) & "cfinclude", text) GT 0>
			<cfset entry.names = StructNew()>

			<cfif NOT entry.all>
				<cfset entry.names = __names(CreateObject("java", "java.util.Arrays").asList(UCase(text).split("[^A-Z0-9_]+")), arguments.state.known)>
			</cfif>

			<cfset files[arguments.path] = entry>
		</cfif>

		<cfset variables.__checked[arguments.path] = entry>

		<cfreturn entry>
	</cffunction>

	<!---
	 * Gives what a file of global functions says: "functions" (by
	 * function, the global functions it names). For this folder, every
	 * file in it is read.
	--->
	<cffunction name="__sourceFile" access="private" returntype="struct" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfargument name="state" type="struct" required="yes">
		<cfargument name="directory" type="boolean" required="yes">
		<cfset var files = __store().files>
		<cfset var entry = "">
		<cfset var stamp = "">
		<cfset var list = "">

		<cfif StructKeyExists(variables.__checked, arguments.path) AND variables.__checked[arguments.path].version EQ arguments.state.version>
			<cfreturn variables.__checked[arguments.path]>
		</cfif>

		<cfif StructKeyExists(files, arguments.path)>
			<cfset entry = files[arguments.path]>
		</cfif>

		<cfif IsStruct(entry) AND variables.__trust AND entry.version EQ arguments.state.version AND StructKeyExists(entry, "functions")>
			<cfset stamp = entry.stamp>
		<cfelseif arguments.directory>
			<cfdirectory action="list" directory="#arguments.path#" filter="*.cfm" name="list">
			<cfset stamp = ValueList(list.name) & ValueList(list.size) & ValueList(list.dateLastModified)>
		<cfelse>
			<cfset stamp = __stamp(arguments.path)>
		</cfif>

		<cfif NOT IsStruct(entry) OR entry.version NEQ arguments.state.version OR entry.stamp NEQ stamp OR NOT StructKeyExists(entry, "functions")>
			<cfset entry = StructNew()>
			<cfset entry.id = CreateUUID()>
			<cfset entry.version = arguments.state.version>
			<cfset entry.stamp = stamp>
			<cfset entry.functions = StructNew()>

			<cfif arguments.directory>
				<cfloop query="list">
					<cfset __scan(arguments.path & list.name, arguments.state.known, entry.functions)>
				</cfloop>
			<cfelse>
				<cfset __scan(arguments.path, arguments.state.known, entry.functions)>
			</cfif>

			<cfset files[arguments.path] = entry>
		</cfif>

		<cfset variables.__checked[arguments.path] = entry>

		<cfreturn entry>
	</cffunction>

	<!---
	 * Reads a file of functions and notes, for each function in it, the
	 * global functions it names. The text is cut at each cffunction tag,
	 * and the name of a function is the word after the first "name".
	--->
	<cffunction name="__scan" access="private" returntype="void" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfargument name="known" type="any" required="yes">
		<cfargument name="functions" type="struct" required="yes">
		<cfset var arrays = CreateObject("java", "java.util.Arrays")>
		<cfset var text = "">
		<cfset var chunks = "">
		<cfset var words = "">
		<cfset var names = "">
		<cfset var name = "">
		<cfset var at = 0>

		<cffile action="read" file="#arguments.path#" variable="text">

		<cfset chunks = arrays.asList(UCase(text).split(Chr(60) & "CFFUNCTION")).iterator()>

		<!--- What stands before the first function --->
		<cfset chunks.next()>

		<cfloop condition="chunks.hasNext()">
			<cfset words = arrays.asList(chunks.next().split("[^A-Z0-9_]+"))>
			<cfset at = words.indexOf("NAME")>

			<cfif at GTE 0 AND at + 1 LT words.size()>
				<cfset name = words.get(JavaCast("int", at + 1))>
				<cfset names = __names(words, arguments.known)>

				<cfif StructKeyExists(arguments.functions, name)>
					<cfset StructAppend(names, arguments.functions[name])>
				</cfif>

				<cfset arguments.functions[name] = names>
			</cfif>
		</cfloop>
	</cffunction>

	<!---
	 * Gives the words that are names of global functions. The other
	 * words are dropped here and are not kept anywhere.
	--->
	<cffunction name="__names" access="private" returntype="struct" output="no">
		<cfargument name="words" type="any" required="yes">
		<cfargument name="known" type="any" required="yes">
		<cfset var names = StructNew()>
		<cfset var set = CreateObject("java", "java.util.HashSet").init(arguments.words)>
		<cfset var each = "">

		<cfset set.retainAll(arguments.known)>
		<cfset each = set.iterator()>

		<cfloop condition="each.hasNext()">
			<cfset names[each.next()] = true>
		</cfloop>

		<cfreturn names>
	</cffunction>

	<!---
	 * Gives the time and the size of a file as one text.
	--->
	<cffunction name="__stamp" access="private" returntype="string" output="no">
		<cfargument name="path" type="string" required="yes">
		<cfset var file = CreateObject("java", "java.io.File").init(arguments.path)>

		<cfreturn file.lastModified() & "." & file.length()>
	</cffunction>

</cfcomponent>
