# Mirroring CodeIgniter 4.7.6 architecture in CFML on ColdFusion MX 6.1

Source key used in every citation below (this paragraph is not a section):

- `CI:<path>` = a file in the local CodeIgniter clone `codeigniter4/` (tag v4.7.6, confirmed with `git describe`). Line numbers are from that tag.
- `REF p.N` = ColdFusion MX 6.1 "CFML Reference", text at `cfmx_6.1_docs_en/text/cfmx61_cfml_reference.txt`, page N. "REF, X entry" means the entry exists but its page number was not resolved.
- `DEV p.N` = "Developing ColdFusion MX Applications", `.../text/cfmx61_dev_cf_apps.txt`.
- `ADM p.N` = "Configuring and Administering ColdFusion MX", `.../text/cfmx61_config_admin.txt`.
- `INS p.N` = "Installing and Using ColdFusion MX", `.../text/cfmx61_install.txt`.
- "Absent from manuals" = a case-insensitive text search of REF and DEV returned zero matches. This shows the feature is not documented for 6.1; it is strong but not absolute proof.
- Labels on each mapping: **[MANUAL]** confirmed by the 6.1 manuals; **[PERIOD]** supported by a period or community source (URL given); **[INFERENCE]** my own design reasoning, not sourced. Inferences are kept in the Inferences sub-sections.
- "Brief" = a fact given by the owner in the task assignment (not independently verified by me).

## Layout: what are the top-level folders of a CodeIgniter 4.7.6 project, and what should the CFML port's folders be?

### Takeaway
CodeIgniter has five runtime folders (app, public, writable, tests, and system or vendor), with `public` as the web root and everything else outside it. The same tree can be kept one for one in CFML; the only structural addition 6.1 forces is one ColdFusion mapping, because CFCs and pages outside the web root cannot be reached without one.

### Cited Findings
- A fresh install has five directories: app, public, writable, tests, and vendor or system. — CI:user_guide_src/source/concepts/structure.rst lines 16-22
- `app/` holds Config, Controllers, Database, Filters, Helpers, Language, Libraries, Models, ThirdParty, Views. — CI:user_guide_src/source/concepts/structure.rst lines 36-46
- All files in `app/` live under the `App` namespace (changeable in app/Config/Constants.php); all files in `system/` live under the `CodeIgniter` namespace; system files "should never be modified", extend them instead. — CI:user_guide_src/source/concepts/structure.rst lines 55-69
- `public/` is "meant to be the web root"; it holds .htaccess, index.php and assets, "preventing direct access to your source code". — CI:user_guide_src/source/concepts/structure.rst lines 76-83
- `writable/` holds cache, logs, uploads (clone has cache, debugbar, logs, session, uploads); `tests/` holds tests and `_support`. — CI:user_guide_src/source/concepts/structure.rst lines 85-103; directory listing of CI:writable/
- Top level of the clone: app, public, system, tests, writable, plus admin, changelogs, contributing, user_guide_src, utils, composer.json, env, preload.php, spark. There is no `vendor/` in the clone. — directory listing of the clone root
- With a Composer install, `system` is at `vendor/codeigniter4/framework/system`. — CI:user_guide_src/source/concepts/structure.rst lines 61-62
- Shipped `app/` content: Common.php; Config/ (about 40 config classes including App, Autoload, Constants, Events, Filters, Paths, Routes, Routing, Services, View, and Boot/{development,production,testing}.php); Controllers/BaseController.php and Home.php; Views/welcome_message.php and errors/{cli,html}; Database/{Migrations,Seeds}; Language/en. Filters, Helpers, Libraries, Models, ThirdParty are empty. — directory listing of CI:app/
- `public/` contains index.php, favicon.ico, robots.txt. — directory listing of CI:public/
- `system/` has 40 sub-folders (API, Autoloader, CLI, Cache, Commands, Config, Cookie, DataCaster, DataConverter, Database, Debug, Email, Encryption, Entity, Events, Exceptions, Files, Filters, Format, HTTP, Helpers, Honeypot, HotReloader, I18n, Images, Language, Log, Modules, Pager, Publisher, RESTful, Router, Security, Session, Test, ThirdParty, Throttle, Traits, Typography, Validation, View) and root files BaseModel.php, Boot.php, CodeIgniter.php, Common.php, ComposerScripts.php, Controller.php, Model.php, Superglobals.php, bootstrap.php, rewrite.php, util_bootstrap.php; 492 PHP files outside ThirdParty. — directory listing and file count of CI:system/
- **[MANUAL]** ColdFusion mappings "apply only to pages processed by ColdFusion MX with the cfinclude and cfmodule tags"; pages outside the web root need a mapping. — ADM p.22
- **[MANUAL]** CFC lookup order from a CFML page: (a) the calling page's directory, (b) ColdFusion mappings, (c) the web root, (d) custom tag paths. With only a bare component name the mappings are not searched; a qualified dotted path whose first element is a mapped name is found. If the first path element matches a directory but the CFC is not there, the search stops. — DEV p.224
- **[MANUAL]** CFCs under mappings or custom tag roots are not reachable by URL unless they are inside the web root. — DEV p.241
- **[MANUAL]** A CFC "package" is a directory; dotted names follow directories. — DEV p.247
- **[MANUAL]** Application.cfm is searched for in the requested page's directory and then up the directory tree; the first one found is used, only one per request. OnRequestEnd.cfm must sit in the same directory and does not run after an error or cfabort. — DEV p.271
- **[PERIOD]** Mach-II's convention: framework core in a directory named `MachII` in the web root, or outside it behind a server mapping called `MachII`. — https://github-wiki-see.page/m/Mach-II/Mach-II-Framework/wiki/How-Do-I-Install-Mach-II%3F (this page describes Mach-II 1.8.x, not the 2003 1.0 release)
- **[PERIOD]** Model-Glue: put ModelGlue (and ColdSpring) in the web root or provide a mapping. — https://groups.google.com/g/model-glue/c/t0BwnLOHgjU
- **[PERIOD]** Fusebox 4 kept its core files (fusebox4.runtime.cfmx.cfm and others) in the application root beside index.cfm, with `parsed` and `plugins` sub-directories. — https://community.adobe.com/t5/coldfusion-discussions/cf9-and-fusebox4-cache-problem/m-p/2326287 (seen only through an error log in a forum thread, not official documentation)
- The web root is the repository's `public` folder and the owner can add a ColdFusion mapping in the Administrator. — Brief

### Inferences
- **[INFERENCE]** Keep the tree identical: `app/`, `public/`, `system/`, `tests/`, `writable/`, with the same sub-folder names and the same capitalisation as CodeIgniter (`app/Config`, `app/Controllers`, `system/Router`, and so on). Windows NT file names are case-insensitive, so the capitalisation costs nothing and keeps side-by-side reading with the PHP source easy.
- **[INFERENCE]** File-name rule: one PHP class file becomes one `.cfc` with the same base name (`system/Router/Router.php` to `system/Router/Router.cfc`); PHP files that are not classes (index.php, Common.php, Routes.php, Boot/development.php, views, helpers) become `.cfm`.
- **[INFERENCE]** Because `public/` is the web root and `app/` and `system/` are outside it, at least one mapping is mandatory for CFCs (DEV p.224) and for any absolute cfinclude (ADM p.22). Recommended: one mapping whose name is unlikely to collide with a real directory (for example the project name) pointing at the repository root. Component paths then read `<mapping>.system.Router.Router` and `<mapping>.app.Controllers.Home`. Trade-off against two mappings named `system` and `app`: two short names read closer to PHP namespaces but are more likely to hit the DEV p.224 rule that a matching first path element in the calling directory or web root stops the search.
- **[INFERENCE]** Put `Application.cfm` in `public/` only. Because Application.cfm is found by walking up from the requested page (DEV p.271) and only `public/` is web-served, nothing in `app/` or `system/` is ever a requested page, so they need no Application.cfm. A small defensive `Application.cfm` containing only `<cfabort>` in `app/`, `system/`, `writable/` and `tests/` costs nothing and protects against a misconfigured web root (the CodeIgniter equivalent is the `.htaccess` deny file).
- **[INFERENCE]** `vendor/` has no Composer behind it in CFML; see the vendor section for what the folder should hold.

### Gaps
- No official Fusebox 4 or Mach-II 1.0 (2003) installation document was reached; the period conventions above come from later wiki pages and forum threads.
- Whether IIS 4 on the test server already blocks requests above the web root in every case was not checked; this is a server configuration matter outside the manuals.

## Request lifecycle: what happens from public/index.php to the response, in order, and what is the CFML equivalent of each step?

### Takeaway
CodeIgniter's lifecycle is a fixed chain: index.php, Paths, Boot (constants, env, common functions, autoloader, services), CodeIgniter::run (events, filters, router, controller, output capture, after filters), Response::send. Every step has a workable 6.1 mechanism (cfinclude, CFC instances, cfsavecontent, cfheader/cfcontent), with one real difference: PHP rebuilds everything per request while ColdFusion can keep objects in the Application scope, which is optional and needs locking.

### Cited Findings
CodeIgniter side:
- index.php: checks PHP >= 8.2 (503 on failure), defines FCPATH as its own directory, `chdir(FCPATH)`, requires `../app/Config/Paths.php`, creates `new Paths()`, requires `$paths->systemDirectory . '/Boot.php'`, then `exit(Boot::bootWeb($paths))`. — CI:public/index.php
- `Boot::bootWeb` order: definePathConstants, loadConstants (app/Config/Constants.php), checkMissingExtensions, loadDotEnv, defineEnvironment (ENVIRONMENT from CI_ENVIRONMENT, default `production`), loadEnvironmentBootstrap (app/Config/Boot/{ENVIRONMENT}.php, 503 if missing), loadCommonFunctions (app/Common.php then system/Common.php), loadAutoloader, setExceptionHandler, initializeKint, optional config cache load, autoloadHelpers, initializeCodeIgniter (`service('codeigniter')`, `initialize()`, `setContext('web')`), runCodeIgniter (`$app->run()`), optional config cache save. — CI:system/Boot.php lines 42-75
- Other entry points exist: bootWorker, bootConsole, bootSpark, bootTest, preload. — CI:system/Boot.php
- `CodeIgniter::run()`: start benchmark; get request and response objects; `Events::trigger('pre_system')`; required "before" filters (a returned Response short-circuits); `handleRequest()`; catches ResponsableInterface (uses `$e->getResponse()`), PageNotFoundException (404 display), Throwable (rethrow); required "after" filters; `Events::trigger('post_system')`; `sendResponse()`. — CI:system/CodeIgniter.php from line 329
- `handleRequest()`: tryToRouteIt (load routes, build router, start output buffering, `$router->handle($uri)` gives controller, `$router->methodName()` gives method, returns route filters); enable route filters; `$filters->run($uri, 'before')` (a Response short-circuits, a returned Request replaces the request); startController (closure handler is called directly; otherwise class existence check and rejection of methods starting with `_`); createController (`new $controller()` then `initController($request, $response, Services::logger())`); `_remap` or method existence check; `Events::trigger('post_controller_constructor')`; runController (`$class->{$method}(...$params)`); gatherOutput (buffered echo output plus returned string, or returned Response, becomes the response body); `$filters->run($uri, 'after')`; storePreviousURL; return response. — CI:system/CodeIgniter.php from line 456
- `Response::send()` = finalize CSP, sendHeaders (status line and headers through `header()`), sendCookies, sendBody (echo). — CI:system/HTTP/ResponseTrait.php
- app/Config/Events.php registers a `pre_system` closure (output buffering, debug toolbar, hot reload route). — CI:app/Config/Events.php

ColdFusion side:
- **[MANUAL]** cfinclude takes "a logical path": searched relative to the current page's directory, then in Administrator mappings; a leading `/` means a mapping. A manual example uses `../../` in a template path, so parent-relative includes work. — REF p.192; REF p.356; DEV p.165
- **[MANUAL]** `CreateObject("component", "dotted.path")` creates a CFC instance; code in the CFC body outside methods runs at creation (the only built-in "constructor"). — REF p.425
- **[MANUAL]** cfinvoke can call a method on an existing component instance and accepts `argumentCollection` (a struct of arguments). — REF p.209; DEV p.228
- **[MANUAL]** cfsavecontent captures generated output into a variable. — REF p.300
- **[MANUAL]** `GetHttpRequestData()` returns headers, content (raw body), method, protocol. — REF p.491
- **[MANUAL]** CGI variables include REQUEST_METHOD, PATH_INFO, PATH_TRANSLATED, SCRIPT_NAME. — REF p.30
- **[MANUAL]** `GetPageContext()` exposes the underlying JSP PageContext. — REF p.501
- **[MANUAL]** cfheader has `statusCode` and `statusText` attributes; cfcontent, cfcookie, cflocation, cfsetting, cfflush, cfabort, cferror, cflog all exist as tags. — REF, cfheader entry (text line 8687 shows `statusCode = "status_code"`); REF entries for the other tags (page numbers not resolved)
- **[MANUAL]** Exceptions: cftry, cfcatch, cfthrow, cfrethrow exist; custom exception types are hierarchical dotted names and cfcatch matches by prefix. `cffinally` is absent from manuals. — REF entries; DEV p.308
- **[MANUAL]** OnRequestEnd.cfm does not run after an error or cfabort. — DEV p.271
- **[MANUAL]** Data kept in the Application scope should be locked with cflock; CFCs stored in Application or Session scope need locking. — DEV p.331; DEV pp.247-248
- **[MANUAL]** `Application.cfc` (and therefore onRequestStart/onError/onApplicationStart) is absent from manuals. — text search of REF and DEV (zero matches)
- The rewrite sends non-file requests to `index.cfm/<route>`; the route arrives in CGI.PATH_INFO, which on this IIS includes the script name (for example `/index.cfm/about/team`). — Brief

### Inferences
Step-by-step mapping (all **[INFERENCE]** built on the cited mechanisms):

| CodeIgniter step | CFML on 6.1 | Notes |
|---|---|---|
| public/index.php | `public/index.cfm` | Same five jobs: compute FCPATH, load Paths, include Boot, run, stop. |
| PHP version check | Check `Server.ColdFusion.ProductVersion` | Optional; fail with a 503 like CI does. |
| `require app/Config/Paths.php; new Paths()` | `CreateObject("component", "<mapping>.app.Config.Paths")` | Needs the mapping (DEV p.224). |
| `require system/Boot.php; Boot::bootWeb($paths)` | `CreateObject("component", "<mapping>.system.Boot").bootWeb(paths)` | No static methods in 6.1 CFCs, so an instance is created. |
| define path constants | Fill a struct such as `Request.ci.paths` or individual `Request.APPPATH` values | CFML has no constants. |
| loadConstants | `cfinclude` of `app/Config/Constants.cfm` that sets Request values | |
| loadDotEnv | Small CFC that reads `.env` with cffile and parses `key = value` lines into `Request.ci.env` | See Config section. |
| defineEnvironment + Boot/{env}.php | Set `Request.ENVIRONMENT`, cfinclude `app/Config/Boot/#env#.cfm` | Page-level debug output is an Administrator setting on 6.1, not something code switches on. |
| loadCommonFunctions | cfinclude `app/Common.cfm` then `system/Common.cfm`; copy each UDF into the Request scope | Pattern from DEV pp.206-207. |
| loadAutoloader | Build the class-name-to-component-path map (see Paths section) | There is no autoload hook in CFML. |
| setExceptionHandler | One cftry/cfcatch around the run call in Boot, plus cferror in Application.cfm as a last resort | |
| `service('codeigniter')->run()` | `Request.service("codeigniter").run()` | |
| `Events::trigger()` | Events CFC holding an array of listener descriptors per event name | Listeners cannot be closures; see PHP features section. |
| output buffering (`ob_start`) around the controller | Wrap the controller cfinvoke in `<cfsavecontent>` | Captures anything the controller or view writes. |
| `$class->{$method}(...$params)` | `<cfinvoke component="#controller#" method="#method#" argumentCollection="#params#" returnVariable="result">` | Dynamic method name is the reason to use cfinvoke. |
| gatherOutput | Body = saved content plus returned string, or the returned Response object's body | A method that returns nothing leaves `returnVariable` undefined; test with IsDefined. |
| `$response->send()` | Response CFC `send()`: cfheader statusCode, loop cfheader name/value, cfcookie, then output the body | cfcontent `reset="yes"` can clear stray whitespace before the body. |
| `exit` | Simply end index.cfm | Avoid cfabort so OnRequestEnd.cfm stays usable (DEV p.271). |

- **[INFERENCE]** Per-request versus persistent: PHP builds every object on every request. The simplest faithful port does the same and stores everything in the Request scope (no locks needed, behaviour identical to CodeIgniter). Caching the route table, config objects and stateless services in the Application scope is a later optimisation that then requires cflock around initialisation (DEV p.331) and a "reload" switch for development.
- **[INFERENCE]** Do not use OnRequestEnd.cfm for "after" filters or sending the response; it is skipped on errors and aborts (DEV p.271). Keep the whole pipeline inside `CodeIgniter.run()` as CodeIgniter does.
- **[INFERENCE]** `Application.cfm` in `public/` should do only `cfapplication` (name, session settings) and the last-resort cferror; the bootstrap belongs in index.cfm so the file-for-file mirror of index.php holds.
- **[INFERENCE]** Whitespace: CFML pages emit whitespace for every tag line. Use `<cfsetting enablecfoutputonly="yes">` at the top of index.cfm and `output="no"` on CFC functions so the captured body is clean.

### Gaps
- The CGI.PATH_INFO behaviour on IIS 4 (script name included) is taken from the brief; the 6.1 manuals list the variable (REF p.30) but do not describe the IIS behaviour.
- Whether `GetPageContext().getResponse()` can set a status code or header after output has started on 6.1 was not tested; cfheader is the documented route.
- I did not read CodeIgniter's Session, IncomingRequest internals, Model/BaseModel, spark or preload.php in detail; lifecycle steps touching those are not covered here.
- Whether cfheader works when called inside a CFC method invoked inside cfsavecontent was not verified in the manual (expected to work, needs a test on the server).

## PHP features: which PHP language features does CodeIgniter 4.7.6 depend on, and what is the ColdFusion MX 6.1 answer to each?

### Takeaway
CodeIgniter leans hardest on namespaces with autoloading, static classes, interfaces, closures, magic methods and null handling; none of these exist in 6.1 CFML. Each has a workable substitute (directories and dotted paths, Request-scoped instances, base components, named handlers, explicit methods, key-existence checks), but closures, traits and null need deliberate design decisions early.

### Cited Findings
Usage counts in `system/` excluding ThirdParty (number of files containing the feature, from grep over the clone): interfaces 42, traits 20, abstract classes 18, final classes 26, enums 1, `yield` 2, attributes 4, `__get` 11, `__call` 5, `__callStatic` 2, `__set` 2, Reflection 16, static closures 48, `match` 23, variadics 45, `readonly` 33, `static::` 42, `instanceof` 88, serialize 9, `ob_start` 10, `preg_` functions 82, `??` 175, closure `use (` 27, class constants 14, heredoc 4. — grep over CI:system/ (my own counts; approximate, pattern based)
- composer.json requires PHP ^8.2, ext-intl, ext-mbstring. — CI:composer.json

ColdFusion 6.1 facts:
- **[MANUAL]** cfcomponent supports `extends`; all CFCs extend `WEB-INF\cftags\component.cfc`; `Super` reaches the parent's methods, one level only. — REF p.85; DEV p.246
- **[MANUAL]** Method access levels: private (visible to the component and those extending it, "like Java protected"), package, public, remote. — DEV pp.247-248
- **[MANUAL]** This scope is public instance data; Variables scope is private to the CFC instance, persists for the instance's life and is shared with pages the CFC includes. — DEV p.242
- **[MANUAL]** Manual note: "When you use a component that extends another component, the This scope is not available in the base (parent) component". — DEV p.242 and p.245
- **[MANUAL]** `var` local variables must be declared at the top of the function body. — DEV p.244
- **[MANUAL]** UDFs are variables; a function name can be passed as an argument and assigned (`Request.MyFunc = MyFunc`). — DEV p.202, p.208, pp.206-207
- **[MANUAL]** Simple values and arrays are passed to functions by value; structures, queries and objects are passed by reference. — DEV p.202 and p.210
- **[MANUAL]** CFML tags cannot be used inside CFScript. — DEV p.128 and p.131
- **[MANUAL]** "ColdFusion does not use a null data type"; nulls from a database or Java object become empty strings when used as simple values. — DEV p.56
- **[MANUAL]** "A structure's keys are unordered"; StructKeyList no longer returns keys alphabetically. — REF p.689; DEV p.405
- **[MANUAL]** `IsStruct` returns true for a Java object that implements java.util.Map. — DEV p.117
- **[MANUAL]** ColdFusion regular expressions support lookahead and minimal (non-greedy) matching. REFind and REFindNoCase have a `returnsubexpressions` argument. — DEV p.149 and p.157; REF, REFind entry
- **[MANUAL]** Java objects: `CreateObject("java", class)`; `init()` calls the constructor; static methods can be called without init; overloads are chosen by argument count. — REF p.428; DEV p.746
- **[MANUAL]** ColdFusion MX 6.1 ships with the Sun 1.4.2 JVM. — INS p.12
- **[MANUAL]** GetMetaData exists (component introspection); cfwddx exists (serialisation to WDDX). — REF, GetMetaData and cfwddx entries
- **[MANUAL]** Absent from manuals: `cfinterface`, `onMissingMethod`, `IsInstanceOf`, `Application.cfc`, `SerializeJSON`, `cffinally`. — text search of REF and DEV (zero matches each)
- **[MANUAL]** cfinvoke accepts `argumentCollection`. — DEV p.228
- JDK 1.4 class files are major version 48; Java 5 is 49, Java 6 is 50, Java 8 is 52. — https://en.wikipedia.org/wiki/Java_class_file

### Inferences
Mapping table (every row **[INFERENCE]** unless a manual page is cited in the row):

| PHP feature (CI usage) | 6.1 substitute | Trade-off |
|---|---|---|
| Namespaces (`CodeIgniter\Router\Router`) | Directory packages with dotted paths (DEV p.247): `<mapping>.system.Router.Router` | The mapping name replaces the vendor prefix; keep one translation function so the mapping name appears in one place. |
| Autoloading (PSR-4, `spl_autoload_register`) | None. Explicit `CreateObject` through one factory UDF that translates a CodeIgniter-style class name to a component path | A missing class surfaces as a CreateObject error at the call site instead of at autoload time. |
| `use` imports | Nothing; write the full name at the creation point, or go through the factory | |
| Static classes and static methods (`Services::router()`, `Events::trigger()`, `Factories::config()`) | One instance per request (or per application) held in the Request scope; callers go through UDFs `service()`, `config()` | Request scope is visible everywhere including inside CFCs, which is what makes it the natural home. |
| Class constants and `define()` | Request-scope values set once in Boot (`Request.APPPATH`) or read-only getter methods | Nothing enforces immutability. |
| Interfaces (42 files) | Duck typing; optionally a base CFC whose methods `cfthrow` "not implemented" | No compile-time check; a test that calls every required method name through GetMetaData can stand in. |
| Abstract classes (18) | Base CFC with throwing stubs | |
| `final`, `readonly` | Convention only | |
| Traits (20 files; for example ResponseTrait, RequestTrait, MessageTrait) | Fold the trait into a base component and use `extends`, or `cfinclude` a file of cffunctions into the cfcomponent body | Inheritance is single; where a class uses two traits one must be merged into a parent. Whether functions defined in an included file become public methods on 6.1 needs a server test (see Gaps). |
| Closures and callables (route closures, event listeners, `static fn`) | Named handlers: a string such as `Controller::method`, or a struct `{component, method}` invoked with cfinvoke; or a UDF reference passed as a value (DEV p.208) | No variable capture. Route closures are the visible loss; the `Routes` file must use string handlers. |
| `__get`/`__set` (11 files; config and entity property access) | Public This-scope fields for plain property bags (config), explicit `get(name)`/`set(name, value)` methods elsewhere | |
| `__call`/`__callStatic` (service name discovery, Factories) | Explicit dispatcher method: `Services.get(name)` that does a cfinvoke with a dynamic method name | `onMissingMethod` is absent in 6.1. |
| Variadics `...$params` (45 files) | `Arguments` scope, and `argumentCollection` on cfinvoke (DEV p.228) | Positional parameters from a route become a struct with numeric keys `1`, `2`, ... passed as argumentCollection (needs a test), or are passed as one array argument. |
| Named/default/typed parameters, return types | `cfargument name type required default`, `cffunction returntype` | Types are checked at run time only. |
| Nullable types, `null`, `??` (175 files), `?->` | `StructKeyExists(struct, key)` / `IsDefined()` before reading; methods that "return null" either return an empty string or return a struct and the caller checks a key | DEV p.56: there is no null. Pick one convention and document it in the port. |
| `instanceof` (88 files) | Compare `GetMetaData(obj).name` and walk `.extends`, wrapped in one helper `isInstanceOf(obj, name)` | `IsInstanceOf` is absent in 6.1. |
| Exceptions, class hierarchy, `finally` | `cfthrow type="CodeIgniter.Exceptions.PageNotFoundException"`; cfcatch on the dotted prefix (DEV p.308); no finally, so repeat cleanup code in both paths | Exception objects cannot carry methods (for example `getResponse()` of RedirectException); carry data in `message`, `detail`, `extendedInfo`, `errorCode` instead. |
| Associative arrays with insertion order | CFML structs are unordered (REF p.689). Use arrays of structs wherever order matters (routes, filters, listeners), or `CreateObject("java", "java.util.LinkedHashMap")` | LinkedHashMap is part of Java 1.4 (general Java knowledge, not from the manuals) and passes IsStruct (DEV p.117); whether struct functions and cfloop collection preserve its order on 6.1 needs a test. |
| Numeric arrays | CFML arrays, 1-based, passed by value to functions (DEV p.202) | By-value passing means a function that "modifies an array argument" must return it. |
| Objects passed by handle | CFC instances and structs are passed by reference (DEV p.210) | Same as PHP for objects. |
| `preg_match`, `preg_replace` (82 files) | REFind / REReplace (with `returnsubexpressions` for groups), or java.util.regex through Java objects on the 1.4.2 JVM (INS p.12) | CFML regex has no `#...#u` delimiters or flags syntax; route patterns must be translated. java.util.regex being present in Java 1.4 is general Java knowledge. |
| `ob_start`/`ob_get_clean` (10 files) | cfsavecontent (REF p.300) | Nesting works by nesting tags; there is no "current buffer level" API. |
| `include` with `extract()` (views) | cfinclude inside a CFC method, with the data copied into a scope the view can see | See the views section. |
| `serialize`/`unserialize` | cfwddx | Format differs from PHP; fine for cache and session payloads. |
| `json_encode` | Hand-written encoder CFC, or a Java library that runs on 1.4 | No native JSON in 6.1 (`SerializeJSON` absent). |
| Reflection (16 files) | GetMetaData | Enough for method lists, arguments, `extends`. |
| Attributes (4 files, route attributes), enums (1), `match` (23), generators (2) | Drop route attributes; structs of constants; cfswitch / if-else; arrays | Small surface, safe to defer. |
| `sprintf`, heredoc | String concatenation, cfsavecontent for long literals | |
| Superglobals `$_GET/$_POST/$_SERVER/$_COOKIE` | URL, Form, CGI, Cookie scopes; raw body and headers through GetHttpRequestData (REF p.491) | |
| `header()`, `setcookie()` | cfheader, cfcookie | |
| mbstring / intl | Java String and java.text classes on 1.4.2 | Not examined in detail. |

- **[INFERENCE]** Because tags cannot appear in CFScript (DEV p.128), anything that needs cfinvoke, cfthrow, cfinclude, cfsavecontent, cfquery or cflock must be written in tag syntax or wrapped in a small tag-based UDF (`throw()`, `invoke()`, `include()`) that script code calls. Wrapping these once in `system/Common.cfm` lets most ported logic stay in CFScript, which reads closest to the PHP original.
- **[INFERENCE]** Constructor convention: since only body code runs at creation (REF p.425), give every ported class an `init()` method that takes the PHP constructor's arguments and returns `This`, and always create with `CreateObject(...).init(...)`. This is the well-known community convention for CFCs of that era, stated here from memory without a fetched source.
- **[INFERENCE]** The "This scope is not available in the base component" note (DEV p.242) threatens the `init()` returns This pattern when `init` lives in a parent. It must be the first thing tested on the real server; if it bites, keep public data in the Variables scope behind getter methods.
- **[INFERENCE]** Java libraries must be compiled for class-file version 48 or lower to load on the 1.4.2 JVM; anything built for Java 5 or later will not load. The version numbers are sourced (Wikipedia); the refusal rule is general JVM knowledge.

### Gaps
- Whether cffunctions defined in a file that a cfcomponent includes become callable methods (and public ones) on 6.1 was not confirmed in the manuals. DEV p.242 only says included pages share the Variables scope.
- Whether including the same UDF file twice in one request raises a "function already defined" error on 6.1 was not found in the manual text I searched; DEV pp.206-207 recommend defining once and copying to the Request scope, which sidesteps the question.
- Whether `argumentCollection` with numeric keys maps onto positional arguments on 6.1 is not stated in the pages I read.
- CFML regex differences from PCRE (lookbehind, Unicode classes, named groups) were not catalogued; only lookahead and minimal matching are confirmed (DEV p.149, p.157).
- Whether anonymous functions are truly unavailable was not searched as a phrase; the manuals document only named UDFs, and I am confident closures arrived in a much later release, but that statement is from memory.
- Struct key case behaviour (keys reported in upper case by StructKeyList when created with dot notation) is from memory and was not looked up.

## Config: how does CodeIgniter load configuration (.env, Constants, Config classes), and how should that work in CFML?

### Takeaway
A CodeIgniter config is a plain class with public properties whose constructor overlays values from `.env`; `config('App')` returns a shared instance through Factories. In CFML a config is a CFC that sets This-scope fields in its body and a BaseConfig parent that overlays `.env` values, fetched through a `config()` UDF.

### Cited Findings
- Config files are classes in `app/Config/` (App, Autoload, Cache, Database, Filters, Routing, View and about 35 more). — directory listing of CI:app/Config/
- `BaseConfig` constructor loops over the object's public properties and overlays environment values looked up by the full class prefix and by the lower-case short class name (`initEnvValue`), then applies registrars (`registerProperties`). — CI:system/Config/BaseConfig.php
- The `env` file uses `CI_ENVIRONMENT` and dotted keys such as `app.baseURL`, `database.default.hostname`, `encryption.key`, `session.driver`, `logger.threshold`. — CI:env
- `Boot::loadDotEnv` does `new DotEnv($envDirectory)->load()`; `defineEnvironment` sets ENVIRONMENT from CI_ENVIRONMENT, default `production`; `loadEnvironmentBootstrap` requires app/Config/Boot/{ENVIRONMENT}.php. — CI:system/Boot.php
- Constants.php defines APP_NAMESPACE `App`, COMPOSER_PATH (`ROOTPATH . 'vendor/autoload.php'`), time constants SECOND to DECADE, EXIT_* codes. — CI:app/Config/Constants.php
- Boot/development.php sets error_reporting(E_ALL), display_errors 1, SHOW_DEBUG_BACKTRACE true, CI_DEBUG true. — CI:app/Config/Boot/development.php
- `config($name, $getShared = true)` calls `Factories::get('config', $name)`. — CI:system/Common.php
- `env()` helper exists in Common.php. — CI:system/Common.php
- app/Config/App.php has baseURL, indexPage (default `index.php`), uriProtocol (default REQUEST_URI; PATH_INFO and QUERY_STRING also accepted). — CI:app/Config/App.php; CI:system/HTTP/SiteURIFactory.php
- Boot can load and save a config cache (Config\Optimize). — CI:system/Boot.php lines 42-75
- **[MANUAL]** Code in a CFC body outside functions runs when the CFC is created. — REF p.425
- **[MANUAL]** This scope holds public data of a CFC instance. — DEV p.242
- **[MANUAL]** GetMetaData exists; cfproperty exists (metadata only in the reference entry list). — REF entries
- **[MANUAL]** cffile exists for reading files; FileExists and DirectoryExists exist. — REF entries
- **[MANUAL]** A base component's access to the child's This scope is flagged as unavailable. — DEV p.242 and p.245

### Inferences
- **[INFERENCE]** `app/Config/App.cfc`: `<cfcomponent extends="<mapping>.system.Config.BaseConfig">` with the body setting `This.baseURL = "..."`, `This.indexPage = "index.cfm"`, `This.uriProtocol = "PATH_INFO"`, then an `init()` that calls the BaseConfig overlay. This keeps the file readable side by side with `App.php`.
- **[INFERENCE]** The overlay cannot use reflection on public properties as PHP does; in CFML loop over the keys of `This` (skipping keys that are functions, using IsCustomFunction, which exists in REF) and look up `Request.ci.env["<shortname>.<key>"]`. Because of the DEV p.242 warning this loop may need to live in a function the child calls with `This` passed as an argument (`overlayEnv(This, "app")`) rather than relying on `This` inside the parent.
- **[INFERENCE]** `.env`: a `DotEnv.cfc` reads the file with cffile, splits on line ends, skips `#` comments, splits each line at the first `=`, trims and unquotes, and stores keys in a Request-scope struct. Dotted keys such as `database.default.hostname` are stored as flat string keys (bracket notation) so nothing interprets the dots. The file name `.env` works on NT file systems but Windows Explorer of that era refuses to create a file that starts with a dot; creating it from a command prompt or over FTP avoids that.
- **[INFERENCE]** Web-server protection: CodeIgniter keeps `.env` outside the web root; with `public/` as web root the port inherits that safety without extra work.
- **[INFERENCE]** Constants: `app/Config/Constants.cfm` is a cfincluded page that sets `Request.APP_NAMESPACE`, `Request.SECOND`, `Request.MINUTE` and so on. COMPOSER_PATH has no meaning; drop it or point it at the vendor manifest described later.
- **[INFERENCE]** Environment boot files: keep `app/Config/Boot/development.cfm`, `production.cfm`, `testing.cfm`, setting `Request.CI_DEBUG` and `Request.SHOW_DEBUG_BACKTRACE`. PHP's `display_errors` has no page-level twin; robust exception information is an Administrator debugging setting on 6.1, so the port should render its own error views instead.
- **[INFERENCE]** Config caching (Config\Optimize) is the natural place to use the Application scope later: config objects are read-only after construction, so a single cflock-guarded build per application start is safe. Skip it at first.

### Gaps
- DotEnv's exact parsing rules (quoting, variable interpolation `${VAR}`, `export` prefix) were not read from CI:system/Config/DotEnv.php; the port should read that file before copying behaviour.
- Registrars and Modules discovery (`registerProperties`) were not studied; assume not needed at the start.
- How CF 6.1 handles a struct key containing dots when used with IsDefined was not checked; bracket notation with StructKeyExists avoids the question.

## Services and Factories: how do Services (service locator) and Factories work, and what is the CFML design?

### Takeaway
`Services` is a static class of factory methods with a shared-instance cache and an application override class; `Factories` creates and caches config and model classes by short name. In CFML both become ordinary CFC instances stored in the Request scope and reached through the `service()` and `config()` UDFs, with `app/Config/Services.cfc` extending the system one to preserve the override point.

### Cited Findings
- `BaseService` holds static `$instances`, `$mocks`, `$factories`; methods `get`, `has`, `set`, `override`, `reset`, `resetSingle`, `injectMock`; `getSharedInstance($key, ...$params)` lower-cases the key, returns a mock if present, otherwise appends `false` to the parameters and calls `AppServices::$key(...$params)`; `__callStatic` gives case-insensitive names and service discovery. — CI:system/Config/BaseService.php
- Each service method has the form `name(..., bool $getShared = true)`: when shared it returns `static::getSharedInstance('name', ...)`, otherwise builds a new object. — CI:system/Config/Services.php
- Services defined: cache, clirequest, codeigniter, commands, csp, curlrequest, email, encrypter, exceptions, filters, format, honeypot, image, iterator, language, logger, migrations, negotiator, responsecache, pager, parser, renderer, request, createRequest, incomingrequest, response, redirectresponse, routes, router, security, session, siteurifactory, superglobals, throttler, timer, toolbar, uri, validation, viewcell, typography. — CI:system/Config/Services.php
- `app/Config/Services.php` is an empty class extending BaseService; it is the place where an application overrides or adds services. — CI:app/Config/Services.php
- `service($name, ...$params)` in Common.php returns `Services::get($name)` or calls `Services::$name(...$params)`; `single_service()` returns an unshared instance. — CI:system/Common.php
- `Factories::__callStatic($component, [$alias, $options])` with options getShared, preferApp, instanceOf; `get`, `define`, `injectMock`, `reset`, `locateClass`. `config()` and `model()` go through it. — CI:system/Config/Factories.php; CI:system/Common.php
- Boot loads AutoloadConfig, app Autoload, Modules, Autoloader, BaseService, system Services, app Services in that order, then `Services::autoloader()->initialize(new Autoload(), new Modules())->register()`. — CI:system/Boot.php (loadAutoloader)
- **[MANUAL]** UDFs copied to the Request scope are callable everywhere in the request (`Request.MyFunc = MyFunc`). — DEV pp.206-207
- **[MANUAL]** cfinvoke on an instance with a dynamic method name and argumentCollection. — REF p.209; DEV p.228
- **[MANUAL]** `Super` allows a child to call the parent's version of a method, one level. — DEV p.246
- **[MANUAL]** Shared-scope CFCs need locking. — DEV pp.247-248
- **[PERIOD]** Model-Glue was commonly paired with ColdSpring, a dependency container CFC library. — https://groups.google.com/g/model-glue/c/t0BwnLOHgjU (mention only; ColdSpring itself was not researched)

### Inferences
- **[INFERENCE]** Shape: `system/Config/BaseService.cfc` keeps `Variables.instances` and `Variables.mocks` structs and provides `get(name)`, `has`, `set`, `reset`, `injectMock`, `getSharedInstance(name, args)`. `system/Config/Services.cfc` extends it with one method per service (`router(getShared)`, `routes(getShared)`, `request(getShared)`, ...). `app/Config/Services.cfc` extends the system Services and is the one that Boot instantiates, so application overrides win by ordinary inheritance. This is a simplification of PHP's two-sibling-classes-plus-`__callStatic` arrangement that gives the same result.
- **[INFERENCE]** `get(name)`: lower-case the name; if a mock exists return it; if an instance is cached return it; otherwise `<cfinvoke component="#This#" method="#name#" getShared="false" returnVariable="obj">`, cache and return. Case-insensitivity comes free because CFML method names are case-insensitive.
- **[INFERENCE]** The services object lives at `Request.ci.services`. `service()` and `single_service()` are UDFs defined in `system/Common.cfm` and copied to the Request scope; inside CFCs they are called as `Request.service("router")`. A shorter form is possible if every framework CFC extends a common base that defines `service()` as a private method, at the price of one more inheritance level in every class and the Super one-level limit (DEV p.246).
- **[INFERENCE]** Factories: one `Factories.cfc` with `get(component, alias)` that translates `("config", "App")` to component path `<mapping>.app.Config.App`, falling back to `<mapping>.system.Config.<alias>`, creates it with `init()`, and caches it by `component & ":" & alias`. `preferApp` maps onto "try the app path first"; test existence with FileExists on the translated physical path before CreateObject so a missing class does not have to be detected by catching an exception.
- **[INFERENCE]** Request scope first, Application scope later: services such as request, response, router and uri are per-request by nature and must never be cached across requests. Only pure, stateless ones (routes table, config, autoload map) are candidates for Application caching.
- **[INFERENCE]** Mocks (`injectMock`) cost almost nothing to keep and make the testing story work later.

### Gaps
- `Factories::locateClass` search rules (namespaces, modules, `preferApp` details) were not read line by line.
- Service discovery across modules (Config\Modules) was not studied.
- ColdSpring's minimum ColdFusion version and suitability for 6.1 were not researched.

## Routing: how are routes defined and matched, how do filters attach, and how is this done with CGI.PATH_INFO in CFML?

### Takeaway
Routes are per-verb maps from a regex-capable pattern to a `Controller::method/$1` string (or closure), matched in definition order with `preg_match`; filters are before/after classes attached globally, by route, or as "required". In CFML the route table must be an ordered array, patterns are matched with REFind or java.util.regex, the URI comes from CGI.PATH_INFO with the script name stripped, and closure handlers are dropped.

### Cited Findings
- `app/Config/Routes.php` receives `$routes` and contains `$routes->get('/', 'Home::index');`. — CI:app/Config/Routes.php
- RouteCollection methods: add, get, post, put, delete, head, patch, options, cli, view, match, map, group, resource, presenter, addRedirect, environment, reverseRoute, addPlaceholder, setDefaultNamespace, setDefaultController, setDefaultMethod, setAutoRoute, set404Override, setTranslateURIDashes. — CI:system/Router/RouteCollection.php
- Placeholders: `(:any)` = `.*`, `(:segment)` = `[^/]+`, `(:alphanum)` = `[a-zA-Z0-9]+`, `(:num)` = `[0-9]+`, `(:alpha)` = `[a-zA-Z]+`, `(:hash)` = `[^/]+`. — CI:system/Router/RouteCollection.php around line 109
- `Router::handle($uri)`: urldecode, check disallowed characters, `checkRoutes` (routes for the current HTTP verb; `preg_match('#^' . $routeKey . '$#u', $uri)`; a closure handler stores its params; a string handler `Controller::method/$1` gets back-references substituted; redirect routes throw RedirectException), otherwise auto-routing if enabled, otherwise PageNotFoundException. — CI:system/Router/Router.php from line 205
- Router folder contents: Attributes/{Cache, Filter, Restrict, RouteAttributeInterface}, AutoRouter, AutoRouterImproved, AutoRouterInterface, DefinedRouteCollector, RouteCollection (+Interface), Router (+Interface). — directory listing of CI:system/Router/
- `SiteURIFactory::detectRoutePath` chooses by `uriProtocol` (REQUEST_URI default, PATH_INFO, QUERY_STRING); `parseRequestURI` strips the SCRIPT_NAME segments and the `indexPage` from the path. — CI:system/HTTP/SiteURIFactory.php
- FilterInterface: `before(RequestInterface $request, $arguments = null)` and `after(RequestInterface $request, ResponseInterface $response, $arguments = null)`. — CI:system/Filters/FilterInterface.php
- app/Config/Filters.php: `$aliases` (csrf, toolbar, honeypot, invalidchars, secureheaders, cors, forcehttps, pagecache, performance), `$required` (before: forcehttps, pagecache; after: pagecache, performance, toolbar), `$globals`, `$methods`, `$filters`. — CI:app/Config/Filters.php
- Shipped filters: CSRF, Cors, DebugToolbar, ForceHTTPS, Honeypot, InvalidChars, PageCache, PerformanceMetrics, SecureHeaders. — directory listing of CI:system/Filters/
- In `handleRequest`, a "before" filter returning a Response short-circuits the request; "after" filters run in reverse order unless the old filter order is configured. — CI:system/CodeIgniter.php from line 456
- Controller methods starting with `_` are rejected; `_remap` is honoured if present. — CI:system/CodeIgniter.php (startController, runController)
- **[MANUAL]** CGI.PATH_INFO, CGI.SCRIPT_NAME, CGI.REQUEST_METHOD exist. — REF p.30
- **[MANUAL]** Structures are unordered. — REF p.689; DEV p.405
- **[MANUAL]** REFind / REFindNoCase with `returnsubexpressions`; lookahead and minimal matching supported. — REF, REFind entry; DEV p.149, p.157
- **[MANUAL]** URLDecode exists. — REF, URLDecode entry
- **[MANUAL]** JVM is Sun 1.4.2 and Java classes can be instantiated from CFML. — INS p.12; REF p.428
- On this server CGI.PATH_INFO includes the script name, for example `/index.cfm/about/team`. — Brief

### Inferences
- **[INFERENCE]** URI detection mirrors CodeIgniter exactly: set `uriProtocol = "PATH_INFO"` and `indexPage = "index.cfm"` in App config, and in the SiteURIFactory port strip a leading CGI.SCRIPT_NAME from CGI.PATH_INFO when present (CodeIgniter already strips SCRIPT_NAME segments, so the IIS quirk fits the existing algorithm rather than needing a special case). Result for `/index.cfm/about/team` is `about/team`; an empty remainder is `/`.
- **[INFERENCE]** Route storage: `Variables.routes[verb]` is an array of structs `{from, handler, options}` in definition order, never a struct keyed by pattern, because order decides which route wins and CFML structs lose it (REF p.689). A java.util.LinkedHashMap is the alternative if keyed lookup is wanted.
- **[INFERENCE]** `app/Config/Routes.cfm` is a cfincluded page that expects a variable named `routes` in scope, so the line reads `<cfset routes.get("/", "Home::index")>`, nearly identical to PHP. Group callbacks (`$routes->group('admin', static function ($routes) {...})`) need a different shape because there are no closures: either `routes.group("admin")` / `routes.endGroup()` bracketing, or a named UDF passed by reference.
- **[INFERENCE]** Handler string: keep CodeIgniter's `Controller::method/$1/$2`. `::` is harmless inside a CFML string. Parsing: split on `::`, then split the method part on `/`; substitute `$n` with captured groups. The controller short name resolves through the default namespace `App\Controllers` to `<mapping>.app.Controllers.<Name>`.
- **[INFERENCE]** Matching: translate placeholders to regex, wrap as `^pattern$`, and match with REFind using `returnsubexpressions = true` to get group positions, then Mid() to extract. Trade-off: CFML's regex engine differs from PCRE in details; using java.util.regex.Pattern on the 1.4.2 JVM gives behaviour closer to PCRE (groups by index, case flags) at the cost of Java interop in a hot path. Start with REFind; the six shipped placeholders use only basic character classes.
- **[INFERENCE]** `#` characters: CodeIgniter writes the regex delimiter as `#`; in CFML `#` is the expression delimiter and must be doubled inside strings. Avoid `#` in the port's pattern strings entirely.
- **[INFERENCE]** HTTP verb: `CGI.REQUEST_METHOD` lower-cased selects the route list; CodeIgniter also supports method spoofing through a `_method` form field, which can be added later.
- **[INFERENCE]** Filters: a filter is a CFC with `before(request, arguments)` and `after(request, response, arguments)`. No interface exists, so the Filters runner simply calls those two names. "Returned a Response" is detected with the `isInstanceOf` helper or a marker method (`isResponse()`), and "returned nothing" with IsDefined on the cfinvoke returnVariable.
- **[INFERENCE]** Auto-routing (AutoRouterImproved) and route attributes can be left out initially; CodeIgniter itself ships with auto-routing off by default in app/Config/Routing.php (default value not re-read; see Gaps).
- **[INFERENCE]** 404: throw `CodeIgniter.Exceptions.PageNotFoundException` with cfthrow and catch it in `run()` to render `app/Views/errors/html/error_404.cfm` with status 404 through cfheader.

### Gaps
- The exact default of `$autoRoute` in CI:app/Config/Routing.php was not re-read during this session.
- Reverse routing (`route_to`, `reverseRoute`), route options (filter, namespace, hostname, subdomain, priority), `resource`/`presenter` expansions were listed but not studied in detail.
- Whether IIS 4 passes a URL-decoded or raw PATH_INFO to ColdFusion, and how it treats `+`, `%2F` and trailing dots, is not in the manuals and needs a server test.
- Unicode matching (`u` flag) equivalence in REFind on 6.1 was not checked.

## Controllers, models and views: how do they work in CodeIgniter, and what are the CFML equivalents?

### Takeaway
Controllers are plain classes initialised with request, response and logger whose methods return a string or Response; views are PHP files included inside an output buffer with data extracted into local variables; the database layer is a large query-builder stack. Controllers and views map cleanly to CFCs, cfinclude and cfsavecontent; the model and database layer is the largest piece and should start as a thin wrapper around cfquery with cfqueryparam.

### Cited Findings
- `Controller::initController(RequestInterface, ResponseInterface, LoggerInterface)`; other members: forceHTTPS, cachePage, validate, validateData. — CI:system/Controller.php
- `app/Controllers/BaseController.php` (application base class) and `Home.php` (returns `view('welcome_message')`) ship by default. — CI:app/Controllers/
- The controller is created with `new $controller()` then `initController(...)`; the method is called as `$class->{$method}(...$params)`; the return value (string or Response) and any echoed output become the response body. — CI:system/CodeIgniter.php from line 456
- `view($name, $data, $options)` = `service('renderer')->setData($data, 'raw')->render($name, $options, $saveData)`. — CI:system/Common.php
- `View::render()` resolves the file under the view path (else through the file locator), then inside an isolating closure does `extract($this->tempData); ob_start(); include $file; return ob_get_clean();`. Layout support: extend, section, endSection, renderSection, include; decorators; optional caching. — CI:system/View/View.php
- View folder: Cell, Cells, Filters, Parser, Plugins, RendererInterface, Table, View, ViewDecorator classes. — directory listing of CI:system/View/
- `esc($data, $context)` supports contexts html, js, css, url, attr, raw and uses the bundled Laminas Escaper. — CI:system/Common.php; CI:system/ThirdParty/Escaper
- `helper()` finds `<name>_helper` files, application helper first and system last, with include_once. Shipped helpers: array, cookie, date, filesystem, form, html, inflector, kint, number, security, test, text, url, xml. — CI:system/Common.php; directory listing of CI:system/Helpers/
- Database layer: BaseBuilder, BaseConnection, Forge, Migration, Seeder; drivers MySQLi, OCI8, Postgre, SQLSRV, SQLite3; Model.php and BaseModel.php at the system root. — directory listing of CI:system/Database/ and CI:system/
- `model()` and `db_connect()` helpers exist in Common.php. — CI:system/Common.php
- **[MANUAL]** cfinclude inside a CFC shares the CFC's Variables scope with the included page. — DEV p.242
- **[MANUAL]** cfsavecontent captures output. — REF p.300
- **[MANUAL]** cfquery runs SQL against a named data source; cfqueryparam binds parameters, with `list` and `null` attributes. — REF p.283; REF pp.286-287
- **[MANUAL]** The developing guide has a dynamic SQL section with a cfqueryparam example. — DEV pp.564-565
- **[MANUAL]** Data sources are defined in the Administrator. Standard edition: ODBC with desktop databases such as Access and Type 4 drivers for SQL Server or MySQL; Enterprise adds Oracle, DB2, Sybase, Informix drivers. MySQL 3.23.47 is in the listed requirements. — INS pp.9-10
- **[MANUAL]** HTMLEditFormat, JSStringFormat, URLEncodedFormat exist as functions. — REF entries
- **[MANUAL]** cftransaction and cfstoredproc exist. — REF entries
- **[MANUAL]** Structs and objects pass by reference; arrays and simple values by value. — DEV p.202, p.210

### Inferences
- **[INFERENCE]** Controller: `app/Controllers/Home.cfc` extends `<mapping>.app.Controllers.BaseController`, which extends `<mapping>.system.Controller`. `initController(request, response, logger)` stores the three in the Variables scope. Action methods are `access="public"`, `output="no"`, and return a string (usually `Request.view("welcome_message", data)`) or a Response object. Note the inheritance depth here is three levels, so `Super` (one level, DEV p.246) can reach only the immediate parent; avoid designs that need to skip a level.
- **[INFERENCE]** Method visibility rule: CodeIgniter rejects methods starting with `_`. Keep that rule and additionally require the method to exist as a public function (check `StructKeyExists(controller, method)` plus IsCustomFunction), so `init`, `initController` and inherited framework methods are put on a deny list.
- **[INFERENCE]** View renderer: `system/View/View.cfc` with `render(name, options)`. To copy PHP's isolation (each render has its own variable set), create a small throwaway "view context" CFC instance per render, copy the data struct into its Variables scope with StructAppend, and inside its `run(file)` method do `<cfsavecontent variable="out"><cfinclude template="#file#"></cfsavecontent>`. The view file then reads `#title#` exactly where PHP reads `$title`. Cheaper alternative: one View instance and views that read `data.title`; less faithful, no object creation per render.
- **[INFERENCE]** View file path: cfinclude needs a logical path, not a physical one (REF p.192), so the renderer builds `/<mapping>/app/Views/<name>.cfm`. View files are `.cfm`.
- **[INFERENCE]** Layouts (extend/section/renderSection) are implementable with nested cfsavecontent and a sections struct held by the View instance; `section()`/`endSection()` as a pair of calls cannot open and close a cfsavecontent across two function calls, so sections are better expressed as a custom tag pair (`<cf_section name="content"> ... </cf_section>`) or a cfimport-ed tag library. Defer.
- **[INFERENCE]** `esc()`: map `html` to HTMLEditFormat, `js` to JSStringFormat, `url` to URLEncodedFormat; `attr` and `css` need hand-written encoders if wanted. This replaces the Laminas Escaper dependency.
- **[INFERENCE]** Helpers: `system/Helpers/url_helper.cfm` files of UDFs; `helper("url")` cfincludes app then system versions once per request (track loaded names in a Request struct) and copies the functions to the Request scope. Views inside a view-context CFC cannot see page-level UDFs, so helper functions must be reachable as `Request.site_url()` or be copied into the view context's Variables scope before the include.
- **[INFERENCE]** Models and database: do not port BaseBuilder first. Start with a `Database/Connection.cfc` that holds a data source name and offers `query(sql, binds)`, building the cfquery body from an array of bind descriptors with cfqueryparam inside a cfloop. Then a minimal `Model.cfc` (table, primaryKey, find, findAll, insert, update, delete). The CodeIgniter driver set (MySQLi, Postgre, SQLite3, SQLSRV, OCI8) collapses into "whatever data source the Administrator defines", with only SQL dialect differences (limit/offset, identifier quoting) left to handle.
- **[INFERENCE]** Connection settings do not live in `app/Config/Database` as host/user/password on ColdFusion; the config class should carry the data source name per connection group (`default`, `tests`), since credentials sit in the Administrator.

### Gaps
- An explicit manual statement that cfqueryparam may be generated inside cfloop or cfif within a cfquery body was not found; only the general dynamic SQL guidance (DEV pp.564-565) was. Needs a one-line server test.
- Whether function-local `var` variables are visible to a page cfincluded inside that function on 6.1 was not confirmed; the per-render context CFC design avoids depending on it.
- Whether cfinclude accepts a dynamic `template` expression containing a mapping on 6.1 was not separately verified (the attribute is documented as a path; dynamic values are normal CFML practice).
- Model.php, BaseModel.php, Entity, Validation, Session and Pager were not read; nothing above describes their behaviour.
- Which database the NT 4 test server will use, and which drivers its edition has, is unknown to me.

## Paths: how does CodeIgniter resolve directories and class files (Paths, constants, PSR-4), and how should paths and component names be resolved in CFML?

### Takeaway
CodeIgniter derives five path constants from `app/Config/Paths.php` and resolves class names to files through a PSR-4 prefix map in the Autoloader. CFML needs two parallel things: physical paths (for cffile, FileExists, writable/) derived from the front controller's own location, and logical paths (for cfinclude and CreateObject) derived from one mapping name; a small prefix map reproduces the PSR-4 table.

### Cited Findings
- index.php defines FCPATH as `__DIR__ . DIRECTORY_SEPARATOR` and requires `FCPATH . '../app/Config/Paths.php'`. — CI:public/index.php
- Paths has public string properties systemDirectory, appDirectory, writableDirectory, testsDirectory, viewDirectory, envDirectory, each relative to its own `__DIR__`. — CI:app/Config/Paths.php
- Boot::definePathConstants defines APPPATH, ROOTPATH, SYSTEMPATH, WRITEPATH, TESTPATH. — CI:system/Boot.php lines 245-280
- app/Config/Autoload.php: `$psr4 = [APP_NAMESPACE => APPPATH]`, plus `$classmap`, `$files`, `$helpers`. — CI:app/Config/Autoload.php
- Core map: psr4 `CodeIgniter => SYSTEMPATH`, `Config => APPPATH . 'Config'`; core classmap points PSR Log and Laminas Escaper class names at files under system/ThirdParty. — CI:system/Config/AutoloadConfig.php lines 95-124
- Autoloader: `register()` uses `spl_autoload_register` for loadClassmap and loadClass; addNamespace; loadInNamespace; includeFile (include_once); loadComposerAutoloader; loadHelpers. — CI:system/Autoloader/Autoloader.php
- FileLocator (and FileLocatorCached) find non-class files such as views and helpers across namespaces. — CI:system/Autoloader/FileLocator.php, FileLocatorCached.php
- composer.json autoload: psr-4 `CodeIgniter\\` => `system/`. — CI:composer.json
- **[MANUAL]** GetCurrentTemplatePath, GetBaseTemplatePath, GetDirectoryFromPath and ExpandPath exist. — REF entries (pages not resolved)
- **[MANUAL]** cfinclude: logical path, relative to the current page or via mapping; cfmodule: "A physical path is not valid". — REF p.192; REF p.250
- **[MANUAL]** CreateObject component names are dotted (example `appResources.components.tellTime`). — REF p.425
- **[MANUAL]** CFC search order: calling page directory, mappings, web root, custom tag paths. — DEV p.224
- **[MANUAL]** Mappings and custom tag paths are set on Administrator pages. — ADM p.22; ADM p.33
- **[MANUAL]** Per-application mappings are not documented for 6.1 (no Application.cfc). — text search of REF and DEV for `Application.cfc` (zero matches)

### Inferences
- **[INFERENCE]** Physical paths: in `public/index.cfm`, `FCPATH = GetDirectoryFromPath(GetCurrentTemplatePath())`. `app/Config/Paths.cfc` keeps the same six property names with values relative to the front controller (`..\system`, `..\app`, `..\writable`, `..\tests`). Boot turns them into `Request.SYSTEMPATH`, `Request.APPPATH`, `Request.ROOTPATH`, `Request.WRITEPATH`, `Request.TESTPATH`, `Request.FCPATH`. These are used for cffile, cfdirectory, FileExists and cflog-style file work, never for cfinclude or CreateObject.
- **[INFERENCE]** Logical paths: add one more property to Paths that PHP does not need, for example `mappingName`, holding the Administrator mapping that points at the repository root. Everything that builds a cfinclude path (`/<mapping>/app/Views/x.cfm`) or a component path (`<mapping>.app.Controllers.Home`) derives from that single value, so a deployment with a different mapping name changes one line.
- **[INFERENCE]** PSR-4 equivalent: `app/Config/Autoload.cfc` holds `This.psr4`, a struct such as `App = "<mapping>.app"`, and `system/Config/AutoloadConfig.cfc` adds `CodeIgniter = "<mapping>.system"` and `Config = "<mapping>.app.Config"`. A resolver function `resolveClass("CodeIgniter\Router\Router")` (or with dots) finds the longest matching prefix and replaces it, returning `<mapping>.system.Router.Router`. A factory `Request.new(className)` then does CreateObject on the result. This is the autoloader's job done explicitly at creation time.
- **[INFERENCE]** Classmap equivalent: a struct from class name to full component path, checked before the prefix map; useful for vendor packages whose folder layout does not follow the prefix rule.
- **[INFERENCE]** Class existence (`class_exists`) = translate the component path to a physical file under ROOTPATH and call FileExists. That gives clean 404s for unknown controllers without catching CreateObject errors.
- **[INFERENCE]** Relative cfinclude with `../` (REF p.356 shows it working) could reach `system/` without a mapping, but CreateObject cannot go above the calling directory because component names are dotted only (REF p.425, DEV p.224). So the mapping is unavoidable once CFCs are used, and using it for cfinclude too keeps one rule.
- **[INFERENCE]** Zero-configuration fallback worth knowing about: if the owner ever wants no Administrator mapping, the only alternatives the manual leaves are placing `system/` and `app/` inside the web root (reachable by URL unless protected, DEV p.241) or under a custom tag path (DEV p.224 item d). Both break the "same layout, source outside the web root" goal, so the mapping is the right choice.

### Gaps
- Whether `ExpandPath("/<mapping>/...")` resolves through ColdFusion mappings on 6.1 (which would allow deriving physical paths from the mapping instead of from index.cfm) was not read in the ExpandPath entry.
- Whether a mapping can be created programmatically on 6.1 (ServiceFactory or the Administrator API) so setup could be scripted was not researched; the brief says the owner adds it by hand.
- How ColdFusion caches resolved CFC paths (the "trusted cache" option) and what that means for development reloads was not found in the manual text search ("Trusted cache" had zero matches in REF and DEV; ADM was not searched for it).

## Vendor and packages: what does Composer's vendor folder provide, what does CodeIgniter itself bundle, and what are the options for vendor-type packages in CFML on 6.1?

### Takeaway
CodeIgniter 4.7.6 itself has only two runtime third-party packages (Laminas Escaper and PSR Log) and it bundles both, plus Kint for debugging, inside `system/ThirdParty` with a classmap, so a no-Composer install already exists as a model. For the CFML port the most faithful and workable scheme is a checked-in `vendor/` folder of CFC packages resolved through the same prefix map as `app` and `system`, described by a small manifest; Java JARs are a strong second source of libraries, limited to Java 1.4-compatible builds.

### Cited Findings
- Runtime requirements: php ^8.2, ext-intl, ext-mbstring, laminas/laminas-escaper ^2.18, psr/log ^3.0. Dev requirements include kint-php/kint ^6.1, fakerphp/faker ^1.24, phpunit/phpunit ^10.5.16 || ^11.2, mikey179/vfsstream, predis/predis, phpstan, rector. — CI:composer.json
- `system/ThirdParty` contains Escaper, Kint, PSR/Log. — directory listing of CI:system/ThirdParty/
- The core classmap maps the PSR Log and Escaper class names to files in system/ThirdParty, so they load without Composer. — CI:system/Config/AutoloadConfig.php lines 95-124
- COMPOSER_PATH is `ROOTPATH . 'vendor/autoload.php'`; the Autoloader has `loadComposerAutoloader`. — CI:app/Config/Constants.php; CI:system/Autoloader/Autoloader.php
- `app/ThirdParty/` exists (empty) for "ThirdParty libraries that can be used in application". — CI:user_guide_src/source/concepts/structure.rst line 45
- app/Config/Autoload.php offers `$psr4`, `$classmap` and `$files` for registering extra code. — CI:app/Config/Autoload.php
- With Composer, the framework itself lives at `vendor/codeigniter4/framework/system`. — CI:user_guide_src/source/concepts/structure.rst lines 61-62
- **[MANUAL]** Java class search order: JARs in `web_root/WEB-INF/lib` and classes in `web_root/WEB-INF/classes` (reloaded dynamically when the time stamp changes), then the Administrator class path, then the JVM class path (loaded once per server lifetime). — DEV pp.737-738
- **[MANUAL]** Administrator Java and JVM page: JVM path (default cf_root/runtime/jre) and Class Path (directories containing JARs or JAR file names, comma separated). — ADM p.25
- **[MANUAL]** `CreateObject("java", class)` for any class on the class path. — REF p.428
- **[MANUAL]** JVM is Sun 1.4.2. — INS p.12
- **[MANUAL]** Custom tag paths are configured in the Administrator; CFX tags can be C++ DLLs or Java classes. — ADM p.33
- **[MANUAL]** cfmodule `name` uses dot notation under the custom tag root; `template` takes a relative or mapped path. — REF p.250
- **[MANUAL]** cfimport `taglib` can be a directory of CFML custom tags (relative to web root, current page or a mapping) or a JSP tag library; it must appear on each page that uses the tags. — REF pp.190-191
- **[MANUAL]** JSP tag library import is an Enterprise (and Developer) edition feature. — INS pp.9-10
- **[MANUAL]** CFCs are found through mappings and custom tag paths. — DEV p.224
- Java class-file major versions: 1.4 = 48, 5 = 49, 6 = 50, 8 = 52. — https://en.wikipedia.org/wiki/Java_class_file
- **[PERIOD]** CFLib.org is a library of open source UDFs "for ColdFusion 5.0 and higher", started in 2001 by Raymond Camden and Rob Brooks-Bilson. — https://raymondcamden.com/2007/01/18/CFLib-hits-1000 ; https://www.raymondcamden.com/2004/02/18/C91C1337-FE36-73E9-1BCAD6C67B182B26 ; site now at https://cflib.netlify.app
- **[PERIOD]** RIAForge (open source ColdFusion project hosting) was decommissioned by Adobe; some projects survive elsewhere. — https://coldfusion.adobe.com/2019/01/riaforge-decommissioning/ ; https://www.raymondcamden.com/2015/10/25/status-of-riaforge
- **[PERIOD]** Frameworks of the era were distributed as a folder to drop in the web root or behind a mapping (Mach-II, Model-Glue). — https://github-wiki-see.page/m/Mach-II/Mach-II-Framework/wiki/How-Do-I-Install-Mach-II%3F ; https://groups.google.com/g/model-glue/c/t0BwnLOHgjU
- Modern CFML packaging: CommandBox's `box.json` descriptor has name, slug, version, type, dependencies, devDependencies, installPaths, ignore and a testbox block; dependencies map a slug to a ForgeBox version, local path, URL or Git endpoint. — https://commandbox.ortusbooks.com/package-management/box-json.md

### Inferences
Six options, all **[INFERENCE]** assessments built on the findings above:

1. **Checked-in `vendor/` folder of CFC packages, resolved by the prefix map (recommended).** Layout `vendor/<vendor>/<package>/...` under the repository root, the same shape Composer produces. Since the single mapping points at the repository root, any vendor CFC is `<mapping>.vendor.<vendor>.<package>.<Class>` with no further Administrator work. Register a short prefix per package in `app/Config/Autoload.cfc` (`psr4`), exactly as CodeIgniter registers namespaces. Caveat: directory names become part of dotted component paths, so vendor and package folder names must not contain hyphens or dots; use underscores or camel case. Trade-off: no dependency solver, updates are manual copies; in exchange it works on a stock 6.1 server and mirrors the PHP layout.
2. **`system/ThirdParty` and `app/ThirdParty` bundling.** Exactly what CodeIgniter does for Escaper, PSR Log and Kint: copy the library into the tree and list it in the classmap. Best for the handful of things the framework itself needs (an escaper, a logger contract, a debug dumper). Use this for framework-internal dependencies and option 1 for application-level ones.
3. **Java JARs.** The richest source of ready-made functionality (regex, collections, crypto, zip, XML, HTTP clients). Placement: `WEB-INF/lib` under the web root (auto-reloading, but that means under `public/`, DEV pp.737-738) or the Administrator class path (ADM p.25, needs a restart to pick up changes). Hard limit: libraries must be compiled for Java 1.4 or older (class version 48 or below). Trade-off: placing JARs is a server-level act, not a repository-level one, so it is less self-contained than CFC code; a `vendor/java/` folder in the repository plus one class path entry pointing at it keeps the files in version control.
4. **Custom tag libraries (cfmodule / cfimport / custom tag paths).** Fits presentation helpers (form widgets, layout sections, pagination). A vendor tag library can be imported with `<cfimport taglib="/<mapping>/vendor/x/tags" prefix="x">`; the import must be repeated on every page (REF p.191). Not suitable for general class libraries.
5. **UDF libraries (CFLib style).** Single `.cfm` files of functions included on demand; this is the direct twin of CodeIgniter helpers and of Composer's `autoload.files`. Good for small utilities; CFLib functions target CF 5 and later, so many should run on 6.1. Store under `vendor/` or `app/Helpers` and load through `helper()`.
6. **A manifest and a fetch script run on the development machine, not on the server.** A `vendor.json` (or a `box.json`-shaped file for familiarity) lists each package with name, version, source URL and install path; a script on the modern development machine downloads and unpacks into `vendor/`, and the result is committed or synced to the NT 4 server. This gives Composer's reproducibility without requiring anything on the 6.1 server. CommandBox itself is a modern Java tool and would run only on the development machine, never on NT 4; ForgeBox packages mostly target current engines and will rarely run unmodified on 6.1.

- **[INFERENCE]** What CodeIgniter's own bundled packages become: Laminas Escaper becomes built-in functions (HTMLEditFormat, JSStringFormat, URLEncodedFormat) plus small hand-written encoders; PSR Log becomes a documented method list (emergency, alert, critical, error, warning, notice, info, debug, log) on the Logger CFC since interfaces do not exist; Kint becomes cfdump. So the port's own core needs zero third-party code at the start.
- **[INFERENCE]** The CFML equivalent of `vendor/autoload.php` is a generated or hand-kept `vendor/autoload.cfm` that sets the prefix and classmap entries for installed packages and is cfincluded by Boot when present (mirroring COMPOSER_PATH and loadComposerAutoloader).
- **[INFERENCE]** Realistic supply: very little third-party CFML written after about 2007 will run on 6.1 (it tends to use Application.cfc, onMissingMethod, cfinterface, script components or closures, all later features). Period libraries from the 2003-2006 window and Java 1.4 JARs are the practical pool; anything else must be back-ported, so the vendor mechanism matters more for organising the project's own reusable packages than for consuming outside ones.

### Gaps
- No verified list of period CFML libraries that still exist for download and run on 6.1 was produced; RIAForge is gone and its launch date was not confirmed by my search.
- The Macromedia Developer's Exchange (the period distribution channel for tags and components) was not researched; no source fetched.
- Whether `WEB-INF/lib` under the IIS web root is the same `web_root/WEB-INF` the manual means on a server-configuration install (it may refer to `cf_root/wwwroot/WEB-INF` regardless of the IIS site root) was not resolved and must be checked on the server.
- The rule that a JVM rejects class files with a higher major version than it supports was not present on the fetched page; it is stated from general Java knowledge.
- Which specific versions of common Java libraries (for example JSON or HTTP clients) still support Java 1.4 was not researched.
- CommandBox's own Java requirement was not confirmed from its documentation.

## Testing and tooling: how does CodeIgniter test and run CLI tasks, and what can be used on 6.1?

### Takeaway
CodeIgniter relies on PHPUnit plus its own test support classes and the `spark` CLI; neither has a ready 6.1 equivalent. Modern CFML test frameworks do not support 6.1, the period ones are unmaintained and their 6.1 support is unconfirmed, so a very small home-grown test runner page, with HTTP-level checks driven from the development machine, is the dependable start.

### Cited Findings
- Dev dependencies: phpunit/phpunit ^10.5.16 || ^11.2, fakerphp/faker, mikey179/vfsstream, kint, phpstan, rector. — CI:composer.json
- `tests/` has `_support` and `system`; `system/Test` holds the framework's test helpers; Boot has `bootTest`. — directory listing of CI:tests/ and CI:system/; CI:system/Boot.php
- `spark` is the CLI entry point (Boot::bootSpark, bootConsole); `system/CLI` and `system/Commands` hold the command framework. — clone root listing; CI:system/Boot.php
- Services support `injectMock`, `reset`, `resetSingle` for tests. — CI:system/Config/BaseService.php
- TestBox currently lists Adobe ColdFusion 2023+, Lucee 6+ and BoxLang; version 2 required ColdFusion 10+ (its xUnit compatibility in v3 mentions ColdFusion 9.01+). — https://testbox.ortusbooks.com/getting-started/installing-testbox ; https://testbox.ortusbooks.com/v2.x-1/introduction/overview/system-requirements
- MXUnit: "A test framework for CFML (ColdFusion)"; the README excerpt gives no minimum version; mailing list threads discuss ColdFusion 7 compatibility fixes between 2.1.0 and 2.1.1. — https://github.com/mxunit/mxunit ; https://groups.google.com/g/mxunit/c/KT0D2M6SaGE
- CFUnit: open source, modelled on JUnit, no longer supported by its creators, whose page recommends MXUnit; required ColdFusion version not stated on the page. — https://cfunit.sourceforge.net/
- ColdUnit: unit testing for ColdFusion 5 and MX, installed into CustomTags. — https://coldunit.sourceforge.net/
- CFTestingKit: tutorial states ColdFusion MX and BlueDragon Server 6.1. — https://cftestingkit.sourceforge.net/tutorial01.html
- cfcUnit: a 2007 user group talk describes it as strong at exhaustively testing CFC methods; no version requirements found. — https://www.bennadel.com/blog/1036-john-mason-presents-on-unit-testing-with-cfcunit.htm
- **[MANUAL]** cfhttp, cfexecute, cfschedule, cflog, cfdump, GetTickCount exist on 6.1. — REF entries
- **[MANUAL]** cftry/cfcatch with typed, hierarchical exceptions. — DEV p.308
- **[MANUAL]** GetMetaData lists a component's functions. — REF, GetMetaData entry
- **[MANUAL]** Developer edition includes every Enterprise feature with limits. — INS pp.9-10

### Inferences
- **[INFERENCE]** TestBox is ruled out on 6.1 (its oldest documented floor is ColdFusion 9/10). MXUnit most likely needs ColdFusion 7 or later given the compatibility discussion, but that is not confirmed; treat it as unusable until proven on the server.
- **[INFERENCE]** Minimal xUnit in roughly one CFC: `tests/_support/TestCase.cfc` with `assertEquals`, `assertTrue`, `assertThrows`-style helpers that cfthrow type `Test.AssertionFailed`; `tests/run.cfm` uses cfdirectory to find `*Test.cfc`, GetMetaData to list functions whose names start with `test`, cfinvoke inside cftry for each, and prints a plain pass/fail table. Because `tests/` is outside the web root, a thin `public/tests.cfm` (enabled only when ENVIRONMENT is `testing` or `development`) includes it.
- **[INFERENCE]** HTTP-level tests from the development machine (a script requesting URLs on the test server and comparing status, headers and body) exercise the real IIS 4 plus rewrite plus PATH_INFO path that unit tests cannot, and need nothing installed on NT 4. This is the closest stand-in for CodeIgniter's FeatureTestTrait.
- **[INFERENCE]** `spark`: no CLI runner for CFML exists on 6.1. Options are (a) web-invoked command pages under a protected URL (`index.cfm/spark/routes`), (b) a batch file calling such URLs through a command-line HTTP client or cfschedule for recurring tasks. `spark routes` (list the route table) is the most useful early command because it doubles as a routing debug page.
- **[INFERENCE]** Debugging: cfdump replaces Kint and `dd()`; cflog replaces the file logger initially; the Administrator's debug output replaces part of the debug toolbar.
- **[INFERENCE]** Static analysis and refactoring tools (phpstan, rector) have no counterpart for 6.1 CFML; a syntax check is simply requesting every page once, which the test runner can do.

### Gaps
- No primary source for cfcUnit's requirements or a working download was found; CFUnit's minimum ColdFusion version is not stated on its page.
- MXUnit's true minimum ColdFusion version was not found in an official statement.
- Whether any of the period frameworks' downloads are still retrievable was not tested.
- How deploy/sync from the development machine to the NT 4 server will run tests automatically was outside this research.
- `system/Test` classes (FeatureTestTrait, ControllerTestTrait, Fabricator, mocks) were not read.

## Recommended first slices: in what order should the port be built, in small steps?

### Takeaway
Start with a proof that the mapping, CFC resolution and inheritance behave as the manual says, then grow a thin vertical slice in CodeIgniter's own boot order (index, Paths, Boot, Common, Services, Routes, Router, Controller, View, Response) and only afterwards widen into filters, config overlay, events, errors, helpers, database and vendor packages. Each slice ends at something visible in a browser.

### Cited Findings
- CodeIgniter's own dependency order at boot: Paths, path constants, Constants, DotEnv, environment, Common functions, Autoloader, Services, CodeIgniter::run. — CI:system/Boot.php lines 42-75
- The smallest shipped application is one route (`$routes->get('/', 'Home::index')`), one controller (Home) returning `view('welcome_message')`, and one view. — CI:app/Config/Routes.php; CI:app/Controllers/Home.php; CI:app/Views/welcome_message.php
- The request path through run/handleRequest names the minimum collaborating classes: Request, Response, RouteCollection, Router, Filters, Controller, View. — CI:system/CodeIgniter.php from lines 329 and 456
- **[MANUAL]** Manual statements that need verification on the actual server because the design depends on them: CFC search order through mappings (DEV p.224); This scope not available in a base component (DEV p.242, p.245); Super limited to one level (DEV p.246); var declarations at the top of functions (DEV p.244); Application.cfm lookup (DEV p.271); cfinclude path rules (REF p.192).
- **[MANUAL]** Application-scope data needs cflock. — DEV p.331
- The owner's stated preferences: use CFCs often, start slowly, mirror CodeIgniter functionality, keep the same layout, be creative about vendor packages. — Brief

### Inferences
All **[INFERENCE]**. Each slice is small enough for one sitting and leaves the site working.

0. **Server probes (no framework code).** A throwaway folder with five or six tiny pages answering: does `CreateObject("component", "<mapping>.system.Probe")` resolve; does a parent CFC's `init()` see and return the child's `This`; do functions in a cfincluded file become methods of the including CFC; is a function's `var` visible in a page it includes; does `argumentCollection` with keys `1`, `2` fill positional arguments; what exactly are CGI.PATH_INFO and CGI.SCRIPT_NAME for `/`, `/index.cfm`, `/index.cfm/a/b`, and a rewritten `/a/b`; does cfqueryparam work inside cfloop in a cfquery; does a java.util.LinkedHashMap keep order under cfloop collection. Record the answers in the notes folder; several design choices above flip on them.
1. **Skeleton and front controller.** Create the tree (app, public, system, tests, writable, vendor). `public/Application.cfm` (cfapplication only), `public/index.cfm` computing FCPATH, creating `app/Config/Paths.cfc`, and printing the resolved paths. Proves layout plus mapping.
2. **Boot and constants.** `system/Boot.cfc` with `bootWeb(paths)`: path values into the Request scope, `app/Config/Constants.cfm`, ENVIRONMENT (hard-coded default, no .env yet), `app/Config/Boot/<env>.cfm`.
3. **Common functions and the class resolver.** `system/Common.cfm` with the tag wrappers (`throw`, `invoke`, `include`), `service()`, `config()`, and the prefix-map resolver plus `new()` factory; `app/Common.cfm` empty; `app/Config/Autoload.cfc` and `system/Config/AutoloadConfig.cfc`.
4. **Services.** `system/Config/BaseService.cfc`, `system/Config/Services.cfc` with only the services needed so far, `app/Config/Services.cfc` extending it. `service("codeigniter")` returns a stub whose `run()` prints a line.
5. **Request, URI and Response.** `system/HTTP/IncomingRequest.cfc` (method, path from PATH_INFO with script name stripped, getGet/getPost/getHeader), minimal `URI`, `Response.cfc` (setStatusCode, setHeader, setBody, send). `run()` now sends a hard-coded Response through cfheader and output.
6. **Routes and Router.** `system/Router/RouteCollection.cfc` with `get`, `post`, `add`, `match` and placeholders; `app/Config/Routes.cfm` with the single home route; `system/Router/Router.cfc` `handle(uri)` returning controller and method names and params; PageNotFoundException as a typed cfthrow.
7. **Controller dispatch.** `system/Controller.cfc`, `app/Controllers/BaseController.cfc`, `app/Controllers/Home.cfc`; `CodeIgniter.cfc` gains tryToRouteIt, startController, createController, runController, gatherOutput (cfsavecontent plus return value). `Home.index` returns a string. First real end-to-end page.
8. **Views.** `system/View/View.cfc`, the `view()` function, `app/Views/welcome_message.cfm`. The stock welcome page now renders through the full pipeline, which is the same milestone as a fresh CodeIgniter install.
9. **Errors.** Exception handling in `run()`: 404 view for PageNotFoundException, a development error page with cfcatch details when CI_DEBUG is set, production error view otherwise; cferror in Application.cfm as the last resort.
10. **Config overlay and .env.** `system/Config/BaseConfig.cfc`, `DotEnv.cfc`, `Factories.cfc`; move ENVIRONMENT, baseURL and indexPage to real config.
11. **Filters.** `system/Filters/Filters.cfc`, `app/Config/Filters.cfc`, before/after execution with short-circuit, one simple shipped filter (for example SecureHeaders or ForceHTTPS) as proof.
12. **Events.** `system/Events/Events.cfc` with named-handler listeners; trigger `pre_system`, `post_controller_constructor`, `post_system` at the same points as CodeIgniter.
13. **Helpers.** `helper()` loader and the url helper first (`site_url`, `base_url`, `current_url`, `redirect()` with RedirectResponse), then form and html as needed.
14. **Tests.** The minimal TestCase and runner; back-fill tests for Router and RouteCollection first, since they are pure logic.
15. **Database and Model.** Connection wrapper around cfquery with bound parameters, then a minimal Model; query builder much later.
16. **Vendor mechanism.** `vendor/` layout, `vendor/autoload.cfm`, the manifest and the development-machine fetch script; move one of the port's own reusable pieces into a package to prove it.
17. **Later, in any order.** Session, validation, logger with file handlers, caching, Application-scope caching of routes and config with cflock and a reload switch, route groups and resources, reverse routing, layouts and view cells, CSRF, a `spark`-like command page, pagination.

- **[INFERENCE]** Rule for every slice: open the matching PHP file in the clone, port the public method names and argument order unchanged, leave unported methods as stubs that cfthrow "not implemented", and note any deliberate deviation (no closures, no null, ordered arrays instead of maps) in a comment at the top of the CFC. That keeps the port diffable against CodeIgniter upgrades.
- **[INFERENCE]** Keep everything in the Request scope until slice 17; it removes locking from the first sixteen slices and matches PHP's per-request model, so behaviour differences from CodeIgniter stay minimal while the structure settles.

### Gaps
- Performance of creating dozens of CFC instances per request on the NT 4 hardware is unknown; if slice 8 is visibly slow, Application-scope caching moves earlier.
- The probe results from slice 0 do not exist yet; until they do, the items marked as needing a server test throughout these notes remain open.
- Session, validation, model and CLI internals of CodeIgniter were not read, so the ordering of slice 17 items is a guess based on typical application needs.
