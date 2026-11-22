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
