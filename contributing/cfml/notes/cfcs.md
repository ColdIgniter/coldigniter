# ColdFusion components (CFCs) in ColdFusion MX 6.1, and building an object-oriented framework from them

Source key used below (every claim carries one):

- **DevApps p.N** = "Developing ColdFusion MX Applications" (ColdFusion MX 6.1 manual), local text `cfmx_6.1_docs_en/text/cfmx61_dev_cf_apps.txt`, printed page N.
- **CFMLRef p.N** = "CFML Reference" (ColdFusion MX 6.1 manual), local text `cfmx_6.1_docs_en/text/cfmx61_cfml_reference.txt`.
- **Admin p.N** = "Configuring and Administering ColdFusion MX" (6.1 manual), local text `cfmx_6.1_docs_en/text/cfmx61_config_admin.txt`.
- **Guidelines 3.1** = Sean Corfield / Macromedia Web Technology Group, "ColdFusion MX Coding Guidelines, Release 3.1 (12/25/2004)", which states it applies "to CFMX 6.1 specifically". Archived copy: http://web.archive.org/web/20041229212714/http://livedocs.macromedia.com:80/wtg/public/coding_standards/printable.html (section name given with each citation).
- Other web sources are given as full URLs.

Nothing in these notes was run on a real 6.1 server. Code examples are assembled from the cited facts and are marked as untested.

## Definition: cfcomponent, cffunction, cfargument, cfproperty, pseudo-constructor, cfreturn, output

### Takeaway
A CFC is one `.cfc` file wrapped in one `cfcomponent` tag; methods are `cffunction` tags, arguments are `cfargument` tags, and any code outside a `cffunction` is the pseudo-constructor that runs on every instantiation. In 6.1 the attribute sets are small (no `implements`, `accessors`, `persistent`, `initmethod` and so on), `cfproperty` creates nothing, and `output="false"` on both `cfcomponent` and every `cffunction` is the accepted practice.

### Cited Findings
- A component is a file with the `.cfc` extension; the component name is the file name; the whole page is surrounded by `cfcomponent` and "No code can be outside this tag" — DevApps p.219-223.
- CFC object features are "similar to" JavaScript 2.0 / ECMAScript 4 and "do not strictly follow Java object rules" — DevApps p.219-221.
- `cfcomponent` attributes in 6.1: `extends`, `output`, `displayname`, `hint`, and nothing else — CFMLRef p.85-86.
- `cfcomponent output`: yes = constructor code processed as if inside `cfoutput`; no = as if inside `cfsilent`; omitted = processed as standard CFML. It applies to the constructor code only — CFMLRef p.85-86.
- `cffunction` attributes in 6.1: `name`, `returnType` (default any; required for web services), `roles`, `access` (default public), `output`, `displayname`, `hint` — CFMLRef p.146-148.
- `cffunction output` has the same three states (yes / no / omitted) with the same meaning for the function body — CFMLRef p.146-148.
- `cfargument` attributes: `name`, `type`, `required` (default no), `default`, `displayname`, `hint`. Types: any, array, binary, boolean, date, guid, numeric, query, string, struct, uuid, variableName, or a component name (an error is thrown if the value is not a CFC of that name). `cfargument` tags must come before any other tags in the function body — CFMLRef p.54-55.
- `returntype="void"` is used by a 6.1-targeted source: Mach-II `configure()` "has returnType="void"" — Guidelines 3.1, "Components & Constructors". The type list as read in CFMLRef p.146-148 did not show "void" (see Gaps).
- `cfproperty` attributes: `name`, `type`, `required`, `default`, `displayname`, `hint`; must be placed at the top of the component; used for web service type description and documentation only, and "does not create a variable or assign it a value" — CFMLRef p.280-281; DevApps p.240-241.
- Corfield: `cfproperty` "should not be used" in general; it gives no type checking and no default values for instance data — Guidelines 3.1, "Components & cfproperty".
- Code outside `cffunction` (constructor code) runs when the component is instantiated, and on every transient (non-instance) invocation — DevApps p.223; constructor code is conventionally placed at the top — DevApps p.236.
- The pseudo-constructor cannot take arguments; an `init()` method can — Corfield, cfcdev 2004-03-16, https://www.mail-archive.com/cfcdev@cfczone.org/msg04254.html
- A CFScript `function` declaration inside a CFC creates a simple method, but with no control of access, metadata, return type or output — DevApps p.223.
- With 6.1, `cfscript` and `var` statements can be used inside `cffunction`-based methods — Camden 2003-08-21, https://raymondcamden.com/2003/08/21/395FDB6C-C96C-8AE1-BB8CD08646FE1262 ; both body styles shown in Guidelines 3.1, "Style: Naming" (scope section).
- `cfreturn` returns one expression. CFMLRef p.298 says "You can code a maximum of one cfreturn tag within a function", but the example on DevApps p.245 places `cfreturn` inside `cfif` branches (conflict inside the manuals).
- `cfinclude` inside a method is allowed, but the `cfreturn` must be on the component page, not in the included page — DevApps p.237.
- `displayname` and `hint` exist on cfcomponent, cffunction, cfargument, cfproperty; arbitrary extra attributes are allowed and appear in `GetMetaData` output; avoid expressions in them — DevApps p.240-241.
- Use `output="false"` on `cffunction` and `cfcomponent` — Corfield, cfcdev 2004-03-16, https://www.mail-archive.com/cfcdev@cfczone.org/msg04254.html
- Always write a `cfargument` for each named argument, always give `type` (avoid any) and `required`; no `default` on required arguments; to detect an omitted optional argument use `structKeyExists(arguments,"argName")` with no default — Guidelines 3.1, "Components & cfargument".
- Recommended file layout: prolog comment, `cfcomponent`, minimal pseudo-constructor, public methods with `init()` first, package methods, private methods — Guidelines 3.1, "Component File Structure".
- Avoid `cfparam` inside CFC methods for performance — DevApps p.236.
- Not available in 6.1: `cfinterface` and the `implements` attribute (ColdFusion 8) — https://helpx.adobe.com/coldfusion/cfml-reference/coldfusion-tags/tags-i/cfinterface.html , https://cfdocs.org/cf8 ; neither word appears anywhere in the 6.1 CFML Reference or Developing manual (grep of the local texts returned nothing).

### Inferences
- Untested 6.1-safe skeleton assembled from the facts above:

```cfm
<cfcomponent displayname="Example" hint="..." output="false">

    <cfset variables.instance = StructNew()>

    <cffunction name="init" access="public" returntype="any" output="false">
        <cfargument name="config" type="struct" required="true">
        <cfset var key = "">
        <cfset variables.instance.config = arguments.config>
        <cfreturn this>
    </cffunction>

    <cffunction name="get" access="public" returntype="any" output="false">
        <cfargument name="name" type="string" required="true">
        <cfreturn variables.instance.config[arguments.name]>
    </cffunction>

</cfcomponent>
```

- Because `output` omitted means "standard CFML" (whitespace from the function body reaches the page), a framework that returns strings or writes headers should set `output="false"` everywhere and build output with `cfsavecontent`.
- Multiple `cfreturn` tags in different branches very probably work in 6.1 (the manual's own example does it); the "maximum of one" sentence most likely means one executes. Treat as unconfirmed until run on the test server.

### Gaps
- Whether `returntype="void"` is listed in the 6.1 CFML Reference: not seen in my reading of p.146-148; supported only by the 6.1-era Guidelines. Verify on the server.
- Self-closing tag syntax (`<cfset x = 1 />`) is used throughout Guidelines 3.1, so it is accepted by 6.1, but I found no manual statement about it.
- No official list of the cfcomponent / cffunction changes between 6.0 and 6.1 was found (the 6.1 release notes could not be retrieved from the Wayback Machine).

## Scopes: This, Variables, unnamed, Arguments, var, shared scopes, 6.0 versus 6.1

### Takeaway
In 6.1 a CFC instance has two lasting scopes: `this` (public, visible to callers) and `variables` (non-public, identical to the unnamed scope, lives as long as the instance). `arguments` and `var` locals live only for one call. Any unscoped assignment inside a method without `var` lands in `variables` and persists, which is the main thread-safety trap.

### Cited Findings
- `This` scope is shared by all methods of the instance and is visible to the page that instantiated the CFC and to included pages — DevApps p.242.
- `Variables` scope "is private to the CFC", includes variables set in constructor code and in methods, is set with the `Variables` prefix or with no prefix, lasts as long as the instance, and is shared with pages included by the CFC. The caller's Variables scope is not visible inside the CFC unless passed in — DevApps p.242.
- `this` = public instance data; `variables` (the unnamed scope) = non-public instance data; both live as long as the instance; `arguments` and `var` only during the call — Corfield, cfcdev Aug 2003, https://www.mail-archive.com/cfcdev@cfczone.org/msg01399.html
- "in CFMX 6.0, variables scope was not available and you used instead the unnamed scope". `variables.member` and unscoped `member` are the same variable; `this.member` is a different one. Always write `variables.member` — Guidelines 3.1, "Style: Naming" (scope section).
- Before 6.1, values set in the unnamed scope inside `init()` were reported as not visible to other methods; 6.1 was expected to fix it — Eric Davis, cfcdev 2003-08-14, https://mail-archive.com/cfcdev@cfczone.org/msg01345.html
- Unqualified variables in functions "persist for the lifetime of the instance ... hence the need to use var" — Guidelines 3.1, same section.
- `var` locals "must be defined at the top of the function definition, before any other CFML code" (after the `cfargument` tags); `var` is not allowed outside functions — DevApps p.243-244. A `var` declaration must have an initial value (all manual and Guidelines examples are `<cfset var x = ...>`) — Guidelines 3.1, same section.
- The function-local scope has no prefix and cannot be accessed as a structure — DevApps p.75-77. (There is no `local` scope in 6.1; that arrived in ColdFusion 9 — later-version fact, see Gaps.)
- Arguments can be read as `Arguments.name`, `Arguments[1]`, or unscoped — DevApps p.238.
- Unscoped variable lookup order: Arguments, Variables, CGI, Cffile, URL, Form, Cookie, Client — DevApps p.75-77.
- A CFC shares Form, URL, Request, CGI, Cookie, Client, Session, Application, Server and Flash scopes with the calling page — DevApps p.244.
- Structure CFCs so that use of shared scopes is minimised (Session Facade pattern) — Guidelines 3.1, "Structure".
- Keeping all instance state in one struct, `variables.instance`, is Corfield's idiom (helps memento / DAO code) — Corfield, cfcdev 2004-03-16, https://www.mail-archive.com/cfcdev@cfczone.org/msg04254.html
- Manual claim: "If you use component inheritance, you cannot use the This scope in the base (parent) component" — DevApps p.242 and p.245; contradicted in practice by Guidelines 3.1 "Components & Constructors", which tells every component to `<cfreturn this />` from `init()` and children to call `super.init()`.
- Passing semantics: strings, numbers, dates and arrays are passed by value; structs, queries and objects (including CFC instances) by reference — DevApps p.202-204.

### Inferences
- A port of PHP class properties should map `private` and `protected` properties to keys of `variables.instance` and avoid `this.x` data entirely (use getters), so public state cannot be changed from outside.
- Since arrays are copied on assignment and on every argument pass, PHP code that mutates an array argument or shares an array between objects must be reworked to use structs, or to return the array.
- Every loop index, query name, `cfsavecontent` variable, `cfcatch`-derived temp and so on used in a method needs a `var` line at the top; forgetting one in an Application-scoped object is a cross-request race.

### Gaps
- Whether the 6.0 unnamed-scope bug is really gone in 6.1: only an expectation in a mailing-list post plus the Guidelines' unqualified use of `variables`; no release note found.
- Whether `this` in a base component fails in any way in 6.1 (manual says cannot, Corfield's guideline depends on it). Needs a test on the 6.1 server.
- I found no source for 6.1 on whether a `var` variable can share a name with an argument, or what error results.

## Access levels and roles

### Takeaway
Four levels: private, package, public (default), remote. "private" in a CFC behaves like Java `protected`: subclasses can call it. There is no truly private level and no protected keyword. `roles` ties a method to the cflogin security framework.

### Cited Findings
- private: available only to the component that declares the method and to components that extend it; "similar to the Java protected keyword, not the Java private keyword" — DevApps p.248.
- package: available to the declaring component, components that extend it, and any other component in the same directory (package) — DevApps p.247-248.
- public: available to any locally executing ColdFusion page or component; this is the default — DevApps p.248; CFMLRef p.146-148.
- remote: additionally callable by URL, form post, Flash Remoting and as a web service — DevApps p.248, p.230-231.
- A URL or form invocation of a CFC method requires `access="remote"`; a non-simple result comes back as a WDDX packet — DevApps p.230-231.
- Browsing straight to a `.cfc` URL without a method redirects to the component explorer under `/CFIDE/componentutils` — DevApps p.233.
- `roles` attribute on `cffunction`: comma list of roles; if the caller is not in a role, an exception is thrown — DevApps p.249; CFMLRef p.146-148.
- Web-accessible (remote) components should live under the web root with lower-case file names; all others outside the web root — Guidelines 3.1, "File Naming / ColdFusion Components".

### Inferences
- PHP `protected` maps to `access="private"`; PHP `private` has no equivalent and can only be a naming convention.
- A framework that keeps its `.cfc` files under the web root should give no method `access="remote"`, and should block direct `.cfc` requests at the web server, because a `.cfc` URL otherwise reaches the component explorer login page.

### Gaps
- Whether `access` applies to data: it does not appear to (access is a `cffunction` attribute only); anything in `this` is public. No explicit manual sentence captured.
- No source found on calling a private method through `cfinvoke` with a dynamic name from inside the same component versus from outside (expected: allowed inside, error outside).

## Creating and calling: CreateObject, cfobject, cfinvoke, argumentCollection, dynamic method names, init()

### Takeaway
Create instances with `CreateObject("component", "dotted.path")` or `cfobject`; there is no `new` operator and no automatic constructor call. Convention is an `init()` method that returns `this`, chained as `CreateObject(...).init(...)`. A method name held in a variable can only be called cleanly through `cfinvoke`.

### Cited Findings
- `CreateObject("component", name)` and `<cfobject component="..." name="...">` create an instance and run the constructor code — CFMLRef p.423-425, p.256; DevApps p.225.
- `cfinvoke` with a component name creates a transient instance, calls the method and destroys the instance; with `component="#instance#"` it calls an existing instance; inside a CFC the `component` attribute can be omitted to call a method of the same component — DevApps p.226-229; CFMLRef p.208-212.
- `cfinvoke` argument precedence: `cfinvokeargument` over tag attributes over `argumentCollection`. Reserved attribute names: component, method, argumentCollection, returnVariable (plus web service ones) — DevApps p.226-229; CFMLRef p.208-213.
- "The cfinvoke tag is the only way to efficiently invoke different component methods based on variable data", e.g. `<cfinvoke component="corpQuery" method="#Form.queryType#">` — DevApps p.229.
- Direct calls always need parentheses and accept positional arguments, named arguments (`obj.getAuth(name="x", password="y")`) or an argument structure — DevApps p.229-230. The manual prints the struct key as "argumentsCollection" on p.230 while `cfinvoke` documents `argumentCollection`; treat p.230 as a typo (unconfirmed).
- All components should define `init()`, even if empty, with a return type matching the component, returning `this`, so that `<cfset obj = createObject("component","util.lib.thing").init() />` is always legal; this mirrors Java objects in CFML — Guidelines 3.1, "Components & Constructors".
- `init()` returning `this` also works through `cfinvoke` with `returnvariable` — Corfield, cfcdev 2004-03-16, https://www.mail-archive.com/cfcdev@cfczone.org/msg04254.html
- A child's `init()` should start with `super.init()`; "The call to super.init() must use positional arguments - the argumentCollection= calling style does not work with methods called via super" — Guidelines 3.1, "Components & Constructors".
- Named arguments on a `super` call were broken until fixed in CFMX 7 / 7.0.1 — Camden 2005-10-27, https://raymondcamden.com/2005/10/27/CFMX-7-and-Super-Fixes (later-version source describing the earlier bug).
- Function names are variables and can be passed as arguments and assigned — DevApps p.208; `IsCustomFunction` tests for one — DevApps p.209-210.
- Not available in 6.1: the `new` operator and script-based components (ColdFusion 9) — see Gaps for source status.

### Inferences
- Untested 6.1 calling patterns built from the facts above:

```cfm
<!--- construct and initialise --->
<cfset loader = CreateObject("component", "system.core.Loader").init(config)>

<!--- dynamic method with an argument struct --->
<cfinvoke component="#controller#" method="#methodName#"
          argumentcollection="#args#" returnvariable="result">

<!--- a void method leaves "result" undefined; test with IsDefined("result") --->
```

- A PHP static factory or `new Foo($a, $b)` becomes `CreateObject("component", "path.Foo").init(a, b)`; a central `make(path, args)` helper in the framework keeps the dotted paths in one place.
- For dynamic calls without `cfinvoke`, the alternative is `Evaluate("obj.#name#(args)")`, which the manual (DevApps p.209-210) and Guidelines 3.1 ("Don't use evaluate()") advise against; so `cfinvoke` is the choice.
- Assigning `fn = obj[name]` then calling `fn()` runs the function detached from the instance (its `this`/`variables` would be the caller's), so it is not a substitute for `cfinvoke`. Unconfirmed for 6.1.

### Gaps
- No source found on what `returnvariable` holds in 6.1 when the method returns nothing (expected: variable not set).
- `obj[methodName](args)` bracket-call syntax: no 6.1 source; believed not to parse before much later versions. Unconfirmed.
- I did not retrieve a citable page for "the `new` operator arrived in ColdFusion 9"; the claim is from general knowledge, supported only by its absence from the 6.1 manuals.

## Location and naming: path resolution, mappings, packages, case, layout

### Takeaway
Components are addressed by dotted paths that mirror directories. From a CFML page, 6.1 searches the calling page's directory, then ColdFusion mappings, then the web root, then the Custom Tag Paths. Mappings are server-wide and set only in the Administrator; there are no per-application mappings (ColdFusion 8) and no Application.cfc (ColdFusion 7).

### Cited Findings
- Search order for `cfinvoke`, `cfobject` and `CreateObject` from a CFML page: (1) directory of the calling page, (2) directories in ColdFusion Mappings, (3) the web root, (4) Custom Tag Paths — DevApps p.224.
- For a qualified (dotted) name, the first element is matched as a directory in each of those locations; if that directory is found but the component is not under it, ColdFusion throws an error and searches no further — DevApps p.224.
- Remote invocation (URL, form, Flash, web service) resolves relative to the web root only — DevApps p.225, p.241.
- On UNIX, ColdFusion first looks for an all-lower-case file name, then for the exact case used in the CFML — DevApps p.225; CFMLRef p.423-425.
- Mixed-case component file names "were not uniformly supported" before 6.1; with 6.1 MixedCase names are preferred, and "All references to component names in code shall match exactly the case of the implementation filename" — Guidelines 3.1, "File Naming / ColdFusion Components".
- Mappings are defined on the Administrator's Mappings page and are server-wide — Admin p.22 (that page mentions cfinclude and cfmodule; DevApps p.224 adds their use for component lookup).
- A package is the set of components in one directory; a component in the same directory is found first; `access="package"` is scoped to it — DevApps p.247.
- Every component implicitly extends `WEB-INF/cftags/component.cfc`, a zero-length file that can be edited to give all components on the server common methods — DevApps p.245-246.
- Macromedia's own layout: web-accessible `.cfm` and remote `.cfc` under `wwwroot/{app}/`; all other components under `extensions/components/{app}/`, with `extensions/components/` registered as a Custom Tag Path so dotted names resolve from it; a `/MachII` mapping for the framework core — Guidelines 3.1, "Directory Structure For Applications".
- Naming: MixedCase `.cfc` names for non-URL-accessible components; methods, properties and instance variables mixedCaseInitLower; verb-noun names — Guidelines 3.1, "Naming".
- Not available in 6.1: Application.cfc (ColdFusion 7) and per-application mappings via `this.mappings` (ColdFusion 8); neither "Application.cfc" nor per-application mappings appear in the 6.1 manuals (grep of local texts returned nothing).

### Inferences
- Three workable layouts for an `app/` + `system/` framework, in order of least server configuration:
  1. No mapping: put `app/` and `system/` directly under the web root; `CreateObject("component", "system.core.Loader")` resolves through rule 3 (web root). Cost: files are web-reachable, so direct `.cfc`/`.cfm` requests must be blocked.
  2. One Custom Tag Path or one mapping per top-level name (`/system`, `/app`) pointing outside the web root, as Macromedia did.
  3. Relative lookup only works from the calling page's own directory (rule 1), so it cannot serve a tree.
- Because rule 1 is "directory of the calling page", a short name inside `system/core/` resolves to a sibling first; the framework should always use full dotted paths to avoid surprises.
- Because a first-element directory match stops the search, an unrelated `system/` or `app/` directory beside the calling page or under a mapping will shadow the real one. Pick distinctive top-level names if this is likely.
- Develop with exact-case names everywhere, so the code works on both Windows (case-insensitive) and UNIX.
- PHP namespaces map to directories; two classes with the same short name in different namespaces are fine as long as full dotted paths are used.

### Gaps
- Whether a component path can be given relative with dots upward (no; no syntax exists in the manual) or as a slash path: no 6.1 source says slash paths work in `CreateObject`. Unconfirmed.
- Whether 6.1 caches a failed or successful path resolution (so that moving a file needs a restart): not found.
- Maximum path depth and legal characters in package directory names (hyphens, leading digits): not found.

## Inheritance: extends, Super, and emulating interfaces, abstract classes, static members and traits

### Takeaway
6.1 has single inheritance through `extends` and, new in 6.1, the `Super` keyword for calling an overridden parent method (methods only, one level up, positional arguments). There are no interfaces, abstract classes, static members, traits or final; each must be emulated by convention.

### Cited Findings
- `extends="dotted.path"` on `cfcomponent` gives single inheritance; a child inherits methods and (non-This) data; all components ultimately extend `WEB-INF/cftags/component.cfc` — DevApps p.245-246; CFMLRef p.85-86.
- The parent's constructor code runs before the child's — DevApps p.236.
- `Super` was added in 6.1 — Camden 2003-08-05, https://raymondcamden.com/2003/08/05/395FD4C5-A28A-E02F-B6EFD3603DBA0F8A ; listed as a feature in DevApps p.219-221.
- `Super` works for methods only, not variables; can be used in included pages; "supports only one level of inheritance" (no `Super.Super`); to reach a grandparent, add a pass-through method in the middle component — DevApps p.245-246.
- Manual: `Super` cannot be used for a method that uses the This scope — DevApps p.246 (conflicts with the common `super.init()` + `return this` idiom in Guidelines 3.1; see Scopes).
- `super.init()` must use positional arguments; `argumentCollection` does not work through `super` — Guidelines 3.1, "Components & Constructors". Named arguments through `super` also failed until CFMX 7 / 7.0.1 — https://raymondcamden.com/2005/10/27/CFMX-7-and-Super-Fixes
- Mach-II components (listeners, plugins, event filters) extend framework base components and override `configure()` instead of `init()`, because the framework's own `init()` needs framework arguments — Guidelines 3.1, "Components & Constructors".
- Not available in 6.1: `cfinterface` / `implements` (ColdFusion 8) — https://helpx.adobe.com/coldfusion/cfml-reference/coldfusion-tags/tags-i/cfinterface.html ; `IsInstanceOf` (ColdFusion 8) — https://cfdocs.org/isinstanceof

### Inferences
- Emulations (all untested, all convention):
  - **Abstract method**: base method whose body is `<cfthrow type="Framework.AbstractMethod" message="...">`.
  - **Abstract class**: base `init()` checks `GetMetaData(this).name` against its own name and throws.
  - **Interface**: a documentation-only base CFC, plus an optional runtime check that walks a required method list with `StructKeyExists(obj, name)` (public methods only), done once at registration, not per call.
  - **Static methods / constants**: a single shared instance kept in the Application scope (see Persistence); PHP `Foo::bar()` becomes `application.framework.foo.bar()` or a service lookup.
  - **Traits**: either a helper object held by composition, or a `.cfm` file of `cffunction` definitions pulled into the component body with `cfinclude` (functions defined in an included page become methods; `cfreturn` location rule on DevApps p.237 speaks of included pages inside a method, so this exact use is unconfirmed).
  - **parent::method()**: `super.method(positional, args)`.
- Since private is really protected, a deep hierarchy has no way to hide helpers from subclasses; prefix such helpers (for example `_name`) by convention.
- Keep hierarchies shallow: `Super` reaches one level, so a three-level chain needs each level to forward explicitly, which the `super.init()` chain does naturally.

### Gaps
- What exactly breaks, if anything, when a `super` method touches `this` in 6.1 (manual warning versus community practice). Needs a server test.
- Whether `cfinclude` of a file of `cffunction` tags at pseudo-constructor level works in 6.1 and whether such functions respect `access`: no source found.
- Whether `extends` accepts a relative (same-directory) short name when the child is instantiated from another directory: rule 1 on DevApps p.224 is about the calling page; p.247 says same-directory lookup comes first for components in a package. Likely yes, unconfirmed.
- Circular `extends` and maximum inheritance depth: not found.

## Introspection and dynamic behaviour

### Takeaway
`GetMetaData` is the only reflection tool: it returns name, path, the extends chain, functions and properties. There is no `onMissingMethod`, no `IsInstanceOf`, no `GetComponentMetaData` in 6.1; type tests are done by walking the metadata extends chain or by checking for methods with `StructKeyExists`.

### Cited Findings
- `GetMetaData(obj)` (or `GetMetaData(this)` inside a CFC) returns a structure with `name`, `path`, `extends` (the parent's metadata, recursively), `functions` (array; each with name, parameters and its attributes), `properties`, plus `displayname`, `hint` and any custom attributes — CFMLRef p.497-498; DevApps p.235, p.240-241.
- Custom attributes on the tags are readable, e.g. `GetMetadata(obj).MetaType` — DevApps p.240-241.
- `IsObject(value)` is true for objects (including CFC instances), false for queries and XML objects — CFMLRef p.541.
- `IsCustomFunction(name)` tells whether a name is a user-defined function — DevApps p.209-210.
- Function names are ordinary variables: they can be assigned and passed as arguments — DevApps p.208.
- UDFs copied into the Request scope failed when called with named arguments until fixed around CFMX 7 — https://raymondcamden.com/2005/10/27/CFMX-7-and-Super-Fixes (later-version source describing the earlier behaviour).
- "dynamic systems driven by component metadata tend not to scale well" — Guidelines 3.1, "Components & cfproperty".
- Browsing a CFC, or the component explorer, shows generated documentation from the metadata, including the hierarchy up to `WEB-INF.cftags.component` — DevApps p.233.
- Not available in 6.1: `onMissingMethod` (ColdFusion 8) — https://www.bennadel.com/blog/868-learning-coldfusion-8-onmissingmethod-event-handler.htm , https://cfdocs.org/cf8 ; `IsInstanceOf` (ColdFusion 8) — https://cfdocs.org/isinstanceof ; none of these words occur in the 6.1 manuals (grep).

### Inferences
- Untested `isInstanceOf` substitute:

```cfm
<cffunction name="isA" access="public" returntype="boolean" output="false">
    <cfargument name="obj" type="any" required="true">
    <cfargument name="typeName" type="string" required="true">
    <cfset var md = "">
    <cfif not IsObject(arguments.obj)><cfreturn false></cfif>
    <cfset md = GetMetaData(arguments.obj)>
    <cfloop condition="true">
        <cfif md.name eq arguments.typeName><cfreturn true></cfif>
        <cfif not StructKeyExists(md, "extends")><cfreturn false></cfif>
        <cfset md = md.extends>
    </cfloop>
</cffunction>
```

  (`md.name` is expected to be the full dotted path as resolved; compare case-insensitively with `eq`. Exact format is unconfirmed.)
- Public methods are keys of the instance, so `StructKeyExists(obj, "methodName")` is the cheap `method_exists()` for public methods; private methods are not visible that way from outside.
- PHP `__call` / `__get` magic has no counterpart; any proxy, facade or fluent builder that relies on it must be written out method by method, or routed through one explicit `call(name, args)` method using `cfinvoke`.
- Mixins by assigning a function into an instance (`obj.newMethod = someFunction`) were an era technique, but I hold no 6.1 source for it; treat as unconfirmed.
- Given Corfield's scaling remark and the instantiation cost, cache any `GetMetaData` result per component name rather than calling it per request.

### Gaps
- Exact `GetMetaData().name` format in 6.1 (full dotted path versus as written) not confirmed.
- `cfdump` of a CFC instance in 6.1 (what it shows, cost): not captured from the manuals.
- `Duplicate()` on a CFC instance: CFMLRef p.466 only excludes COM, CORBA and Java objects and says nothing about CFCs. Later community knowledge is that deep-copying CFC instances was unreliable before ColdFusion 8; unsourced here, so unconfirmed. Do not rely on `Duplicate()` for objects.
- Function injection / mixins and `StructKeyExists(this, ...)` behaviour inside versus outside the component: no 6.1 source found.

## Type checking

### Takeaway
Types are checked only at run time, at two points: when an argument enters a function (`cfargument type`) and when a value leaves it (`returntype`). A component type name is matched against the object's own name and its ancestors; there are no interface types.

### Cited Findings
- `cfargument type` and `cffunction returntype` accept: any, array, binary, boolean, date, guid, numeric, query, string, struct, uuid, variableName, or a component name; a mismatch throws an error — CFMLRef p.54-55, p.146-148.
- If the type is a component name, ColdFusion raises an error when the value "is not a CFC with the specified name" — CFMLRef p.54-55.
- `init()` "should have a return type that matches the component" (example `returntype="util.lib.thing"`) — Guidelines 3.1, "Components & Constructors".
- "Always specify the type= attribute ... Try to avoid using type="any"" — Guidelines 3.1, "Components & cfargument".
- Type names referring to Mach-II components must use the exact case of the file name — Guidelines 3.1, "File Naming".
- `cfproperty` gives no type checking of instance data — Guidelines 3.1, "Components & cfproperty"; DevApps p.240-241.
- CFCs give "encapsulation and type safety" compared with custom tags — Guidelines 3.1, "Structure".

### Inferences
- With no interfaces, an argument that PHP types as an interface must be typed as a common base component (if all implementers can extend it) or as `any` with an explicit check.
- Nullable PHP types have no equivalent: there is no null in 6.1 CFML. Use `required="false"` with no default and `StructKeyExists(arguments, "x")`, as Guidelines 3.1 recommends.
- A component-typed argument forces a metadata/ancestor comparison on every call; in very hot paths `type="any"` is the pragmatic choice. This is an inference; no 6.1 measurement was found.
- Using a full dotted path in `type`/`returntype` ties the code to the install location (mapping or web-root layout); decide the layout before writing types.

### Gaps
- Whether a component type given as a short name (no package) matches a component in another package, and whether matching walks the full extends chain in 6.1: the manual sentence is brief. Believed yes for ancestors; unconfirmed.
- No measurement of the run-time cost of type checks on 6.1.
- Whether `returntype` with a component name is validated strictly in 6.1 or loosely: not found.

## Persistence and concurrency

### Takeaway
CFC instances may be stored in Session, Application or Server scope and are then shared by concurrent requests, so they must be written without request-specific state in `variables` and with every local `var`-scoped. Creation of shared singletons is guarded with a double-checked `cflock`. Instances cannot be put in Client scope or replicated across a cluster.

### Cited Findings
- An instance can be kept in Session or Application scope and reused — DevApps p.223-224, p.247-248.
- Code that manipulates the properties of a persistent CFC should be locked — DevApps p.247-248.
- "Session scope CFCs cannot be serialized, so you cannot use them with clustered sessions" — DevApps p.248.
- Client variables must be simple values (so a CFC cannot be stored there) — DevApps, Client scope section (page number not captured); "Client scope limits you to text data" — Guidelines 3.1, "Use of Shared Scopes".
- Double-checked initialisation idiom for Application scope: read the "initialised" flag under a readonly lock into a local variable, and only if not set take an exclusive lock, re-test, then initialise — DevApps p.339-340.
- Macromedia used named locks for server/application resources (name unique to the resource) and a scoped lock for session; "most read operations do not need to be locked; most write operations should be locked" where a race matters — Guidelines 3.1, "Locking & Shared Scopes".
- macromedia.com stored CFC instances in session scope and cached non-user data in server scope (marginally faster than application scope) — Guidelines 3.1, "Clustering & Session Scope", "Use of Shared Scopes".
- Unqualified variables in methods persist for the life of the instance — Guidelines 3.1, scope section (the root cause of shared-instance races).
- Not available in 6.1: Application.cfc and its `onApplicationStart` / `onRequestStart` events (ColdFusion 7); the entry points are `Application.cfm` and `OnRequestEnd.cfm`, whose file names must have exactly that case — Guidelines 3.1, "File Naming"; absence of "Application.cfc" in the 6.1 manuals (grep).

### Inferences
- Untested bootstrap for `Application.cfm`:

```cfm
<cfapplication name="myapp" sessionmanagement="true">
<cfif not StructKeyExists(application, "framework")>
    <cflock name="myapp_framework_init" type="exclusive" timeout="30">
        <cfif not StructKeyExists(application, "framework")>
            <cfset application.framework =
                CreateObject("component", "system.core.Framework").init()>
        </cfif>
    </cflock>
</cfif>
```

  Assign only the fully initialised object to the Application key, so other requests never see a half-built one.
- Split objects into two kinds: stateless services (routers, loaders, config, the service container) created once per application; and per-request objects (request, response, controller instance) created per request and stored in the Request scope or local variables.
- A URL reload switch (for example a secret `?reinit=`) is needed in development, since there is no `onApplicationStart` and Application-scoped objects otherwise live until timeout or restart.

### Gaps
- No 6.1 source on memory behaviour of many Session-scoped CFCs.
- Whether a named lock is needed around reads of Application-scoped object references in 6.1 (MX made shared-scope access itself thread-safe; I did not capture the manual page for that statement).

## Performance

### Takeaway
The manual states that instantiating a CFC is substantially more expensive than a custom tag or UDF, while calling a method on an existing instance costs about the same as a custom tag. The consistent era advice is: create objects once, cache them in a shared scope, keep per-request object creation low, and turn on the trusted cache in production.

### Cited Findings
- Instantiating a CFC takes "substantially more processing time" than processing a custom tag (which takes more than a UDF); once instantiated, calling a method takes about the same as an equivalent custom tag; do not use CFCs for independent single-purpose functions — DevApps p.221.
- A transient `cfinvoke` by component name instantiates and discards the component on every call — DevApps p.223-224; CFMLRef p.208-212.
- `cfmodule` is "slower than a CFC method invocation" — Guidelines 3.1, "Performance Don'ts".
- Avoid `evaluate()`, `iif()`, `structFind()`; prefer `compareNoCase()`/`listFindNoCase()` in hot comparisons; string/list handling is slow in MX, arrays are usually faster — Guidelines 3.1, "Appendix: Performance Techniques".
- "Do not optimize unless you know you have a performance problem"; biggest wins come from architecture and caching; load-test rather than single-request time — Guidelines 3.1, same appendix.
- Server scope access is marginally faster than application scope — Guidelines 3.1, "Use of Shared Scopes".
- Avoid `cfparam` in CFC methods for performance — DevApps p.236.
- Administrator Caching page: Trusted cache (use compiled templates without checking the files for changes), Save Class Files, template cache size — Admin p.19.
- Create objects once and cache them — Camden 2006, https://raymondcamden.com/2006/07/17/Ask-a-Jedi-Is-CreateObject-slow (written for a later version). `createObject()` named as the bottleneck in a CFC-heavy system — cfcdev thread 2006, https://mail-archive.com/cfcdev@cfczone.org/msg15588.html (search snippet only; page not read).
- Metadata-driven systems "tend not to scale well" — Guidelines 3.1, "Components & cfproperty".

### Inferences
- A CodeIgniter-style request builds many small objects (request, response, URI, router, controller, model, view renderer, helpers). On 6.1 everything stateless should be an application singleton and the per-request count kept to a handful.
- Value objects and entities per database row would be costly; return queries or structs from models rather than one CFC per row.
- Set the template cache size at least as large as the number of `.cfm` + `.cfc` files, and enable the trusted cache in production (with a restart or cache clear on deploy).

### Gaps
- No numeric 6.1 benchmark (ms per `CreateObject`, per method call) was found. Measure on the test server.
- No 6.1 source on the relative cost of `cfinvoke` versus a direct method call.
- No source on the cost of deep `extends` chains at instantiation in 6.1.

## Known 6.1 bugs, hot fixes and updaters

### Takeaway
I could confirm only a few CFC-specific defects for 6.1, all around `Super`: no named arguments and no `argumentCollection` through `super`, plus the manual's own warnings about `This` with inheritance. The official 6.1 release notes, Updater notes and hot fix list could not be retrieved, so this section is mostly gaps.

### Cited Findings
- 6.1 itself fixed a number of CFC problems from 6.0 and added `super` — Camden 2003-08-05, https://raymondcamden.com/2003/08/05/395FD4C5-A28A-E02F-B6EFD3603DBA0F8A
- 6.0 lacked the named `variables` scope in CFCs (only the unnamed scope) — Guidelines 3.1, scope section; 6.0 had problems with unnamed-scope values set in `init()` — https://mail-archive.com/cfcdev@cfczone.org/msg01345.html
- 6.0 did not uniformly support mixed-case component file names; 6.1 does — Guidelines 3.1, "File Naming".
- 6.1 allows `cfscript` with `var` inside `cffunction` — https://raymondcamden.com/2003/08/21/395FDB6C-C96C-8AE1-BB8CD08646FE1262
- `argumentCollection` does not work on calls through `super` (stated for 6.1) — Guidelines 3.1, "Components & Constructors".
- Named arguments on `super` calls were broken until CFMX 7 / 7.0.1; UDFs stored in Request scope failed with named arguments — https://raymondcamden.com/2005/10/27/CFMX-7-and-Super-Fixes
- `Super` only reaches one level — DevApps p.245-246.
- Manual warnings: no `This` scope in a base component under inheritance; no `Super` call to a method that uses `This` — DevApps p.242, p.245, p.246 (disputed by practice, see Scopes).
- Session-scoped CFCs cannot be serialised for clustered sessions — DevApps p.248.
- Doc inconsistencies in the 6.1 manuals themselves: "argumentsCollection" on DevApps p.230; "maximum of one cfreturn" on CFMLRef p.298 versus the DevApps p.245 example.

### Inferences
- Safe rule for the port: every `super.method(...)` call uses positional arguments only, in declared order, with optional arguments passed explicitly.
- Because the hot fix level of the target server is unknown from these sources, each emulation trick (include-based mixins, function assignment, metadata walk) should have a small smoke-test page run on the real server before the framework depends on it.

### Gaps
- Macromedia ColdFusion MX 6.1 release notes: no Wayback snapshot at the URL tried (`www.macromedia.com/support/documentation/en/coldfusion/mx61/releasenotes_mx61.html`); other URLs not tried.
- ColdFusion MX 6.1 Updater (released 2004) contents and any CFC fixes in it: not retrieved.
- Individual hot fixes / TechNotes for CFCs on 6.1 (memory use with many CFC instances, `cfdump` of CFCs, concurrency of component path resolution): not retrieved; none can be stated.
- The well-known later-era caution about a memory leak with CFCs held in shared scopes on some 6.1 builds is a recollection without a source; unconfirmed.

## Era frameworks and guidelines: Mach-II, Fusebox 4, Model-Glue, ColdSpring, Tartan, Corfield's guidelines

### Takeaway
The one era source I read in full is Corfield's Macromedia guidelines (Release 3.1, written for 6.1): MVC with CFCs, `init()` returning `this`, `variables` for state, `var` everything, components outside the web root resolved through a Custom Tag Path or mapping, and Mach-II or Fusebox 4.1 as the recommended frameworks. I did not retrieve primary material for the individual frameworks, so their internal conventions are recorded as gaps.

### Cited Findings
- The guidelines' scope: "intended to apply to CFMX 6.1 specifically and may not be appropriate for earlier versions (including CFMX 6.0)"; Release 3.0 incorporated "the changes in ColdFusion Components introduced by CFMX 6.1" — Guidelines 3.1, "Introduction". (Release 3.2 of 2005 retargets CFMX 7: http://web.archive.org/web/20060110034323/http://livedocs.macromedia.com:80/wtg/public/coding_standards/contents.html — do not use 3.2 as a 6.1 source.)
- "Construct as much of the application logic as possible using CFCs"; MVC as the basic pattern; loose coupling, minimal awareness of shared scopes (Session Facade) — Guidelines 3.1, "Structure".
- "Mach II and Fusebox 4.1 are both well-designed frameworks for building MVC-based applications" — Guidelines 3.1, "Structure".
- Mach-II facts visible in the guidelines: its files are mixed case and not URL-accessible; type names referring to them must match file-name case; it is installed under the components tree with a `/MachII` mapping "for including the core file"; user listeners, plugins and event filters extend framework components and implement `configure()` (returntype void) instead of `init()` — Guidelines 3.1, "File Naming", "Directory Structure For Applications", "Components & Constructors".
- Components preferred over custom tags; custom tags still used where a start/end wrapper is natural (page layout) — Guidelines 3.1, "Basic Modularity".
- Exception convention: dotted hierarchical `cfthrow type` values (`Feature.ITEM`), caught from specific to general, message naming component and method — Guidelines 3.1, "Exception Strategy".
- Component conventions: MixedCase file names, verb-noun method names, `displayname`/`hint` on every tag, public methods first with `init()` first, minimal pseudo-constructor — Guidelines 3.1, "Naming", "Component Comments", "Component File Structure".
- Site constants are loaded by `cfinclude` of `.cfm` files rather than WDDX; complex configuration in XML — Guidelines 3.1, "Performance Don'ts".
- A later derivative, "ColdFusion Coding Guidelines, Release 1.1" (2010, author not stated), repeats the same component rules — https://www.slideshare.net/slideshow/coldfusion-coding-guidelines/8365519 (derivative, not a 6.1 source).

### Inferences
- The guidelines' practices map directly onto a CodeIgniter-style port: front controller in a `.cfm` under the web root, everything else as CFCs outside it (or blocked), framework core behind one stable top-level name, user classes extending framework base components.
- Mach-II's `configure()` hook is a useful precedent: let the framework own `init()` on base controllers/models and give user code a separate argument-free hook, which avoids the `super.init()` positional-argument fragility.
- An XML-configured, event/listener framework (Mach-II style) and CodeIgniter's convention-based routing differ in structure, so the frameworks are useful mainly as proof of what CFC patterns ran well on 6.1, not as a design to copy.

### Gaps
- Mach-II 1.0 internals (how it loads listeners, caches the app in Application scope, its use of `cfinvoke` for dynamic dispatch, reload config modes): not retrieved; the Mach-II Development Guide was not found.
- Fusebox 4 / 4.1: recollection only (XML circuits compiled to parsed `.cfm` files; core written as `.cfm`, not CFCs, with CFC use in application code; ran on CF 5 and MX). Unsourced; unconfirmed.
- Model-Glue 1.0 (2005), ColdSpring (2005) and Tartan: release dates, minimum ColdFusion versions (6.1 support is my recollection for early versions) and their patterns (setter/constructor injection via metadata, singleton factories in Application scope) were not retrieved. Unconfirmed.
- Which of these frameworks' idioms were known to be slow or fragile on 6.1 specifically: not found.
