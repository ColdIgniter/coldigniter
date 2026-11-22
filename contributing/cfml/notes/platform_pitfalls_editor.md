# ColdFusion MX 6.1 platform, pitfalls and VS Code editing (state at 2026-11-22)

Source conventions used below.

- "Install p. N" = *Installing and Using ColdFusion MX* (6.1), local text copy `cfmx_6.1_docs_en/text/cfmx61_install.txt`.
- "Admin p. N" = *Configuring and Administering ColdFusion MX* (6.1), `cfmx61_config_admin.txt`.
- "Dev p. N" = *Developing ColdFusion MX Applications* (6.1), `cfmx61_dev_cf_apps.txt`.
- "Ref p. N" = *CFML Reference* (6.1), `cfmx61_cfml_reference.txt`. "Ref, entry X" means the entry was read but its page number was not captured.
- All four manuals describe MX 6.1 itself. Web sources are labelled with the version and web server they describe; most are NOT about 6.1 on IIS 4.
- Registry data (Marketplace, Open VSX, GitHub) was retrieved through their public APIs on 2026-11-22.
- "UNCONFIRMED" marks a statement that no source read in this research supports directly.

---

## 1. What is build 6,1,0,63958, and what did the Updater and hot fixes change?

### Takeaway
6,1,0,63958 is the original ColdFusion MX 6.1 release build. The reported number does not prove the absence of the 6.1 Updater or hot fixes, because 6.1 keeps reporting the original number; check for a `cumulative_hotfix_bkup` directory instead.

### Cited Findings
- Adobe's TechNote "ColdFusion MX: Determining version information" lists 6,1,0,63958 for ColdFusion MX 6.1 and 6,1,0,83762 for ColdFusion MX 6.1 Updater; it says a 6.1 installation "will display the original version number, 6,1,0,63958", that the updater can be detected by a `\cumulative_hotfix_bkup` directory in the install folder, and that `cfinfo -version` does not show hot fixes. Read only as a search-result summary; the page itself returned HTTP 403 to the fetch tool. — [Adobe TechNote](https://helpx.adobe.com/coldfusion/kb/coldfusion-mx-determining-version-information.html)
- The 6.1 Updater was announced on 2004-08-24 (a forum page gives the release date as 2004-08-25). It bundles JRun Updater 3 (server configuration only), new DataDirect JDBC driver releases, JIntegra COM updates, security fixes through July 2004, "over 60" ColdFusion bug fixes, and all 6.1 hot fixes and security patches released to that date. Original link: `http://www.macromedia.com/support/coldfusion/ts/documents/cfmx61_updater.htm`. — [Forta blog mirror](https://fortacom.vercel.app/blog/coldfusion-mx-6-1-updater-available); [Adobe community thread](https://community.adobe.com/questions-582/coldfusion-mx6-0-to-mx6-1-updater-278832)
- Comments on that post: the updater must be installed once per instance on multi-instance installs; one user saw the old hot fix version string until a hot fix entry was removed from web.xml; by the time of later comments the download links returned 404. — [Forta blog mirror](https://fortacom.vercel.app/blog/coldfusion-mx-6-1-updater-available)
- Installing 6.1 over MX 6.0 acts as an updater and preserves settings. — Install p. 8
- Security bulletins that name 6.1 (from third-party archives, not Macromedia's pages): MPSB04-02 (form fields denial of service), MPSB04-06 (2004-04-15, denial of service from repeatedly interrupted file uploads), MPSB04-09 (September 2004 cumulative security patch), MPSB05-02 (2005-04-07, file disclosure in 6.1 Updater 1 for JRun 4 J2EE configuration), MPSB05-12 (Secunia SA18078; 6.0, 6.1 and 6.1 with JRun affected, hot fix for 6.1). — [seclists Bugtraq 2004-04](https://seclists.org/bugtraq/2004/Apr/190); [seclists Bugtraq 2004-09](https://seclists.org/bugtraq/2004/Sep/347); [seclists Bugtraq 2005-04](https://seclists.org/bugtraq/2005/Apr/110); [Packet Storm, Secunia SA18078](https://packetstormsecurity.com/files/42371/Secunia-Security-Advisory-18078.html)

### Inferences
- A server reporting 63958 may or may not have the Updater; look for `C:\CFusionMX\cumulative_hotfix_bkup` and for hot fix JARs before assuming base behaviour.
- A base 6.1 server lacks more than 60 fixes plus JRun Updater 3, so the port should be tested on the real server rather than assumed correct from documentation.

### Gaps
- The Updater release notes (the itemised fix list, in particular CFC, template cache, memory leak and connector fixes) could not be read: web.archive.org is blocked for the fetch tool and helpx.adobe.com returned 403. Which fixes matter for CFC-heavy code is therefore unanswered.
- Whether the Updater or 6.1 hot fixes are still downloadable in 2026 is unconfirmed; the only evidence is old comments reporting 404s.
- The exact contents of each MPSB bulletin were not read from a primary source.

---

## 2. Architecture: JRun 4, JVM, editions, disk layout, compilation and the FTP development loop

### Takeaway
MX 6.1 server configuration is one ColdFusion instance on an embedded JRun 4 with a bundled Sun 1.4.2 JVM; every CFML file is compiled to Java bytecode on first request and cached. With Trusted cache off the server checks source files for change, so an FTP push is picked up on the next request; with it on, nothing is picked up until the cache is cleared or the service restarts.

### Cited Findings
- Server configuration = one ColdFusion instance with an embedded copy of JRun; J2EE configuration is available in Enterprise and Developer only. — Install p. 8
- "ColdFusion MX 6.1 ships with the Sun 1.4.2 JVM"; supported Sun JDK/JRE is 1.3.1 or later. — Install p. 11 to 12
- Windows NT 4.0 Workstation and Server SP6A are supported for all editions; IIS 4.0, 5.x and 6 are supported; NT 4 needs MDAC 2.6 SP2 and the Visual C++ 6.0 runtime; minimum RAM 128 MB (Developer) or 256 MB (Standard/Enterprise). — Install p. 11 to 12
- Editions: Developer is free, accepts requests from localhost and one remote IP address, and has Enterprise features except ClusterCATS (10K Verity limit); Trial reverts to Developer after 30 days. Standard has ODBC to desktop databases plus Type 4 drivers for SQL Server and MySQL, resource security, 125K Verity. Enterprise adds Type 4 drivers for Oracle, DB2, Sybase and Informix, JSP and tag library import, server sandbox security, multiple instances, backup mail servers and multithreaded mail delivery. — Install p. 9 to 10
- Default `cf_root` is `C:\CFusionMX`; the built-in web server listens on port 8500 with web root `C:\CFusionMX\wwwroot`. — Install around p. 21
- Directories under cf_root: `bin`, `cache`, `cfx`, `charting`, `CustomTags`, `db`, `jintegra`, `lib` (JARs, XML, properties), `logs` (JRE-specific logs in `runtime\logs`), `Mail` (spool, undeliverable), `META-INF`, `runtime` (bundled JRE in `runtime\jre`), `wwwroot`. With an external web server `wwwroot` holds only `WEB-INF` and must not be removed. — Install p. 26 to 27
- `jrun.xml` is in `cf_root\runtime\servers\default\SERVER-INF` and defines the WebService (port 8500) and the ProxyService used by the connector. `web.xml` is in `cf_root\wwwroot\WEB-INF`; `default-web.xml` is in `runtime/servers/default/SERVER-INF`. — Install p. 27 to 28, 62 to 63
- J2EE configuration layout has `WEB-INF/cfclasses`, `WEB-INF/cfc-skeletons`, `WEB-INF/cftags`, `WEB-INF/cfusion/lib`. — Install, J2EE layout section
- Caching page settings: template cache size is a number of templates (suggested start: one page per MB of JVM heap); Trusted cache makes the server use cached templates without checking for change; Save Class Files writes classes to disk (the manual says to disable it in development); Cache web server paths should be deselected with multiple web sites. — Admin p. 19
- The first request after a change compiles the page to Java bytecode, so timings drop on the second request. — Dev around p. 394
- Java and JVM page edits `cf_root/runtime/bin/jvm.config` (backup `jvm.bak`); maximum heap default is 512 MB; class path entries are comma separated; the page does not exist in J2EE configuration. The manual prints the initial heap default as "8196 MB", an evident misprint. — Admin p. 25
- From 6.1 onward ColdFusion generates class files directly with the BCEL library instead of generating Java source (newsgroup report, anecdotal; the stack trace shown is `org.apache.bcel.generic.ClassGenException`). — [macromedia.coldfusion.advanced_techniques thread](https://groups.google.com/g/macromedia.coldfusion.advanced_techniques/c/rZsfM0TPn8c)
- Later-version descriptions of the same mechanism: with trusted cache on "the server will never ever touch your disk to check for recompilation"; a loaded class is used directly, and timestamps are compared only when trusted cache is off; the reliable fix is to push files, then clear the template cache, and adding whitespace does not help. These describe ColdFusion 8 and later, not 6.1. — [Adobe community thread](https://community.adobe.com/t5/coldfusion-discussions/coldfusion-class-loading-and-code-file-access/m-p/241094); [Ben Nadel 2007](https://www.bennadel.com/blog/673-force-coldfusion-server-to-recompile-a-coldfusion-template.htm)

### Inferences
- For an FTP loop: keep Trusted cache off and Save Class Files off on the development server. Change detection is by file timestamp (later-version sources), so an FTP client that preserves an older modification time, or a server clock ahead of the upload time, could leave a stale class; UNCONFIRMED for 6.1.
- If stale behaviour is seen: restart the "ColdFusion MX Application Server" service, and if Save Class Files was on, delete the saved classes first. The server-configuration location of saved classes is UNCONFIRMED (the manual only shows `WEB-INF/cfclasses` for J2EE layout; `C:\CFusionMX\wwwroot\WEB-INF\cfclasses` is the expected equivalent).
- A restart is also needed after editing `web.xml`, `jvm.config` or `jrun.xml`, since these are read at startup (stated for web.xml by the SES sources in section 4).

### Gaps
- Whether the 6.1 Administrator has a "Clear Template Cache Now" button was not confirmed in the 6.1 Admin manual (Admin p. 19 lists only the four caching settings above). Later versions have one.
- File time resolution on NTFS/FAT versus FTP timestamps, and whether 6.1 compares "newer than" or "different from", were not found.
- JRun 4 build and thread pool defaults were not researched.

---

## 3. Administrator settings that affect a framework

### Takeaway
The settings a framework most depends on are mappings (documented only for cfinclude and cfmodule), request timeout, whitespace management, HTTP status codes, the two server-wide handlers, session/client storage and the debugging switches. All are server-wide in 6.1; there is no per-application equivalent.

### Cited Findings
- Settings page: limit simultaneous requests; "Timeout requests after [n] seconds"; "Use UUID for cftoken"; "Enable HTTP status codes" (returns 500 for unhandled errors; otherwise every response is 200); "Enable Whitespace Management" (server configuration only). — Admin p. 18
- Missing Template Handler and Site-wide Error Handler paths are relative to the web root. Internet Explorer replaces error pages of 512 bytes or fewer with its "friendly" page. — Admin p. 19
- Client variables: database (CDATA and CGLOBAL tables), cookies (4 KB limit, three cookies used) or registry (Macromedia recommends against the registry). — Admin p. 20
- Application variables default timeout is two days; "Use J2EE session variables" is an option; mappings are described as applying to cfinclude and cfmodule. — Admin p. 22
- Mail is spooled to disk and sent on a spool interval; backup servers, maintained connections, delivery threads and in-memory spooling are Enterprise only; logs are `mail.log` and `mailsent.log`. — Admin p. 23 to 24
- Debugging settings: robust exception information, `classic.cfm` or `dockable.cfm` output format, stack trace depth, database activity, exceptions, tracing, variables. With no debugging IP addresses listed, debugging output is shown to all users. — Admin p. 28 to 30
- Sandbox security is called Resource Security in Standard (single sandbox); Enterprise has multiple sandboxes; it is not enabled by default. — Admin p. 35, 70
- Drivers: DB2 (Type 4), Informix 9.x (4), Microsoft Access (Type 3, ODBC socket), Microsoft Access with Unicode (Type 2), SQL Server 7.x/2000 (4), MySQL (4), ODBC Socket (3), Oracle 8.1.7/9i (4), Sybase (4), Other. Reserved data source names: `service`, `jms_provider`, `comp`, `jms`. — Admin p. 38 to 39
- `cfsetting requestTimeOut` replaces the old URL parameter; `enableCFoutputOnly` calls nest. — Ref, entry cfsetting
- RDS is disabled by commenting out the RDSServlet servlet-mapping in web.xml. — Install p. 62 to 63

### Inferences
- A framework that needs its own status codes (404, 500) should set them with cfheader; "Enable HTTP status codes" only governs unhandled errors.
- Keep framework error pages above 512 bytes so Internet Explorer shows them.
- Debugging output is appended to every response when enabled and no IP list is set, which will corrupt non-HTML output; a framework should call `cfsetting showDebugOutput="no"` for such responses. UNCONFIRMED that this attribute fully suppresses output in 6.1 (attribute not re-read in the reference).

### Gaps
- Whether Administrator mappings also resolve CFC paths (CreateObject, cfinvoke, extends) in 6.1: Admin p. 22 names only cfinclude and cfmodule. Not confirmed either way; the CFC researcher should settle it.
- The cost of debugging with CFCs (reported to be severe in later versions) was not sourced for 6.1.

---

## 4. IIS connector behaviour and URLs of the form index.cfm/a/b

### Takeaway
The connector is `jrun.dll`, installed as an ISAPI filter plus extension mappings, forwarding to the JRun proxy service. `index.cfm/a/b` URLs need two things on MX-era IIS: a servlet mapping in `web.xml` that accepts trailing path info, and "Check that file exists" unchecked on the IIS mapping. The exact mapping pattern for 6.1 is not confirmed by a primary source.

### Cited Findings
- The connector opens a network connection to the JRun proxy service; on IIS it adds an ISAPI filter and extension mappings at global or site level; `jrun.dll` serves IIS 4 and 5; it logs to its own log in the wsconfig subdirectory when `verbose=true`. — Admin p. 59 to 64
- Typical `jrun.ini`: `verbose=false`, `scriptpath=/JRunScripts/jrun.dll`, `serverstore=C:/CFusionMX/runtime/lib/wsconfig/1/jrunserver.store`, `bootstrap=127.0.0.1:51010`, `apialloc=false`, `ssl=false`, `ignoresuffixmap=true`, optional `errorurl`. `-filter-prefix-only` sets `ignoresuffixmap=true` so the module runs as an IIS extension. — Admin p. 59 to 64
- Verify after configuration: `cf_root\runtime\lib\wsconfig\jrun.dll`, application mappings for `.cfm`, `.cfml`, `.cfc`, `.jsp`, `.jws`, and a `JRunScripts` virtual directory in each site pointing to `wsconfig\number` (typically 1). Omitting "Configure web server for ColdFusion MX applications" makes the web server serve CFML source. — Install p. 54 to 55
- SES URLs, MX 6.0 on IIS (2003-04-17; mentions MX Updater 3; not 6.1): edit `cfusionmx\wwwroot\WEB-INF\web.xml` and add a CfmServlet mapping with `<url-pattern>.cfm*</url-pattern>`, said to ship by default with Updater 3; fall back to `<url-pattern>*</url-pattern>`; in IIS, Home Directory, Configuration, edit the `jrun.dll` mapping and uncheck "Check that file exists" (otherwise IIS looks for a file named with the extra path); restart W3SVC and the ColdFusion service; if needed run `Remove_ALL_connectors.bat` then `IIS_connector.bat` in `cfusionmx\bin\connectors`. — [pengoworks 2003](https://blog.pengoworks.com/index.cfm/2003/4/17/Search-Friendly-URLs-with-CFMXIIS)
- MX 6.0 (2002-10-25): SES URLs "break when ColdFusion MX is installed"; the fix is a servlet mapping for CfmServlet in web.xml and a restart. The post's XML was not recoverable. — [Forta 2002](https://forta.com/blog/search-engine-friendly-urls)
- Later versions commonly use `<url-pattern>*.cfm/*</url-pattern>` (a non-standard pattern accepted by JRun; reported not accepted by plain Tomcat). Found only as a search summary of a 2010 thread and a ColdBox list thread; not confirmed for 6.1. — [ColdBox list](https://groups.google.com/g/coldbox/c/VNqqiC9Lba8)
- CGI values on IIS (2007-07-18; ColdFusion version not stated, probably 8; not 6.1): with no extra path, `CGI.PATH_INFO` equals `CGI.SCRIPT_NAME`; for `test.cfm/images/sexy.jpg?download=true`, `SCRIPT_NAME` is the script path and `PATH_INFO` is `/images/sexy.jpg`. Relative links in the page resolve against the extra path, so assets need absolute URLs. — [Ben Nadel 2007](https://www.bennadel.com/blog/838-exploring-path-info-and-how-it-interacts-with-coldfusion-and-the-browser.htm)
- An Adobe forum reply says the old behaviour of putting the script path in PATH_INFO was treated as a bug and changed in ColdFusion 10. — [Adobe community](https://community.adobe.com/questions-582/cf9-to-cf10-upgrade-default-page-in-a-loop-266677)
- The CFML Reference lists the CGI variables with generic CGI 1.1 definitions only; nothing IIS specific. — Ref, CGI variables section
- `GetHttpRequestData()` returns a structure with `content` (string when the Content-Type starts with `text/` or is `application/x-www-form-urlencoded`, otherwise binary), `headers`, `method` and `protocol`. — Ref p. 491
- After `cfflush`: cfheader and cfcontent throw an error, a cookie set afterwards is not sent, cflocation has no effect, and cfform, cfhtmlhead and SetLocale misbehave. — Ref, entries cfflush, cfcookie (p. 91 to 92), cflocation
- cfcookie attributes are only `name`, `value`, `expires`, `secure`, `path`, `domain`; cookie names are upper-cased. — Ref p. 91 to 92
- A grep of all local 6.1 manuals found no mention of a `*.cfm/*` mapping or search-engine-safe URLs. — negative finding, local manuals

### Inferences
- A router should compute the route defensively: if `CGI.PATH_INFO` equals `CGI.SCRIPT_NAME` (or starts with it), strip the script name; treat the remainder as the route. This covers both IIS behaviours described above.
- HttpOnly and SameSite cookies cannot be set with cfcookie in 6.1; they need a hand-built `Set-Cookie` header through cfheader. Whether IIS 4 or the connector alters such headers is UNCONFIRMED.
- Supporting PUT, DELETE or PATCH through IIS 4 is doubtful; a `_method` form field override on POST is the safe design. UNCONFIRMED.

### Gaps
- The correct url-pattern for 6.1 build 63958 (`.cfm*`, `*.cfm/*` or already present in the shipped web.xml) must be read from the server's own `C:\CFusionMX\wwwroot\WEB-INF\web.xml`; no primary source found.
- No source found for: which HTTP methods IIS 4 and the connector pass through; request body or upload size limits; whether IIS 4 replaces error response bodies (custom errors); default document handling for `/` with CFML; HTTP/1.0 versus 1.1 and chunked output with cfflush through the connector.

---

## 5. Character encoding

### Takeaway
ColdFusion MX is Unicode internally and sends UTF-8 by default, but a source file without a BOM is read in the operating system's default encoding. For files edited on Linux and pushed by FTP, either keep source ASCII-only or declare the encoding in every file.

### Cited Findings
- Internal representation is Java Unicode (UCS-2); the default response encoding is UTF-8, changed with `cfcontent type="text/html; charset=..."`. — Dev p. 375 to 380
- Page encoding is decided by BOM first, then `cfprocessingdirective pageEncoding` (which must agree with any BOM or an error is raised), then the JVM `file.encoding` default, which is the operating system encoding. — Dev p. 375 to 380
- `SetEncoding` sets the encoding used to interpret Form and URL scope data; the default locale is the JVM locale. — Dev p. 375 to 380
- cfmail gained a `charset` attribute in 6.1. — Ref p. 42 to 43

### Inferences
- On an English NT 4 server the fallback is expected to be Windows-1252, so a UTF-8 file without a BOM that contains non-ASCII characters would be misread. Safe choices: ASCII-only source with HTML entities, or `<cfprocessingdirective pageEncoding="utf-8">` at the top of each file, or UTF-8 with BOM.
- pageEncoding has to be declared per file (it is a compile-time directive of that file); includes and CFCs each need their own. UNCONFIRMED from the reference entry, which was not re-read.

### Gaps
- LF-only source files: no source found stating a problem or the absence of one on Windows; test on the server. FTP in ASCII mode converts line endings; binary mode does not.
- Whether a BOM in a CFC or in Application.cfm leaks into output in 6.1 was not found.
- cffile `charset` attribute behaviour was not re-read.

---

## 6. Known bugs and gotchas of the 6.1 era

### Takeaway
The documented traps are type coercion in comparisons, 32-bit integers, list functions dropping empty elements, regex differences, cflocation losing session variables, and everything forbidden after cfflush. Several well-known traps (var scoping, struct key case, short-circuiting) are not covered by a 6.1 source found here and must be verified on the server.

### Cited Findings
- Integers are 32-bit signed; larger values are kept as strings and become floating point in arithmetic (for example 1.23456789012E+020). — Dev around p. 53
- `\` is integer division ("9\4 is 2", right operand cannot be zero); `^` is exponentiation; `-1^.5` yields the string "-1.#IND". Boolean operators are NOT, AND, OR, XOR, EQV, IMP. — Dev p. 85
- List functions ignore empty elements: "1,2,,3,,4,,,5" has five elements. True, nonzero numbers and "Yes" are equivalent. — Dev p. 57
- Comparison operators convert strings to numbers or dates where possible; short strings such as "1a" and "2P" can be read as times; use `<cfif var>` rather than `IS` for Booleans. — Dev around p. 67 to 70
- `StructKeyExists` is slightly faster than `IsDefined`; `IsDefined("myArray[3]")` always returns False. — Dev around p. 78
- IsDate "checks against U.S. date formats only"; valid range 100 AD to 9999 AD. — Ref p. 531
- Regex is Perl compliant except: a period always matches newlines, replacement backreferences use `\n` not `$n`, embedded modifiers affect the whole expression, and lookbehind, `\x{hhhh}`, `\N`, `\p` and `\C` are unsupported. — Dev p. 159 to 160
- Reserved words: function names, scope names, names starting with `cf`, operators, built-in structures and variables, CFScript keywords; form field suffixes `_integer`, `_float`, `_range`, `_date`, `_time`, `_eurodate` trigger validation. — Dev p. 51
- `OnRequestEnd.cfm` does not run after an error, cfabort or cfexit; `Application.cfm` and `OnRequestEnd.cfm` capitalisation matters on Unix. — Dev around p. 271
- "If you set session variables on a CFML template that uses the cflocation tag, ColdFusion might not set the variables" (TechNote 22712). Adobe's workaround is `addToken="yes"` or a client-side redirect. — Dev p. 329; [Adobe TechNote](https://helpx.adobe.com/coldfusion/kb/missing-session-variables-using-cflocation.html) (search summary only)
- Cookies and cflocation: before MX a cookie set before cflocation was not sent; an O'Reilly *Programming ColdFusion MX* reference entry says this "is no longer the case in ColdFusion MX" and suggests cfheader for redirects otherwise. Search summary only; exact version boundary unconfirmed. — [O'Reilly, Programming ColdFusion MX](https://www.oreilly.com/library/view/programming-coldfusion-mx/0596003803/re19.html)
- cflocation appends URLToken (CFID/CFTOKEN) unless `addtoken="No"`; CFID and CFTOKEN in URLs and cookies are a hijacking risk and J2EE session variables are recommended; a J2EE session can be ended with `getPageContext().getSession().invalidate()`. — Dev around p. 322 to 329
- Locking: the manual still tells developers to lock all writes to Session, Application and Server variables and reads of data that can change; "ColdFusion MX is thread-safe and does not try to modify a variable simultaneously, it does not ensure the correct order of access"; nested lock order is Session, Application, Server; initialise shared data with a read-only check followed by an exclusive lock and a second check. — Dev p. 331 to 340
- Recursion: "If a recursive function calls itself too many times, it causes a stack overflow." No numeric limit is given. — Dev p. 212
- Java interop: ColdFusion cannot distinguish variables differing only by case; Request scope variables shared with JSP must be all-lowercase on the Java side. — Dev, chapter on integrating J2EE and Java elements (text line 33950)
- 64 KB method limit: reported as "Branch target offset too large for short" thrown from `org.apache.bcel.generic.ClassGenException`; a newsgroup poster says code that ran on CF 5 and 6.0 failed on 6.1. Causes cited in later-version threads: very long templates or functions and large cfif/cfswitch blocks; fix by splitting into more functions or included files. The JVM limit is 65535 bytes per method, with 16-bit branch offsets. — [newsgroup thread](https://groups.google.com/g/macromedia.coldfusion.advanced_techniques/c/rZsfM0TPn8c); [Adam Presley 2009](https://adampresley.github.io/2009/04/13/coldfusion-branch-target-offset-too-large-for-short.html); [Adobe community](https://community.adobe.com/questions-582/fixing-cfc-code-ideas-271450)
- Short-circuit Boolean evaluation: a 2006 post states ColdFusion skips the second operand of AND when the first is false. Version not stated; not confirmed for 6.1. — [Raymond Camden 2006](https://www.raymondcamden.com/2006/07/10/ColdFusion-and-Short-Circuit-Boolean-Evaluation)
- New in 6.1 (so present on the target): cfhttp methods HEAD, PUT, DELETE, OPTIONS, TRACE, multipart, `getasbinary`, proxyUser/proxyPassword; cfhttpparam types `header` and `body`; cfmail `charset`, `failto`, `replyTo`, `userName`, `password`, `wrapText`; cfmailpart; cfapplication `loginStorage`; cfexecute `variable`. — Ref p. 42 to 43
- cfhttp follows at most four redirects. cffile upload: only an approximate size is available beforehand, from `CGI.content_length`. — Ref, entries cfhttp and cffile

### Inferences
- A long front controller or a CFC with very large methods can hit the 64 KB limit; keep each function and each template pseudo-constructor small.
- Because list functions skip empty elements, route segment or CSV parsing must not use list functions where empty fields are meaningful.
- Version or identifier strings such as "1e3", "2P" or "0123" should be compared with `Compare()` rather than `IS`/`EQ`, given the coercion rules on Dev p. 67 to 70.

### Gaps
(Widely repeated community knowledge that no source read here confirms for 6.1; treat each as UNCONFIRMED and test.)
- Unscoped variables inside CFC methods landing in the instance's variables scope, and the resulting thread-safety problem for cached components. Only later-version sources were found ([Ortus blog](https://www.ortussolutions.com/blog/importance-of-var-scoping)). The rule that `var` declarations must come first in a function body in 6.1 was not sourced.
- Struct keys created with dot notation being stored upper-case, struct key ordering, and the case of `StructKeyList` output.
- Whitespace emitted by CFCs and the `output="false"` attribute; CFC instantiation cost; memory leaks from CFCs stored in Session.
- Floating point display, MOD with non-integers, Evaluate cost, scheduled task behaviour, cfmail and cffile upload bugs, session fixation specifics, file name case rules for CFC lookup on Unix.

---

## 7. Security features the framework must supply

### Takeaway
6.1 offers MD5-only `Hash`, an XOR-based `Encrypt`, cfqueryparam and HTMLEditFormat. Everything else (CSRF tokens, stronger hashes, HMAC, secure random values, HttpOnly cookies) has to be built, mostly by calling Java classes of the bundled 1.4.2 JVM.

### Cited Findings
- `Hash(string)` takes one argument and returns a 32-character hexadecimal MD5 digest. — Ref p. 513
- `Encrypt` uses an "XOR-based algorithm that uses a pseudo-random 32-bit key". — Ref p. 467
- `HTMLEditFormat(string [, version])` escapes special characters ("for example, < \" &") and removes returns from the string. — Ref, entry HTMLEditFormat (text line 24850)
- cfcookie has no httpOnly or sameSite attribute. — Ref p. 91 to 92
- SHA digests through Java (2005-01-25, ColdFusion version not stated): `CreateObject("java", "java.security.MessageDigest")`, then `digest.getInstance("SHA")`, `digest.digest(str.getBytes())`, and `ToBase64(result)`; the post lists algorithm names MD2, MD5, SHA-1, SHA-256, SHA-384 and SHA-512. — [Pete Freitag 2005](https://www.petefreitag.com/blog/sha-md5-digests-coldfusion/)
- HMAC through Java (later-version posts): create a `javax.crypto.spec.SecretKeySpec`, get `javax.crypto.Mac` with `getInstance("HmacSHA1")`, call `init(key)` then `doFinal(bytes)`. The built-in HMac function arrived in ColdFusion 10. — [Ben Nadel 2012](https://www.bennadel.com/blog/2412-crypto-cfc-for-hmac-sha1-hmac-sha256-and-hmac-md5-code-generation-in-coldfusion.htm); [Adobe HMac reference](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/hmac.html)
- Later Hash documentation describes a `CFMX_COMPAT` mode that reproduces the MX and MX 6.1 output, confirming that 6.1 has only the MD5 form. — [Adobe Hash reference](https://helpx.adobe.com/africa/coldfusion/cfml-reference/coldfusion-functions/functions-h-im/hash.html) (search summary only)
- Known 6.1 vulnerabilities: see the MPSB list in section 1.

### Inferences
- `str.getBytes()` with no argument uses the platform default charset; pass `"UTF-8"` so digests match other systems.
- JVM 1.4.2 includes `java.security.MessageDigest`, `javax.crypto.Mac` and `java.security.SecureRandom` (JCE became part of J2SE in 1.4). Algorithm availability on the bundled JRE (SHA-256, HmacSHA256, PBKDF2) is UNCONFIRMED and should be probed on the server inside cftry.
- No bcrypt, scrypt or built-in PBKDF2 function exists in 6.1; a salted, iterated SHA-256 or HMAC loop written in CFML over the Java classes is the realistic password option. Design choice, not sourced.
- CSRF protection, output-encoding beyond HTMLEditFormat (JavaScript, URL, attribute contexts) and input filtering must be framework code.

### Gaps
- What HTMLEditFormat does not escape in 6.1 (single quote in particular) was not confirmed from the parameter table.
- That scriptProtect arrived in version 7 was not sourced in this research.
- cfqueryparam entry (Ref p. 287 to 289) was located but not re-read for type list and null handling.

---

## 8. Debugging on 6.1

### Takeaway
Use the Administrator debugging output restricted to named IP addresses, cfdump, cftrace, cflog and GetTickCount, and read `application.log` and `exceptions.log` on the server.

### Cited Findings
- Debug output formats `classic.cfm` and `dockable.cfm`; options for robust exception information, stack trace depth, database activity, exceptions, tracing and variables; an empty IP list shows output to everyone; `cfstat` is available. — Admin p. 28 to 30
- Logs in `C:\CFusionMX\logs`: `application.log` (every error reported to a user), `exceptions.log` (stack traces), `server.log` (including slow pages), `scheduler.log`, `webserver.log`, `customtag.log`, `rdservice.log`, `car.log`, `mail.log`, `mailsent.log`, `flash.log`. JRE-specific logs are in `runtime\logs`. — Admin p. 31; Install p. 26 to 27
- `GetTickCount()` returns an internal millisecond timer; only differences between two calls are meaningful. — Ref, entry GetTickCount (text line 24532)
- cftrace is documented at Ref p. 341; cfdump, cflog and cferror have entries in the same reference. — Ref p. 341
- The connector writes its own log in the wsconfig subdirectory when `verbose=true` in `jrun.ini`. — Admin p. 59 to 64
- First request after a change includes compile time. — Dev around p. 394

### Inferences
- Reading `exceptions.log` over the same FTP channel used for deployment gives full stack traces without enabling robust exceptions for all visitors.

### Gaps
- Exact content of the 6.1 error page with and without "robust exception information", and the cfcatch keys available (tagContext and so on), were not re-read.

---

## 9. Which CFML extensions exist for VS Code in 2026?

### Takeaway
Two editor extensions matter: the original KamasamaK.vscode-cfml (unmaintained since January 2022) and its actively maintained successor CFMLEditor.cfmleditor (last Marketplace release 2026-10-23). Adobe's ColdFusion Builder extension is free and maintained but is built around modern ColdFusion servers.

### Cited Findings
All Marketplace figures: [Marketplace extension query API](https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery), search "cfml coldfusion", 2026-11-22. All Open VSX figures: [Open VSX search API](https://open-vsx.org/api/-/search?query=cfml&size=30), same date.

| Extension ID | Marketplace version, last updated | Installs | Open VSX version, date, downloads |
|---|---|---|---|
| `KamasamaK.vscode-cfml` (CFML) | 0.5.4, 2022-01-06 | 79,589 | 0.5.4, 2022-01-06, 4,927 |
| `CFMLEditor.cfmleditor` (CFML Editor) | 0.7.8, 2026-10-23 (first released 2023-12-12) | 6,579 | `cfmleditor.cfmleditor` 0.7.0, 2026-01-27, 7,117 |
| `CFMLEditor.cfmleditor-lint` | 0.7.0, 2026-01-27 | 1,740 | 0.7.0, 2026-01-27, 3,010 |
| `KamasamaK.vscode-cflint` (CFLint) | 0.3.6, 2022-04-16 | 21,328 | 0.3.6, 2022-04-16, 2,514 |
| `com-adobe-coldfusion.adobe-cfml-lsp` (Adobe ColdFusion Builder) | 1.0.880, 2026-10-09 (first released 2022-07-29), rating 2.52 | 24,037 | 1.0.880, 2026-10-09, 3,764 |
| `ilich8086.ColdFusion` | 1.0.1, 2018-01-01 | 106,835 | not listed |
| `ortus-solutions.vscode-boxlang` (BoxLang) | 1.34.1, 2026-10-31 | 1,540 | 1.34.1, 6,965 |
| `markdrew.cfml-formatter` | 1.0.104, 2025-05-15 | 1,997 | not listed |
| `hri.cfml-auto-formatter` | 1.0.24, 2025-11-28 | 990 | 1.0.24, 1,250 |
| `DavidRogers.cflsp` (syntax error checker) | 1.0.51, 2025-05-28 | 2,185 | not listed |
| `trst.cfml-comment-tags` | 0.2.2, 2016-10-23 | 9,544 | not listed |
| `muratuzun79.coldfusion-snippets` | 0.0.31, 2026-11-08 | 353 | not listed |
| `ortus-solutions.vscode-coldbox` | 1.1.1, 2023-10-04 | 7,696 | 1.1.1, 1,669 |

- KamasamaK/vscode-cfml repository: last push 2023-11-06, 77 stars, 48 open issues, not archived. — [GitHub API](https://api.github.com/repos/KamasamaK/vscode-cfml)
- cfmleditor/cfmleditor repository: last push 2026-11-22, 34 stars, 11 open issues, MIT licence. Its README credits KamasamaK/vscode-cfml as the original project, via the vadim-sibiryanskiy-yumasoft fork, and ilich/vscode-coldfusion for the syntax highlighting. — [GitHub API](https://api.github.com/repos/cfmleditor/cfmleditor); [README](https://github.com/cfmleditor/cfmleditor#readme)
- The author of ilich/vscode-coldfusion stopped development and points users to KamasamaK's extension. — [ilich/vscode-coldfusion](https://github.com/ilich/vscode-coldfusion)
- cfmleditor features (README): syntax highlighting, signature help, hover documentation for CFML global functions, tags and attributes, user functions, HTML tags and CSS properties, document and workspace symbols, completion, go to and peek definition, docblock generation, commands "Toggle CFML line comment" (Ctrl+/) and "Toggle CFML block comment" (Shift+Alt+A), "Open CFDocs page", "Refresh cache for global definitions". It registers language id `cfml` for `.cfml`, `.cfm`, `.cfc` and id `cfs` for `.cfs`. — [README](https://github.com/cfmleditor/cfmleditor#readme); [package.json](https://raw.githubusercontent.com/cfmleditor/cfmleditor/HEAD/package.json)
- Documentation source: CFDocs data. KamasamaK default is `cfml.cfDocs.source: "remote"` (fetched from GitHub; enum `remote`, `local`). cfmleditor default is `"extension"` (bundled; enum `remote`, `extension`, `lucee`, `local`). The foundeo/cfdocs repository was last pushed 2026-11-17. — [KamasamaK package.json](https://raw.githubusercontent.com/KamasamaK/vscode-cfml/master/package.json); [cfmleditor package.json](https://raw.githubusercontent.com/cfmleditor/cfmleditor/HEAD/package.json); [GitHub API](https://api.github.com/repos/foundeo/cfdocs)
- cfmleditor 0.7.8 adds an optional formatter and language server (`cfml.format.enabled`, `cfml.lsp.enabled`, both default false; the server binary "clif" is shipped in platform builds or downloaded). — [cfmleditor package.json](https://raw.githubusercontent.com/cfmleditor/cfmleditor/HEAD/package.json)
- Known limitations (both extensions): parsing is mostly regular expressions; one language id for all CFML so Emmet applies everywhere; no JavaScript or SQL assistance inside CFML; cfoutput inside CSS or JavaScript breaks highlighting. — [README](https://github.com/cfmleditor/cfmleditor#readme)
- CFLint: latest release is 1.5.0, published 2020-03-13; repository last pushed 2026-03-01, 178 stars, 138 open issues, not archived. The lint extensions need Java SE 8 or later and the standalone `CFLint-*-all.jar` (v1.5.0+) configured in `cflint.jarPath`; the README warns CFLint is slow and "often misreports issue location". — [GitHub API](https://api.github.com/repos/cflint/CFLint/releases/latest); [cfmleditor-lint README](https://github.com/cfmleditor/cfmleditor-lint#readme)
- `CFMLEditor.cfmleditor-lint` declares an extension dependency on `cfmleditor.cfmleditor`. — [package.json](https://raw.githubusercontent.com/cfmleditor/cfmleditor-lint/HEAD/package.json)
- Adobe ColdFusion Builder extension: free; features are a server panel, RDS file and data source access, PMT code profiler integration, security analyzer, code assist for CFML/CFScript/HTML/JavaScript/CSS, refactoring, quick fixes, debugger, remote project support and log viewer. Update 2 (January 2024) added ColdFusion 2023 function dictionaries and JDK 21.0.1 support. Licence on Open VSX is "SEE LICENSE IN LICENSE" (proprietary). — [Marketplace listing](https://marketplace.visualstudio.com/items?itemName=com-adobe-coldfusion.adobe-cfml-lsp); [Open VSX API](https://open-vsx.org/api/com-adobe-coldfusion/adobe-cfml-lsp); [Adobe release notes](https://helpx.adobe.com/coldfusion/coldfusion-builder-extension-for-visual-studio-code/release-notes-coldfusion-builder-extension-vs-code-update.html) (search summary only)
- ColdFusion Builder (the Eclipse-based IDE) reached end of life on 2024-10-01 per the title of an Adobe page in search results. — [Adobe](https://helpx.adobe.com/coldfusion/kb/faq-coldfusion-mx-7-updater-1.html) (title only)

### Inferences
- Several low-install 2025 to 2026 formatter and "AI formatter" extensions exist (for example the AkhilTeotia.* group, 100 to 300 installs each); none has a track record, and a formatter that understands only modern CFML is a risk for 6.1 code.
- BoxLang tooling targets the BoxLang runtime; it is not useful for a 2003 engine.

### Gaps
- Which ColdFusion versions Adobe's extension's dictionaries cover (and whether anything older than 2016 can be selected) was not found; Adobe's pages returned 403.
- cfformat through CommandBox (`commandbox-cfformat`) was not researched; no VS Code integration for it appeared in either registry search. It formats CFScript and component code, so its value for tag-based 6.1 code is unconfirmed.
- Marketplace install counts for KamasamaK include many years of history and do not show current use.

---

## 10. Which extension to recommend for tag-based CFML aimed at a 2003 engine, and how to configure it?

### Takeaway
Recommend `CFMLEditor.cfmleditor` with `cfml.engine.name = "coldfusion"` and `cfml.engine.version = "6.1.0"`, which hides functions and tags whose CFDocs minimum ColdFusion version is newer than 6.1. Add `CFMLEditor.cfmleditor-lint` only if Java and the CFLint jar are available, with a `.cflintrc` that turns off rules that push modern syntax.

### Cited Findings
- `cfml.engine.name` is a string with enum `coldfusion`, `lucee`, `railo`, `openbd`; `cfml.engine.version` is a free string ("SemVer format is preferred"), so there is no lowest selectable value. Both default to null. — [cfmleditor package.json](https://raw.githubusercontent.com/cfmleditor/cfmleditor/HEAD/package.json)
- Filtering logic (`isCompatible`): with no engine set, everything is shown; with an engine but no version, everything for that engine is shown; with a version, a definition is hidden when the target is older than the CFDocs `minimum_version` for that engine, or newer than or equal to its `removed` version; a definition with an empty `minimum_version` is treated as compatible; a definition with no entry for the engine is hidden. Versions that are not valid SemVer are coerced (so "6.1" becomes 6.1.0). — [definitionInfo.ts](https://raw.githubusercontent.com/cfmleditor/cfmleditor/HEAD/src/utils/cfdocs/definitionInfo.ts); [cfmlEngine.ts](https://raw.githubusercontent.com/cfmleditor/cfmleditor/HEAD/src/utils/cfdocs/cfmlEngine.ts)
- CFDocs sample data: `structKeyExists` coldfusion minimum_version "4"; `isValid` "7"; `arrayEach` "10"; `cfthread` "8". So with version 6.1.0 the last three are filtered out. — [cfdocs data](https://github.com/foundeo/cfdocs/tree/master/data/en) (files `structkeyexists.json`, `isvalid.json`, `arrayeach.json`, `cfthread.json`)
- Other relevant keys in cfmleditor 0.7.8: `cfml.mappings` (array of `{logicalPath, directoryPath, isPhysicalDirectoryPath}`; logicalPath must start with `/`), `cfml.webroot` (subfolder used as web root), `cfml.autoCloseTags.enable` (default true), `cfml.suggest.globalTags.attributes.quoteType`, `cfml.suggest.globalTags.includeAttributes.setType` (`none`, `required`, `all`), `cfml.suggest.globalFunctions.firstLetterCase`, `cfml.suggest.scopes.case` (`lower`, `upper`), `cfml.cfDocs.source`, `cfml.cfDocs.localPath`, `cfml.indexComponents.enable`, `cfml.definition.userFunctions.search.enable`, `cfml.comments.uncommentAnywhere.enabled`, `cfml.format.enabled` (default false), `cfml.lsp.enabled` (default false). — [cfmleditor package.json](https://raw.githubusercontent.com/cfmleditor/cfmleditor/HEAD/package.json)
- In KamasamaK 0.5.4 auto-closing relies on the third-party `formulahendry.auto-close-tag` extension and has `cfml.autoCloseTags.configurationTarget`; cfmleditor 0.7.8 describes `cfml.autoCloseTags.enable` without that dependency. — [KamasamaK README](https://github.com/KamasamaK/vscode-cfml#readme); [cfmleditor package.json](https://raw.githubusercontent.com/cfmleditor/cfmleditor/HEAD/package.json)
- Emmet in CFML files: `"emmet.includeLanguages": { "cfml": "html" }`. — [cfmleditor README](https://github.com/cfmleditor/cfmleditor#readme)
- Lint extension keys (0.7.0): `cflint.enabled`, `cflint.javaPath`, `cflint.jarPath`, `cflint.exclude`, `cflint.runModes` (`onOpen`, `onSave`, `onChange`), `cflint.altConfigFile.path`, `cflint.altConfigFile.usage` (`fallback`, `always`), `cflint.ignoreInfo`, `cflint.ignoreWarnings`, `cflint.notify.latestVersion`, `cflint.quickfix.var`, `cflint.quickfix.local`, `cflint.quickfix.ignoreLine`, `cflint.quickfix.excludeRule`, `cflint.cflintDebug`. Rule configuration lives in a `.cflintrc` file; the extension has commands to create and open it. — [cfmleditor-lint package.json](https://raw.githubusercontent.com/cfmleditor/cfmleditor-lint/HEAD/package.json); [README](https://github.com/cfmleditor/cfmleditor-lint#readme)
- CFLint 86 message codes include: `MISSING_VAR` (error), `ARG_VAR_CONFLICT` (error), `NESTED_CFOUTPUT` (error), `QUERYNEW_DUPLICATE_COLUMNS` (error), `CFQUERYPARAM_REQ`, `QUERYPARAM_REQ`, `GLOBAL_VAR`, `OUTPUT_ATTR`, `COMPARE_INSTEAD_OF_ASSIGN`, `UNUSED_LOCAL_VARIABLE`, `UNUSED_METHOD_ARGUMENT`, `ARG_DEFAULT_MISSING`, `AVOID_USING_CFDUMP_TAG`, `AVOID_USING_ISDATE`, `AVOID_USING_STRUCTNEW`, `AVOID_USING_ARRAYNEW`, `AVOID_USING_CREATEOBJECT`, `AVOID_USING_CFINCLUDE_TAG`, `AVOID_USING_CFMODULE_TAG`, `AVOID_USING_CFABORT_TAG`, `ARG_TYPE_ANY`, `FUNCTION_TYPE_ANY`, `SQL_SELECT_STAR`, `NEVER_USE_QUERY_IN_CFM`, `PACKAGE_CASE_MISMATCH`, plus naming and length rules (`VAR_*`, `ARGUMENT_*`, `METHOD_*`, `COMPONENT_*`, `EXCESSIVE_*`). — [cflint.definition.json](https://github.com/cflint/CFLint/blob/master/src/main/resources/cflint.definition.json)

Example `.vscode/settings.json` (setting keys taken from the package.json files cited above; `files.*` and `[cfml]` keys are standard VS Code settings and were not re-verified in this research):

```json
{
  "cfml.engine.name": "coldfusion",
  "cfml.engine.version": "6.1.0",
  "cfml.cfDocs.source": "extension",
  "cfml.mappings": [
    { "logicalPath": "/system", "directoryPath": "system", "isPhysicalDirectoryPath": false },
    { "logicalPath": "/app", "directoryPath": "app", "isPhysicalDirectoryPath": false }
  ],
  "cfml.webroot": "public",
  "cfml.autoCloseTags.enable": true,
  "cfml.suggest.globalTags.attributes.quoteType": "double",
  "cfml.suggest.globalTags.includeAttributes.setType": "required",
  "cfml.suggest.globalFunctions.firstLetterCase": "unchanged",
  "cfml.format.enabled": false,
  "cfml.lsp.enabled": false,
  "emmet.includeLanguages": { "cfml": "html" },
  "files.associations": { "*.cfm": "cfml", "*.cfml": "cfml", "*.cfc": "cfml" },
  "[cfml]": { "editor.formatOnSave": false, "editor.insertSpaces": false },
  "cflint.enabled": true,
  "cflint.jarPath": "/path/to/CFLint-1.5.0-all.jar",
  "cflint.runModes": { "onOpen": true, "onSave": true, "onChange": false },
  "cflint.ignoreInfo": true,
  "cflint.quickfix.local": false
}
```

The mapping paths and `cfml.webroot` value are placeholders to be replaced with the project's real layout.

Example `.vscode/extensions.json`:

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

### Inferences
- Engine filtering is only as good as CFDocs `minimum_version` data. Entries with an empty ColdFusion minimum version are still suggested, and tag attributes or function arguments added after 6.1 are probably not filtered per attribute (UNCONFIRMED). The local 6.1 CFML Reference remains the authority; the editor is a first filter only.
- `files.associations` is redundant because the extension already registers `.cfm`, `.cfml` and `.cfc`; it is harmless and guards against another extension claiming them.
- Keep `cfml.format.enabled` and `cfml.lsp.enabled` off: both are new, default-off features whose parser targets current CFML.
- `cflint.quickfix.local` should be false because the quick fix inserts a `local.` prefix, which relies on the function-local scope of later ColdFusion versions (UNCONFIRMED here that 6.1 lacks it; the language researcher should confirm). `cflint.quickfix.var` is the useful one.
- Suggested `.cflintrc` policy for 6.1: keep `MISSING_VAR`, `ARG_VAR_CONFLICT`, `NESTED_CFOUTPUT`, `CFQUERYPARAM_REQ`, `QUERYPARAM_REQ`, `GLOBAL_VAR`, `OUTPUT_ATTR`, `COMPARE_INSTEAD_OF_ASSIGN`, `UNUSED_LOCAL_VARIABLE`, `AVOID_USING_CFDUMP_TAG`, `AVOID_USING_ISDATE`; exclude `AVOID_USING_STRUCTNEW`, `AVOID_USING_ARRAYNEW` and `AVOID_USING_CREATEOBJECT` (they steer towards literal and `new` syntax that a 2003 engine is not expected to have; UNCONFIRMED), `AVOID_USING_CFINCLUDE_TAG`, `AVOID_USING_CFMODULE_TAG`, `AVOID_USING_CFABORT_TAG`, `ARG_TYPE_ANY`, `FUNCTION_TYPE_ANY`, and the naming and length families.
- CFLint 1.5.0 parses with a modern CFML grammar; it may report parse errors or miss problems in 6.1-specific constructs. Treat its output as advisory.
- Encoding: given section 5, add `"files.encoding"` deliberately (UTF-8 with a `cfprocessingdirective` in each file, or ASCII-only source) rather than relying on defaults.

### Gaps
- The exact `.cflintrc` JSON schema (keys `rule`, `excludes`, `includes`, `inheritParent`) was not read from the CFLint README in this research; generate the file with the extension's "Create '.cflintrc' file" command and edit from there.
- Whether CFDocs has attribute-level version data that the extension uses was not checked.
- No test was run; nothing was installed.

---

## 11. VS Code forks and Remote SSH

### Takeaway
All four main extensions are published on Open VSX, so they install in forks that use that registry, but the Open VSX build of cfmleditor is older (0.7.0, January 2026) than the Marketplace build (0.7.8, October 2026). The editor and lint extensions run on the workspace side, so under Remote SSH they, Java and the CFLint jar live on the remote host.

### Cited Findings
- Open VSX has `cfmleditor.cfmleditor` 0.7.0 (2026-01-27, engine `^1.99.3`), `cfmleditor.cfmleditor-lint` 0.7.0, `KamasamaK.vscode-cfml` 0.5.4, `KamasamaK.vscode-cflint` 0.3.6 and `com-adobe-coldfusion.adobe-cfml-lsp` 1.0.880. — [Open VSX API, cfmleditor](https://open-vsx.org/api/cfmleditor/cfmleditor); [Open VSX search API](https://open-vsx.org/api/-/search?query=cfml&size=30)
- The Marketplace build 0.7.8 requires VS Code engine `^1.105.1`. — [cfmleditor package.json](https://raw.githubusercontent.com/cfmleditor/cfmleditor/HEAD/package.json)
- Open VSX reports `extensionKind` `["workspace", "web"]` for cfmleditor and `["workspace"]` for cfmleditor-lint, vscode-cflint and the Adobe extension. — [Open VSX API](https://open-vsx.org/api/cfmleditor/cfmleditor); [Open VSX API](https://open-vsx.org/api/cfmleditor/cfmleditor-lint); [Open VSX API](https://open-vsx.org/api/com-adobe-coldfusion/adobe-cfml-lsp)
- The Open VSX search results include a test entry named "Extension Confusion Lab (test)" in a look-alike namespace, a reminder to install by exact ID. — [Open VSX search API](https://open-vsx.org/api/-/search?query=coldfusion&size=30)

### Inferences
- Under Remote SSH the extension is installed on the remote host and indexes components there; `cflint.jarPath` and `cflint.javaPath` must be remote paths.
- A fork whose bundled VS Code API is older than 1.105 cannot take the 0.7.8 build even by manual VSIX install; the 0.7.0 Open VSX build needs API 1.99.3 or later.
- On Open VSX the namespace is lower-case `cfmleditor`; extension IDs are case-insensitive in VS Code, so `CFMLEditor.cfmleditor` in `extensions.json` should resolve in both registries (UNCONFIRMED).

### Gaps
- No source states compatibility with specific forks (Cursor, Windsurf, VSCodium) or reports Remote SSH problems; not tested.
- Whether the Adobe extension's debugger and server panel work over Remote SSH or on Linux was not found.
