# Core CFML language in ColdFusion MX 6.1 (excluding CFCs)

Source key used in every citation below:

- **Dev p. N** = *Developing ColdFusion MX Applications* (Macromedia, ColdFusion MX 6.1 edition), local text `cfmx_6.1_docs_en/text/cfmx61_dev_cf_apps.txt`, printed page N.
- **Ref p. N** = *CFML Reference* (Macromedia, ColdFusion MX 6.1 edition), local text `cfmx_6.1_docs_en/text/cfmx61_cfml_reference.txt`, printed page N.
- **Install p. N** = *Installing ColdFusion MX 6.1*, local text `cfmx61_install.txt` in the same directory.
- Web sources are given as URLs. Version claims about CF 7/8/9 come from the web only; the 6.1 manuals can only show that a feature is absent.

## Variables and scopes: every scope, lookup order, which are structs, naming, case, by-value vs by-reference, Duplicate()

### Takeaway
MX 6.1 has 17 scopes; unscoped names resolve Arguments, Variables, CGI, Cffile, URL, Form, Cookie, Client (function-local `var` variables come before all of them). Simple values and arrays are copied on assignment; structs, queries and objects are shared by reference, and `Duplicate()` is the deep copy.

### Cited Findings
- CFML tag names and variable names are case-insensitive — Dev p. 40.
- Variable names start with a letter, underscore or Unicode currency symbol, then letters, digits, underscores, currency symbols; no spaces; no periods in simple names except in the Cookie and Client scopes — Dev p. 54.
- Variables are created with `cfset`, `cfparam` or a CFScript assignment; using an undefined variable is an error — Dev p. 54.
- Scope list: Variables, Form, URL, Attributes, Caller, ThisTag, Request, CGI, Cookie, Client, Session, Application, Server, Flash, Arguments, This, function local; the Cffile scope also appears in the tables — Dev p. 44-45, 72-74.
- Scope prefix NOT required for: Variables, Form, URL, CGI, Cookie, Client, Arguments. Prefix REQUIRED for: Attributes, Caller, ThisTag, Request, Cffile, Session, Application, Server, Flash, This. Prefix PROHIBITED for function-local variables — Dev p. 75-76.
- Unscoped lookup order: 1 Arguments, 2 Variables, 3 CGI, 4 Cffile, 5 URL, 6 Form, 7 Cookie, 8 Client — Dev p. 77.
- Function-local (`var`) variables take precedence over all other scopes — Dev p. 198. (Dev p. 77 leaves them out of its numbered list; see Inferences.)
- "ColdFusion makes all named scopes available as structures. You cannot access the function-local scope for user defined functions (UDFs) that you define using CFScript as a structure." — Dev p. 77.
- The Caller scope is a structure since MX — Ref p. 23.
- Do not call `StructClear(Session)` — Dev p. 78.
- Client scope holds simple values only — Dev p. 72-74, 316.
- Array assignment copies the array: `<cfset b = a>` gives an independent array — Dev p. 61.
- Struct assignment is by reference; `<cfset MyStruct.MyValue=2>` auto-creates the struct in MX; use `Duplicate` for a copy — Dev p. 61-62. Queries are also by reference — Dev p. 62-64.
- Passing to UDFs and custom tags: simple values and arrays are copied; structs, queries and objects are passed by reference — Dev p. 82.
- `Duplicate(variable_name)` returns a deep copy ("clone") with no reference to the original; works on nested structs, queries and (since MX) XML objects; it cannot duplicate COM, CORBA or Java objects, nor a struct/array that contains one. `StructCopy` is shallow: nested structs stay shared — Ref p. 466.
  ```cfml
  <cfset s1 = StructNew()>
  <cfset s1.nested = StructNew()>
  <cfset s1.nested.item = "original">
  <cfset copy = StructCopy(s1)>   <!--- nested still shared --->
  <cfset clone = Duplicate(s1)>   <!--- fully independent --->
  ```
- Names with periods and nested auto-creation: `Variables["my.var.with.periods"]` is legal; `<cfset myVar.a.b = "x">` auto-creates nested structs — Dev p. 65-67.
- `IsDefined("variable_name")` takes a quoted name; it always returns False for bracket notation such as `IsDefined("myArray[3]")`; in MX it handles only simple variables and dot notation — Ref p. 533; Dev p. 79.
- `StructKeyExists(structure, "key")` is the equivalent for struct scopes: `<cfif StructKeyExists(Form,"JediMaster")>`; it throws if the structure itself does not exist — Ref p. 710.
- `cfparam` attributes `name`, `type`, `default`; types any, array, binary, boolean, date, numeric, query, string, struct, UUID, variableName — Dev p. 79-81.
- Reserved words: built-in function names, scope names, anything starting with `cf`, operators (AND, OR, IS, CONTAINS, MOD, ...), built-in structure names (Error, File), CFScript keywords; form-field suffixes `_integer`, `_float`, `_range`, `_date`, `_time`, `_eurodate` — Dev p. 51; Ref p. 20.
- A cffunction UDF assigned into a struct gets `This` bound to the containing struct — Dev p. 78.

### Inferences
- Dev p. 77 and Dev p. 198 are consistent if the full order is read as: function-local var, Arguments, Variables, CGI, Cffile, URL, Form, Cookie, Client. Always scope-prefix shared-scope access anyway, because Request, Session, Application and Server are never searched.
- Because arrays copy on assignment and on function call, a framework that passes arrays into helpers and expects mutation must return the array or wrap it in a struct.

### Gaps
- The manuals read do not state whether the function-local scope of a `cffunction` (tag) UDF is reachable as a struct; no `local` scope name exists in 6.1 as far as the text read shows (unconfirmed: the explicit `Local` scope is a later-version feature; not verified here).

## Data types: simple, array, struct, query, object, binary, XML; conversion; boolean truthiness; dates; null

### Takeaway
CFML 6.1 is typeless with automatic conversion; there is no null type (external nulls become empty strings when used) and no array or struct literal syntax, only `ArrayNew()` and `StructNew()`.

### Cited Findings
- Type categories: simple (number, string, Boolean, date-time), complex (array, structure, query, XML document object), binary, object (COM, CORBA, Java, CFC, web service) — Dev p. 55.
- Type tests: IsArray, IsBinary, IsBoolean, IsObject, IsQuery, IsSimpleValue, IsStruct, IsXmlDoc, IsDate, IsNumeric — Dev p. 56.
- Null: "ColdFusion does not use a null data type. However, if ColdFusion receives a null value from an external source such as a database, a Java object, or some other mechanism, it maintains the null value until you use it as a simple value. At that time, ColdFusion converts the null to an empty string ("")." — Dev p. 56.
- Integers are 32-bit signed; larger values become floating point and lose precision. Reals range to about ±10^300 with 12 significant digits — Dev p. 56-57.
- Strings use single or double quotes; escape a quote or `#` by doubling it — Dev p. 50, 57.
- Lists are just delimited strings; default delimiter is the comma; empty elements are ignored — Dev p. 58.
- Boolean truthiness: True, any nonzero number and "Yes" are true; False, 0 and "No" are false — Dev p. 58. Conversion: "Yes" → True/1; True converted to a string is "Yes" — Dev p. 68.
- Write `<cfif myVariable>`, not `<cfif myVariable IS True>`: `12 IS True` is false — Dev p. 69-70.
- Comparison quirks: `"0.0" IS "0"` is true (numeric compare); "1a" is read as the time 1:00am; use `Compare()`/`CompareNoCase()` for strict string comparison — Dev p. 70.
- Dates: range 100 AD to 9999 AD; two-digit years 0-29 map to 20xx and 30-99 to 19xx; stored as real numbers where 0 is 12/30/1899; a date converted to a string is an ODBC timestamp — Dev p. 58-60, 68.
- Arrays: `ArrayNew(1)` (1 to 3 dimensions); index from 1 (`<cfset months[2] = "February">`) — Dev p. 61; Ref p. 318.
- Structs: `StructNew()`; keys by dot or bracket notation; keys are unordered — Dev p. 61-62; Ref p. 710.
- Queries: column access `myQuery.Col[2]` — Dev p. 62-64.
- Binary/Base64: `ToString(ToBinary(ToBase64("Hello world")))` — Dev p. 60. `ToString(any_value[, encoding])` converts simple values, binary without zero bytes, and XML document objects; throws if it cannot convert — Ref p. 725.
- `GetHttpRequestData().content` may be binary; test with `IsBinary()` — Ref p. 491.

### Inferences
- A "null" check in 6.1 has to be written as an existence check (`IsDefined`/`StructKeyExists`) or an empty-string check; there is no `IsNull()` in the 6.1 function set that was read (not seen in the manuals; unconfirmed that it is absent, but the manual states there is no null type).
- Since everything coerces, a PHP-style strict `===` must be emulated with `Compare()` plus type-test functions.

### Gaps
- Array/struct literal syntax (`[]`, `{}`) is not documented anywhere in the 6.1 chapters read; web sources place its introduction in ColdFusion 8 — https://www.bennadel.com/blog/740-learning-coldfusion-8-implicit-struct-and-array-creation.htm ; https://www.petefreitag.com/blog/implicit-structure-notation . NOT available in 6.1.
- XML object details (XmlParse, XmlNew, XmlSearch) were not researched in depth.

## Operators: the full 6.1 list, what is not available, pound sign rules

### Takeaway
6.1 has only word operators for comparison and logic (EQ, NEQ, GT, AND, OR, NOT ...), arithmetic `+ - * / \ ^ MOD`, and `&` for concatenation. None of `== != < > <= >= && || ! ++ -- += ?:` exist, in tags or in CFScript.

### Cited Findings
- Arithmetic: `+ - * /`, unary `+ -`, `MOD`, `\` (integer division), `^` (exponent) — Dev p. 84-85.
- Boolean: `NOT`, `AND`, `OR`, `XOR`, `EQV`, `IMP` — Dev p. 85.
- Decision: `IS`, `IS NOT`, `CONTAINS`, `DOES NOT CONTAIN`, `GREATER THAN`, `LESS THAN`, `GREATER THAN OR EQUAL TO`, `LESS THAN OR EQUAL TO`; short forms `EQUAL`, `EQ`, `NOT EQUAL`, `NEQ`, `GT`, `LT`, `GTE`, `GE`, `LTE`, `LE` — Dev p. 85-86.
- Comparisons are numeric if both operands convert to numbers, otherwise case-insensitive string comparisons — Dev p. 86.
- String operator: `&` only — Dev p. 87.
- Precedence, high to low: unary `+ -`; `^`; `* /`; `\`; `MOD`; `+ -`; `&`; comparison operators; `NOT`; `AND`; `OR`; `XOR`; `EQV`; `IMP` — Dev p. 87.
- "You cannot use JavaScript operators, such as <, >, ==, or ++." (in CFScript) — Dev p. 129.
- Assignments are statements, not expressions (no `a = b = 1`, no assignment inside a condition) — Dev p. 131.
- Loop increment must be written `i = i + 1` — Dev p. 135.
- Pound signs: used around variables/expressions inside `cfoutput`, strings and attribute values; not needed in `cfset` expressions; never around function arguments; full expressions are allowed inside pounds in a string: `value="The #CookieValue & 'ate the cookie!'#"`; a literal `#` is written `##` — Dev p. 50, 89-91.
- `++`, `--`, `+=` style operators: "Since ColdFusion 8, CFScript has supported syntax abbreviations that are common in many other programming languages" — https://en.wikipedia.org/wiki/CFScript . NOT available in 6.1.
- `==`, `!=`, `<`, `>` in CFScript are described as ColdFusion 8 additions — https://hub.packtpub.com/coldfusion-8-enhancements-you-may-have-missed/ (third-party; the page has a typo in its operator list). NOT available in 6.1.

### Inferences
- A ternary must be written as `cfif/cfelse`, a script `if/else`, or `IIf()` (see Dynamic evaluation). The 6.1 operator tables (Dev p. 84-87) contain no `?:`, `&&`, `||` or `!`, so they are unavailable.

### Gaps
- The exact version that introduced `&&`, `||`, `!` and the ternary operator was not confirmed from a primary source (commonly cited as CF 8 for the logical operators and CF 9 for ternary; unconfirmed).

## CFScript: every statement supported, what it cannot do, comments, where var must appear

### Takeaway
CFScript in 6.1 is a small statement language: assignment, function call, if/else, switch, for, for-in (structs only), while, do-while, break, continue, try/catch, function, var, return. It cannot run tags, has no throw/rethrow/finally, no typed or defaulted arguments, and `var` lines must be the first statements of a function.

### Cited Findings
- Statements: assignment, function call, `if`-`else`, `switch`-`case`, `for`, `for`-`in`, `while`, `do`-`while`, `break`, `continue`, `try`-`catch`, `function`, `var` (functions only), `return` (functions only) — Dev p. 129-130.
- Semicolons end statements; comments are `//` and `/* */` (CFML `<!--- --->` comments are for tag code) — Dev p. 50, 130-131.
- Reserved words: break, case, catch, continue, default, do, else, for, function, if, in, return, switch, try, var, while — Dev p. 131.
- No tags inside `cfscript`; use `WriteOutput()` in place of `cfoutput` — Dev p. 42-43, 129, 131.
- No `elseif` keyword; write `else if ( condition ) { }` — Dev p. 133; Ref p. 305.
- `switch`: case values must be constants; execution falls through without `break`; `default` supported — Dev p. 133-134.
- `for (init; test; final)`; `for (key in struct)` works on structures only, with no script equivalent for query or list loops — Dev p. 131-138.
- `continue` exists in script and has no tag equivalent in 6.1 — Dev p. 131-138.
- Exception handling: `try { } catch(exceptionType exceptionVariable) { }`, for example `catch(Any excpt)`; every `try` needs a `catch`; there is no script throw, rethrow or finally — Dev p. 139, 216-217; Ref p. 305.
- "If you code a cftry/cfcatch block within this tag using an exception's Java class name, you must provide the fully-qualified class name." — Ref p. 304.
- A UDF defined in script cannot have a name beginning with `cf`, `cf_`, `_cf`, `coldfusion`, `coldfusion_`, `_coldfusion` — Ref p. 304.
- `var`: "All var statements must be at the top of the function declaration, before any other statements. You must initialize all variables when you declare them. You cannot use the same name for a function variable and an argument. Each var statement can initialize only one variable." — Dev p. 198.
- Script functions: `function functionName( [argName1[, argName2...]] ) { }`; every listed argument is required; no types, no defaults, no access/returntype — Dev p. 198.
- Example (valid 6.1):
  ```cfml
  <cfscript>
  function sumTo(n) {
      var i = 0;
      var total = 0;
      for (i = 1; i LTE n; i = i + 1) {
          if (i MOD 2 EQ 0) { continue; }
          total = total + i;
      }
      return total;
  }
  try {
      WriteOutput(sumTo(10));
  } catch (Any e) {
      WriteOutput(e.message);
  }
  </cfscript>
  ```
- CF 9 added script `throw`, `rethrow`, `finally`, and script forms of tags such as abort, exit, include — https://www.bennadel.com/blog/1663-learning-coldfusion-9-cfscript-updates-for-tag-operators.htm ; https://forta.com/blog/cfml-enhancements-coming-soon ; `cffinally` history "ColdFusion 9: Added the tag" — https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/cffinally.html . NOT available in 6.1.

### Inferences
- To throw from script in 6.1, wrap `cfthrow` in a `cffunction` UDF (cffunction UDFs can use cftry/cfthrow/cfrethrow, Dev p. 216-217) and call that UDF from script. The same wrapper trick covers `cfinclude`, `cfabort`, `cflocation`, `cfheader`, `cfdump`, etc.
- Ref p. 305 says the catch variable "contains the exception type" and is "the equivalent of ... cfcatch.Type", while Dev p. 139 uses it as the full exception object (`excpt.Message`). Treat it as the cfcatch-like structure; the Ref wording looks loose.

### Gaps
- Script-defined components, the `new` keyword, script `for-in` over arrays, and typed/default script arguments are absent from the 6.1 chapters read; the introducing versions (commonly cited as CF 9) were not confirmed from a primary source.
- `cfcontinue` tag: not in the 6.1 tag list that was read; its introduction version (commonly cited as CF 9) is unconfirmed.

## UDFs: cffunction/cfargument/cfreturn, script functions, Arguments scope, call styles, argumentCollection, functions as variables, recursion, name clashes

### Takeaway
Tag UDFs (`cffunction`) are the full-featured form: typed, optional and defaulted arguments, `output` control, and access to all tags. Calls are positional or named, never mixed. Function names are global to the page, cannot be redefined, and cannot collide with built-ins.

### Cited Findings
- `<cffunction name="methodName" returnType="dataType" roles="securityRoles" access="methodAccess" output="yes" or "no" displayName="name" Hint="hint text">` — Ref p. 146.
- `returnType` (default any): any, array, binary, boolean, date, guid, numeric, query, string, struct, uuid, variableName, void, or a component name — Ref p. 146; Dev p. 200-201.
- `output`: omitted = body processed as standard CFML; `yes` = as if inside `cfoutput`; `no` = as if inside `cfsilent` — Ref p. 147; Dev p. 201.
- `access` default public (private, package, public, remote; meaningful for CFC methods) — Ref p. 147.
- `<cfargument name="string" type="data type" required="Yes or No" default="default value" displayname="descriptive name" hint="extended description">`; `required` defaults to no; types as for returnType (without void); `cfargument` tags must come before any other tags in the function body — Ref p. 54-55; Dev p. 201.
- `<cfreturn expr>`; returns one expression (return a struct for multiple values) — Ref p. 298. The Ref also states "You can code a maximum of one cfreturn tag within a function" — Ref p. 298 (see Inferences).
- Local variables in a tag UDF: `<cfset var myVar = "This is a test">`. "Any cfset tag that uses the var keyword must be inside the body of a cffunction tag" and "You must place all cfset tags that use the var keyword at the beginning of the cffunction tag body, before any other ColdFusion tags." — Ref p. 319.
- Calls use positional OR named arguments, never both in one call — Dev p. 192-193.
- Arguments scope behaves as both an array and a struct: `#myargument#`, `#arguments[1]#`, `#arguments.myargument#`; extra unnamed arguments are reachable as `Arguments[3]`; with `cffunction`, an optional argument that was not passed occupies a slot but `IsDefined("Arguments.x")` is False — Dev p. 194-197; Ref p. 55.
- Function names must be unique, must not start with `cf`, cannot be redefined or overloaded, and definitions cannot be nested; recursion is allowed — Dev p. 194, 212.
- Functions are values: `<cfset Request.MyFunc = Variables.MyFunc>`; they can be passed as arguments and stored in structs; `IsCustomFunction(name)` (unquoted name) tests for one — Dev p. 206-209.
- UDFs are usually kept in a library page pulled in with `cfinclude` from Application.cfm — Dev p. 275-276.
- `argumentCollection` is documented as an attribute of `cfinvoke` (struct of named arguments; reserved names component, method, argumentCollection, returnVariable): `<cfinvoke ... argumentCollection="#args#">` — Dev p. 170 and the cfinvoke entry in Ref (lines 10657-10963 of the text file).
- Example (valid 6.1):
  ```cfml
  <cffunction name="greet" returntype="string" output="no">
      <cfargument name="name" type="string" required="yes">
      <cfargument name="greeting" type="string" required="no" default="Hello">
      <cfset var result = "">
      <cfset result = Arguments.greeting & ", " & Arguments.name>
      <cfreturn result>
  </cffunction>
  <cfoutput>#greet("Ann")# #greet(name="Bob", greeting="Hi")#</cfoutput>
  ```

### Inferences
- The "maximum of one cfreturn" sentence on Ref p. 298 conflicts with common practice (several `cfreturn` tags in different branches are widely used in MX code); treat it as a documentation statement to verify on the real 6.1 server before relying on either reading.
- Always `var` every local in every function: unscoped assignments inside a UDF otherwise land in the page's Variables scope (follows from Dev p. 198 and Ref p. 319).

### Gaps
- `myFunc(argumentCollection = someStruct)` for a plain function call (not `cfinvoke`) was NOT found in the manual passages read. Unconfirmed for 6.1; test on the server.
- Behaviour when a UDF name clashes with a built-in function (exact error text) was not captured; the manual only states names must not be built-in/reserved names (Dev p. 51, 194).

## Error handling: cftry/cfcatch types, cfthrow, cfrethrow, cfcatch structure, cferror, site-wide handler, Java exceptions, dotted type hierarchy

### Takeaway
`cftry`/`cfcatch` with best-match type resolution, `cfthrow` with dotted custom types, and `cfrethrow` are all present in 6.1; there is no `cffinally`. `type="Any"` catches `java.lang.Exception` but not `java.lang.Throwable`.

### Cited Findings
- Handling order for a runtime exception: 1 matching `cfcatch`; 2 `cferror type="exception"` for the type; 3 Administrator site-wide error handler; 4 `cferror type="request"`; 5 standard error page — Dev p. 291.
- `cfcatch type` values: Application, Database, Template, Security, Object, MissingInclude, Expression, Lock, SearchEngine, Any (default), a custom type, or a Java class name — Dev p. 289-290; Ref p. 65.
- "The Any type includes all error with the Java object type of java.lang.Exception. It does not include java.lang.Throwable errors. To catch Throwable errors, specify java.lang.Throwable in the cfcatch tag type attribute." — Dev p. 289.
- Java exception classes: `<cfcatch type="java.io.IOException">`; use `java.lang.Exception` for any Java exception — Dev p. 290, 753-754.
- Legacy advanced types `COM.Allaire.ColdFusion.*` (for example `COM.Allaire.ColdFusion.Request.Timeout`) are kept for compatibility — Dev p. 290; Ref p. 67-68.
- Rules: `cfcatch` tags come after all other code in the `cftry` body; at least one `cfcatch` is required; `cftry` blocks can nest; an exception raised inside a `cfcatch` is not handled by sibling `cfcatch` blocks; the whole `cftry` must be on one page; an empty handler may be written `<cfcatch type="Database" />` — Dev p. 300-301; Ref p. 65-66.
- MX matches the best-fit `cfcatch`, not the first one, so `type="any"` need not be last; the `cfcatch` object cannot be modified — Ref p. 64, 321.
- `cfcatch` variables: Type, Message, Detail, ErrorCode, ExtendedInfo, RootCause, TagContext (array of structs: Column, ID, Line, Raw_Trace, Template, Type). Database adds NativeErrorCode, SQLState, Sql, queryError, where; Expression adds ErrNumber; Lock adds lockName, lockOperation; MissingInclude adds missingFileName — Dev p. 301-303; Ref p. 66.
- `cfthrow` syntax 1: `<cfthrow type="exception_type" message="message" detail="detail_description" errorCode="error_code" extendedInfo="additional_information" object="java_except_object">`; syntax 2: `<cfthrow object=#object_name#>` — Ref p. 338.
- `cfthrow type` defaults to Application and may only be Application or a custom type, not a built-in type — Dev p. 288-289, 307.
- Throwing a Java exception object: `<cfobject type="java" action="create" class="myException" name="obj">`, `<cfset obj.init("message")>`, `<cfthrow object=#obj#>` — Ref p. 339.
- Dotted hierarchy: `<cfthrow type="MyApp.BusinessRuleException.InvalidAccount">` is caught by `cfcatch` types `MyApp.BusinessRuleException.InvalidAccount`, `MyApp.BusinessRuleException` or `MyApp`; the most specific wins; matching is case-insensitive — Dev p. 308; Ref p. 65.
- `<cfrethrow>`: only inside a `cfcatch`; rethrows the active exception preserving `cfcatch.type` and `cfcatch.tagContext` — Ref p. 297; Dev p. 309.
- `cferror`: `<cferror type="a type" template="template_path" mailTo="email_address" exception="exception_type">`; type is exception, validation or request; `exception` defaults to Any. Request and validation pages cannot use CFML tags (only `#error.xxx#` variables); exception pages can use full CFML — Ref p. 102; Dev p. 294-296.
- Error-page variables: error.browser, dateTime, diagnostics, generatedContent, HTTPReferer, mailTo, queryString, remoteAddress, template; exception pages also get message, rootCause, tagContext, type and all cfcatch variables — Dev p. 294-296.
- Site-wide Error Handler and Missing Template Handler are configured in the Administrator Settings page — Dev p. 286, 293.
- Compile errors in an included or custom-tag page surface as runtime exceptions in the caller and can be caught by a `cftry` around the `cfinclude` — Dev p. 288, 290, 293.
- `<cfabort showError="error_message">` routes to a `cferror` page when one is set — Ref p. 47.
- Logging: `<cflog type="Error" file="myapp_errors" text="...">` — Dev p. 298.
- Example (valid 6.1):
  ```cfml
  <cftry>
      <cfthrow type="MyApp.Database.NotFound" message="Row missing" errorcode="404">
      <cfcatch type="MyApp.Database">
          <cfoutput>#cfcatch.type#: #cfcatch.message#</cfoutput>
      </cfcatch>
      <cfcatch type="any">
          <cfrethrow>
      </cfcatch>
  </cftry>
  ```

### Inferences
- With no `cffinally`, cleanup code must be duplicated: run it at the end of the `cftry` body and again in a `cfcatch type="any"` before `cfrethrow`.
- A framework exception hierarchy maps cleanly onto dotted types (for example `App.HTTP.PageNotFound`), since parent-prefix matching is built in.

### Gaps
- Whether `cfcatch.StackTrace` exists in 6.1 was not seen in the variable tables read (unconfirmed).
- No `try/finally` in tags or script in 6.1: absence confirmed from the manual statement lists; the CF 9 introduction is from web sources listed in the CFScript section.

## Application framework: Application.cfm and OnRequestEnd.cfm, cfapplication, session/client/application variables, J2EE sessions, cflock

### Takeaway
6.1 has only Application.cfm and OnRequestEnd.cfm; Application.cfc does not exist (it arrived in ColdFusion MX 7). Locking is still required in MX for data consistency (race conditions), although no longer to prevent memory corruption.

### Cited Findings
- Application.cfm runs before every page request; OnRequestEnd.cfm runs after. On UNIX the file-name capitalisation must be exact — Dev p. 269.
- Lookup: ColdFusion looks in the requested page's directory, then walks up the directory tree and uses the first Application.cfm found; only one runs per request; `cfinclude` does not trigger a new search — Dev p. 271.
- OnRequestEnd.cfm must be in the same directory as the Application.cfm that was used; it does not run after an error/exception, `cfabort` or `cfexit` — Dev p. 271.
- "Application.cfc" occurs zero times in all eight local 6.1 manuals (grep of the text files) — local manuals, whole-file search.
- "ColdFusion MX 7 introduced the Application.cfc ColdFusion component", which replaces Application.cfm and OnRequestEnd.cfm — https://www.bennadel.com/blog/726-coldfusion-application-cfc-tutorial-and-application-cfc-reference.htm ; Adobe docs refer to "techniques used previous to ColdFusion MX 7" — https://helpx.adobe.com/coldfusion/developing-applications/developing-cfml-applications/designing-and-optimizing-a-coldfusion-application/elements-of-a-coldfusion-application.html . NOT available in 6.1.
- `<cfapplication name="application_name" loginStorage="cookie" or "session" clientManagement="Yes" or "No" clientStorage="datasource_name" or "Registry" or "Cookie" setClientCookies="Yes" or "No" sessionManagement="Yes" or "No" sessionTimeout=#CreateTimeSpan(days, hours, minutes, seconds)# applicationTimeout=#CreateTimeSpan(days, hours, minutes, seconds)# setDomainCookies="Yes" or "No">` — Ref p. 51.
- Defaults: loginStorage cookie (attribute added in 6.1); clientManagement No; clientStorage registry; setClientCookies Yes; sessionManagement No; setDomainCookies No; timeouts from the Administrator — Ref p. 51-53.
- Application name is limited to 64 characters — Dev p. 273.
- Client variables: simple values only; stored in registry (default), data source or cookie; no locking needed; built-ins CFID, CFToken, URLToken, HitCount, LastVisit, TimeCreated; complex data must be serialised with `cfwddx`; registry storage is not supported on UNIX — Dev p. 316-325.
- Session variables: in memory; default timeout 20 minutes; need `sessionManagement="Yes"` and an application name; built-ins CFID, CFToken, URLToken, SessionID; `sessiontimeout=#CreateTimeSpan(0,0,45,0)#` — Dev p. 326-329.
- J2EE session management (Administrator option): uses `jsessionid`; session ends when the browser closes; shareable with JSP/servlets; `<cfset getPageContext().getSession().invalidate()>` — Dev p. 321, 327, 329-330.
- Application variables: default and maximum timeout two days; `Application.applicationName` built in. Server scope has `Server.ColdFusion.*` and `Server.OS.*` — Dev p. 331-333.
- `URLSessionFormat(url)` appends session identifiers only when cookies are off — Dev p. 320.
- Locking in MX: "ColdFusion runs in a J2EE environment, which prevents simultaneous data access, so multiple requests do not cause severe system errors. However, such requests can result in inconsistent data values" — Dev p. 317; "Although ColdFusion MX is thread-safe and does not try to modify a variable simultaneously, it does not ensure the correct order of access to information." — Dev p. 333.
- `<cflock timeout="timeout in seconds" scope="Application" or "Server" or "Session" name="lockname" throwOnTimeout="Yes" or "No" type="readOnly" or "exclusive">`; `timeout` is required; `scope` and `name` are mutually exclusive; `throwOnTimeout` defaults to Yes; type defaults to exclusive; named locks are global to the server — Ref p. 221-222; Dev p. 335-337.
- Never nest an exclusive lock inside a read-only lock of the same scope; nest scopes in the order Session, Application, Server to avoid deadlock — Dev p. 336, 338.
- Standard init pattern in Application.cfm: read-only lock to test a flag, then an exclusive `cflock scope="application"` that re-tests and initialises — Dev p. 275-276.
- Request-scope copy technique: copy shared data into Request in Application.cfm and back in OnRequestEnd.cfm — Dev p. 339.
- Example (valid 6.1 Application.cfm):
  ```cfml
  <cfapplication name="MyApp" sessionmanagement="Yes"
      sessiontimeout=#CreateTimeSpan(0,0,30,0)#>
  <cfif NOT IsDefined("Application.initialized")>
      <cflock scope="Application" type="exclusive" timeout="10">
          <cfif NOT IsDefined("Application.initialized")>
              <cfset Application.config = StructNew()>
              <cfset Application.initialized = true>
          </cfif>
      </cflock>
  </cfif>
  ```

### Inferences
- A front-controller framework on 6.1 has no onRequestStart/onError/onSessionEnd hooks; bootstrapping goes in Application.cfm, teardown in OnRequestEnd.cfm (which is skipped after `cfabort`, `cflocation` or an error), and global error handling in `cferror` or a top-level `cftry`.
- Dev p. 339-340 shows `cflock` examples without `timeout` although Ref p. 221 marks it Required; always supply it.

### Gaps
- Whether the unlocked first read in the double-checked pattern above is formally safe is not stated; the manual's own sample (Dev p. 275-276) wraps that read in a read-only lock.

## Code reuse and output: cfinclude, custom tags, cfsavecontent, cfsilent, cfsetting, cfprocessingdirective, cfoutput, cfflush, cfabort, cfexit, cflocation, cfheader, cfcontent, GetPageContext()

### Takeaway
`cfinclude` shares the caller's Variables scope; custom tags (`cf_name`, `cfmodule`, `cfimport`) get an isolated scope with Attributes/Caller/ThisTag. `cfsavecontent` is the output-buffer capture primitive; header-changing tags fail or are ignored after `cfflush`.

### Cited Findings
- `<cfinclude template="template_name">`: searched first relative to the current page's directory, then in Administrator mappings (leading `/`); the included page shares all caller variables; no parameters can be passed; tags such as `cfoutput` or `cfif` cannot span the two files; recursive embedding is allowed; a zero-byte include is not an error in MX — Ref p. 192; Dev p. 164-165.
- Custom tag invocation: `<cf_myTag attr="x">`, `<cfmodule template="../MyTag.cfm" ...>` or `<cfmodule name="MyApp.GetUserOptions" ...>` (template and name are mutually exclusive; a physical path is not valid for template), and `<cfimport prefix="mytags" taglib="myCustomTags">` then `<mytags:tagName>` — Dev p. 175-176; Ref p. 190, 250.
- `cfimport`: `taglib` is relative to the web root (starts with `/`), the current page, or a mapping; an empty prefix `""` allows unprefixed CFML tags; the tag must be on every page that uses the prefix and cannot be placed in Application.cfm — Ref p. 190; Dev p. 739.
- Custom tag search: calling page's directory, then `cfusion\CustomTags` and subdirectories, then Administrator-configured paths; file names must be lowercase on UNIX — Dev p. 175.
- Inside a tag: `Attributes` holds passed attributes, `Caller` is the calling page's Variables scope, tag-local variables vanish at exit; return values with `<cfset Caller.result = x>` or `<cfset "Caller.#Attributes.resultName#" = result>` — Dev p. 177-178.
- `attributeCollection="#struct#"` passes attributes as a struct and can be combined with explicit attributes — Dev p. 180-181; Ref p. 250. Conflict rule differs between the two manuals (see Inferences).
- ThisTag variables: ExecutionMode (start, end, inactive), HasEndTag, GeneratedContent, AssocAttribs; body content can be rewritten in end mode via `thisTag.GeneratedContent` — Dev p. 182-185.
- `<cfexit method="exitTag|exitTemplate|loop">` (default exitTag); outside a custom tag it behaves like `cfabort` — Ref p. 108; Dev p. 186.
- Nested tags: `<cfassociate baseTag="tagName" dataCollection="collectionName">`, `GetBaseTagList()`, `GetBaseTagData(tagName)` — Dev p. 187-189.
- `<cfsavecontent variable="variable name"> ... </cfsavecontent>` stores generated output in a variable; end tag required; cannot suppress JSP tag-library output — Ref p. 300.
- `<cfsilent> ... </cfsilent>` suppresses all output in its body — Ref p. 323.
- `<cfsetting enableCFoutputOnly="Yes" or "No" showDebugOutput="Yes" or "No" requestTimeOut="value in seconds">`; requestTimeout was added in MX and replaces the old URL parameter; in 6.1, if the tag has a body the body is executed — Ref p. 321.
- `<cfprocessingdirective pageencoding="..."/>` or `<cfprocessingdirective suppressWhiteSpace="Yes" or "No"> ... </cfprocessingdirective>`; pageEncoding must be in the first 4096 bytes, is compile-time (cannot be conditional), and does not apply to included pages; use separate tags for the two attributes — Ref p. 271-272.
- `<cfoutput query="query_name" group="query_column" groupCaseSensitive="Yes" or "No" startRow="start_row" maxRows="max_rows_output">` — Ref p. 263.
- `<cfflush interval="integer number of bytes">`; after a flush, `cfcontent`, `cfcookie`, `cfform`, `cfheader`, `cfhtmlhead`, `cflocation` and `SetLocale` cause errors or are ignored; `cfflush` inside `cfsavecontent`, `cfquery` or custom tags causes errors — Ref p. 130.
- `<cflocation url="url" addToken="Yes" or "No">` stops the current page and redirects; no effect after `cfflush`; appends client tokens unless `addToken="No"` — Ref p. 220; Dev p. 325. Session variables set on a page that then uses `cflocation` might not be saved — Dev p. 329.
- `<cfheader name="header_name" value="header_value" charset="charset">` or `<cfheader statusCode="status_code" statusText="status_text">`; throws an error if used after `cfflush` — Ref p. 171-172.
- `<cfcontent type="file_type" deleteFile="Yes" or "No" file="filename" reset="Yes" or "No">`; `reset` defaults to Yes (discards prior output); default response is text/html in UTF-8; charset set via `type="text/html; charset=ISO-8859-1"` — Ref p. 87-89.
- `<cfabort showError="error_message">` — Ref p. 47.
- `GetPageContext()` (added in MX) returns the Java PageContext wrapper; `GetPageContext().include("hello.jsp?name=Bobby");` and `.forward(...)` — Ref p. 501; Dev p. 738-742.
- Example (render a view to a string, valid 6.1):
  ```cfml
  <cfsavecontent variable="html"><cfinclude template="views/home.cfm"></cfsavecontent>
  <cfheader statuscode="200" statustext="OK">
  <cfcontent type="text/html; charset=utf-8" reset="yes"><cfoutput>#html#</cfoutput>
  ```

### Inferences
- attributeCollection conflict rule: Dev p. 180-181 says an explicit attribute wins, while Ref p. 250 (History) says that inside a custom tag the value in the attributeCollection wins. Avoid passing the same key both ways.
- `cfinclude` has no way to give a view its own variable scope; a view renderer that needs isolation should use `cfmodule` (Attributes scope) or copy data into Request.
- `GetPageContext().getOut()` / `getResponse()` are reachable through the PageContext object (Ref p. 501 says it exposes request and response objects), but specific method behaviour under 6.1 is not documented in the pages read.

### Gaps
- No documented way in 6.1 to read or clear the page output buffer other than `cfcontent reset`, `cfsavecontent`, `cfsilent`; `GetPageContext().getOut().clearBuffer()` is unconfirmed for 6.1.
- `cfhtmlhead` and `cfdump` entries were located (Ref lines 8756 and 5014 of the text file) but not read.

## Dynamic evaluation: Evaluate, DE, IIf, SetVariable, scope array notation

### Takeaway
Prefer struct bracket notation on scopes (`Variables["name"]`, `Form["f" & i]`) over `Evaluate`; `IIf` is the only inline conditional but evaluates its string arguments dynamically, so wrap literals in `DE()`.

### Cited Findings
- Only `Evaluate` and `IIf` perform dynamic evaluation — Dev p. 92.
- `Evaluate(string_expression1 [, string_expression2 [, ...]])` evaluates left to right and returns the rightmost result: `<cfset v = Evaluate("qNames.#colname#[#index#]")>` — Ref p. 468.
- `DE(string)` wraps the string in double quotes (escaping inner quotes) so `IIf`/`Evaluate` return it unevaluated; pound signs inside are still evaluated first — Ref p. 458.
- `IIf(condition, string_expression1, string_expression2)` is shorthand for `cfif` + `Evaluate` of one branch; `IIf(y is 0, DE("Error"), x/y)` still fails when y is 0 because the third argument is evaluated as an argument — Ref p. 517.
- `#IIf(IsDefined("LocalVar"), "LocalVar", DE("The variable is not defined."))#` — Dev p. 98.
- `SetVariable(name, value)` "is no longer required in well-formed ColdFusion pages"; `<cfset "myVar#i#" = myVal>` is equivalent to `SetVariable("myVar" & i, myVal)` — Ref p. 680; Dev p. 93-97.
- Dynamic names via quoted left side: `<cfset "#myvariable#" = 5>` — Ref p. 318.
- Prefer `Form["product_" & i]` to `Evaluate` — Dev p. 97. All named scopes are structs, so `Variables[name]`, `Request[name]`, `Session[name]` work — Dev p. 77.
- Functions are variables, so a function stored in a struct can be fetched by dynamic key and called: `<cfset f = handlers[action]>` then `f()` — Dev p. 206-208 (functions as values) and Dev p. 77 (bracket notation).

### Inferences
- A safe ternary idiom is `IIf(cond, DE(a), DE(b))` for string results; for non-string or complex results use `cfif`.

### Gaps
- Direct call syntax `handlers[action]()` (call on a bracket expression without an intermediate variable) is not shown in the pages read; unconfirmed for 6.1, so assign to a variable first.
- Dynamic method invocation on objects is covered by `cfinvoke` (CFC researcher's scope).

## Java interop: CreateObject("java"), cfobject, init(), static methods, JavaCast, JVM version, class loading, Java collections/strings

### Takeaway
6.1 runs on Sun JVM 1.4.2 (so no generics, no java.util.concurrent, no StringBuilder). `CreateObject("java", class)` loads a class; `init()` calls a constructor; classes load from `WEB-INF/lib`, `WEB-INF/classes`, then the Administrator class path.

### Cited Findings
- "ColdFusion MX 6.1 ships with the Sun 1.4.2 JVM"; supported JVMs are Sun JDK/JRE 1.3.1 or later — Install p. 14 (page number derived from the nearest page marker in the text file).
- `CreateObject(type, ...)` types: com, corba, java, component, webservice; the function/tag can be disabled in the Administrator (Basic Security, Tag Restrictions) — Ref p. 423-428.
- `<cfobject type="Java" class="MyClass" name="myObj">` (optionally `action="create"`) loads the class without constructing an instance; static members are usable at once; calling a non-static method first triggers an implicit default-constructor call; `<cfset ret = myObj.init(arg1, arg2)>` calls a matching constructor; a Java method actually named `init` cannot be called — Dev p. 746.
- Static call example: `iaddrClass = CreateObject("java", "java.net.InetAddress"); address = iaddrClass.getByName(host);` — Dev p. 754.
- Class search order: 1 `web_root/WEB-INF/lib` (jars) and `web_root/WEB-INF/classes` (classes), reloaded dynamically when the file timestamp changes; 2 the class path set on the Administrator "JVM and Java Settings" page; 3 the default JVM class path (loaded once per server lifetime) — Dev p. 737-738.
- Class names are case-sensitive; method and field names are not — Dev p. 738, 750.
- Properties: `<cfset obj.property = "value">`; JavaBean getters/setters are invoked automatically, except on standard classes such as Date, Boolean, Integer, String, List — Dev p. 747-748.
- CFML to Java: integer → short/int/long; real → float/double; Boolean → boolean; date-time → java.util.Date; string → String; array → java.util.Vector or primitive/String/Object arrays; structure → java.util.Map; query → java.util.Map — Dev p. 751.
- Java to CFML: boolean → Boolean; byte/char → string; short/int/long → integer; float/double → real; String → string; java.util.Date → date-time; java.util.List → comma-delimited list; byte[]/char[]/boolean[]/String[] and java.util.Vector → array; java.util.Map → structure — Dev p. 752.
- `JavaCast(type, variable)` with type boolean, int, long, float, double or string; only for scalar/string arguments to overloaded methods; cannot cast complex objects or to a superclass: `<cfset emp.SetJobGrade(JavaCast("int", "1"))>` — Ref p. 554-555; Dev p. 753.
- Java exceptions are caught by class name in `cfcatch`, or `java.lang.Exception` for any — Dev p. 753-754.
- `Duplicate()` cannot copy Java objects — Ref p. 466.
- Example (valid 6.1):
  ```cfml
  <cfscript>
  sb = CreateObject("java", "java.lang.StringBuffer").init("abc");
  sb.append(JavaCast("string", "def"));
  s = sb.toString();
  sys = CreateObject("java", "java.lang.System");
  ms = sys.currentTimeMillis();
  </cfscript>
  ```

### Inferences
- JVM 1.4.2 means Java 5+ APIs are unavailable: use `java.lang.StringBuffer` (not StringBuilder), `java.util.HashMap`/`ArrayList`/`Vector`, `java.util.regex` (present since 1.4), `java.security.MessageDigest`. No `java.util.UUID` (added in Java 5).
- Because CFML arrays are internally Vectors (Dev p. 751) and structs convert to Map, Java collection methods are in principle callable on CFML arrays/structs, but the manual does not document doing so; treat as unsupported.
- `JavaCast("null", "")` and array casts are not in the 6.1 type list (Ref p. 554) and so are NOT available.

### Gaps
- Calling undocumented Java methods directly on CFML strings/arrays/structs (for example `myString.getBytes()`, `myArray.size()`) is not covered by the 6.1 manuals read; unconfirmed.
- Dev p. 71 lists "bool" where Ref p. 554 lists "boolean" as the JavaCast type name; use "boolean" and verify.

## Request basics: GetHttpRequestData, CGI, status and headers, cfcookie, SetEncoding, URL/HTML encoding, path functions, GetTickCount, CreateUUID

### Takeaway
Everything needed for a request/response abstraction exists in 6.1: raw headers and body via `GetHttpRequestData()`, CGI variables, `cfheader`/`cfcontent`/`cfcookie`, and path helpers. Note the non-standard 35-character UUID format and that CGI variables always "exist".

### Cited Findings
- `GetHttpRequestData()` returns a struct with `headers` (struct of request headers), `content` (raw body; string if Content-Type starts with `text/` or is `application/x-www-form-urlencoded`, otherwise binary), `method`, `protocol` — Ref p. 491.
  ```cfml
  <cfset req = GetHttpRequestData()>
  <cfif StructKeyExists(req.headers, "X-Requested-With")>...</cfif>
  ```
- CGI variables are read-only; testing a CGI variable for existence always returns True, so test for an empty string: `<cfif CGI.varname IS NOT "">` — Ref p. 29-30.
- CGI variables listed: AUTH_TYPE, CONTENT_LENGTH, CONTENT_TYPE, PATH_INFO, PATH_TRANSLATED, QUERY_STRING, REMOTE_ADDR, REMOTE_HOST, REMOTE_USER, REMOTE_IDENT, REQUEST_METHOD, SCRIPT_NAME, GATEWAY_INTERFACE, SERVER_NAME, SERVER_PORT, SERVER_PROTOCOL, SERVER_SOFTWARE, CERT_ISSUER, CERT_SUBJECT, CLIENT_CERT_ENCODED, HTTP_ACCEPT, HTTP_IF_MODIFIED_SINCE, HTTP_USER_AGENT, HTTP_REFERER; availability depends on the web server — Ref p. 29-31.
- `Form.fieldnames` lists submitted field names — Dev p. 79.
- Status and headers: `<cfheader statusCode="404" statusText="Not Found">`, `<cfheader name="Expires" value="#Now()#">`; `charset` attribute defaults to UTF-8; error if used after `cfflush` — Ref p. 171-172.
- `<cfcookie name="cookie_name" value="text" expires="period" secure="Yes" or "No" path="url" domain=".domain">`; `expires` accepts a date (date-time objects accepted since 6.1), a number of days, `now` (delete) or `never` (30 years); omitted means a browser-session cookie; names are converted to uppercase; not sent if used after `cfflush` — Ref p. 91-92.
- Cookies may also be set by assignment: `<cfset Cookie.mycookie="sugar">` (session cookie); dots allowed in names: `<cfcookie name="person.name" value="wilson, john">` — Ref p. 92.
- `SetEncoding(scope_name, charset)` with scope `url` or `form`; call before reading the scope, typically in Application.cfm; added in MX — Ref p. 674.
- `URLEncodedFormat(string [, charset])`: 6.1 changed the default charset to the response character encoding — Ref p. 731. `URLDecode(urlEncodedString[, charset])`: 6.1 changed the default charset to the encoding of the URL scope — Ref p. 729.
- `HTMLEditFormat(string [, version])` escapes HTML special characters; the version argument is currently ignored — Ref p. 515-516.
- `GetCurrentTemplatePath()` returns the absolute path of the page containing the call (the included file when called in an include); `GetBaseTemplatePath()` returns the absolute path of the top-level requested page — Ref p. 482, 484.
- `ExpandPath(relative_path)` resolves relative to the currently executing page's directory; a leading `/` uses ColdFusion mappings (web-server virtual mappings are not reliably used); accepts absolute paths in MX; keeps a trailing slash — Ref p. 470.
- `GetDirectoryFromPath(path)` returns the directory with a trailing slash: `GetDirectoryFromPath(GetCurrentTemplatePath())` — Ref p. 485.
- `GetTickCount()` returns a millisecond counter (as a string); only differences are meaningful — Ref p. 508.
- `CreateUUID()` returns a 35-character string in the format xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxxxxxx (8-4-4-16), which does not match the Microsoft/DCE 8-4-4-4-12 format — Ref p. 438.
- Response default: text/html in UTF-8 unless overridden by `cfcontent type="...; charset=..."` — Ref p. 88-89.

### Inferences
- Detect the HTTP method with `CGI.REQUEST_METHOD` or `GetHttpRequestData().method`; read a JSON/raw body with `ToString(GetHttpRequestData().content)` when it is binary (Ref p. 491 note).
- `cfcookie` has no `httpOnly` attribute in the 6.1 syntax (Ref p. 91); an HttpOnly cookie must be emitted manually with `<cfheader name="Set-Cookie" value="...">`.
- Front-controller URLs depend on `CGI.PATH_INFO` and `CGI.SCRIPT_NAME`, whose content varies by web server (Ref p. 29-31 caveat); test on the target IIS.

### Gaps
- Whether `cfheader` can emit several headers with the same name (for example multiple Set-Cookie) is not stated in the entry read.
- Dev Chapter 17 (globalisation and character encoding) was not read; details of request/response encoding beyond the function entries are unconfirmed.
- No JSON functions were seen in 6.1 (SerializeJSON is commonly cited as CF 8; unconfirmed here, not researched).
