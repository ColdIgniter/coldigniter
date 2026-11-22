# Write ColdFusion MX 6.1 CFML that compiles first time

ColdFusion MX 6.1 is a tag-based language with word operators, no null, no literals, no interfaces and only `Application.cfm`, so correct code for it is closer to 2003 habits than to anything a modern CFML tool suggests. A CodeIgniter 4 port is workable on it: components, inheritance with multi-level `super`, typed exception hierarchies, first-class functions, `cfsavecontent`, full HTTP method and status control through IIS 4, and the Java 1.4.2 class library all work on the target server. The three facts that shape the design most were all found by testing the real server and contradict or go beyond the manuals: **components cannot be found "up or across" folders without a ColdFusion mapping**, **`super` accepts positional arguments only**, and **a `cfinclude` inside a method copies that method's `var` locals into the component instance**, so views must be rendered by a throwaway object. Start with one mapping test, then build CodeIgniter's own boot order one small slice at a time, keeping everything in the Request scope.

## How to read the evidence marks

Every fact carries one of four marks. Where they conflict, the server wins.

| Mark | Meaning | Source |
|---|---|---|
| **[S]** | Verified on the 6.1 server, 2026-11-22 | `server_probe_results.md` (raw output in `server_probe_raw_round1.txt` and `server_probe_raw_round2.txt`) |
| **[M]** | From the 6.1 manuals, with printed page | Dev = *Developing ColdFusion MX Applications*; Ref = *CFML Reference*; Adm = *Configuring and Administering*; Ins = *Installing*; all under `cfmx_6.1_docs_en/` |
| **[W]** | From a web source, linked inline | Mostly later-version or period community sources |
| **[U]** | Not verified: an inference or design choice that needs a test | Collected in "What still needs a test" near the end |

Notes folder: `contributing/cfml/notes/`. CodeIgniter references are to the 4.7.6 clone at `codeigniter4/`, written `CI:<path>`. Code examples below use only constructs that are verified or documented, but the examples themselves were not run as written unless marked [S].

## The server is the original 6.1 on NT 4, IIS 4 and Java 1.4.2

All rows are [S] unless marked.

| Item | Value |
|---|---|
| Product | ColdFusion Server 6,1,0,63958 Standard |
| Build meaning | 63958 is the original 6.1 release; the Updater is 83762 ([Adobe TechNote](https://helpx.adobe.com/coldfusion/kb/coldfusion-mx-determining-version-information.html)) [W] |
| OS and web server | Windows NT 4.0, Microsoft-IIS/4.0, HTTP/1.1, `Connection: close` on every response |
| Java | Sun 1.4.2, class version 48.0, `file.encoding=Cp1252`; JRun 4, Servlet API 2.3 |
| Site home | `D:\Inetpub\vhosts\coldigniter.lan\public`; repository root is its parent |
| ColdFusion root | `C:\CFusionMX`; logs in `C:\CFusionMX\logs` [M Adm p.31] |
| Mappings | Only `/CFIDE` |
| Data sources | None defined |
| Caching | Trusted cache OFF, save class files ON, template cache size 1024 |
| Whitespace management | OFF |
| `ExpandPath("/")` | `C:\CFusionMX\wwwroot\`, not the site home |

A class version of 48 means **any Java library must be compiled for Java 1.4 or older** ([Wikipedia](https://en.wikipedia.org/wiki/Java_class_file)) [W].

## Hard rules of the 6.1 language

### What compiles and what does not

| Construct | Result on 6.1 | Use instead |
|---|---|---|
| `==`, `!=`, `<`, `>`, `&&`, `\|\|`, `!`, `++`, `+=` | Compile error (`==` in `cfif` tested) [S]; none exist in tags or CFScript [M Dev p.129] | `EQ NEQ LT LTE GT GTE AND OR NOT`, `x = x + 1` |
| `[1,2]`, `{a=1}` literals | Compile error [S] | `ArrayNew(1)` plus `ArrayAppend`; `StructNew()`; `ListToArray("a,b")` |
| `s[k]("z")` (call through bracket lookup) | Compile error [S] | `cfinvoke` with a dynamic `method`, or copy to a variable first |
| `(expr).method()` | Compile error [S] | Assign to a variable, then call |
| `cfset var` after any other statement | Compile error: "must be grouped at the top of the function body" [S] | All `var` lines first, each with an initial value [M Dev p.198] |
| CFScript `throw`, `rethrow`, `finally` | `throw` is not a statement: "Variable THROW is undefined" [S]; none exist [M Dev p.129-130] | A tag-based UDF wrapping `cfthrow`; `cfrethrow` |
| `Application.cfc` | Ignored; `onRequestStart` never runs [S] | `Application.cfm`, `OnRequestEnd.cfm`, `cfapplication` |
| `component { }`, `new`, `local` scope, `cfinterface`, `onMissingMethod` | Do not exist (arrived in 8 or 9) ([cfdocs](https://cfdocs.org/coldfusion-versions)) [W] | `cfcomponent` tags, `CreateObject(...).init()` |
| `JavaCast("bool", x)` | Fails [S] | `JavaCast("boolean", x)` |
| Several `cfreturn` tags in one function | Works [S] (the manual implies one) | |
| `returntype="void"` | Works [S] | |
| `CreateObject("component", n).init(a).method()` | Works [S] | |
| Method call on a function result, array element or struct member | Works [S] | |
| Functions as values: pass, store, call `arguments.fn(1)`, `variables[name]`, `Evaluate("#name#(1)")` | Works; `IsCustomFunction` is YES [S] | No closures: a UDF cannot capture variables [W [cfdocs](https://cfdocs.org/closures)] |
| Nested struct auto-creation (`a.b.c = 1`) | Works [S] | |
| `AND` / `OR` short-circuit | Yes [S] | |

### Operators, numbers and comparison

- Operators are words. Arithmetic is `+ - * /`, `\` integer division, `^` power, `MOD`; string concatenation is `&`; Boolean operators are `NOT AND OR XOR EQV IMP` [M Dev p.85, p.87].
- **`EQ` coerces.** All of these are YES: `1 EQ "1.0"`, `"1e3" EQ 1000`, `"a" EQ "A"`, `"yes" EQ true`, `"01" EQ 1` [S]. Use **`Compare(a, b) EQ 0`** for exact, case-sensitive string equality (tokens, hashes, route segments, version strings).
- `IsDate("1,2")` is YES and `IsBoolean(2)` is YES [S]. Do not use the `Is*` functions as input validators without an extra pattern test.
- Integers are 32-bit; larger values become floating point [M Dev p.53]. `7/2` is 3.5, `7\2` is 3, `0.1+0.2` prints 0.3, `1000000*1000000` prints `1E+012`, `2^40` prints `1.09951162778E+012` (about 12 significant digits) [S]. Use `NumberFormat` or `java.math.BigDecimal` when a large number must print in full.
- Booleans print as `YES` and `NO` [S]. Never write a Boolean straight into JSON or a URL.

### No null, and how undefined behaves

There is no null value [M Dev p.56]. A null from Java or a database becomes an undefined variable or an empty string. Test with `StructKeyExists(scope, "key")` (preferred) or `IsDefined("name")`; `IsDefined("a[3]")` is always false [M Dev p.78]. A port of PHP code that returns `null` needs an agreed stand-in per method: an empty string, a "found" flag in a struct, or a typed exception.

Undefined CGI variables are a special case: **every CGI variable name tests as defined and returns an empty string** [S]. Test CGI values with `Len()`, never with `IsDefined`.

### Scopes and `var`

- Unscoped names are looked up in this order: function locals, Arguments, Variables, CGI, Cffile, URL, Form, Cookie, Client [M Dev p.77, p.198]. Always write the scope prefix for anything that is not a `var` local.
- Inside a component, **an unscoped assignment lands in the instance's Variables scope** [S]. A missing `var` therefore turns a local into shared instance state. This is the most common serious bug in 6.1 component code.
- `var` lines must be the first statements of the function and must have an initial value [S] [M Dev p.198]. Loop indexes, query names, `cfsavecontent` variables and `cfcatch`-derived values all need a `var` line.
- The Application scope does not exist until `cfapplication` has run: using it earlier throws "The requested scope application has not been enabled" [S]. `cfapplication` may run late in the request and still works [S].
- The Request scope is visible inside components [S]. It is the right home for per-request framework state.
- Variables, Request, Form, URL, CGI, Cookie and Server all pass `IsStruct` [S], so `StructKeyExists(form, "x")` and `form[name]` work.

### Data passing

| Type | Assignment | Passing to a function |
|---|---|---|
| Simple values | Copy | Copy |
| Arrays | **Copy** [S] | **Not copied on the way in**: changing `arguments.a` changes the caller's array, in UDFs and CFC methods alike [S]. This contradicts the manual. |
| Structs, queries, components | Reference [S] | Reference |

To mutate an array privately, copy it into a `var` first; that copy is independent [S].

```cfm
<cffunction name="withExtra" returntype="array" output="no">
	<cfargument name="items" type="array" required="yes">
	<cfset var copy = arguments.items>
	<cfset ArrayAppend(copy, "extra")>
	<cfreturn copy>
</cffunction>
```

### Structs, arrays and lists

- `s.fooBar = 1` stores the key as `FOOBAR`; `s["bazQux"] = 1` keeps the case [S]. Use bracket notation whenever key case matters (JSON output, HTTP header names, anything shown to a user). Lookups are case-insensitive either way.
- **Struct key order is not preserved** [S]. PHP arrays are ordered, so anything CodeIgniter iterates in insertion order (routes, filters, headers, config lists) needs an array of structs, or a struct plus a separate array of keys.
- `java.util.LinkedHashMap` keeps insertion order, passes `IsStruct`, and works with `StructKeyList` and `StructKeyExists`, but **its keys are case-sensitive** (`StructKeyExists(m, "ALPHA")` is NO for key `alpha`) [S]. Use it only with bracket notation and one fixed key case.
- Arrays are 1-based and built only with functions; most mutating functions return `True`, not the collection [M Ref p.376-394].
- **List functions skip empty elements**: `ListLen("a,,b")` is 2 and `ListToArray("a,,b")` has 2 elements [S]. Never parse CSV, query strings or URI segments with list functions where an empty field means something.
- `cfloop` has five forms: index, condition, query, list, collection (struct). There is no array form and no `cfcontinue` [M Ref p.232-239]. Loop arrays by index to `ArrayLen`.

### CFScript limits

CFScript in 6.1 has `if / else if`, `switch`, `for`, `while`, `do-while`, `for (k in struct)`, `break`, `continue`, `return`, `var`, `try / catch` and function definitions [M Dev p.129-130]. It cannot contain tags, so it cannot query, include, throw, lock, set headers or save content. `catch(Any e)` gives `e.type` and `e.message` [S]. `WriteOutput` exists [S]. **Recommendation: write components and framework code in tags.** Use `cfscript` only for dense pure logic (string and array loops), and call tag-based wrapper functions for anything else.

### Calling functions

- Positional or named arguments, never mixed in one call [M Dev p.192-193].
- Named arguments work; extra positional arguments are reachable as `arguments[3]` [S].
- `f(argumentCollection = s)` works for direct calls **when the struct keys are argument names** [S]. **Numeric keys do not fill positional arguments** [S]. To pass a positional list dynamically, build a name-keyed struct from the target's parameter names (`GetMetaData`) or build a call string for `Evaluate`.
- `cfinvoke` with a dynamic `method` and `argumentcollection` works [S] and is the standard dynamic dispatch tool.
- A function used as a value keeps no link to its component: calling a detached method fails with "Element NAME is undefined in VARIABLES" [S]. Dispatch through `cfinvoke`, not through a copied function reference.

### Error handling

- `cftry` / `cfcatch` / `cfthrow` / `cfrethrow` exist; `cffinally` does not [M Ref p.338, p.297]. Repeat clean-up code in the `cftry` body and in the `cfcatch` before `cfrethrow`.
- **Dotted custom types match as a hierarchy**: a throw of `ci.http.notfound` is caught by `type="ci.http"` and by `type="ci"`, is not caught by `type="application"`, and is caught by `type="any"` [S]. This is the stand-in for PHP exception class inheritance.
- `cfcatch` carries `Type`, `Message`, `Detail`, `ErrorCode`, `ExtendedInfo`, `StackTrace` and `TagContext` [S]. Java exceptions can be caught by class name (`type="java.lang.NumberFormatException"`) [S]. `type="any"` does not catch every Java `Throwable` [M Dev p.289-290].
- A compile error in an included template is catchable, with type `Template` [S]. The front controller can therefore show a framework error page for a broken view or controller file.
- A failed component type check on `cfargument` throws an exception whose **type is the component name** [S].
- `cferror` in `Application.cfm` is the last resort for errors nothing caught [M Ref p.102]. `OnRequestEnd.cfm` does not run after an error, `cfabort` or `cfexit` [M Dev p.271].

```cfm
<!--- system/Common.cfm: throw() for use from cfscript and expressions --->
<cffunction name="throw" returntype="void" output="no">
	<cfargument name="type" type="string" required="yes">
	<cfargument name="message" type="string" default="">
	<cfargument name="detail" type="string" default="">
	<cfthrow type="#arguments.type#" message="#arguments.message#" detail="#arguments.detail#">
</cffunction>

<cftry>
	<cfset throw("ci.http.notfound", "No route for /about")>
	<cfcatch type="ci.http">
		<cfheader statuscode="404" statustext="Not Found">
		<cfoutput>#HTMLEditFormat(cfcatch.message)#</cfoutput>
	</cfcatch>
</cftry>
```

`IsDefined("throw")` is NO on a stock page [S], so the name is free for a UDF.

### The application framework is `Application.cfm` only

ColdFusion runs the nearest `Application.cfm` found by walking up from the requested page's folder, then the page, then `OnRequestEnd.cfm` from the same folder [M Dev p.271]. `cfapplication` names the application and switches on Session and Client management [M Ref p.51]. There are no start or end events. One-time setup is a check, an exclusive named lock, and a second check [M Dev p.275-276, Ref p.221-222]:

```cfm
<cfif NOT StructKeyExists(application, "ciReady")>
	<cflock name="ci_boot_#application.applicationname#" type="exclusive" timeout="30">
		<cfif NOT StructKeyExists(application, "ciReady")>
			<cfset application.routes = CreateObject("component", "coldigniter.system.Router.RouteCollection").init()>
			<cfset application.ciReady = true>
		</cfif>
	</cflock>
</cfif>
```

Named `cflock` works [S]. The manual still asks for locks around writes to Session, Application and Server data and around reads of data that can change [M Dev p.331-340]. Sleeping is `CreateObject("java", "java.lang.Thread").sleep(ms)` [S]; there is no `Sleep()` and no `cfthread`.

## CFCs in 6.1 and the conventions to follow

### What a component is and is not

| Fact | Mark |
|---|---|
| `cfcomponent` accepts only `extends`, `output`, `displayname`, `hint` | [M Ref p.85-86] |
| `cfproperty` is documentation and metadata only; it creates no variable | [M Ref p.280] |
| Access levels: `private` (callable from the component **and its children**, so it means protected), `package`, `public`, `remote` | [M Dev p.247-248]; private from child works, from outside fails [S] |
| The pseudo-constructor (code outside functions) runs for parent and child at creation | [S] |
| A base `init()` can use `This` and `return this`; the caller gets the full child instance | [S] (the manual says otherwise) |
| `super` works through at least three levels | [S] (the manual says one) |
| **`super.method(name=value)` and `super.method(argumentCollection=s)` fail**: "Cannot invoke method init on an object of type coldfusion.runtime.Struct with named arguments. Use ordered arguments instead." | [S] |
| A child with no `init` inherits the parent's | [S] |
| Variables scope of an instance holds every method, `THIS`, and the instance data | [S] |
| `GetMetaData(obj)` keys: `PATH`, `TYPE`, `NAME`, `OUTPUT`, `EXTENDS`, `FUNCTIONS` | [S] |
| `NAME` in metadata has no package prefix when the component was found relative to the caller (`Foo`), and has one when found from the web root (`_t.Child`) | [S] |
| Without `output="no"`, each method call emits whitespace into the response | [S] |
| `Duplicate()` on a component is broken (the copy loses its Variables) | [S] |
| Functions in a file included from the pseudo-constructor become methods (mixin) | [S] |
| A function assigned onto an instance (`obj.inj = udf`) runs against that instance's Variables | [S] |
| No interfaces, no abstract, no static, no `onMissingMethod`, no `IsInstanceOf` | [M] absent from Ref; arrived in 8 ([cfdocs](https://cfdocs.org/cfinterface), [cfdocs](https://cfdocs.org/isinstanceof)) [W] |
| Creating an instance is costly; calling a method is cheap | [M Dev p.221]; timing on this hardware untested [U] |
| Components kept in shared scopes need locking; Session components do not serialise | [M Dev p.248] |

### The house conventions

1. **One class per `.cfc`, file name equal to the CodeIgniter class name**, same folder.
2. `output="no"` on every `cfcomponent` and every `cffunction` that does not deliberately write output.
3. An `init()` method on every component, `returntype="any"`, ending in `<cfreturn this>`. Always create with `CreateObject("component", name).init(...)`.
4. All `var` lines first. Scope everything else: `arguments.`, `variables.`, `this.`, `request.`.
5. Private data in `variables.instance` (a struct), following Macromedia's own coding guidelines of the period ([Corfield, ColdFusion MX Coding Guidelines 3.1](http://web.archive.org/web/20041229212714/http://livedocs.macromedia.com:80/wtg/public/coding_standards/printable.html)) [W]. Public config fields go on `This` so they read like PHP public properties.
6. **Call `super` with positional arguments only**, so keep the argument order of every overridable method stable and identical to CodeIgniter's.
7. Declare `access` on every function. Use `private` where PHP says `protected` or `private`.
8. Never use `Duplicate()` on a component; write a `clone()` method where CodeIgniter relies on `clone` (Response, URI, Time).
9. Keep each function short. A method or template that compiles to more than 64 KB of bytecode fails with "Branch target offset too large for short" ([newsgroup thread](https://groups.google.com/g/macromedia.coldfusion.advanced_techniques/c/rZsfM0TPn8c), [Adam Presley 2009](https://adampresley.github.io/2009/04/13/coldfusion-branch-target-offset-too-large-for-short.html)) [W].

```cfm
<!--- system/HTTP/Message.cfc --->
<cfcomponent output="no" hint="Port of CodeIgniter\HTTP\Message">

	<cffunction name="init" access="public" returntype="any" output="no">
		<cfargument name="body" type="string" default="">
		<cfset variables.instance = StructNew()>
		<cfset variables.instance.body = arguments.body>
		<cfset variables.instance.headers = StructNew()>
		<cfreturn this>
	</cffunction>

	<cffunction name="setHeader" access="public" returntype="any" output="no">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="value" type="string" required="yes">
		<cfset variables.instance.headers[arguments.name] = arguments.value>
		<cfreturn this>
	</cffunction>

	<cffunction name="getBody" access="public" returntype="string" output="no">
		<cfreturn variables.instance.body>
	</cffunction>

</cfcomponent>
```

```cfm
<!--- system/HTTP/Response.cfc --->
<cfcomponent extends="Message" output="no" hint="Port of CodeIgniter\HTTP\Response">

	<cffunction name="init" access="public" returntype="any" output="no">
		<cfargument name="body" type="string" default="">
		<cfargument name="statusCode" type="numeric" default="200">
		<!--- positional only: named arguments through super fail on 6.1 --->
		<cfset super.init(arguments.body)>
		<cfset variables.instance.statusCode = arguments.statusCode>
		<cfreturn this>
	</cffunction>

</cfcomponent>
```

`extends="Message"` works because the parent is a sibling file [S]. Any parent in another folder needs the full mapped name (see "How components are located").

### Stand-ins for missing object features

| PHP feature | 6.1 stand-in | Mark |
|---|---|---|
| Interface | A base CFC whose methods throw `ci.notimplemented`, plus an optional check that walks `GetMetaData(obj).functions` for a required method list | [U] design |
| Abstract method | A method body that is one `cfthrow` | [U] design |
| Static method or property | One shared instance reached through `service()`, or a UDF in `Common.cfm` | [U] design |
| Trait | A `.cfm` file of `cffunction` tags included in the pseudo-constructor | mechanism [S] |
| `instanceof` | Walk the `extends` chain of `GetMetaData(obj)` | [W] ([cfdocs](https://cfdocs.org/isinstanceof)); chain shape below top level untested [U] |
| `__call`, `__get` | None; define every method, or one `call(name, args)` method using `cfinvoke` | [W] ([cfdocs](https://cfdocs.org/onmissingmethod)) |
| Closure | A named UDF passed as a value, or a struct `{component, method}` dispatched with `cfinvoke` | passing [S] |
| `clone` | A hand-written `clone()` | `Duplicate` broken [S] |
| Variadic arguments | Read `arguments[n]` up to `ArrayLen(arguments)` | extras readable [S] |

Because the metadata `NAME` changes with how the component was found [S], an `isA()` helper should compare the metadata `PATH` (the physical file) or always create components by full mapped name.

```cfm
<!--- mixin: system/Traits/ResponseTrait.cfm holds plain cffunction tags --->
<cfcomponent extends="coldigniter.system.Controller" output="no">
	<cfinclude template="../../system/Traits/ResponseTrait.cfm">
</cfcomponent>
```

### Persistence and thread safety

Per-request objects need no locking. A component stored in the Application or Session scope is shared by concurrent requests, so every non-`var` write inside it is a race. Three rules follow:

- A shared singleton must hold only data that is fixed after `init()`.
- **Never `cfinclude` a view from a method of a shared instance.** After the include, the method's `var` locals and anything the included file set are copied into the instance's Variables scope [S]. Render through an object created for that one render.
- Create shared objects inside the double-checked lock shown earlier, and give the framework a reload switch (for example a URL key allowed only in development) because the server has no application restart function [W] ([cfdocs](https://cfdocs.org/applicationstop)).

## Tags and functions: what exists, and what to use for what is missing

### Inventory by category

The 6.1 Reference has **101 tags** [M Ref p.47-361] and **270 function entries** [M Ref p.374-748]. `GetFunctionList()` on the server reports **262** [S]. Comparing the two lists, the 8 names the server does not report are the five obsolete security functions (`AuthenticatedContext`, `AuthenticatedUser`, `IsAuthenticated`, `IsAuthorized`, `IsProtected`) and `GetEncoding`, `SetEncoding`, `URLSessionFormat`; whether the last three can still be called is untested [U]. **The full per-item lists, with signatures and pages, are in `tags_and_functions.md`.** Anything not listed there does not exist in 6.1.

| Tag group (manual's grouping, Ref p.39-41) | Tags a framework uses |
|---|---|
| Application framework | `cfapplication`, `cflock`, `cferror`, `cfmodule`, `cfimport`, `cfscript` |
| Components and functions | `cfcomponent`, `cffunction`, `cfargument`, `cfreturn`, `cfinvoke`, `cfinvokeargument`, `cfobject`, `cfproperty` |
| Flow control | `cfif`, `cfelseif`, `cfelse`, `cfswitch`, `cfcase`, `cfdefaultcase`, `cfloop`, `cfbreak`, `cfinclude`, `cfabort`, `cfexit`, `cflocation` |
| Exceptions | `cftry`, `cfcatch`, `cfthrow`, `cfrethrow` |
| Variables and output | `cfset`, `cfparam`, `cfoutput`, `cfsavecontent`, `cfsilent`, `cfsetting`, `cfprocessingdirective`, `cfflush`, `cfhtmlhead` |
| HTTP | `cfheader`, `cfcontent`, `cfcookie`, `cfhttp`, `cfhttpparam`, `cfcache` |
| Database | `cfquery`, `cfqueryparam`, `cfstoredproc`, `cfprocparam`, `cfprocresult`, `cftransaction`, `cfinsert`, `cfupdate`, `cfobjectcache` |
| Files | `cffile`, `cfdirectory`, `cfftp`, `cfexecute`, `cfregistry` |
| Data formats | `cfwddx`, `cfxml` |
| Mail and protocols | `cfmail`, `cfmailparam`, `cfmailpart` (new in 6.1), `cfpop`, `cfldap` |
| Debugging and logging | `cfdump`, `cftrace`, `cflog` |
| Security | `cflogin`, `cfloginuser`, `cflogout` |
| Forms, charts, search, scheduling | `cfform` family (Java applet controls), `cfchart` family, Verity tags, `cfschedule`, `cfreport` |

| Function category (count in the notes) | Notes for a framework |
|---|---|
| String (31), Display and formatting (17) | `Find`, `Replace`, `REFind`, `REReplace`, `Mid`, `Left`, `Trim`, `HTMLEditFormat`, `JSStringFormat`, `URLEncodedFormat`, `XMLFormat`, `Wrap` (new in 6.1) |
| List (21) | Always skip empty elements |
| Array (19), Structure (16) | Function-built only; no search or iteration functions |
| Decision (22) | `IsArray`, `IsStruct`, `IsQuery`, `IsObject`, `IsCustomFunction`, `IsSimpleValue`, `IsBinary`, `IsDefined`, `IsNumeric`, `IsDate`, `IsBoolean`, `IsWddx`, `IsXmlDoc` |
| Date and time (41), International (6) | `Now`, `DateAdd`, `DateDiff`, `DateFormat`, `TimeFormat`, `GetHttpTimeString`, `GetTimeZoneInfo`, `GetTickCount` |
| Mathematical (34) | `Int`, `Round`, `Fix`, `RandRange`, bit functions |
| Conversion (9), Query (5) | `ToBase64`, `ToBinary`, `ToString`, `JavaCast`, `Val`; `QueryNew`, `QueryAddRow`, `QuerySetCell`, `ValueList` |
| Dynamic evaluation (3) | `Evaluate`, `DE`, `IIf` [M Ref p.468, 458, 517] |
| System (17), Extensibility (7), Other (11) | `ExpandPath`, `FileExists`, `DirectoryExists`, `GetCurrentTemplatePath`, `GetBaseTemplatePath`, `GetDirectoryFromPath`, `GetTempDirectory`, `CreateObject`, `GetMetaData`, `GetPageContext`, `GetHttpRequestData`, `CreateUUID`, `Hash`, `Duplicate` |

### Details of the tags a framework depends on

**Output control.** `cfsavecontent` captures output into a variable and nests correctly [S]; it is the stand-in for `ob_start()` [M Ref p.300]. Under `cfsetting enablecfoutputonly="yes"`, text that is not inside `cfoutput` is discarded, also inside `cfsavecontent` [S], so pick one output mode for the whole framework. `cfcontent reset="yes"` discards output generated so far [M Ref p.87-89]. After `cfflush`, `cfheader`, `cfcookie`, `cfcontent`, `cflocation` and `cfhtmlhead` fail [M Ref p.130], so the framework must never flush before the response object has sent its headers.

**Includes.** `cfinclude template` takes a path relative to the current file or a mapped logical path, never a physical path [M Ref p.192]. A relative include may climb out of the web root with `../` [S]. Included code shares the including page's Variables scope and, inside a method, sees its `var` locals and arguments [S].

**HTTP.** `cfheader` has two forms: `name` plus `value`, or `statuscode` plus `statustext` [M Ref p.171-172]. `cflocation` always sends 302 and has no status attribute [S] [M Ref p.220]. `cfcookie` has no HttpOnly attribute and upper-cases cookie names [S] [M Ref p.91-92]. `GetHttpRequestData()` returns `content`, `headers`, `method`, `protocol` [S]; `content` is a string for `text/*` and form-urlencoded bodies and binary otherwise [M Ref p.491], so guard a JSON body with `IsBinary` and `ToString`. `cfhttp` supports GET, POST, PUT, DELETE, HEAD, TRACE, OPTIONS but not PATCH, follows at most four redirects, and always writes its result to the fixed `cfhttp` structure [M Ref p.174-182].

**Database.** `cfquery` needs `name` and `datasource` and has no `result` attribute, so there is no built-in insert id or affected-row count; use database-specific SQL in the same `cftransaction` [M Ref p.282-285] (same-connection behaviour untested [U]). `cfqueryparam` requires the `CF_SQL_` prefix and supports `null="yes"` and `list="yes"` [M Ref p.286-288]. `cfqueryparam` inside `cfloop` inside `cfquery` works, and SQL held in a variable needs `PreserveSingleQuotes()` [S] (both tested with query of queries). Query of queries is SELECT-only, with two-table comma joins and no table aliases [M Dev p.451-475]. `cftransaction` has begin, commit, rollback and isolation, no savepoints [M Ref p.343].

**Files.** All file work is `cffile` and `cfdirectory`; the only file functions are `FileExists` and `DirectoryExists`. A relative `cffile` path resolves against the ColdFusion temp directory, so always pass absolute paths [M Ref p.110-129]. `cffile` with `charset="utf-8"` works [S]. `cfdirectory` list columns are `ATTRIBUTES, DATELASTMODIFIED, MODE, NAME, SIZE, TYPE` [S]; there is no `recurse` [M Ref p.95-97].

**Serialisation.** WDDX (`cfwddx`) and XML (`XmlParse`, `XmlSearch`, `cfxml`) work [S]. **There is no JSON support of any kind**; the framework needs a hand-written encoder and parser, and should use WDDX for its own cache and session payloads.

**Regular expressions.** `REFind` and `REReplace` (and the NoCase forms) are the only functions. Lookahead, non-greedy quantifiers and POSIX classes work; **lookbehind fails** ("Sequence (?<...) not recognized") [S]. Replacement backreferences are `\1`, not `$1` [M Dev p.159-160]. `java.util.regex.Pattern` is available and supports lookbehind [S]; use it for the router if CodeIgniter's patterns need more than `REFind` offers.

### Not in 6.1: use this instead

A shortened table. The full version, with arrival version and source for every row, is the last section of `tags_and_functions.md`. Absence is from the 6.1 Reference [M]; rows marked [S] were also confirmed absent by `GetFunctionList()` or a compile test.

| Not in 6.1 | Arrived | The 6.1 way |
|---|---|---|
| `Application.cfc` and its events [S] | 7 | `Application.cfm`, `OnRequestEnd.cfm`, lock-guarded lazy setup |
| Per-application mappings | 8 | Mappings set in the Administrator |
| `cfinterface`, `implements`, `onMissingMethod`, `IsInstanceOf` [S] | 8 | Base CFC with throwing stubs; explicit methods; metadata walk |
| Script components, `new`, `local` scope, `var` anywhere | 9 | Tag components, `CreateObject().init()`, `var` at the top |
| `==`, `!=`, `&&`, `\|\|`, `!`, `++`, `+=`, `&=` [S] | 8 | Word operators, `x = x + 1`, `s = s & "x"` |
| `[]` and `{}` literals [S] | 8 | `ArrayNew(1)`, `StructNew()`, `ListToArray()` |
| Ternary `? :`, Elvis `?:` | 9, 11 | `cfif`, or `IIf(c, DE(a), DE(b))` with care |
| `null`, `IsNull` | 2018, 9 | `StructKeyExists` / `IsDefined` |
| Script `throw` [S], `finally`, `cffinally`, `cfcontinue` | 9 | UDF wrapping `cfthrow`; repeated clean-up; `cfif` around the loop body |
| Closures, `ArrayEach`, `ArrayMap`, member functions | 10, 11 | Named UDFs and explicit loops |
| Ordered structs | 2016 | Array of structs, key array, or `java.util.LinkedHashMap` [S] |
| `SerializeJSON`, `DeserializeJSON`, `IsJSON` [S] | 8 | Hand-written encoder and parser; WDDX internally |
| `IsValid` [S], `cfparam` patterns | 7 | `IsNumeric`, `REFind` patterns, hand validation |
| `Hash(s, "SHA-256")`, `Encrypt` with AES, `GenerateSecretKey` | 7 | `java.security.MessageDigest`, `javax.crypto` [S] |
| `HMAC()`, `EncodeForHTML`, `CSRFGenerateToken`, `SessionRotate` | 10 | `javax.crypto.Mac` (HmacSHA1 only) [S]; `HTMLEditFormat`; hand-written tokens |
| `CharsetEncode`, `BinaryEncode` [S] | 7 | `ToBase64`, `ToBinary`, `ToString(binary, encoding)`, Java `String.getBytes` |
| `REMatch` [S] | 8 | `REFind` with subexpressions in a loop, or `java.util.regex` |
| `ArrayContains` [S], `ArrayFind`, `ArraySlice`, `ArrayIsDefined` | 8 to 10 | Loops |
| `FileRead` [S], `FileWrite`, `DirectoryList` | 8, 9 | `cffile`, `cfdirectory`, `java.io.File` |
| `Sleep` [S], `cfthread` | 8 | `java.lang.Thread.sleep()` [S]; `cfschedule` or a second HTTP request |
| `GetContextRoot` [S] | 7 | `GetPageContext().getRequest().getContextPath()` |
| `Invoke()`, `GetComponentMetaData` | 10, 8 | `cfinvoke`; `GetMetaData(CreateObject(...))` |
| `DateTimeFormat` | 10 | `DateFormat(d, m) & " " & TimeFormat(d, m)` |
| `cfquery result`, generated key | 7, 8 | `q.RecordCount`, `cfquery.ExecutionTime`; database-specific SQL |
| `cflocation statusCode` | 8 | `cfheader statuscode` + `cfheader name="Location"` + `cfabort` [S] |
| `cfcookie httpOnly` | 9 | `cfheader name="Set-Cookie"` [S] |
| `cfdirectory recurse`, `cfloop array`, `cfinclude runOnce` | 7, 8, 10 | Recursive UDF; index loop; a Request-scope flag |
| `cfdump abort`, `output`, `top` | 7 to 9 | `cfdump` then `cfabort`; `cfsavecontent` around `cfdump` |
| `cfhttp result`, PATCH | 7 | Fixed `cfhttp` struct; Java HTTP client for PATCH |
| `cfmail useSSL` / `useTLS` | 8 | Plain SMTP with optional AUTH |
| `cftimer`, `cfzip`, `cfimage`, `cfdocument`, `cfdbinfo`, `cffeed` | 7, 8 | `GetTickCount()`; `java.util.zip`; `java.awt` / `javax.imageio`; none; catalog tables; `cfhttp` + `XmlParse` |

## Mirroring CodeIgniter 4 on 6.1

### Same folders, same file names

Keep CodeIgniter's tree unchanged: `app/`, `public/`, `system/`, `tests/`, `writable/`, plus `vendor/` (CI:user_guide_src/source/concepts/structure.rst). Each PHP class file becomes a `.cfc` of the same name in the same folder; each PHP file that is not a class becomes a `.cfm` of the same name.

| CodeIgniter file | CFML port file | Kind |
|---|---|---|
| `public/index.php` | `public/index.cfm` | Front controller page |
| (none) | `public/Application.cfm` | `cfapplication` and last-resort `cferror` only |
| `app/Config/Paths.php` | `app/Config/Paths.cfc` | Config component |
| `system/Boot.php` | `system/Boot.cfc` | Component |
| `app/Config/Constants.php`, `system/Common.php`, `app/Common.php` | same names, `.cfm` | Included files |
| `app/Config/Routes.php` | `app/Config/Routes.cfm` | Included file that calls `routes.get(...)` |
| `app/Config/App.php`, `Autoload.php`, `Services.php`, `Filters.php` | same names, `.cfc` | Config components |
| `system/CodeIgniter.php`, `system/Router/Router.php`, `system/HTTP/Response.php` | same names, `.cfc` | Components |
| `app/Controllers/Home.php`, `BaseController.php` | same names, `.cfc` | Components |
| `app/Views/welcome_message.php` | `app/Views/welcome_message.cfm` | View template |
| `app/Helpers/*_helper.php` | `app/Helpers/*_helper.cfm` | UDF files |
| `vendor/autoload.php` | `vendor/autoload.cfm` | Included file |

**Rule for every ported class:** open the PHP file, keep the public method names and argument order, leave unported methods as stubs that throw `ci.notimplemented`, and note each deliberate difference (no closures, no null, ordered arrays in place of maps) in a comment at the top of the CFC. That keeps the port comparable against future CodeIgniter releases.

### How components are located: one mapping is unavoidable

Tests on the server [S]:

- `CreateObject("component", name)` resolves **relative to the folder of the file that contains the call**, including for a file that was reached by `cfinclude` from elsewhere.
- From a page in the web root, dotted names resolve against the IIS site home (`public/`).
- `extends="Base"` for a sibling file works. Downward names (`sub.Bar`) work.
- **Anything upward or across fails without a mapping**: `extends="sys.Base"`, `CreateObject("component", "sys.Base")` and `cfargument type="sys.Base"` all ended in "Could not find the ColdFusion Component sys.Base" when `sys` was a folder outside the caller's own tree.
- A relative `cfinclude` can leave the web root with `../`. `CreateObject` cannot, because component names are dotted only.

The manual's search order is: the calling page's folder, then mappings, then the web root, then custom tag paths [M Dev p.224]; mappings are created on an Administrator page [M Adm p.22]. Since `app/` and `system/` sit beside `public/` and must refer to each other, **the port needs one ColdFusion mapping that points at the repository root**, for example `/coldigniter` to `D:\Inetpub\vhosts\coldigniter.lan`. Then:

- Components: `coldigniter.system.Router.Router`, `coldigniter.app.Controllers.Home`, `coldigniter.vendor.acme.widgets.Widget`.
- Includes: `/coldigniter/app/Views/welcome_message.cfm`.

Three cautions:

1. **Mappings resolving component names for `CreateObject`, `extends` and `type` has not been tested on this server** [U]. It is documented, and it is the first thing to test.
2. `extends` and `type` attributes are fixed text, so the mapping name ends up written in most component files. Choose it once and treat it as permanent [U].
3. The calling folder is searched first, so do not create a folder with the mapping's name anywhere in the tree [U], based on [M Dev p.224].

**Physical paths** (for `cffile`, `cfdirectory`, `FileExists`, `writable/`) must not come from `ExpandPath("/")`, which returns `C:\CFusionMX\wwwroot\` [S]. Derive them from the front controller: `GetDirectoryFromPath(GetCurrentTemplatePath())` in `public/index.cfm` is `FCPATH`; `Paths.cfc` then gives `SYSTEMPATH`, `APPPATH`, `WRITEPATH`, `ROOTPATH`, `TESTPATH`, stored in the Request scope under CodeIgniter's own constant names (CI:system/Boot.php lines 245-280).

**The class resolver** stands in for PSR-4 autoloading (CI:system/Autoloader/Autoloader.php). `app/Config/Autoload.cfc` holds a prefix map (`App` to `coldigniter.app`, `CodeIgniter` to `coldigniter.system`, `Config` to `coldigniter.app.Config`) and a classmap; a `resolveClass()` function swaps the longest matching prefix, and a factory function creates the component. `class_exists` becomes: translate the component path to a file under `ROOTPATH` and call `FileExists`, which gives clean 404s for unknown controllers [U] design.

### Request lifecycle, step by step

| Step in CodeIgniter (CI:system/Boot.php, CI:system/CodeIgniter.php) | 6.1 mechanism |
|---|---|
| Web server sends every request to `public/index.php` | `public/index.cfm/segments` works, with `CGI.PATH_INFO` = `/index.cfm/about/team` [S]. With no extra path, `PATH_INFO` equals `SCRIPT_NAME` [S]. Strip `SCRIPT_NAME` from the front of `PATH_INFO` to get the route. Set `uriProtocol` to `PATH_INFO` and `indexPage` to `index.cfm`. On this site a request for a missing `.cfm` file is answered by `index.cfm` [S]. |
| (PHP has no equivalent) | `public/Application.cfm`: `cfapplication` and `cferror` only |
| `index.php` defines `FCPATH`, loads `Paths` | `index.cfm` computes `FCPATH`, creates `Paths.cfc` |
| `Boot::bootWeb($paths)` | `Boot.cfc` method `bootWeb(paths)` |
| Path constants, `Constants.php` | Values in the Request scope; `Constants.cfm` included |
| `.env` loading | `DotEnv.cfc` reads the file with `cffile` and fills a Request struct |
| Environment boot file | `cfinclude` of `app/Config/Boot/<environment>.cfm` |
| `Common.php` functions | `cfinclude` of `system/Common.cfm` and `app/Common.cfm`: `service()`, `config()`, `view()`, `esc()`, `helper()`, `throw()` |
| Autoloader | The prefix-map resolver |
| Services | `Services.cfc` extends `BaseService.cfc`; shared instances kept in a Request struct |
| `CodeIgniter::run()`: events, before filters, router, controller, after filters | Same method names. The controller is called with `cfinvoke` inside `cfsavecontent` so that both returned strings and written output are gathered (`gatherOutput`) |
| `Response::send()` | `cfheader` for status and headers, `cfcookie` or `cfheader Set-Cookie`, `cfcontent` for the type, then the body in `cfoutput` |

```cfm
<!--- public/Application.cfm --->
<cfapplication name="coldigniter" sessionmanagement="no">
<cferror type="exception" template="error_last_resort.cfm">
```

```cfm
<!--- public/index.cfm --->
<cfsetting enablecfoutputonly="yes">
<cfset request.FCPATH = GetDirectoryFromPath(GetCurrentTemplatePath())>
<cfset paths = CreateObject("component", "coldigniter.app.Config.Paths").init()>
<cfset CreateObject("component", "coldigniter.system.Boot").init().bootWeb(paths)>
```

`cferror` templates are restricted in what CFML they may run depending on type [M Ref p.102]; keep the last-resort page plain.

### Feature by feature

**Config.** Each config class is a CFC with public fields on `This` set in `init()`. `BaseConfig.cfc` overlays `.env` values by walking the field names, as CodeIgniter does (CI:system/Config/BaseConfig.php). `config("App")` returns the per-request shared instance.

**Services.** `service("router")` calls the method `router` on `app/Config/Services.cfc` through `cfinvoke` and stores the result in `request.ci.services`. `getShared`, `injectMock` and `reset` keep their names (CI:system/Config/BaseService.php). This is the stand-in for static calls.

**Routing.** Routes are **an array of structs**, because order matters and struct order is not kept [S]. `routes.get("users/(:num)", "Users::show/$1")` keeps CodeIgniter's string form. There are no route closures; `group()` takes a prefix and is closed with `endGroup()`, or takes the name of a routes file to include [U] design. Match with `REFind`, or `java.util.regex` when a pattern needs more [S]. Compare the HTTP method from `CGI.REQUEST_METHOD`; all of GET, POST, PUT, DELETE, PATCH, OPTIONS and HEAD reach CFML through IIS 4 with the body readable [S].

**Controllers.** `app/Controllers/Home.cfc` extends `BaseController.cfc`, which extends `coldigniter.system.Controller`. Reject method names that start with `_`, as CodeIgniter does, and validate the method name against a strict pattern before dispatch. Route parameters are positional, and numeric-key `argumentCollection` does not fill positions [S], so dispatch by building a name-keyed struct from the method's parameter names in `GetMetaData`, falling back to a generated `Evaluate` call string [U].

**Views.** `view("welcome_message", data)` asks the View service to render `/coldigniter/app/Views/welcome_message.cfm`. Because an include inside a method leaks the method's locals and the view's own variables into the instance [S], the renderer creates one small context object per render and lets it be discarded:

```cfm
<!--- system/View/ViewContext.cfc: one instance per render, never shared --->
<cfcomponent output="no">
	<cffunction name="render" access="public" returntype="string" output="no">
		<cfargument name="template" type="string" required="yes">
		<cfargument name="data" type="struct" required="yes">
		<cfset var out = "">
		<cfset var key = "">
		<cfloop collection="#arguments.data#" item="key">
			<cfset variables[key] = arguments.data[key]>
		</cfloop>
		<cfsavecontent variable="out"><cfinclude template="#arguments.template#"></cfsavecontent>
		<cfreturn out>
	</cffunction>
</cfcomponent>
```

Dynamic `variables[key]` assignment and the include seeing instance Variables are both verified on pages and in methods [S]; a dynamic mapped `template` value still needs its own test [U]. Do not let view data keys collide with method names.

**Escaping.** `esc(value, "html")` maps to `HTMLEditFormat`, `"js"` to `JSStringFormat`, `"url"` to `URLEncodedFormat`. **`HTMLEditFormat` does not escape the single quote** [S]; `XMLFormat` does (`&apos;`) [S]. For HTML attributes, always use double quotes around the attribute, or add a `Replace(..., "'", "&##39;", "all")` step in `esc()`.

**Helpers.** A helper is a `.cfm` file of UDFs. `helper("url")` includes it once, guarded by a Request-scope flag, because defining the same function twice in one request is expected to fail [U]. Copy helper functions into the Request scope if components need them.

**Errors.** `CodeIgniter.run()` wraps dispatch in `cftry`. Exception types follow CodeIgniter's class names as dotted types (`ci.pagenotfound`, `ci.http.redirect`, `ci.database`), caught by prefix [S]. Development shows `cfcatch.Message`, `Detail`, `TagContext` and `StackTrace` [S]; production shows `app/Views/errors/html/error_404.cfm` and friends. Status codes with a custom body pass through IIS 4 untouched for 404 and 500 [S].

**Redirects and cookies.** A cookie set with `cfcookie` before `cflocation` is sent on this server [S]. For anything other than 302, and for HttpOnly cookies, write the headers directly [S]:

```cfm
<cfheader name="Set-Cookie" value="ci_session=#token#; path=/; HttpOnly">
<cfheader statuscode="303" statustext="See Other">
<cfheader name="Location" value="#target#">
<cfabort>
```

**JSON responses.** `<cfcontent type="application/json; charset=utf-8" reset="yes">` followed by the body works [S]. The JSON text itself comes from the port's own encoder.

**Database and models.** A thin connection CFC around `cfquery` and `cfqueryparam`, with the data source name in `app/Config/Database.cfc`. No data source exists on the server yet [S]; the choice of database and driver is open. Query builder and Model come much later.

**Sessions.** ColdFusion's own Session scope needs `cfapplication sessionmanagement="yes"` and uses CFID and CFTOKEN cookies; the manual warns that session variables set just before `cflocation` may be lost [M Dev p.329] and recommends J2EE session identifiers [M Dev p.322-329]. Decide later whether to wrap the built-in scope or port CodeIgniter's file handler.

**Testing and command line.** TestBox needs ColdFusion 9 or 10 and later ([TestBox requirements](https://testbox.ortusbooks.com/v2.x-1/introduction/overview/system-requirements)) [W]; MXUnit's support for 6.1 is unconfirmed ([MXUnit](https://github.com/mxunit/mxunit)) [W]. Start with a home-grown `tests/_support/TestCase.cfc` and a runner page that finds `*Test.cfc` with `cfdirectory`, lists `test*` functions with `GetMetaData`, and runs each through `cfinvoke` inside `cftry`. Add HTTP-level checks run from the development machine; they exercise the real IIS 4 path. `spark` becomes protected command pages, with `spark routes` first because it doubles as a routing debug page [U] design.

### The vendor question: a checked-in `vendor/` resolved by the prefix map

6.1 has no package manager, no per-application mappings and no autoloader. CodeIgniter itself shows the model: it bundles its only two runtime dependencies (Laminas Escaper, PSR Log) and Kint in `system/ThirdParty` with a classmap, so it runs without Composer (CI:system/Config/AutoloadConfig.php lines 95-124).

**Recommended approach, in three layers:**

1. **`vendor/<vendor>/<package>/` checked into the repository**, the same shape Composer produces. With the single root mapping, any vendor component is `coldigniter.vendor.<vendor>.<package>.<Class>` with no extra Administrator work. Each package registers a short prefix in the `psr4` map of `app/Config/Autoload.cfc`, as CodeIgniter registers namespaces. **Folder names become part of dotted component names, so they must not contain hyphens or dots.**
2. **`vendor/autoload.cfm`**, included by `Boot` when present, mirroring `COMPOSER_PATH` and `loadComposerAutoloader` (CI:app/Config/Constants.php). It adds the prefix and classmap entries for installed packages.
3. **A manifest and a fetch script that run on the development machine, never on the server.** A `vendor.json` lists name, version, source URL and install path; the script downloads and unpacks into `vendor/`, and the result is committed and synced to NT 4. The shape can borrow from CommandBox's `box.json` ([CommandBox docs](https://commandbox.ortusbooks.com/package-management/box-json.md)) [W].

Other sources of third-party code, each with its place:

| Source | Use it for | Limit |
|---|---|---|
| `system/ThirdParty`, `app/ThirdParty` | The few things the framework itself needs | Manual copies |
| Java 1.4 JARs via `CreateObject("java", ...)` | Regex, collections, crypto, zip, HTTP | Class version 48 or lower; placement is a server-level act (`WEB-INF/lib` or the Administrator class path) [M Dev p.737-738, Adm p.25]; exact `WEB-INF` location on this install untested [U] |
| Custom tag libraries (`cfimport`, `cfmodule`) | Presentation widgets | `cfimport` must be repeated on every page [M Ref p.190-191] |
| UDF libraries in the CFLib style | Small utilities; the twin of helpers and Composer `autoload.files` | CFLib targets ColdFusion 5 and later ([Camden 2007](https://raymondcamden.com/2007/01/18/CFLib-hits-1000)) [W]; check each function |

Realistic supply is thin. CFML written after about 2007 tends to rely on `Application.cfc`, `onMissingMethod`, interfaces or script components, and RIAForge has been shut down ([Adobe 2019](https://coldfusion.adobe.com/2019/01/riaforge-decommissioning/)) [W]. The vendor mechanism will mostly organise the project's own reusable packages and back-ported code. The port's core needs no third-party code at the start: Escaper becomes built-in functions plus small encoders, PSR Log becomes a documented method list on the Logger CFC, and Kint becomes `cfdump`.

### A recommended order of small first steps

The original slice 0 (server probes) is largely done; what remains of it is step 1 here. Each step ends at something visible in a browser.

1. **Mapping proof.** The owner adds the mapping. Three tiny files confirm that `CreateObject`, `extends` and `cfargument type` resolve through it, that `ExpandPath("/coldigniter/")` returns the repository root, and that a dynamic `cfinclude` through the mapping works.
2. **Skeleton and front controller.** The folder tree, `public/Application.cfm`, `public/index.cfm`, `app/Config/Paths.cfc`; print the resolved paths.
3. **Boot and constants.** `system/Boot.cfc` with `bootWeb()`, path values in the Request scope, `Constants.cfm`, a hard-coded `ENVIRONMENT`.
4. **Common functions and the class resolver.** `system/Common.cfm` with `throw()`, `service()`, `config()`, the prefix map and the factory.
5. **Services.** `BaseService.cfc`, `system/Config/Services.cfc`, `app/Config/Services.cfc`; `service("codeigniter").run()` prints one line.
6. **Request, URI and Response.** Path from `PATH_INFO`, method, headers; `Response.send()` through `cfheader`.
7. **Routes and Router.** `RouteCollection.cfc` with `get`, `post`, `add` and placeholders; one home route; a typed 404.
8. **Controller dispatch.** `Controller.cfc`, `BaseController.cfc`, `Home.cfc`; `Home.index` returns a string. First end-to-end page.
9. **Views.** `View.cfc`, `ViewContext.cfc`, `view()`, the stock welcome page. This matches a fresh CodeIgniter install.
10. **Errors.** 404 view, development error page, production error view, `cferror` fallback.
11. **Config overlay and `.env`.**
12. **Filters**, then **Events**, then **Helpers** (url helper first).
13. **Tests.** The minimal runner; back-fill Router and RouteCollection tests first.
14. **Database and Model**, then the **vendor mechanism** proven with one of the port's own packages.
15. **Later:** sessions, validation, logging, CSRF, Application-scope caching of routes and config with `cflock` and a reload switch.

**Keep everything in the Request scope until step 15.** It removes locking from every earlier step and matches PHP's per-request model. Move caching earlier only if step 9 is visibly slow on the NT 4 hardware.

## Platform facts and pitfalls

### Encoding

The page encoding is decided by a byte order mark, then `cfprocessingdirective pageEncoding`, then the JVM default [M Dev p.375-380]. The JVM default here is **Cp1252** [S]. A UTF-8 file without a BOM that holds non-ASCII characters will therefore be misread. Choose one rule: **ASCII-only source with HTML entities** (simplest), or `<cfprocessingdirective pageencoding="utf-8">` at the top of every file that needs it (per-file behaviour untested [U]). Responses default to `Content-Type: text/html; charset=UTF-8` [S]. `String.getBytes()` with no argument uses Cp1252; always pass `"UTF-8"` when hashing.

### Caching and the development loop

Trusted cache is off, and edited files were picked up on the very next request, three edits in a row [S]. Save class files is on, so compiled classes are written to disk [S]. The first request after a change includes compile time [M Dev p.394]. If the trusted cache is ever turned on, changes stop being noticed until the cache is cleared [M Adm p.19]. How change detection behaves when files arrive by FTP with odd timestamps is untested [U].

### HTTP behaviour through IIS 4

- All seven methods reach CFML; request bodies are readable for POST, PUT, DELETE and PATCH [S].
- 404 and 500 responses with a custom body arrive unchanged [S]. The Administrator has an "HTTP status codes" setting, and Internet Explorer replaces short error bodies (under 512 bytes) with its own page [M Adm p.18-19], so pad error pages.
- `cflocation` is always 302; a manual 303 with `Location` and `cfabort` works [S].
- `cfcookie` output is `Set-Cookie: PROBE_C=1;path=/` (name upper-cased); a hand-written `Set-Cookie` with HttpOnly passes through [S].
- Every response closes the connection [S].
- Extra path after `index.cfm` works with the stock connector on this server [S]; period sources describe JRun `web.xml` url-pattern settings for such URLs on other set-ups ([pengoworks 2003](https://blog.pengoworks.com/index.cfm/2003/4/17/Search-Friendly-URLs-with-CFMXIIS)) [W].

### Security and crypto that is available

| Need | What works on the server |
|---|---|
| MD5 | `Hash(s)`: MD5 only, upper-case hex [S] [M Ref p.513] |
| SHA family | `java.security.MessageDigest`: MD5, SHA, SHA-1, SHA-256, SHA-384, SHA-512 [S] |
| HMAC | `javax.crypto.Mac`: **HmacMD5 and HmacSHA1 only; HmacSHA256 is "not available"** [S]. Build HMAC-SHA256 by hand from `MessageDigest` (inner and outer pads) if CodeIgniter's signing must match |
| Symmetric encryption | `AES/CBC/PKCS5Padding` through `javax.crypto.Cipher` [S]. Built-in `Encrypt()` is a weak XOR-based scheme [M Ref p.467]; do not use it |
| Random values | `java.security.SecureRandom` [S] |
| Identifiers | `CreateUUID()` is 35 characters in 8-4-4-16 form, not a standard UUID [S] [M Ref p.438] |
| SQL injection | `cfqueryparam` [M Ref p.286-288] |
| Output escaping | `HTMLEditFormat` (no single quote), `XMLFormat`, `JSStringFormat`, `URLEncodedFormat` [S] |
| CSRF, session rotation, password hashing | Nothing built in; framework code. No bcrypt or PBKDF2 function exists; a salted, iterated SHA-256 loop is the realistic option [U] design |

Converting a digest to hex through `java.math.BigInteger` drops leading zeros [S], so pad to the full length:

```cfm
<cffunction name="sha256" access="public" returntype="string" output="no">
	<cfargument name="text" type="string" required="yes">
	<cfset var md = CreateObject("java", "java.security.MessageDigest").getInstance("SHA-256")>
	<cfset var big = "">
	<cfset var hex = "">
	<cfset md.update(arguments.text.getBytes("UTF-8"))>
	<cfset big = CreateObject("java", "java.math.BigInteger").init(JavaCast("int", 1), md.digest())>
	<cfset hex = LCase(big.toString(JavaCast("int", 16)))>
	<cfreturn RepeatString("0", 64 - Len(hex)) & hex>
</cffunction>
```

Build 63958 predates the 6.1 Updater, which carried more than 60 fixes ([Forta blog mirror](https://fortacom.vercel.app/blog/coldfusion-mx-6-1-updater-available)) [W], and later Macromedia security bulletins ([Bugtraq 2004-04](https://seclists.org/bugtraq/2004/Apr/190), [Bugtraq 2004-09](https://seclists.org/bugtraq/2004/Sep/347), [Bugtraq 2005-04](https://seclists.org/bugtraq/2005/Apr/110)) [W]. Treat the server as a lab machine, not something to expose.

### Debugging

- `cfdump` (no `abort`, no `top`), `cftrace`, `cflog`, and `GetTickCount()` differences for timing [M Ref p.98, p.341, p.226].
- Administrator debugging output, limited to named IP addresses, with robust exception information [M Adm p.28-30]. Default error pages hide detail until that option is on [S].
- `C:\CFusionMX\logs\application.log` (every error shown to a user) and `exceptions.log` (stack traces) [M Adm p.31]. Reading them over the deployment channel gives full traces without turning on robust errors for everyone.
- `cfcatch.TagContext` gives template and line for each level [S].
- A syntax check is simply requesting the page: compile errors name the line and column [S].

### Pitfalls worth memorising

| Pitfall | Mark |
|---|---|
| Missing `var` writes to the instance; with shared components this is a race | [S] |
| Arrays passed into functions are not copied on the way in | [S] |
| `EQ` treats `"1e3"`, `"01"`, `"yes"` as numbers or Booleans | [S] |
| Dot-notation keys are upper-cased; struct order is arbitrary | [S] |
| List functions drop empty elements | [S] |
| `ExpandPath("/")` is not the site | [S] |
| Every CGI variable name is "defined" | [S] |
| Text outside `cfoutput` vanishes under `enablecfoutputonly` | [S] |
| Component methods without `output="no"` emit whitespace | [S] |
| `super` with named arguments fails | [S] |
| `Duplicate()` of a component is broken | [S] |
| Nothing header-related works after `cfflush` | [M Ref p.130] |
| `OnRequestEnd.cfm` is skipped after `cfabort` or an error | [M Dev p.271] |
| Methods over 64 KB of bytecode fail to compile | [W] |
| `cflocation` appends CFID and CFTOKEN unless `addtoken="no"` | [M Ref p.220] |
| The fixed result structs `cfhttp`, `cffile`, `cfquery` are shared names; copy what is needed at once | [M Ref p.174-182]; `var`-scoping them untested [U] |

## The VS Code extension to use and how to set it for 6.1

**Use `CFMLEditor.cfmleditor`** (version 0.7.8, released 2026-10-23). It is the maintained successor of `KamasamaK.vscode-cfml`, whose last release was 0.5.4 on 2022-01-06 ([Marketplace API](https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery), [cfmleditor README](https://github.com/cfmleditor/cfmleditor#readme)) [W]. It gives highlighting, completion, hover documentation, signature help and go-to-definition for tags, functions and user components.

The reason it suits a 2003 target is its engine filter: `cfml.engine.name` accepts `coldfusion`, and `cfml.engine.version` is a free string, so `6.1.0` is valid ([package.json](https://raw.githubusercontent.com/cfmleditor/cfmleditor/HEAD/package.json)) [W]. With a version set, a tag or function is hidden when its CFDocs minimum ColdFusion version is newer than the target ([definitionInfo.ts](https://raw.githubusercontent.com/cfmleditor/cfmleditor/HEAD/src/utils/cfdocs/definitionInfo.ts)) [W]. So `IsValid` (7), `cfthread` (8) and `ArrayEach` (10) disappear from suggestions. The filter is only a first pass: entries with no minimum version still show, and attributes added to existing tags after 6.1 are probably not filtered [U]. `tags_and_functions.md` and the 6.1 Reference stay the authority.

Not recommended: Adobe's `com-adobe-coldfusion.adobe-cfml-lsp`, which is built around current ColdFusion servers ([Marketplace listing](https://marketplace.visualstudio.com/items?itemName=com-adobe-coldfusion.adobe-cfml-lsp)) [W]; `ilich8086.ColdFusion`, abandoned in 2018 ([repository](https://github.com/ilich/vscode-coldfusion)) [W]; and any formatter, since all of them target modern CFML.

Optional: `CFMLEditor.cfmleditor-lint`, which runs CFLint 1.5.0 (released 2020) and needs Java 8 or later plus the `CFLint-1.5.0-all.jar` on the development machine ([lint README](https://github.com/cfmleditor/cfmleditor-lint#readme)) [W]. Its `MISSING_VAR` rule catches the most damaging 6.1 bug. CFLint parses with a modern grammar and often misreports locations, so treat it as advice.

On VS Code forks that use Open VSX, only `cfmleditor` 0.7.0 is published there ([Open VSX API](https://open-vsx.org/api/cfmleditor/cfmleditor)) [W]. Under Remote SSH these extensions run on the workspace (remote) side, so Java and the CFLint jar must be on that machine.

`.vscode/settings.json` (setting keys from the extensions' `package.json` files [W]; not installed or run in this research):

```json
{
  "cfml.engine.name": "coldfusion",
  "cfml.engine.version": "6.1.0",
  "cfml.cfDocs.source": "extension",
  "cfml.webroot": "public",
  "cfml.mappings": [
    { "logicalPath": "/coldigniter", "directoryPath": ".", "isPhysicalDirectoryPath": false }
  ],
  "cfml.autoCloseTags.enable": true,
  "cfml.suggest.globalTags.attributes.quoteType": "double",
  "cfml.suggest.globalTags.includeAttributes.setType": "required",
  "cfml.suggest.globalFunctions.firstLetterCase": "unchanged",
  "cfml.format.enabled": false,
  "cfml.lsp.enabled": false,
  "emmet.includeLanguages": { "cfml": "html" },
  "files.associations": { "*.cfm": "cfml", "*.cfml": "cfml", "*.cfc": "cfml" },
  "files.encoding": "utf8",
  "files.eol": "\r\n",
  "[cfml]": { "editor.formatOnSave": false, "editor.insertSpaces": false },
  "cflint.enabled": true,
  "cflint.jarPath": "/path/to/CFLint-1.5.0-all.jar",
  "cflint.runModes": { "onOpen": true, "onSave": true, "onChange": false },
  "cflint.ignoreInfo": true,
  "cflint.quickfix.var": true,
  "cflint.quickfix.local": false
}
```

Adjust three things. Replace `/coldigniter` with the real mapping name; if a relative `"."` does not resolve, use the absolute repository path with `"isPhysicalDirectoryPath": true` [U]. Remove the four `cflint.*` lines if the lint extension is not installed. `files.eol` set to CRLF is a cautious choice for a Windows server; whether LF-only source causes any trouble on 6.1 is untested [U]. `cfml.format.enabled` and `cfml.lsp.enabled` stay false because both are new features whose parser targets current CFML. `cflint.quickfix.local` stays false because that fix inserts a `local.` prefix, which needs the ColdFusion 9 local scope.

`.vscode/extensions.json`:

```json
{
  "recommendations": [
    "CFMLEditor.cfmleditor",
    "CFMLEditor.cfmleditor-lint"
  ],
  "unwantedRecommendations": [
    "KamasamaK.vscode-cfml",
    "ilich8086.ColdFusion",
    "com-adobe-coldfusion.adobe-cfml-lsp"
  ]
}
```

`.cflintrc` policy: generate the file with the extension's "Create '.cflintrc' file" command, then keep `MISSING_VAR`, `ARG_VAR_CONFLICT`, `NESTED_CFOUTPUT`, `CFQUERYPARAM_REQ`, `QUERYPARAM_REQ`, `GLOBAL_VAR`, `OUTPUT_ATTR`, `COMPARE_INSTEAD_OF_ASSIGN` and `UNUSED_LOCAL_VARIABLE`. Exclude `AVOID_USING_STRUCTNEW`, `AVOID_USING_ARRAYNEW`, `AVOID_USING_CREATEOBJECT` (they push toward literals and `new`, which do not compile on 6.1 [S]), `AVOID_USING_CFINCLUDE_TAG`, `AVOID_USING_CFMODULE_TAG`, `AVOID_USING_CFABORT_TAG`, `ARG_TYPE_ANY`, `FUNCTION_TYPE_ANY`, and the naming and length rule families ([rule list](https://github.com/cflint/CFLint/blob/master/src/main/resources/cflint.definition.json)) [W].

## Where the server overruled the manuals

| Manual or web statement | Server result [S] |
|---|---|
| A function has at most one `cfreturn` | Several work |
| `This` is not usable in a base component | A base `init()` uses `This` and returns the full child instance |
| `Super` reaches one level only | Three levels work |
| Arrays are passed to functions by value [M Dev] | Not copied on the way in; assignment does copy |
| Cookies set before `cflocation` may be lost (pre-MX lore) | The cookie is sent |
| `JavaCast` type `bool` (common in later code) | Fails; `boolean` works |
| `ExpandPath("/")` is the web root | It is `C:\CFusionMX\wwwroot\`, not the IIS site |
| Numeric keys in `argumentCollection` fill positional arguments (assumed in the mapping notes) | They do not |
| HmacSHA256 expected in JCE | Not available on this JVM |
| A view can be included from a long-lived renderer component | The include leaks method locals into the instance |

## What still needs a test

Ordered by how much design rests on each.

1. A ColdFusion mapping resolves component names for `CreateObject`, `extends` and `cfargument type`. **Test first.**
2. `ExpandPath("/<mapping>/...")` returns the mapped physical path.
3. `cfinclude` with a dynamic `template` value through the mapping, inside a method inside `cfsavecontent`.
4. Dynamic controller dispatch with positional route parameters: name-keyed struct from `GetMetaData(...).functions[n].parameters`, and the `Evaluate("obj.method(args)")` fallback.
5. Shape of `GetMetaData(obj).extends` below the top level (keys and `PATH`), for the `isA()` helper.
6. Including the same UDF file twice in one request (expected to throw), and defining a UDF named like a built-in.
7. `cfheader` and `cfcookie` called inside a component method while inside `cfsavecontent`.
8. `java.util.LinkedHashMap` key order under `cfloop collection`.
9. Whether `GetEncoding`, `SetEncoding` and `URLSessionFormat` can be called although `GetFunctionList()` omits them.
10. Whether the Updater or any hot fix is installed (look for `C:\CFusionMX\cumulative_hotfix_bkup`).
11. `PATH_INFO` with encoded characters, spaces, plus signs, dots and very long paths; raw versus decoded form; the JRun `web.xml` url-pattern in force.
12. LF-only source files, a BOM in a CFC or in `Application.cfm`, and `pageEncoding` declared per file.
13. Change detection for files delivered by FTP (timestamps), and where saved class files live.
14. Cost of `CreateObject` and of a method call on the NT 4 hardware, to decide when Application-scope caching is needed.
15. Request body and upload size limits; several headers of the same name through `cfheader`.
16. `cfsetting showdebugoutput`, and `GetPageContext()` buffer and response methods beyond the documented `include` and `forward`.
17. `var`-scoping of the fixed result names (`cfhttp`, `cffile`, `cfquery`) inside methods.
18. Whether two `cfquery` tags in one `cftransaction` share a connection (for insert ids), once a database is chosen; which database and driver to use.
19. Where `WEB-INF/lib` is for this install, and which Java 1.4 builds of wanted libraries exist.
20. Whether MXUnit or another period test framework runs on 6.1.
21. Editor: whether CFDocs data filters per attribute, whether `cfml.mappings` accepts a relative root path, and the extension ID case on Open VSX.

## Conclusion

The practical picture is better than the manuals suggest. Multi-level `super`, base-class `init()` returning the child, several returns per function, hierarchical exception types and first-class functions give enough object machinery to keep CodeIgniter's class shapes almost one to one, and IIS 4 turned out to pass every HTTP method and status code a modern framework needs. The price is discipline in four places: `var` everything, pass `super` arguments by position, never rely on struct order or key case, and render views through a throwaway object.

Two decisions are owed before code starts: the name of the single mapping, which will be written into most component files, and the source-encoding rule. After the mapping proof, the stock welcome page rendered through index, Boot, Services, Router, Controller and View is the right first milestone, because it is the same milestone a fresh CodeIgniter install reaches and it exercises every mechanism this report describes.
