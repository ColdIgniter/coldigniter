# Results of tests run on the real ColdFusion MX 6.1 server (2026-11-22)

These are first-hand observations from probe pages run on the target server itself, not from manuals
or the web. Where they conflict with a manual or a web source, THE SERVER RESULT WINS for this project.
Cite them as "[verified on the 6.1 server, 2026-11-22]". The raw output is in `server_probe_raw.md` in
this folder; the probe sources that produced it are quoted where useful below.

Server: ColdFusion Server 6,1,0,63958 **Standard** edition, Windows NT 4.0, IIS 4.0 (`Microsoft-IIS/4.0`),
JRun 4, Servlet API 2.3, Sun Java **1.4.2** (class file version 48.0), `file.encoding=Cp1252`.
Site home directory `D:\Inetpub\vhosts\coldigniter.lan\public`; repository root is its parent.
ColdFusion root `C:\CFusionMX`. Only one ColdFusion mapping exists so far: `/CFIDE`. No data sources defined.
Runtime settings read from the server: trusted cache OFF, save class files ON, template cache size 1024,
whitespace management OFF.

## Syntax that does NOT compile on this server (confirmed compile errors)

- `<cfif a == 1>`: "Invalid CFML construct". Word operators only (EQ, NEQ, GT, LT, GTE, LTE, AND, OR, NOT, MOD...).
- `<cfset a = [1,2]>`: array literals do not exist.
- `s[k]("z")`: calling a function through bracket notation does not compile. Copy the function to a
  variable first (`<cfset f = s[k]>` then `f("z")`), or use cfinvoke with a dynamic method name.
- `(1 EQ 1).toString()`: a method call on a parenthesised expression does not compile.
- A `<cfset var y = 2>` after any other statement in a function: "Local variable y on line 1 must be
  grouped at the top of the function body." (compile-time error, so it is caught early.)
- CFScript has no `throw`: `throw("x")` compiles as a call to an undefined function and fails at run time
  with "Variable THROW is undefined". Use the cfthrow tag (or a UDF written with tags that wraps cfthrow).
- `Application.cfc` is ignored: an `Application.cfc` with `onRequestStart` placed beside a page did not run.

## Syntax and behaviour that DOES work (confirmed)

- Several `<cfreturn>` tags in one function (inside cfif branches) work. The CFML Reference statement
  "a maximum of one cfreturn tag" is wrong in practice.
- `returntype="void"` works.
- `CreateObject("component", "Child").init("x").getName()` chaining works.
- Method call on a function result works: `Now().getClass().getName()`, `UCase("a").concat("b")`.
- Method call on an array element and struct member works: `objs[1].getName()`, `holder.o.getName()`,
  `holder["o"].getName()`.
- `arguments.fn(1)` works (calling a function passed as an argument directly through the Arguments scope),
  and so does copying it to a var first. `IsCustomFunction(f)` is YES. Functions are first-class values.
- `Evaluate("#fnname#(1)")` works; `variables[fnname]` returns the function object.
- Auto-creation of nested structs by dotted assignment works: `<cfset deep.a.b.c = 1>`.
- `variables["name"]` bracket notation on the Variables scope works, for reading and writing.
- Boolean operators short-circuit: in `false AND f()` and `true OR f()`, `f` is not called.
- Nested cfsavecontent works (`[ac][b]`). NOTE: under `<cfsetting enablecfoutputonly="yes">`, text in a
  cfsavecontent body that is not inside cfoutput is discarded (the captured string is empty).
- cfqueryparam inside cfloop inside cfquery works (tested with query of queries:
  `WHERE id IN (<cfloop list=...><cfqueryparam value="#one#" cfsqltype="cf_sql_integer"><cfif ...>,</cfif></cfloop>)`).
  A whole SQL statement held in a variable works with `#PreserveSingleQuotes(sqltext)#`.
  `cfquery.executiontime` is defined after a query. Query columnlist is upper case.
- cfwddx round trip, XmlParse, XmlSearch with an XPath predicate all work.
- cffile write/read/delete with `charset="utf-8"` and an absolute path works.
- cfdirectory list columns: ATTRIBUTES, DATELASTMODIFIED, MODE, NAME, SIZE, TYPE.
- `cfapplication` can be called late in a request; before it, touching the Application scope throws
  "The requested scope application has not been enabled".
- `CreateObject("java","java.lang.Thread").sleep(JavaCast("long",120))` works as a Sleep substitute.
- `JavaCast("boolean", true)` works; `JavaCast("bool", ...)` FAILS (the Developing guide's "bool" is wrong).

## Components (CFCs): verified behaviour

Test components: `Base` (init sets `variables.name`, `this.pub`, returns `this`), `Mid extends Base`,
`Child extends Mid`, each with `init` calling `super.init(arguments.name)` and a `who()` calling `super.who()`.

- `init()` in a base component can use `This` and `return this`; the object returned is the full child
  instance (This keys afterwards include members set in Base, Mid and Child). The manual's warning that
  This cannot be used in a base component is NOT a practical limit here.
- **`super` works through more than one level**: `child>mid>base` from a three-level chain. (Notes that say
  "one level only" are contradicted.)
- **`super.method(name=value)` and `super.method(argumentCollection=arguments)` both FAIL** with
  "Cannot invoke method init on an object of type coldfusion.runtime.Struct with named arguments. Use ordered
  arguments instead." Calls through `super` must use positional arguments.
- A child with no `init` inherits the parent's; `GetMetaData(obj).name` is `_t.ChildNoInit`,
  `GetMetaData(obj).extends.name` is `_t.Base`. Metadata keys for a component: PATH, TYPE, NAME, OUTPUT,
  EXTENDS, FUNCTIONS (plus any custom attributes). The name is the dotted path as resolved (see below:
  it has no package prefix when the component was found relative to the caller's directory).
- Code in the pseudo-constructor area runs at CreateObject time for parent and child (`variables.pseudo`
  set in Base exists in a child instance).
- The Variables scope of an instance contains every method (public and private) plus `THIS` plus data;
  the This scope contains the public methods plus public data.
- `access="private"` methods are callable from a child component (so private means protected) and are not
  callable from outside ("The method 'secret' could not be found in component ...").
- An unscoped assignment in a method (`<cfset leaked = "x">`) lands in the instance's Variables scope.
- **cfinclude inside a method**: the included template can read the method's `var` locals and its Arguments
  scope, the instance's Variables scope and This. Unscoped variables it sets go into the instance's Variables
  scope. **Worse: after the include, the method's `var` locals (e.g. `local1`) exist in the instance's
  Variables scope too**, so an include inside a method copies the function-local variables into the shared
  instance scope. A view renderer that is a shared (Application-scope) singleton would therefore leak and
  race; render views from a per-request object (or a throwaway object per render), never a shared singleton.
- **Mixins by include work**: `<cfinclude template="mixin.cfm">` in the pseudo-constructor area of a
  component, where the file contains cffunction definitions, adds those functions as methods, and they can
  read `variables.*` of the instance.
- **Method injection works**: `<cfset obj.inj = someUdf>` then `obj.inj(1)`; and a method copied from one
  instance to another (`o2.gn = obj.getName`) runs against the receiving instance's Variables scope.
- A method detached into a plain variable (`<cfset f = obj.getName>` then `f()`) loses its instance
  ("Element NAME is undefined in VARIABLES").
- **`Duplicate()` on a component instance is broken**: the copy passes IsObject but its Variables data is
  gone. Never Duplicate a CFC; write a `clone()` method by hand.
- cfinvoke with `component="#obj#" method="#dynamicName#"` works, also with `argumentcollection="#struct#"`.
- Plain UDF call with `f(argumentCollection=s)` works when the struct keys are argument NAMES. With numeric
  keys ("1", "2") it does NOT fill positional arguments (the declared arguments keep their defaults and the
  numeric keys arrive as extra named entries). To pass a list of positional values to a dynamic method,
  build a struct keyed by the target's argument names (from GetMetaData(function).parameters) or generate the
  call with Evaluate.
- Named arguments on a normal call work (`f(b="nb")`), extra positional arguments arrive as `arguments[3]`
  and `ArrayLen(arguments)` counts them.
- A cfargument `type="some.Component"` check fails with an error whose cfcatch TYPE is the component name
  itself (e.g. type `sys.Base`) when the type cannot be resolved or does not match.
- Whitespace: a component and function without `output="no"` emitted `"\n  \n  "` into the page around a
  call; with `output="no"` on cfcomponent and cffunction it emitted nothing. Always set output="no".

## Passing and copying data: verified behaviour

- Array assignment copies: `a2 = a1` then appending to `a2` leaves `a1` unchanged.
- **Arrays passed to a function are NOT copied on the way in**: `ArrayAppend(arguments.a, "x")` inside a UDF
  or a CFC method changed the caller's array (outside length went from 1 to 2). The copy only happens when
  the function assigns it to another variable (`<cfset var b = arguments.a>` then changing `b` leaves the
  caller's array alone). This contradicts the manual's "arrays are passed by value". Rule: never mutate
  `arguments.someArray` in place; copy to a var first.
- An array inside a struct is shared when the struct is copied by reference (`s2 = s1`), and
  `tmp = s1.list` makes a copy.
- Structs are passed by reference.

## Structs and Java collections: verified behaviour

- Key case: `sk.fooBar = 1` creates key `FOOBAR`; `sk["bazQux"] = 2` keeps `bazQux`. StructKeyList shows them so.
- Key order is NOT preserved: inserting zeta,alpha,mike,bravo,yankee,charlie,k1,k10,k2 listed as
  zeta,k2,alpha,k1,yankee,charlie,mike,k10,bravo.
- `java.util.LinkedHashMap` (via CreateObject("java",...).init()) keeps insertion order, passes IsStruct,
  works with bracket assignment, StructKeyList, StructCount and StructKeyExists, BUT its keys are
  CASE-SENSITIVE (`StructKeyExists(lh,"ALPHA")` is NO when the key is "alpha"). Normalise key case when using it.
- Java classes behind CFML values: string = java.lang.String (so `str.length()`, `str.getBytes()` work),
  array = coldfusion.runtime.Array (`.size()` works), struct = coldfusion.runtime.Struct,
  result of arithmetic = java.lang.Double, date = coldfusion.runtime.OleDateTime, boolean = java.lang.Boolean.

## Numbers, comparisons, lists: verified behaviour

- `1+1`=2, `10/2`=5, `7/2`=3.5, `7\2`=3, `7 MOD 2`=1, `0.1+0.2`=0.3, `2147483647+1`=2147483648,
  `123456789*1000`=123456789000, but `1000000*1000000` prints `1E+012` and `2^40` prints `1.09951162778E+012`.
  Large numbers turn into scientific notation with about 12 significant digits when converted to strings.
  `GetTickCount()` returned 1795332839671 (13 digits printed in full when not the result of arithmetic).
- `1 EQ "1.0"`, `"1e3" EQ 1000`, `"a" EQ "A"`, `"yes" EQ true`, `"01" EQ 1` are all YES. `Compare("a","A")`
  is 1 (case-sensitive). `IsDate("1,2")` is YES, `IsNumeric("1e3")` is YES, `IsBoolean(2)` is YES.
  Use `Compare()` for exact string equality (tokens, hashes, keys).
- Lists skip empty elements: `ListLen("a,,b")` is 2, `ListToArray("a,,b")` has 2 elements, `ListGetAt("a,,b",2)` is "b".
- Booleans print as YES/NO.

## Exceptions: verified behaviour

- `<cfthrow type="ci.http.notfound">` is caught by `<cfcatch type="ci.http">` and by `<cfcatch type="ci">`
  (dotted hierarchy matching works); it is NOT caught by `type="application"`, it is caught by `type="any"`.
- cfcatch keys for a cfthrow: code, Detail, ErrorCode, extended_info, ExtendedInfo, Message, StackTrace,
  TagContext, Type. `cfcatch.StackTrace` exists; TagContext is an array.
- cfrethrow works. A Java exception is catchable by class name (`type="java.lang.NumberFormatException"`).
- In CFScript, `catch(Any e)` gives `e.type` and `e.message` (e is the exception object).
- A compile error in a cfincluded template is catchable by cftry in the including page (cfcatch type
  "Template"), which is useful for a test runner.

## Security and crypto available on this JVM: verified

- `Hash("abc")` = MD5, UPPER-case hex. java.security.MessageDigest provides MD5, SHA, SHA-1, **SHA-256,
  SHA-384, SHA-512** (hex via `java.math.BigInteger.init(JavaCast("int",1), bytes).toString(JavaCast("int",16))`,
  which drops leading zeros and must be left-padded).
- javax.crypto.Mac provides **HmacMD5 and HmacSHA1 only; HmacSHA256 is NOT available**
  (NoSuchAlgorithmException). HMAC-SHA256 would have to be built by hand from MessageDigest SHA-256.
- `javax.crypto.Cipher.getInstance("AES/CBC/PKCS5Padding")` is available. java.security.SecureRandom works.
- java.util.regex is available and supports lookbehind. The CFML RE functions support lookahead `(?=`,
  non-greedy `+?` and POSIX classes, but NOT lookbehind ("Sequence (?<...) not recognized").
- HTMLEditFormat escapes `< > & "` but NOT the single quote. XMLFormat escapes `< > & ' "`.
  JSStringFormat escapes both quote kinds with backslashes. URLEncodedFormat("a b/c?d=e&f") = `a%20b%2Fc%3Fd%3De%26f`.
- CreateUUID format: `022D1BD6-BC24-11E7-42AE1E49994C32A5` (8-4-4-16).

## Built-in functions: verified from GetFunctionList() on the server

262 functions reported. Confirmed ABSENT: IsValid, SerializeJSON, IsInstanceOf, Sleep, GetContextRoot,
CharsetEncode, REMatch, ArrayContains, FileRead, throw. Confirmed PRESENT: GetHttpTimeString, WriteOutput.
(The count 262 versus the manual's 270 entries is expected: the manual also documents obsolete functions.)

## HTTP, IIS 4 and the connector: verified behaviour

- CGI on a plain request to `/_t/index.cfm`: `SCRIPT_NAME=/_t/index.cfm`, **`PATH_INFO=/_t/index.cfm`**
  (equal to the script name when there is no extra path; with extra path it is `/index.cfm/about/team`),
  `PATH_TRANSLATED` = the physical file, `SERVER_PROTOCOL=HTTP/1.1`. An undefined CGI variable tests as
  defined and returns an empty string. All of Variables, Request, Form, URL, CGI, Cookie, Server pass IsStruct.
- `ExpandPath("/")` returns `C:\CFusionMX\wwwroot\` (the ColdFusion root, NOT the IIS site's home directory).
  Use `GetDirectoryFromPath(GetCurrentTemplatePath())` or `GetBaseTemplatePath()` to find real paths.
  Inside an included file GetCurrentTemplatePath() is the included file; GetBaseTemplatePath() is the page requested.
- **All HTTP methods reach CFML**: GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD all returned 200 from a .cfm
  page with `CGI.REQUEST_METHOD` and `GetHttpRequestData().method` set correctly and the body readable from
  `GetHttpRequestData().content` (7 bytes for `a=1&b=2`, also for a JSON body with Content-Type application/json).
  GetHttpRequestData keys: protocol, content, method, headers.
- **Status codes with a custom body pass through IIS 4 untouched**: `<cfheader statuscode="404" statustext="Not Found">`
  plus output returned `HTTP/1.1 404 Not Found` with the CFML body; the same for 500.
- cfcontent `type="application/json; charset=utf-8" reset="yes"` works; default Content-Type is `text/html; charset=UTF-8`.
- **cfcookie followed by cflocation in the same request DOES send the cookie** on this server
  (`302 Moved Temporarily` with `Set-Cookie: PROBE_C=1;path=/` and `location:`). Note cfcookie upper-cases
  the cookie name. cflocation always sends 302.
- Other redirects and cookie attributes work through cfheader:
  `<cfheader name="Set-Cookie" value="probe_h=1; path=/; HttpOnly">`, `<cfheader statuscode="303" statustext="See Other">`,
  `<cfheader name="Location" value="...">`, `<cfabort>` produced a correct 303 with the cookie (name case kept).
- A request for a .cfm file that does not exist under the site is rewritten to the front controller by the
  site's rewrite rules (it returned 200 from index.cfm), so missing .cfm pages reach the framework router.
- `index.cfm/extra/path` URLs already work on this server (verified earlier with the rewrite rules).
- Responses carry `Connection: close`.
- Changed files are picked up immediately: three uploads of the same page in a row each served the new
  content on the next request (trusted cache is off).
- `GetPageContext().getOut()` is coldfusion.runtime.NeoJspWriter; `GetPageContext().getRequest().getMethod()` works.

## Finding components without a mapping: verified behaviour (drives the directory design)

Layout used: site home `...\public`, test tree `...\_tsys` beside it (outside the web root) containing
`loader.cfm`, `Loader.cfc`, `sys\Base.cfc`, `sys\Sibling.cfc` (extends="Base"), `sys\http\Deep.cfc`
(extends="sys.Base"), `sys\http\DeepRoot.cfc` (calls CreateObject("component","sys.Base")), `app\Home.cfc`
(extends="sys.Base").

- `<cfinclude template="../../_tsys/loader.cfm">` from a page in the web root WORKS: relative includes can
  climb out of the web root with `../`.
- Inside the included file, `CreateObject("component", "Loader")` WORKS: component names resolve relative
  to the directory of the file that contains the CreateObject call (the included file's directory), and
  `CreateObject("component", "sub.Bar")` reaches a subdirectory from there. A component created that way
  can itself create components below its own directory.
- From a page in the web root, `CreateObject("component", "_t.Base")` resolved against the IIS site home
  directory, so the site's home directory acts as a root for dotted names.
- `extends="Base"` for a sibling in the same directory WORKS. Its metadata name is just `Sibling`
  (no package prefix), so type names differ depending on how a component was found.
- **Anything that has to go UP or ACROSS fails without a mapping**: `extends="sys.Base"` from
  `sys\http\Deep.cfc`, `CreateObject("component","sys.Base")` from `sys\http\DeepRoot.cfc`, and
  `extends="sys.Base"` from `app\Home.cfc` all failed with "Could not find the ColdFusion Component sys.Base".
  A cfargument `type="sys.Base"` check failed too, even for a real instance.
- Conclusion: a CodeIgniter-style tree outside the web root (app controllers extending a system base
  controller, system packages using each other) NEEDS ColdFusion mappings created in the ColdFusion
  Administrator (the manual says mappings are searched for components; this is not yet tested on the server
  because no mapping exists yet). Only `/CFIDE` is mapped today. The owner can add mappings. Until a mapping
  exists and is verified, treat "mappings resolve CFC names for CreateObject, extends and type checks" as the
  first thing to test.

## A layout with no mapping: verified behaviour (second session, 2026-11-22)

Scratch layout on the server: the page in `public\_t\`, an app tree in `_tapp\deep\er\app\` or `_tb\app\`, a framework tree in `_tsys2\system\` or `_tb\system\`. No mapping other than `/CFIDE` existed.

- `cfinclude` with the path in a variable reaches a file outside the web root, and the included file can create a component that sits beside it.
- `cfinclude template="../../_tb/app/Config/../../system/Boot.cfm"` works: `..` in the middle of the path is resolved.
- `GetCurrentTemplatePath()` inside an included file gives that file's path; inside a component method it gives the `.cfc` path; `GetBaseTemplatePath()` gives the requested page.
- `CreateObject("java", "java.io.File").init(path).getCanonicalPath()` resolves `..` and mixed slashes, with no trailing separator.
- From a method of `_tb\system\Boot.cfc`, `cfinclude template="../../../../../Inetpub/vhosts/coldigniter.lan/_tb/app/Namespace.cfm"` works (one `../` per folder level up to the drive root, then down). The component created by that file then created `Controllers.Home` from its own tree.
- Method copying: a framework loader created `Controllers.Home` (which `extends="BaseController"`, a sibling) through the app's factory, then copied every function of the framework's `Controller.cfc` into it unless the app component already had that name. Copying was done by injecting two helper functions that return and set the Variables scope of each object. Result: the app method called the framework's public method, which called a framework private method and read instance data; the app's own override won; `Controllers.Admin.Users`, in a subfolder and with no `extends`, worked the same; two instances kept separate data.
- Timing on this box: 200 creations with copying took 187 ms, 200 plain creations 141 ms.
- The real bootstrap files (`public/index.cfm`, `app/Config/Paths.cfm`, `system/Boot.cfm`, `system/Boot.cfc`), run from the scratch layout with only the `appDirectory` line changed: 503 with "The WRITEPATH is not set correctly." when the writable folder was missing, and 200 with all six path values once it existed.

## Running a request end to end: verified behaviour (third session, 2026-11-22)

Found while getting the router, a controller and a view to run on the server.

Names:

- A function cannot have the name of a built-in function, and this is true for component methods too. `initialize`, `setLocale` and `getLocale` were refused at compile time with "The names of user defined functions cannot be the same as built-in ColdFusion functions".
- These method names are allowed: `get post put delete options head patch add run send render handle header __construct`.
- An argument named `request` hides the Request scope inside that function.
- An argument or a `var` with the name of a function hides the function; `variables.name(...)` still reaches the function.
- A method named `request` or `server` has to be called through `this.` from inside the component.
- `this.config` as data and a function named `config` can exist together when the function is not public. A public method lives in `this`, so a `this` value with the same name would take its place.
- Defining the same function twice in one page or component fails.

Components:

- The Variables scope of a component holds its own functions only, not the inherited ones, and it has a `THIS` key. `Evaluate(name)` inside the object does return an inherited private function.
- A function copied out of one object and stored in another runs against the new object, and `super.method()` still works inside it.
- A struct of functions taken from another object can be called as `parent.method()`; the function runs against the calling object.
- A custom attribute on `cfcomponent` (for example `parent="..."`) shows up in `GetMetaData(obj)`.
- `GetMetaData(obj).functions` is an array of structs with `name` and `access`.
- `this.privateMethod()` fails; a private method is called without a scope.
- A function that returns nothing leaves the variable it was assigned to undefined.
- `ArrayLen(arguments)` counts the declared arguments, also those not passed.
- `Evaluate("obj.#method#(a, b)")` works for calling a method by name with positional arguments.
- `extends` and `CreateObject` take no file path, only a dotted name.

Output:

- No output leaves a chain of `output="no"` calls. The body has to be handed back and written by the requested page.
- `cfheader` and `cfcontent type` do work inside an `output="no"` method.
- A view renders inside an `output="no"` method with `cfsavecontent`, then `cfsetting enablecfoutputonly="no"`, then `cfinclude`. The included file reads and writes the arguments and `var` locals of that method.

Functions and Java:

- `RemoveChars` fails on an empty string (the start has to be inside the string).
- `REFind(re, string, 1, true)` returns `pos` and `len` arrays.
- `java.util.regex.Pattern` works. `java.lang.String.split` cannot be called on a CFML string.
- `java.util.LinkedHashMap` passes `IsStruct`, keeps the order of its keys, is case-sensitive, and is read with brackets only. `StructIsEmpty` fails on it; `StructCount` works.
- `cfthrow type="A.B.C"` with `errorcode` works, and `cfcatch type="A.B"` catches it.
- Arrays are copied on assignment.
- `GetHttpRequestData()` has the keys `protocol`, `content`, `method`, `headers`.
- `CGI[key]` works with the name in a variable.
- More `../` than there are folders in a `cfinclude` path stops at the drive root.

Request values on this site (IIS 4 with the rewrite rules in `public/.htaccess`):

- `/`: `SCRIPT_NAME`, `PATH_INFO` and `REQUEST_URI` are all `/index.cfm`.
- `/foo/bar?x=1` (rewritten): `PATH_INFO` and `REQUEST_URI` are `/index.cfm/foo/bar`, `QUERY_STRING` is `x=1`.
- `/index.cfm?/foo/bar`: `QUERY_STRING` is `/foo/bar`.
- `SERVER_PROTOCOL` is `HTTP/1.1`, `HTTPS` is `off`, `SERVER_PORT` is `80`.
- A `.htaccess` file in a subfolder is not used.

### Cached metadata of a child component

- `GetMetaData()` of a component keeps the metadata of its `extends` chain from the time the child was compiled. After the `parent` attribute of `app/Controllers/BaseController.cfc` was changed and uploaded, `Home.cfc` (which extends it and was not changed) still reported the old value, and the request failed with "Class not found" for the old name. Uploading `Home.cfc` again, unchanged, made the server compile it again and fixed it. So: when an attribute of a base component changes, upload its children again too.

## Exception handler port (verified on the server)

- An unscoped name `file` resolves to the FILE scope (a struct) before the variables scope. Use `variables.file`.
- A `var` named like a function hides that function for the rest of the method (`var realpath` hid `realpath()`).
- `cfcatch.tagContext` is an array of structs with `template` and `line`; `cfcatch.type` and `cfcatch.message` are usable as the exception.
- Output written with `cfoutput` inside a `savecontent` view is lost when the view errors; debug with `cfthrow message=`.

## Request input port (verified on the server)

- `a[b].method()` does not compile ("Invalid CFML construct"); put `a[b]` in a `var` first.
- `server` is a scope name: inside a component call `this.server(...)`, an unscoped `server(...)` fails with a 500.
- There is no `cfcontinue`; use nested `cfif`.
- `java.util.LinkedHashMap` works as an ordered, case-sensitive map: bracket read, `.remove(key)`, `.equals(...)` and `StructCount` all work, and it passes `IsStruct`.
- Java regex with lookbehind works through `CreateObject("java", "java.util.regex.Pattern")`.
- `CGI.QUERY_STRING`, `CGI.HTTP_COOKIE` and `CGI.CONTENT_TYPE` are available. A cookie `Enc=x%20y` is decoded by `URLDecode`; `Plus=a+b` stays `a+b` in `CGI.HTTP_COOKIE`.
- `GetHttpRequestData().content` is a string for a urlencoded body (POST and PUT) and a JSON body; the body of PUT and POST is not in the `form` scope for PUT.
- Multipart POST: the `form` scope has upper-cased names (`a` becomes `A`, `n[k]` becomes `N` with `K`), plus `FIELDNAMES`; original case cannot be recovered there.
- `index.cfm?/route?a=1&b=2` passes variables with a route (the factory splits on `?`, as upstream). `index.cfm?/route&a=1` gives 400 because the route becomes `route&a=1`.
- `X-Requested-With: XMLHttpRequest` is read as a header; `isSecure` stays false behind `X-Forwarded-Proto: https` unless the proxy is trusted (as upstream).
- A method named like a property clashes (names are case-insensitive): `SiteURI.baseUrl()` against `this.baseURL` gave "Entity has incorrect type for being called as a function"; the method is `baseUrl_`.
- `obj.method(argumentCollection=struct)` works on a method call; `IsDefined("arguments.x")` is false for an optional argument that was not passed.
- Java `String.replaceAll` through `JavaCast("string", s)` works, with `(?iu)` and `\pL`; a `LinkedHashMap` passes `IsStruct` and loops with `cfloop collection`.
- On the scratch tree `indexPage = "index.cfm?"` gives `site_url("a/b")` = `http://coldigniter.lan/_tu/index.cfm?/a/b`, which the server answers (200 for an existing route). A query in the argument gives a second `?` (`.../a/b?x=1`), as the router splits on the last `?`.
- A redirect on IIS answers 302 with a `Refresh: 0;url=...` header (no `Location`), as upstream does for IIS.
- A helper file is loaded once per request by `helper("url")`; the functions then work in controllers and in views.

## Header values and url helper fixes (verified on the server)

- `cfheader` does not stop a CR LF in a value: `value="a#Chr(13)##Chr(10)#Set-Cookie: probe=1"` sent an `X-Probe: a` header and a second, real `Set-Cookie: probe=1` header (the response splits). The check has to be done before `cfheader`; it is in `Message.setHeader` (the original does it in the Header class).
- The literal `false` (also in a `var` or as a `cfargument` default) is the string `"false"` (`getClass().getName()` is `java.lang.String`); only the result of a comparison such as `1 EQ 2` is a `java.lang.Boolean`. So `false`, `"no"` and `0` can be told apart as `"false"` against the others, but not `false` against the string `"false"`.
- A struct made with dot notation (`s.width = 400`) has upper-case keys (`WIDTH`, `ID`); `s["Width"]` keeps its case.
- `JavaCast("string", s).matches("[...]")` works with `\x20`, `\u0080-\uFFFF` and a class that has `##` (a literal `#`).
- `Chr(0)` is an empty string, so the NUL character cannot be in the default list of the trim polyfills.
- The loop over the `CGI` scope lists only `HTTP_COOKIE`, `HTTP_CONNECTION`, `HTTP_REFERER`, `HTTP_USER_AGENT`, `HTTP_ACCEPT_ENCODING`, `HTTP_ACCEPT_LANGUAGE`, `HTTP_ACCEPT` and `HTTP_HOST` of the request headers. A custom header such as `X-Test-Hdr` is missing from the loop, but `CGI.HTTP_X_TEST_HDR` reads it by name; `getServer("HTTP_X_FORWARDED_FOR")` therefore falls back to a read by name.
- `URLDecode` throws (a 500 without a catch) for a percent sign that is not followed by two hexadecimal digits (`a+b%`, `%zz`, `%4`, `%41%`); a well-formed `%20` and `%C3%A9` decode and a plus becomes a space. `parse_str` writes such a lone sign as `%25` first, so it stays as it is.
- `Chr(0)` is an empty string in a literal, `Find(Chr(0), s)` returns 1 for any string; `URLDecode("ab%00cd")` does hold a real NUL character (length 5). `parse_str` cuts a name at the text `%00` before decoding.
- The engine's own form parser (`FormScope`) throws `IllegalArgumentException` for a POST body with a malformed percent sign in the middle (`p=%zz+%4`), before any CFML runs; a trailing one (`q=a+b%`) is fine. A malformed percent sign in the query string of a GET (`?q=a+b%`, `?q=%zz`, `?/hello/world?q=a+b%`) gives a JRun 500 (`String index out of range`, or `null`) also for a page that only prints `CGI.QUERY_STRING`, so the engine fails before any CFML runs and the framework cannot answer it (a well-formed `%41` is fine).
- `java.util.IdentityHashMap` works (`put`, `containsKey`, `get` returns a number); `curl` needs `-g` for a URL with `[`.
- `parse_str` takes at most 1000 pairs and a name with at most 64 pairs of brackets (the defaults of max_input_vars and max_input_nesting_level): 1100 pairs gave 1000 values; a POST of 20000 `a[]=` pairs gave 1000 values in about 2 s.
- `URLDecode` does not throw for well-formed escapes that are not valid UTF-8: `%FF`, `%C3` and `%80%80` each give U+FFFD per bad byte (`%E9t%E9` gives three characters, 65533 116 65533) and `%C3%A9` gives 233. The same text in a GET query after the route and in a POST body reaches `getGet()` and `getPost()` as U+FFFD; the original byte cannot be kept.
- `java.lang.StringBuffer.append()` was wrapped in `JavaCast("string", ...)` so a numeric-looking piece (`0012`) is not given to a numeric overload; `x=%410012` gives `A0012`, `x=0012` stays `0012`.
- A number key is only a canonical decimal integer (`^(0|[1-9][0-9]{0,17})$`): `f[007]=a&f[]=b` gives keys `007` and `0`; a 20-digit key is kept as it is and the next is `0`. The next free number is kept in a `java.math.BigInteger` because `ToString(Int(1E+018))` prints in E notation (`f[999999999999999999]=a&f[]=b` gives `1000000000000000000`).
- A cookie name is checked for a repeat after it is normalised like `parse_str` does: `a.b=1; a_b=2` gives `a_b` = 1 and `%61=1; a=2` gives `a` = 1.

## Filters and events (verified on the server)

- A component method named `log` fails to compile ("names of user defined functions cannot be the same as built-in ColdFusion functions"); other built-in names such as `search` are listed in the same error. Use a trailing underscore.
- A component-body default cannot call a user function such as `array_()`; `CreateObject("java","java.util.LinkedHashMap").init()` works there and keeps insertion order (read and write with brackets, `cfloop collection`; `IsStruct` is true, `IsArray` false).
- `Evaluate("target.method(args)")` calls a method on an object or a component name, which is the callable form of events and filters.
- A Request returned by a before filter replaces the request; a Response stops the controller (403 from a filter, controller not run).
- `cfthrow` with a dotted type and `errorcode` is shown as a 500 unless the type is in the status-code list of `Debug/Exceptions` (`SecurityException` was added: InvalidChars answers 400 for `%01` and for `%FF`).
- `ForceHTTPS` on IIS answers 307 with `Refresh: 0;url=https://...` and `Strict-Transport-Security: max-age=31536000`, also for a 404 route.
- `<cfreturn false>` from a method arrives as the string `"false"` (`java.lang.String`, `Compare(r, "false")` is 0); `<cfreturn 0>` and `"no"` are strings too. Only `JavaCast("boolean", false)` is a `java.lang.Boolean` (`Compare` against `"false"` is not 0, it reads as `NO`). An event listener returning `false` or `"false"` stops the chain; `0`, `"0"`, `"no"` and nothing do not. A before filter returning true, false or 0 lets the next filter run, any other non-empty string stops the filters.
- `URLDecode` of a path with a lone or bad `%` is guarded in `Filters.initialize_` (`parse_str_decode`). A bad escape in the request query (`?/a/%zz`, also `?/a?x=%zz`) is answered by the engine itself with a bare "JRun Servlet Error 500 null" before the framework runs; the filter code is not involved.
- InvalidChars (query `?/flt/plain?ft=2&x=...`): `%01`, `%7F` and `%C2%85` (U+0085) answer 400; `%0A`, `%09`, `%0D`, `%C3%A9` and plain text pass. U+0085 is refused by the original too: `[:^cntrl:]` with the u modifier runs in Unicode property mode, where it is the Cc category (checked with pcre2test: refused with UCP, accepted without).

## .env and the logger (verified on the server)

- `access="protected"` on a `cffunction` does not compile; the valid values are `private`, `package`, `public` and `remote`. `private` is used where the original has `protected`: a private method of `BaseConfig` and of `Logger` is called from the component's own methods on the server, also for a config class of the app that has the methods composed in (arrays of `logger.threshold.1` from `.env` went through the private `initEnvValue`, and `{env}` placeholders through the private `interpolate`).
- A function named `setVariable` (and `date` inside a component, which then shadows the polyfill) clashes with a built-in; use a trailing underscore.
- `<cfcontinue>` is not supported; use `cfif` or `cfbreak`.
- `cfswitch`/`cfcase` is case-insensitive at compile time (`D` and `d` as two cases is a compile error), and it compares with CFML equality: `yes` matches the case `true`. `EQ` does the same, so `Compare()` is used where the exact text matters (`env()` turns `true`, `false`, `empty` and `null` only; `yes` stays `yes`).
- `collection="#this#"` lists the keys in upper case; `IsCustomFunction(this[key])` tells functions from properties.
- `GetMetaData(component).name` of a class loaded through the nearest `autoload.cfm` is only the name relative to that folder (`Logger`, not `Config\Logger`), so `Autoloader.instantiate` stores the requested class name in `__class`.
- `cffile action="append"` needs `charset="utf-8"` and `addnewline="no"` to write exact bytes; to a directory that does not exist it throws type `Application` ("An error occurred when performing a file operation append"), which a `cftry` catches, so a bad log path does not break a request (the line is lost and `log_()` returns false).
- 8 parallel requests with 60 appends each wrote intact lines, with or without a named `cflock`.
- `cflog file="x" application="no"` writes CSV to `C:\CFusionMX\logs\x.log` and flattens line breaks; the engine's own log directory is not writable through FTP, so a probe file there cannot be removed.
- `DateFormat`, `TimeFormat` and `TimeFormat(t, "l")` (milliseconds) work; `tagContext` rows of a caught exception have `TYPE`, `TEMPLATE`, `COLUMN`, `RAW_TRACE`, `ID` (`??`) and `LINE`.
- A `.env` at the application root is not reachable by URL when the tree is outside the web root; inside a served folder IIS answers 404 for `.env` here.
- **Request headers and the CGI scope (security).** A header is read by name through the CGI scope when the engine has no variable of that name. With the headers `CI_ENVIRONMENT: development`, `CI-ENVIRONMENT: development`, `app.baseURL: http://evil.example/` and `logger.threshold: 9`, `CGI.CI_ENVIRONMENT`, `CGI["CI-ENVIRONMENT"]`, `CGI["app.baseURL"]` and `CGI["logger.threshold"]` returned those values. Before the fix `env()` returned them for the same names and the environment became `development` with and without a `.env` file (a `.env` with its own `CI_ENVIRONMENT` was not affected, as it is read first); the config classes (`BaseConfig` reads the `.env` store only) did not change, but the logger threshold followed the environment (4 in production, 9 otherwise). A header whose name is also a real variable did not win (`REMOTE_ADDR`, `REQUEST_METHOD`, `SERVER_NAME`, `SERVER_PORT`, `SCRIPT_NAME`, `QUERY_STRING`, `PATH_INFO`, `AUTH_USER`, `REMOTE_USER`, `CONTENT_TYPE` and the like kept the real value), but a header `HTTPS: on` replaced the real `HTTPS` (`off`), and `CONTEXT_PATH` and `CF_TEMPLATE_PATH` too. After the fix `env()` reads the CGI scope only for a fixed list of server variables (without `HTTPS`) and for names that match `^HTTP_[A-Z0-9_]+$`, and the environment name comes from the `.env` store only; the same four headers changed nothing (environment, `env()`, `baseURL` and threshold stayed the same, with and without a `.env`).
- `.env` values in double quotes follow the original: `"a \"quoted\" b"` gives `a "quoted" b`, `"back\\slash"` gives `back\slash`, `"x\\"y"` gives `x\` (the text after the closing quote is dropped), `"a\\\"b"` gives `a\"b`, `'it\'s'` gives `it's`, `""` gives an empty value and a quote that is never closed keeps the quote in the value. A repeated name keeps its first value unless that is empty or `0` (`A=no` then `A=yes` stays `no`, `Z=0` then `Z=7` gives `7`). A `.env` with CRLF line ends gives the same values as one with LF.
- A logger threshold of 0, a negative one or text gives only `emergency` (the original's `range(1, 0)` is `[1, 0]`); 3 gives emergency, alert and critical; 2.7 is 2; an array in the config class (`2, 5, 8`) is used as it is, and `logger.threshold.1 = 6` in `.env` replaces its second element (`2, 6, 8`), while a plain `logger.threshold` is not used for an array.
- `ErrorlogHandler` with `messageType` 0 wrote CSV lines to `C:\CFusionMX\logs\<name>.log` (the name is `ColdIgniter` in the code; the test ran a copy that wrote `ci_probe.log`, a file that already existed, so no new file was left): `"Fatal","jrpp-29","11/22/26","10:06:13",,"EMERGENCY --> msg "`, with the severities Fatal (emergency, alert, critical), Error, Warning (warning, notice) and Information. `messageType` 4 wrote the same lines to `application.log`. `messageType` 3 throws the LogException of an invalid message type.
- `FileHandler` with the extension `CfM`: a new file starts with `<cfabort>` and an empty line, the line is written once, and a copy of that file under the web root answered 200 with an empty body. A later line that has tag-like text (`<cfif x>`) makes the server fail to compile the file (500) and its error page shows that line, so the guard does not protect a file with such text. With the extension `cFc` nothing is written (handler returns false, the request still answers 200). A read-only log file (the attribute set with `cffile attributes="readOnly"`; a read-only folder cannot be arranged, FTP has no chmod here) does not break the request: the line is dropped and the file is unchanged.

## Forged CGI variables, secure request, log files (verified on the server)

- **Every real server variable can be forged with a request header whose name is the dash form of the variable.** The engine (IIS 4 and the JRun connector) gives each header name in upper case with dashes (`Server_Port`, `Server-Port` and `SERVER-PORT` are one name, `GetHttpRequestData().headers` and `getHeaderNames()` list them that way and list every header), and the connector reads a variable from the header of that name before the variable of the server. The servlet request is fooled too: `Server-Port-Secure: 1` gave `GetPageContext().getRequest().isSecure()` YES and `getScheme()` https (the secure flag on the connector's wire is 1); `Remote-Addr: 192.0.2.9` changed `getRemoteAddr()`, `Request-Method: POST` `getMethod()`, `Server-Name` `getServerName()`, `Server-Protocol` `getProtocol()`, `Server-Port: 443` `getServerPort()` (`Server-Port: evil` gave -1). A header written with underscores (`REMOTE_ADDR: evil`) did not change a variable that is real here, and did change `HTTPS`, `CF_TEMPLATE_PATH`, `CONTEXT_PATH`, `REQUEST_URI` and the names the engine does not set. So nothing in the CGI scope or the servlet request says "secure" in a way a client cannot forge on this transport; the underlying `ProxyEndpoint` object (the connector, reachable through `getHttpRequest().getRequest()` with reflection) holds the same values.
- What the client cannot change is the list of header names it sent. `server_value()` (Common.cfm) reads a server variable only when no header has that name (upper case, dashes as underscores); a forged one reads as empty. Checked: with `HTTPS: on` `isSecure()` stays false and ForceHTTPS still answers 307 (also with `Server-Port-Secure: 1`, `Server-Port: 443`, all together, `X-Forwarded-Proto: https` and `Front-End-Https: on`, which count only for a trusted proxy as in the original); `site_url()`, `base_url()`, `current_url()` and the URI scheme did not change under any forged header; `getServer("HTTPS")`, `getServer("SERVER_PORT")`, `getServer("REMOTE_ADDR")`, `getServer("REQUEST_METHOD")` and `getServer("CF_TEMPLATE_PATH")` returned an empty string for the forged name, and the server array no longer holds it; `getIPAddress()` gives `0.0.0.0` for a forged `Remote-Addr`. A request that forges `Query-String` or `Path-Info` loses its route (empty) and gets the default controller, as without the variable.
- **Could not be tested: https.** The test site serves plain http only. The value for http is right (`HTTPS` off, `SERVER_PORT_SECURE` 0, `isSecure()` false, `getScheme()` http, port 80) and does not move with any forged header once `server_value()` is used, but that a real https request gives `HTTPS` on and a true `isSecure()` is the documented behaviour of IIS, not proven here.
- Table of names (a header of the dash form `NAME-WITH-DASHES: evil`, and of the underscore form; "yes" = the CGI value changed to `evil`):

| Name | Dash form forges | Underscore form forges | Note |
|---|---|---|---|
| HTTPS | yes (`HTTPS: on` has no dash) | yes | the name has no underscore; the plain header replaces it |
| SERVER_PORT, SERVER_PORT_SECURE, SERVER_PROTOCOL, SERVER_NAME, SERVER_SOFTWARE | yes | no | servlet `getServerPort`, `isSecure`, `getScheme`, `getProtocol`, `getServerName` follow |
| REMOTE_ADDR, REMOTE_HOST, REQUEST_METHOD | yes | no | servlet `getRemoteAddr`, `getMethod` follow |
| PATH_INFO, PATH_TRANSLATED, QUERY_STRING, GATEWAY_INTERFACE, LOCAL_ADDR | yes | no | servlet `getQueryString` follows |
| SCRIPT_NAME | no (the connector keeps its own) | no | checked: a `Script-Name` header did not change `CGI.SCRIPT_NAME` in the first probe set; read through `server_value()` anyway |
| AUTH_USER, AUTH_TYPE, AUTH_PASSWORD, REMOTE_USER | yes | no | servlet `getAuthType`, `getRemoteUser` follow |
| CERT_COOKIE, CERT_FLAGS, CERT_ISSUER, CERT_KEYSIZE, CERT_SECRETKEYSIZE, CERT_SERIALNUMBER, CERT_SERVER_ISSUER, CERT_SERVER_SUBJECT, CERT_SUBJECT | yes | no | empty on http |
| HTTPS_KEYSIZE, HTTPS_SECRETKEYSIZE, HTTPS_SERVER_ISSUER, HTTPS_SERVER_SUBJECT | yes | no | empty on http |
| CF_TEMPLATE_PATH, CONTEXT_PATH, REQUEST_URI | yes | yes | not real server variables of IIS (the engine adds them); `REQUEST_URI` is synthesised by the engine |
| INSTANCE_ID, APPL_MD_PATH, APPL_PHYSICAL_PATH | yes | no | |
| CONTENT_TYPE | yes | no | a real header by nature; the servlet `getContentType` follows |
| CONTENT_LENGTH | not tested (`Content-Length` is the real header) | no | |
| HTTP_HOST | no (`Http-Host`, `Http_Host` did not change it; the real `Host` header is the value) | no | `Host: evil` is a different site on this box (not answered) |
| HTTP_COOKIE, HTTP_REFERER, HTTP_USER_AGENT, HTTP_ACCEPT, HTTP_CONNECTION, HTTP_X_*, HTTP_FRONT_END_HTTPS | `Http-Cookie: x` and `Cookie: x` give the same value | yes | these are request headers by nature; the forms `HTTP-X`, `HTTP_X` and `X-` collide on one name, so a client can send what a proxy sends |
| WEB_SERVER_API, SERVER_ROOT, DOCUMENT_ROOT (not variables here) | yes | yes | a name that is not a real variable is supplied by any header |

  The "no" cells of the underscore column come from the first probe set, where the real value was kept for `REMOTE_ADDR`, `REQUEST_METHOD`, `SERVER_NAME`, `SERVER_PORT` and the like when the header had underscores; the dash form is what forges them.
- `FileHandler` with the extensions `cfm`, `cfml` and `cfc` in any case (also `.cfc`) writes nothing and returns false; an extension with a slash, a backslash, a colon or two dots (`x/y`, `x\y`, `x:y`, `a..b`, `../zz`) also writes nothing and returns false, and the log folder held only the file of the extension `txt`. The `cfabort` first line was removed (a later line with tag-like text broke the compile, see above).
- A caught error passed as `exception` (`cfcatch`, a Java object that fails `IsStruct`) gives `message file:line` (`caught with context APPPATH\Controllers\Sec.cfc:34`), read through `cfcatch.message` and `cfcatch.tagContext` inside a `cftry`.
