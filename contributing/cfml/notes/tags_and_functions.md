# ColdFusion MX 6.1 tags and functions: complete inventory, detailed entries, and what is not in 6.1

Scope: Macromedia ColdFusion MX 6.1 (2003). Everything stated as "exists in 6.1" was taken from the local 6.1 manuals, not from memory or later documentation. Web sources are used only for "arrived in version N" claims.

Sources and citation conventions:

- "Ref" = CFML Reference (Macromedia ColdFusion MX 6.1), file `cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf` (text extraction in `cfmx_6.1_docs_en/text/cfmx61_cfml_reference.txt`).
- "Dev" = Developing ColdFusion MX Applications, `cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf`.
- "Adm" = Configuring and Administering ColdFusion MX, `cfmx_6.1_docs_en/cfmx61_config_admin.pdf`.
- Page numbers are the printed page numbers of the manual.
- Code examples in this file were written for these notes using only constructs documented in the 6.1 manuals. They were not executed on a 6.1 server.

## Which tags exist in ColdFusion MX 6.1?

### Takeaway

The 6.1 CFML Reference has 101 distinct tag entries. 95 of them are in the manual's own summary table; the other 6 are obsolete or deprecated tags that still have an entry. Anything not in the list of 101 below does not exist in 6.1.

### Cited Findings

**Counts and cross-check** (done by script over the text extraction of the manual):

- Chapter 2 of the Reference has 127 entry headings, which reduce to 101 unique tags once sub-entries are folded in (cffile actions, cfftp forms, cfloop forms, cfobject types, cfregistry actions). [CFML Reference p47-361](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- The manual's tag summary table lists 95 tags. In the text extraction, cfprocessingdirective appears truncated as "cfprocessingdirect". [CFML Reference p34-38](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- The 6 tags that have an entry but are not in the summary table: `cfauthenticate`, `cfimpersonate` (obsolete), `cfgraph`, `cfgraphdata`, `cfservlet`, `cfservletparam` (deprecated). [CFML Reference p42-46](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- The "tags by function" lists cover 94 tags; `cfargument` is missing from them although it has an entry and is in the summary table. [CFML Reference p39-41](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

**The 101 tags (alphabetical):** cfabort, cfapplet, cfapplication, cfargument, cfassociate, cfauthenticate, cfbreak, cfcache, cfcase, cfcatch, cfchart, cfchartdata, cfchartseries, cfcol, cfcollection, cfcomponent, cfcontent, cfcookie, cfdefaultcase, cfdirectory, cfdump, cfelse, cfelseif, cferror, cfexecute, cfexit, cffile, cfflush, cfform, cfftp, cffunction, cfgraph, cfgraphdata, cfgrid, cfgridcolumn, cfgridrow, cfgridupdate, cfheader, cfhtmlhead, cfhttp, cfhttpparam, cfif, cfimpersonate, cfimport, cfinclude, cfindex, cfinput, cfinsert, cfinvoke, cfinvokeargument, cfldap, cflocation, cflock, cflog, cflogin, cfloginuser, cflogout, cfloop, cfmail, cfmailparam, cfmailpart, cfmodule, cfobject, cfobjectcache, cfoutput, cfparam, cfpop, cfprocessingdirective, cfprocparam, cfprocresult, cfproperty, cfquery, cfqueryparam, cfregistry, cfreport, cfrethrow, cfreturn, cfsavecontent, cfschedule, cfscript, cfsearch, cfselect, cfservlet, cfservletparam, cfset, cfsetting, cfsilent, cfslider, cfstoredproc, cfswitch, cftable, cftextinput, cfthrow, cftrace, cftransaction, cftree, cftreeitem, cftry, cfupdate, cfwddx, cfxml. [CFML Reference p47-361](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

**Tags by function, as the manual groups them** (a tag can be in more than one group): [CFML Reference p39-41](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- Application framework tags: cfapplication, cfassociate, cferror, cfimport, cflock, cfmodule, cfscript.
- Database manipulation tags: cfinsert, cfobjectcache, cfprocparam, cfprocresult, cfquery, cfqueryparam, cfstoredproc, cftransaction, cfupdate.
- Data output tags: cfchart, cfchartdata, cfchartseries, cfcol, cfcontent, cfflush, cfheader, cflog, cfoutput, cfprocessingdirective, cfsilent, cftable.
- Debugging tags: cfdump, cftrace.
- Exception handling tags: cfcatch, cferror, cfrethrow, cfthrow, cftry.
- Extensibility tags: cfchart, cfchartdata, cfchartseries, cfcollection, cfcomponent, cfexecute, cfftp, cffunction, cfindex, cfinvoke, cfinvokeargument, cflogin, cfloginuser, cflogout, cfobject, cfproperty, cfreport, cfreturn, cfsearch, cfwddx, cfxml.
- File management tags: cfdirectory, cffile, cfftp.
- Flow-control tags: cfabort, cfbreak, cfcase, cfdefaultcase, cfelse, cfelseif, cfexecute, cfexit, cfif, cfinclude, cflocation, cfloop, cfrethrow, cfswitch, cfthrow, cftry.
- Forms tags: cfapplet, cfform, cfgrid, cfgridcolumn, cfgridrow, cfgridupdate, cfhtmlhead, cfinput, cfldap, cfmail, cfmailparam, cfmailpart, cfpop, cfselect, cfslider, cftextinput, cftree, cftreeitem.
- Internet Protocol tags: cfftp, cfhttp, cfhttpparam, cfldap, cfmail, cfmailparam, cfmailpart, cfpop.
- Page processing tags: cfcache, cfcontent, cfflush, cfheader, cfhtmlhead, cfinclude, cfsetting, cfsilent.
- Variable manipulation tags: cfcookie, cfdump, cfparam, cfregistry, cfsavecontent, cfschedule, cfset, cfsetting.
- Other tags: cflog, cfregistry.

**New, changed, deprecated and obsolete since ColdFusion 5** [CFML Reference p42-46](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- New tags in MX 6.0: cfargument, cfchart, cfchartdata, cfchartseries, cfcomponent, cffunction, cfimport, cfinvoke, cfinvokeargument, cflogin, cfloginuser, cflogout, cfobjectcache, cfproperty, cfreturn, cftrace, cfxml.
- New attributes in MX 6.0: cfcache `timespan`; cfhttp `charset`, `firstrowasheaders`; cfmail `spoolEnable`; cfprocessingdirective `pageEncoding`; cfsetting `requestTimeOut`; cfthrow `object`.
- New tag in MX 6.1: cfmailpart.
- New in MX 6.1 on existing tags: cfapplication `loginStorage`; cfexecute `variable`; cfhttp methods HEAD, PUT, DELETE, OPTIONS, TRACE, and attributes `multipart`, `getAsBinary`, `proxyUser`, `proxyPassword`, plus `cfhttp.errorDetail`; cfhttpparam types `header` and `body`, attributes `encoded`, `mimeType`; cfmail `charset`, `failto`, `replyto`, `username`, `password`, `wraptext`, and multiple servers; cfmailparam `type`; cfdump can dump COM objects; cfsetting body is now executed.
- Deprecated: cfgraph, cfgraphdata, cfservlet, cfservletparam. cfregistry is deprecated on UNIX. cflog `thread`, `date`, `time` attributes are deprecated.
- Obsolete: cfauthenticate, cfimpersonate. cfprocparam `maxrows` is obsolete and `dbvarname` is ignored (parameters are positional).

**One line per tag entry, in manual order** (127 entry headings; purpose is the first sentence of the manual's description; History is the manual's own history note, clipped):

- `cfabort` (Ref p47): Stops the processing of a ColdFusion page at the tag location.
- `cfapplet` (Ref p49): This tag references a registered custom Java applet. History: ColdFusion MX: • Removed the requirement that you use this tag within a cfform tag. • Changed the behavior when this tag is used within a cfform tag; if the method attribute is defined in the Administrator, the return value of the applet’s method is ...
- `cfapplication` (Ref p51): Defines the scope of a ColdFusion application; History: ColdFusion MX 6.1: Added loginStorage attribute ColdFusion MX: • Changed how persistent scopes are available: Server, Session, and Application scope variables are stored in memory as structures. In earlier releases, only Session and Application scope ...
- `cfargument` (Ref p54): Creates a parameter definition within a component definition.
- `cfassociate` (Ref p56): Allows subtag data to be saved with a base tag.
- `cfauthenticate` (Ref p57): This tag is obsolete. History: ColdFusion MX: this tag is obsolete. It does not work in ColdFusion MX and later releases.
- `cfbreak` (Ref p58): Used within a cfloop tag.
- `cfcache` (Ref p59): Stores a copy of a page on the server and/or client computer, to improve page rendering performance. History: ColdFusion MX: • Deprecated the timeout and cachedirectory attributes. They might not work, and might cause an error, in later releases. • Added the timespan attribute. • Changed how pages are cached: the default action attribute value, cache, caches a page ...
- `cfcase` (Ref p62): Used only inside the cfswitch tag body.
- `cfcatch` (Ref p64): Used inside a cftry tag. History: ColdFusion MX: • Changed SQLSTATE value behavior: the SQLSTATE return value in a cfcatch tag depends on the database driver type: ■Type 1 (JDBC-ODBC bridge): the value is the same as in ColdFusion 5 ■Type 4 (100% Java, no native methods): the value might be ...
- `cfchart` (Ref p70): Generates and displays a chart. History: ColdFusion MX 6.1: • Added the xAxisType and yAxisType attributes. • Changed interpolation behavior: the tag now interpolates data points on line charts with multiple series. ColdFusion MX: Added this tag. cfchart
- `cfchartdata` (Ref p75): Used with the cfchart and cfchartseries tags. History: ColdFusion MX: Added this tag.
- `cfchartseries` (Ref p76): Used with the cfchart tag. History: ColdFusion MX 6.1: Changed interpolation behavior: the tag now interpolates data points on line charts with multiple series. ColdFusion MX: Added this tag.
- `cfcol` (Ref p78): Defines table column header, width, alignment, and text. History: ColdFusion MX: Added the ability to construct dynamic cfcol statements.
- `cfcollection` (Ref p80): Creates, registers, and administers Verity search engine collections. History: ColdFusion MX: • Changed the requirements for the action attribute: it is now required. • Added the action attribute list value. It is the default. • Changed the requirements for the action attribute value map: it is not necessary to specify the action ...
- `cfcomponent` (Ref p85): Creates and defines a component object;
- `cfcontent` (Ref p87): Does either or both of the following: • Sets the MIME content encoding header for the current page • Sends the contents of a file from the server as the page output ...
- `cfcookie` (Ref p91): Defines web browser cookie variables, including expiration and security options. History: ColdFusion MX 6.1: • Changed the expires attribute: it now accepts a date time object. • Cookie names can include all ASCII characters except commas, semicolons, or whitespace characters.
- `cfdefaultcase` (Ref p94): Used only inside the cfswitch tag body. History: ColdFusion MX: Changed placement requirements: this tag does not have to follow all cfcase tags in the cfswitch tag body.
- `cfdirectory` (Ref p95): Manages interactions with directories. History: ColdFusion MX: • Changed behavior for action = "list": ■On Windows, cfdirectory action = "list" no longer returns the directory entries "." (dot) or ".." (dot dot), which represent "the current directory" and "the parent directory." ■On Windows, cfdirectory ...
- `cfdump` (Ref p98): Outputs the elements, variables and values of most kinds of ColdFusion objects. History: ColdFusion MX 6.1: Added the ability to dump COM objects; it displays the methods and Get and Put properties typeinfo information for the object.
- `cfelse` (Ref p100): Used as the last control block in a cfif tag block to handle any case not identified by the cfif tag or a cfelseif tag.
- `cfelseif` (Ref p101): Used as a control block in a cfif tag block to handle any case not identified by the cfif tag or a cfelseif tag.
- `cferror` (Ref p102): Displays a custom HTML page when an error occurs. History: ColdFusion MX: Deprecated the monitor option of the exception attribute. It might not work, and might cause an error, in later releases.
- `cfexecute` (Ref p106): Executes a ColdFusion developer-specified process on a server computer. History: ColdFusion MX 6.1: • Added the variable attribute. • Changed file path behavior for the outputFile attribute: if you do not specify an absolute file path in the outputFile attribute, the path is relative to the ColdFusion temporary directory.
- `cfexit` (Ref p108): This tag aborts processing of the currently executing CFML custom tag, exits the page within the currently executing CFML custom tag, or re-executes a section of code ...
- `cffile` (Ref p110): Manages interactions with server files. History: ColdFusion MX 6.1: • Changed file path requirements: if you do not specify an absolute file path, the path is relative to the ColdFusion temporary directory, which is returned by the GetTempDirectory function. • Changed behavior for action="read": if the file ...
- `cffile action = "append"` (Ref p113): Appends text to a text file on the server. History: See the History section of the main cffile tag page.
- `cffile action = "copy"` (Ref p115): Copies a file from one directory to another on the server. History: See the History section of the main cffile tag page.
- `cffile action = "delete"` (Ref p116): Deletes a file on the server.
- `cffile action = "move"` (Ref p117): Moves a file from one location to another on the server. History: See the History section of the main cffile tag page.
- `cffile action = "read"` (Ref p119): Reads a text file on the server. History: See the History section of the main cffile tag page.
- `cffile action = "readBinary"` (Ref p121): Reads a binary file (such as an executable or image file) on the serve, into a binary object parameter that you can use in the page.
- `cffile action = "rename"` (Ref p122): Renames or moves a file on the server. History: See the History section of the main cffile tag page.
- `cffile action = "upload"` (Ref p124): Copies a file to a directory on the server. History: See the History section of the main cffile tag page.
- `cffile action = "write"` (Ref p127): Writes a text file on the server, based on dynamic content. History: See the History section of the main cffile tag page.
- `cfflush` (Ref p130): Flushes currently available data to the client.
- `cfform` (Ref p132): Builds a form with CFML custom control tags; History: ColdFusion MX: • Deprecated the enableCAB attribute. It might not work, and might cause an error, in later releases. • Changed the name and action attributes to optional.
- `cfftp` (Ref p137): Lets users implement File Transfer Protocol (FTP) operations. History: ColdFusion MX: Deprecated the agentname attribute. It might not work, and might cause an error, in later releases.
- `cfftp: Opening and closing FTP server connections` (Ref p138): To establish a connection with an FTP server, you use the open action with a connection attribute.
- `cfftp: Connection: File and directory operations` (Ref p141): Use this form of the cfftp tag to perform file and directory operations with cfftp.
- `cfftp action = "listDir"` (Ref p145): To access the columns in a query object, use this tag with action = "listDir".
- `cffunction` (Ref p146): Defines a function that you can call in CFML.
- `cfgraph` (Ref p149): This tag is deprecated. History: ColdFusion MX: Deprecated this tag. It works differently than it did in ColdFusion 5, and it might not work in later releases. The incompatibilities between the ColdFusion MX implementation and earlier implementations of this tag are as follows: cfgraph tag ...
- `cfgraphdata` (Ref p151): This tag is deprecated. History: ColdFusion MX: Deprecated this tag. It works differently than in ColdFusion 5 and might not work in later releases.
- `cfgrid` (Ref p152): Used within the cfform tag. History: ColdFusion MX: Changed the rowHeaderWidth attribute: ColdFusion does not use the rowHeaderWidth attribute. You can omit it.
- `cfgridcolumn` (Ref p161): Used with the cfgrid tag in a cfform. History: ColdFusion MX: Changed behavior if select = "no": a user cannot select and edit the cell data, regardless of the cfgrid selectmode attribute value. When clicked, the cell border (and, depending on the selectColor value, the cell background) changes color, but ...
- `cfgridrow` (Ref p166): Lets you define a cfgrid that does not use a query as source for row data.
- `cfgridupdate` (Ref p169): Used within a cfgrid tag. History: ColdFusion MX: Deprecated the connectString, dbName, dbServer, dbtype, provider and providerDSN attributes. They do not work, and might cause an error, in releases later than ColdFusion 5.
- `cfheader` (Ref p171): Generates custom HTTP response headers to return to the client. History: ColdFusion MX 6.1: Changed behavior for the name attribute: cfheader name="Content-Disposition" uses the default file character encoding to encode this header's value, so the name of a file can include characters in the character encoding used in the file.
- `cfhtmlhead` (Ref p173): Writes text to the head section of a generated HTML page.
- `cfhttp` (Ref p174): Generates an HTTP request and handles the response from the server. History: ColdFusion MX 6.1: • Added support for the following methods: HEAD, PUT, DELETE, OPTIONS, TRACE. • Added multipart, getAsBinary, proxyUser, and proxyPassword attributes. • Changed httpparam behavior: All operations can have httpparam tags. • Added ...
- `cfhttpparam` (Ref p183): Allowed inside cfhttp tag bodies only. History: ColdFusion MX 6.1: • Added the header and body types. • Added the encoded, and mimeType attributes. • Changed HTTP method behavior: all HTTP methods can have httpparam tags. • Changed the name attribute requirements: it is not required for all types.
- `cfif` (Ref p187): Creates simple and compound conditional statements in CFML.
- `cfimpersonate` (Ref p189): This tag is obsolete. History: ColdFusion MX: This tag is obsolete. It does not work in ColdFusion MX and later releases.
- `cfimport` (Ref p190): You can use the cfimport tag to import either of the following: • All ColdFusion pages in a directory, as a tag custom tag library. History: ColdFusion MX: Added this tag.
- `cfinclude` (Ref p192): Embeds references to ColdFusion pages in CFML. History: ColdFusion MX: Changed error behavior: if you use this tag to include a CFML page whose length is zero bytes, you do not get an error.
- `cfindex` (Ref p193): Populates a Verity search engine collection with an index of documents on a file system or of ColdFusion query result sets. History: ColdFusion MX: • The action attribute value optimize is obsolete. It does not work, and might cause an error, in ColdFusion MX. • Changed the external attribute behavior: it is not necessary to specify the external attribute. (ColdFusion automatically detects ...
- `cfinput` (Ref p201): Used within the cfform tag, to place radio buttons, check boxes, or text boxes on a form. History: ColdFusion MX 6.1: Changed the requirements for the validate = "creditcard" option: it requires that the text entry have 13-16 digits. ColdFusion MX: Changed the cfform tag preserveData attribute behavior: if it is set to True, ColdFusion checks radio and ...
- `cfinsert` (Ref p205): Inserts records in data sources from data in a ColdFusion form or form Scope. History: ColdFusion MX: Deprecated the connectString, dbName, dbServer, dbtype, provider, and providerDSN attributes. They do not work, and might cause an error, in releases later than ColdFusion 5.
- `cfinvoke` (Ref p208): Does either of the following: • Invokes a component method from within a ColdFusion page or component. History: ColdFusion MX 6.1: Added the following attributes: timeout, proxyServer, proxyPort, proxyUser, and proxyPassword. ColdFusion MX: Added this tag.
- `cfinvokeargument` (Ref p213): Passes the name and value of a parameter to a component method or a web service. History: ColdFusion MX: Added this tag.
- `cfldap` (Ref p215): Provides an interface to a Lightweight Directory Access Protocol (LDAP) directory server, such as the Netscape Directory Server. History: ColdFusion MX: • Changed the name attribute behavior: this tag validates the query name in the name attribute. • Changed sorting behavior: this tag does not support client-side sorting of query results. (It supports server-side sorting; use the sort and ...
- `cflocation` (Ref p220): Stops execution of the current page and opens a ColdFusion page or HTML file.
- `cflock` (Ref p221): Ensures the integrity of shared data.
- `cflog` (Ref p226): Writes a message to a log file. History: ColdFusion MX: Deprecated the thread, date, and time attributes. They might not work, and might cause an error, in later releases. (In earlier releases, these attributes determined whether the respective data items were output to the log. In ColdFusion MX, ...
- `cflogin` (Ref p228): A container for user login and authentication code. History: ColdFusion MX 6.1: Changed behavior: the cflogin variable exists when ColdFusion receives a request with NTLM or Digest (CFHTTP Negotiated header) authentication information. ColdFusion MX: Added this tag.
- `cfloginuser` (Ref p230): Identifies an authenticated user to ColdFusion. History: ColdFusion MX 6.1: Changed behavior: if the Session scope is enabled, and the cfapplication tag loginStorage attribute is set to Session, the login remains in effect until the session expires or the user is logged out by the cflogin tag. ColdFusion MX: Added ...
- `cflogout` (Ref p231): Logs the current user out. History: ColdFusion MX 6.1: Changed behavior: if the Session scope is enabled, a login remains in effect until the session expires or the user is logged out by the cflogin tag. ColdFusion MX: Added this tag.
- `cfloop` (Ref p232): Looping is a programming technique that repeats a set of instructions or displays output repeatedly until one or more conditions are met.
- `cfloop: index loop` (Ref p233): An index loop repeats for a number of times that is determined by a numeric value.
- `cfloop: conditional loop` (Ref p235): A conditional loop iterates over a set of instructions as long as a condition is True.
- `cfloop: looping over a query` (Ref p236): A loop over a query executes for each record in a query record set.
- `cfloop: looping over a list or file` (Ref p238): Looping over a list steps through elements contained in any of these entities: • A variable • A value that is returned from an expression • A file index Required In a ...
- `cfloop: looping over a COM collection or structure` (Ref p239): The cfloop collection attribute loops over every object within a COM/DCOM collection object, or every element in a structure: • A COM/DCOM collection object is a set of ...
- `cfmail` (Ref p240): Sends an e-mail message that optionally contains query output, using an SMTP server. History: ColdFusion MX 6.1: • Added the following attributes: charset, failto, replyto, username, password and wraptext. • Added support for multiple mail servers in the server attribute. • Added several configuration options to the ColdFusion MX Administrator Mail ...
- `cfmailparam` (Ref p246): Attaches a file or adds a header to an e-mail message. History: ColdFusion MX 6.1: Added the type attribute.
- `cfmailpart` (Ref p248): Specifies one part of a multipart e-mail message. History: ColdFusion MX 6.1: Added this tag.
- `cfmodule` (Ref p250): Invokes a custom tag for use in ColdFusion application pages. History: ColdFusion MX: Changed behavior when using this tag within a custom tag: if the attribute_name parameter is the same as a key element within the attributeCollection parameter, ColdFusion now uses the name value that is within the attributeCollection ...
- `cfobject` (Ref p253): Creates a ColdFusion object, of a specified type. History: ColdFusion MX: • Changed instantiation behavior: this tag, and the CreateObject function, can now instantiate ColdFusion components (CFCs); you can use them within the cfscript tag. • For CORBA object: changed the Naming Service separator format for addresses ...
- `cfobject: COM object` (Ref p254): Creates and manipulates a Component Object Model (COM) object.
- `cfobject: component object` (Ref p256): Creates an instance of a ColdFusion component (CFC) object.
- `cfobject: CORBA object` (Ref p257): Calls methods on a registered CORBA object. History: See the History section of the main cfobject tag page.
- `cfobject: Java or EJB object` (Ref p259): Creates and manipulates a Java and Enterprise Java Bean (EJB) object.
- `cfobject: web service object` (Ref p261): Creates a web service proxy object.
- `cfobjectcache` (Ref p262): Flushes the query cache. History: ColdFusion 5: Added this tag.
- `cfoutput` (Ref p263): Displays output that can contain the results of processing ColdFusion variables and functions.
- `cfparam` (Ref p265): Tests for a parameter’s existence, tests its data type, and, if a default value is not assigned, optionally provides one.
- `cfpop` (Ref p267): Retrieves or deletes e-mail messages from a POP mail server. History: ColdFusion MX 6.1: • Added support for multipart mail mesages with Text and HTML parts. • Changed the attachment name separator: the TAB character is now the separator between attachment names in the attachments and attachmentfiles query fields if a message ...
- `cfprocessingdirective` (Ref p271): Provides the following insformation to ColdFusion on how to process the current page: • Specifies whether to remove excess whitespace character from ColdFusion generated ... History: ColdFusion MX: • Changed suppresswhitespace attribute value behavior: you can specify the suppresswhitespace attribute value as a string variable. (ColdFusion 5 supported setting it only as a constant.) • Added the pageEncoding attribute.
- `cfprocparam` (Ref p274): Defines stored procedure parameters. History: ColdFusion MX: • The maxrows attribute is obsolete. • Changed the dbvarname attribute behavior: it is now ignored for all drivers. ColdFusion MX uses JDBC 2.2 and does not support named parameters. • Changed the maxLength attribute behavior: it now applies to ...
- `cfprocresult` (Ref p278): Associates a query object with a result set returned by a stored procedure.
- `cfproperty` (Ref p280): Defines properties of a ColdFusion component (CFC). History: ColdFusion MX: Added this tag.
- `cfquery` (Ref p282): Passes queries or SQL statements to a data source. History: ColdFusion MX: • Changed Query of Queries behavior: it now supports a larger subset of standard SQL. For more information, see Chapter 22, “Using Query of Queries,” in Developing ColdFusion MX Applications. • Changed dot notation support: ColdFusion now ...
- `cfqueryparam` (Ref p286): Verifies the data type of a query parameter and, for DBMSs that support bind variables, enables ColdFusion to use bind variables in the SQL statement.
- `cfregistry` (Ref p290): This tag is deprecated for the UNIX platform. History: ColdFusion MX: • Deprecated this tag on the UNIX platform. It might not work, and might cause an error, in later releases. • Changed how persistent data is stored: ColdFusion now stores most persistent data outside the system registry, in XML files. cfregistry
- `cfregistry action = "getAll"` (Ref p291): Returns all registry keys and values defined in a branch.
- `cfregistry action = "get"` (Ref p292): Accesses a registry value and stores it in a ColdFusion variable.
- `cfregistry action = "set"` (Ref p293): Adds a registry key, adds a value, or updates a value.
- `cfregistry action = "delete"` (Ref p294): Deletes a registry key or value.
- `cfreport` (Ref p295): Runs a predefined Crystal Reports report. History: ColdFusion MX: Changed data source connection behavior: Crystal Reports now establishes an independent connection to the data source. The connection is not subject to any ColdFusion data source-specific restrictions. For example, the Crystal Reports server ...
- `cfrethrow` (Ref p297): Rethrows the currently active exception.
- `cfreturn` (Ref p298): Returns result values from a component method. History: ColdFusion MX: Added this tag.
- `cfsavecontent` (Ref p300): Saves the generated content of the cfsavecontent tag, including the results of evaluating expressions and executing custom tags, in the specified variable.
- `cfschedule` (Ref p301): Provides a programmatic interface to the ColdFusion scheduling engine. History: ColdFusion MX 6.1: Changed the way intervals are calculated. The day length now reflects changes between standard and daylight saving times. The month length is now the calendar month length, not four weeks. The scheduler handles leap years correctly.
- `cfscript` (Ref p304): Encloses a code block that contains cfscript statements. History: ColdFusion MX: • Changed how to invoke component methods: this tag can now invoke component methods, using the createObject function • Changed use of reserved words: you cannot use ColdFusion reserved words within this tag • Added the try and catch statements.
- `cfsearch` (Ref p307): Searches Verity collections using ColdFusion or K2Server, whichever search engine a collection is registered by. History: ColdFusion MX: • Deprecated the external attribute. It might not work, and might cause an error, in later releases. (ColdFusion stores this information about each collection; it automatically detects whether a collection is internal or external.) This tag ...
- `cfselect` (Ref p312): Constructs a drop-down list box form control.
- `cfservlet` (Ref p316): This tag is deprecated. History: ColdFusion MX: Deprecated this tag. It might not work, and it might cause an error, in later releases. cfservletparam
- `cfservletparam` (Ref p317): This tag is deprecated. History: ColdFusion MX: Deprecated this tag. It might not work, and it might cause an error, in later releases.
- `cfset` (Ref p318): Sets a value in ColdFusion.
- `cfsetting` (Ref p321): Controls aspects of page processing, such as the output of HTML code in pages. History: ColdFusion MX 6.1: Changed behavior: if the tag has a body, ColdFusion executes its contents. ColdFusion MX: • Added the requestTimeOut attribute. • The catchExceptionsByPattern attribute is obsolete. It does not work, and causes an error, in releases later ...
- `cfsilent` (Ref p323): Suppresses output produced by CFML within a tag’s scope.
- `cfslider` (Ref p324): Puts a slider control, for selecting a numeric value from a range, in a ColdFusion form. History: ColdFusion MX: Deprecated the img, imgStyle, and grooveColor attributes. They might not work, and might cause an error, in later releases.
- `cfstoredproc` (Ref p328): Executes a stored procedure in a server database. History: ColdFusion MX: Deprecated the connectString, dbName, dbServer, dbtype, provider and providerDSN attributes. They do not work, and might cause an error, in releases later than ColdFusion 5. (ColdFusion MX uses Type 4 JDBC drivers.)
- `cfswitch` (Ref p330): Evaluates a passed expression and passes control to the cfcase tag that matches the expression result. History: ColdFusion MX: Changed cfdefaultcase tag placement requirements: you can put the cfdefaultcase tag at any position within a cfswitch statement; it is not required to be the last item.
- `cftable` (Ref p332): Builds a table in a ColdFusion page.
- `cftextinput` (Ref p334): Puts a single-line text entry box in a cfform tag and controls its display characteristics. History: ColdFusion MX 6.1: Changed the validate = "creditcard" option requirements: the text entry must have 13-16 digits.
- `cfthrow` (Ref p338): Throws a developer-specified exception, which can be caught with a cfcatch tag that has any of the following type attribute options: • type = "custom_type" • type = ... History: ColdFusion MX: Changed thrown exceptions: this tag can throw ColdFusion component method exceptions.
- `cftrace` (Ref p341): Displays and logs debugging data about the state of an application at the time the cftrace tag executes. History: ColdFusion MX: Added this tag.
- `cftransaction` (Ref p343): Instructs the database management system to treat multiple database operations as a single transaction.
- `cftree` (Ref p345): Inserts a tree control in a form. History: ColdFusion MX: Changed behavior: ColdFusion renders a tree control regardless of whether there are any treeitems within it.
- `cftreeitem` (Ref p349): Populates a form tree control, created with the cftree tag, with elements.
- `cftry` (Ref p353): Used with one or more cfcatch tags. History: ColdFusion MX: Changed cfscript to include try and catch statements that are equivalent to the cftry and cfcatch tags.
- `cfupdate` (Ref p355): Updates records in a data source from data in a ColdFusion form or form Scope. History: ColdFusion MX: Deprecated the connectString, dbName, dbServer, dbtype, provider and providerDSN attributes. They do not work, and might cause an error, in releases later than ColdFusion 5.
- `cfwddx` (Ref p358): Serializes and deserializes CFML data structures to the XML-based WDDX format. History: ColdFusion MX • Changed column name case behavior: ColdFusion preserves the case of column names in JavaScript. (Earlier releases converted query column names to lowercase.) • Changed encoding format support: this tag supports several encoding formats. The ...
- `cfxml` (Ref p361): Creates a ColdFusion XML document object that contains the markup in the tag body. History: ColdFusion MX: Added this tag.


### Inferences

- The grouping of tags into the 13 function categories was read from a three-column table in the text extraction. The column order in the extraction is row by row, so the boundary between adjacent groups was reconstructed from the alphabetical restart of each list. The per-entry "Category" line of each tag agrees with the grouping for the tags checked (cfmail, cfpop, cfldap, cfhtmlhead are listed under both Forms and Internet Protocol or Page processing).

### Gaps

- The summary table count of 95 comes from a text extraction in which one name is truncated; the PDF was not re-read visually.

## Which built-in functions exist in ColdFusion MX 6.1?

### Takeaway

The 6.1 CFML Reference has 270 function entries, all unique. Six of them (five obsolete security functions and the deprecated ParameterExists) are absent from the manual's "functions by category" lists. Any function not in the list below does not exist in 6.1.

### Cited Findings

**Counts and cross-check**

- Chapter 3 of the Reference has 270 A to Z function entries. [CFML Reference p374-748](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- The "functions by category" lists do not include these six, which do have entries: `AuthenticatedContext`, `AuthenticatedUser`, `IsAuthenticated`, `IsAuthorized`, `IsProtected` (all obsolete) and `ParameterExists` (deprecated). One name is truncated in the lists ("IsK2ServerDocCoun..."). [CFML Reference p367-371](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- Deprecated: `GetTemplatePath` (use `GetBaseTemplatePath`), `ParameterExists` (use `IsDefined`), `GetK2ServerDocCount`, `GetK2ServerDocCountLimit`, `IsK2ServerABroker`, `IsK2ServerDocCountExceeded`, `IsK2ServerOnline`, the `cachepops` value of `GetMetricData`, and the "Spanish (Mexican)" locale of `SetLocale`. [CFML Reference p372-373](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- New functions in MX 6.0: `CreateObject` for components and web services, `GetAuthUser`, `GetEncoding`, `GetMetaData`, `GetPageContext`, `GetProfileSections`, `IsObject`, `IsUserInRole`, `IsXmlDoc`, `IsXmlElem`, `IsXmlRoot`, `SetEncoding`, `URLSessionFormat`, `XmlChildPos`, `XmlElemNew`, `XmlNew`, `XmlParse`, `XmlSearch`, `XmlTransform`, `XmlFormat`. Charset or encoding parameters were added to `URLDecode`, `URLEncodedFormat`, `ToBase64`, `ToString`. [CFML Reference p372-373](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- New functions in MX 6.1: `ReleaseComObject`, `Wrap`. Also new in 6.1: the `l` (millisecond) part or mask in `DateAdd`, `DatePart`, `TimeFormat`, `LSTimeFormat`; `URLDecode` default charset is the URL scope encoding; `URLEncodedFormat` default is the response encoding. [CFML Reference p372-373](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

**All 270 functions with signature, return value and history note.** Each function is listed once, under the first category named in its own entry; "Also listed under" gives its other categories. Signatures are the manual's syntax lines.


**Array functions** (19)

- `ArrayAppend(array, value)` (Ref p376) Returns: True, on successful completion. History: ColdFusion MX: Changed behavior: this function can be used on XML objects.
- `ArrayAvg(array)` (Ref p377) Returns: Number. If the array parameter value is an empty array, returns zero. Also listed under: Mathematical functions.
- `ArrayClear(array)` (Ref p379) Returns: True, on successful completion. History: ColdFusion MX: Changed behavior: this function can be used on XML objects.
- `ArrayDeleteAt(array, position)` (Ref p380) Returns: True, on successful completion. History: ColdFusion MX: • Changed behavior: this function can be used on XML objects. • Changed thrown exceptions: this function can throw the InvalidArrayIndexException error.
- `ArrayInsertAt(array, position, value)` (Ref p381) Returns: True, on successful completion. History: ColdFusion MX: • Changed behavior: this function can be used on XML objects. • Changed thrown exceptions: this function can throw the InvalidArrayIndexException error.
- `ArrayIsEmpty(array)` (Ref p382) Returns: True, if the array is empty; otherwise, False. History: ColdFusion MX: Changed behavior: this function can be used on XML objects.
- `ArrayLen(array)` (Ref p383) Returns: The number of elements in an array. History: ColdFusion MX: Changed behavior: this function can be used on child XML objects.
- `ArrayMax(array)` (Ref p384) Returns: The largest numeric value in an array. If the array parameter value is an empty array, returns zero.
- `ArrayMin(array)` (Ref p385) Returns: The smallest numeric value in an array. If the array parameter value is an empty array, returns zero.
- `ArrayNew(dimension)` (Ref p386) Returns: An array
- `ArrayPrepend(array, value)` (Ref p387) Returns: True, on successful completion.
- `ArrayResize(array, minimum_size)` (Ref p388) Returns: True, on successful completion.
- `ArraySet(array, start_pos, end_pos, value)` (Ref p389) Returns: True, on successful completion. History: ColdFusion MX: Changed behavior: this function can be used on XML objects.
- `ArraySort(array, sort_type [, sort_order ])` (Ref p390) Returns: True, if sort is successful; False, otherwise. Also listed under: List functions. History: ColdFusion MX: • Changed thrown exceptions: this function can throw the ArraySortSimpleValueException error and ValueNotNumeric error. • Changed the order in which sorted elements are returned: in a textnocase, descending sort, this ...
- `ArraySum(array)` (Ref p392) Returns: The sum of values in an array. If the array parameter value is an empty array, returns zero. Also listed under: Mathematical functions.
- `ArraySwap(array, position1, position2)` (Ref p393) Returns: True, on successful completion.
- `ArrayToList(array [, delimiter ])` (Ref p394) Returns: Delimited list, as a string. Also listed under: Conversion functions, List functions.
- `IsArray(value [, number ])` (Ref p524) Returns: True, if value is an array, or a query column object. Also listed under: Decision functions. History: ColdFusion MX: • Changed behavior: if the value attribute contains a reference to a query result column, this function now returns True. For example: isArray(MyQuery[’Column1’]) returns True. (In earlier releases, it returns False.) • ...
- `ListToArray(list [, delimiters ])` (Ref p589) Returns: An array Also listed under: Conversion functions, List functions.

**Authentication functions** (2)

- `GetAuthUser()` (Ref p479) Returns: The name of an authenticated user. History: ColdFusion MX: Added this function.
- `IsUserInRole("role_name")` (Ref p548) Returns: True, if the authenticated user, belongs to the specified Role; False, otherwise. Also listed under: Decision functions. History: ColdFusion MX: Added this function.

**Conversion functions** (9)

- `Hash(string)` (Ref p513) Returns: 32-byte, hexadecimal string Also listed under: Other functions, String functions.
- `ToBase64(string or binary_object[, encoding])` (Ref p721) Also listed under: Other functions, String functions. History: ColdFusion MX: Added the encoding attribute.
- `ToBinary(string_in_Base64 or binary_value)` (Ref p723) Returns: The binary representation of Base64-encoded data. Also listed under: Other functions, String functions.
- `ToString(any_value[, encoding])` (Ref p725) Returns: A string. Also listed under: Other functions, String functions. History: ColdFusion MX: • Changed Unicode support: ColdFusion supports the Java UCS-2 representation of Unicode character values 0–65535. (ColdFusion 5 and earlier releases supported ASCII values 1–255.) • Added the encoding attribute.
- `URLDecode(urlEncodedString[, charset])` (Ref p729) Returns: A copy of a string, decoded. Also listed under: Other functions, String functions. History: ColdFusion MX 6.1: Changed the default charset: the default charset is the character encoding of the URL scope. ColdFusion MX: • Changed Unicode support: ColdFusion supports the Java UCS-2 representation of Unicode character values ...
- `URLEncodedFormat(string [, charset ])` (Ref p731) Returns: A copy of a string, URL-encoded. Also listed under: Other functions, String functions. History: ColdFusion MX 6.1: Changed the default encoding to be the response character encoding. ColdFusion MX: Added the charset parameter.
- `Val(string)` (Ref p734) Returns: A number. If conversion fails, returns zero. Also listed under: String functions.
- `XmlParse(xmlString [, caseSensitive ] )` (Ref p744) Returns: An XML document object. Also listed under: Extensibility functions, XML functions. History: ColdFusion MX: Added this function.
- `XmlTransform(xmlString | xmlObj, xslString)` (Ref p746) Returns: A string; an XML document after the XSLT is applied Also listed under: Extensibility functions, XML functions. History: ColdFusion MX: Added this function.

**Date and time functions** (41)

- `CreateDate(year, month, day)` (Ref p419) Returns: A date/time value.
- `CreateDateTime(year, month, day, hour, minute, second)` (Ref p421) Returns: A date/time value.
- `CreateODBCDate(date)` (Ref p430) Returns: A date object, in normalized ODBC date format.
- `CreateODBCDateTime(date)` (Ref p432) Returns: A date/time object, in ODBC timestamp format.
- `CreateODBCTime(date)` (Ref p434) Returns: A time object, in ODBC timestamp format.
- `CreateTime(hour, minute, second)` (Ref p435) Returns: A time variable.
- `CreateTimeSpan(days, hours, minutes, seconds)` (Ref p436) Returns: A date/time object.
- `DateAdd("datepart", number, "date")` (Ref p439) Returns: A date/time object. History: ColdFusion MX 6.1: Added the datepart character L or l to represent milliseconds.
- `DateCompare("date1", "date2" [, "datePart"])` (Ref p441) Returns: • -1, if date1 is less than date2 • 0, if date1 is equal to date2 • 1, if date1 is greater than date2
- `DateConvert("conversion-type", "date")` (Ref p443) Returns: UTC- or local-formatted time object.
- `DateDiff("datepart", "date1", "date2")` (Ref p445) Returns: A number of units, of type datepart. History: ColdFusion MX: • Changed how negative date differences are calculated: this function calculates negative date differences correctly; its output may be different from that in earlier releases. • Changed the w and ww attributes; they ...
- `DateFormat("date" [, "mask" ])` (Ref p448) Returns: A text string representing the date formatted according to the mask. If no mask is specified, returns the value in dd-mmm-yy format. History: ColdFusion MX: Added support for the following mask attribute options: short, medium, long, and full.
- `DatePart("datepart", "date")` (Ref p450) Returns: Part of a date, as an integer. History: ColdFusion MX 6.1: Added the datepart character L or l to represent milliseconds.
- `Day("date")` (Ref p452) Returns: The ordinal for the day of the month, ranging from 1 to 31.
- `DayOfWeek("date")` (Ref p453) Returns: The ordinal for the day of the week, as an integer in the range 1 (Sunday) to 7 (Saturday).
- `DayOfWeekAsString(day_of_week)` (Ref p454) Returns: The day of the week, as a string that corresponds to day_of_week. Also listed under: String functions.
- `DayOfYear("date")` (Ref p455) Returns: The ordinal value of day of the year, as an integer.
- `DaysInMonth("date")` (Ref p456) Returns: The number of days in the month in Date.
- `DaysInYear("date")` (Ref p457) Returns: The number of days in a year.
- `FirstDayOfMonth(date)` (Ref p476) Returns: A number corresponding to a day-number in a year.
- `GetHttpTimeString(date_time_object)` (Ref p493) Returns: The time, as a string, according to the HTTP standard described in RFC 1123. Also listed under: International functions.
- `GetTickCount()` (Ref p508) Returns: A string representation of the system time, in milliseconds.
- `GetTimeZoneInfo()` (Ref p509) Returns: Structure that contains these elements and keys: • utcTotalOffset: offset of local time, in seconds, from UTC ■A plus sign indicates a time zone west ... Also listed under: International functions.
- `Hour(date)` (Ref p514) Returns: Ordinal value of the hour, in the range 0 - 23.
- `IsDate(string)` (Ref p531) Returns: True, if string can be converted to a date/time value; otherwise, False. ColdFusion converts the Boolean return value to its string equivalent, "Yes" ... Also listed under: Decision functions.
- `IsLeapYear(year)` (Ref p538) Returns: True, if year is a leap year; otherwise, False. Also listed under: Decision functions.
- `IsNumericDate(number)` (Ref p540) Returns: True, if the parameter represents a valid date/time object; otherwise, False. Also listed under: Decision functions.
- `LSDateFormat(date [, mask ])` (Ref p600) Returns: A formatted date/time value. If no mask is specified, the value is formatted according to the locale setting of the client computer. Also listed under: Display and formatting functions, International functions. History: ColdFusion MX: • Changed formatting behavior: this function might return different formatting than in earlier releases. This function uses Java standard locale formatting rules on all platforms. • Added support for the following mask ...
- `LSIsDate(string)` (Ref p607) Returns: True, if the string can be formatted as a date/time value in the current locale; False, otherwise. Also listed under: Display and formatting functions, International functions. History: ColdFusion MX: • Changed formatting behavior: this function might return a different result than in earlier releases. This function uses Java standard locale formatting rules on all platforms. • Changed behavior: this function accepts a ...
- `LSParseDateTime(date/time-string)` (Ref p615) Returns: A date/time object. Also listed under: Display and formatting functions, International functions, String functions. History: ColdFusion MX: • Changed formatting behavior: this function might not parse string formats that worked with earlier releases. This function uses Java standard locale formatting rules on all platforms. • Changed how the date/time-string ...
- `LSTimeFormat(time [, mask ])` (Ref p621) Returns: A string representing the time value. Also listed under: Display and formatting functions, International functions. History: ColdFusion MX 6.1: Added the mask character L or l to represent milliseconds. ColdFusion MX: • Changed formatting behavior: this function might return different formatting than in earlier releases. This function uses Java standard locale ...
- `Minute(date)` (Ref p627) Returns: The ordinal value of the minute, in the range 0–59.
- `Month(date)` (Ref p628) Returns: The ordinal value of the month, in the range 1 (January) – 12 (December).
- `MonthAsString(month_number)` (Ref p629) Returns: A string; the name of a month. Also listed under: String functions.
- `Now()` (Ref p630) Returns: A date/time object; the current date and time of the computer running the ColdFusion server.
- `ParseDateTime(date/time-string [, pop-conversion ] )` (Ref p636) Returns: A date/time object Also listed under: Display and formatting functions.
- `Quarter(date)` (Ref p641) Returns: An integer, 1–4.
- `Second(date)` (Ref p673) Returns: An integer in the range 0–59.
- `TimeFormat(time [, mask ])` (Ref p719) Returns: A custom-formatted time value. If no mask is specified, returns a time value using the hh:mm tt format. For international time formatting, see ... Also listed under: Display and formatting functions. History: ColdFusion MX 6.1: Added the mask character L or l to represent milliseconds. ColdFusion MX: • Changed the way extra characters are processed: this function processes extra characters within the mask value differently than in earlier ...
- `Week(date)` (Ref p736) Returns: An integer in the range 1–53; the ordinal of the week, within the year.
- `Year(date)` (Ref p747) Returns: The year value of date.

**Decision functions** (22)

- `IIf(condition, string_expression1, string_expression2)` (Ref p517) Returns: If result is True, returns the value of Evaluate(string_expression1); otherwise, returns the value of Evaluate(string_expression2). Also listed under: Dynamic evaluation functions.
- `IsBinary(value)` (Ref p527) Returns: True, if the value is binary; False, otherwise.
- `IsBoolean(value)` (Ref p528) Returns: True, if the parameter can be converted to Boolean; False, otherwise.
- `IsCustomFunction(name)` (Ref p529) Returns: True, if name can be called as a custom function; False, otherwise.
- `IsDebugMode()` (Ref p532) Returns: True, if debugging mode is set in the ColdFusion Administrator; False if debugging mode is disabled.
- `IsDefined("variable_name")` (Ref p533) Returns: True, if the variable is found, or, for a structure, if the specified key is defined; False, otherwise. Returns False for an array or structure ... History: ColdFusion MX: Changed behavior: this function can process only the following constructs: • a simple variable • a named variable with dot notation • a named structure with dot notation (for example: mystruct.key)
- `IsK2ServerABroker()` (Ref p535) Returns: True, if K2Broker is in configured with ColdFusion; False, otherwise. Also listed under: Full-text search functions, Query functions. History: ColdFusion MX 6.1: Deprecated this function. It might not work, and it might cause an error, in later releases. ColdFusion MX: Added this function.
- `IsK2ServerDocCountExceeded()` (Ref p536) Returns: True, if the document count limit is exceeded; False, otherwise. Also listed under: Full-text search functions, Query functions. History: ColdFusion MX 6.1: Deprecated this function. It might not work, and it might cause an error, in later releases. ColdFusion 5: Added this function.
- `IsK2ServerOnline()` (Ref p537) Returns: True, if the K2Server is available to perform a search; False, otherwise. Also listed under: Full-text search functions, Query functions. History: ColdFusion MX 6.1: Deprecated this function. It might not work, and it might cause an error, in later releases. ColdFusion MX: Added this function.
- `IsNumeric(string)` (Ref p539) Returns: True, if string can be converted to a number; otherwise, False.
- `IsObject(value)` (Ref p541) Returns: True, if the value represents a ColdFusion object. False if the value is any other type of data, such as an integer, string, date, or struct. History: ColdFusion MX: Added this function.
- `IsQuery(value)` (Ref p544) Returns: True, if value is a query. Also listed under: Query functions.
- `IsSimpleValue(value)` (Ref p545) Returns: True, if value is a string, number, Boolean, or date/time value; False, otherwise.
- `IsStruct(variable)` (Ref p546) Returns: True, if variable is a ColdFusion structure or is a Java object that implements the java.lang.Map interface. Returns False if the object in variable ... Also listed under: Structure functions. History: ColdFusion MX: Changed behavior: this function can be used on XML objects.
- `IsWDDX` (Ref p549) Returns: True, if the value is a well-formed WDDX packet; False, otherwise. Also listed under: XML functions. History: ColdFusion MX: Changed behavior: if the value parameter is not a WDDX packet, ColdFusion returns False. (In earlier releases, ColdFusion threw an error.)
- `IsXmlDoc(value)` (Ref p551) Returns: True, if the function argument is an XML document object; False, otherwise. Also listed under: XML functions. History: ColdFusion MX: Added this function.
- `IsXmlElem(value)` (Ref p552) Returns: True, if the function argument is an XML document object element; False, otherwise. Also listed under: XML functions. History: ColdFusion MX: Added this function.
- `IsXmlRoot(value)` (Ref p553) Returns: True, if the function argument is the root object of an XML document object; False, otherwise. Also listed under: XML functions. History: ColdFusion MX: Added this function.
- `LSIsNumeric(string)` (Ref p609) Returns: True, if the string represents a number the current locale; False, otherwise. Also listed under: International functions, String functions. History: ColdFusion MX: Changed formatting behavior: this function might return a different result than in earlier releases. This function uses Java standard locale formatting rules on all platforms.
- `StructIsEmpty(structure)` (Ref p707) Returns: True, if structure is empty; if structure does not exist, ColdFusion throws an exception. Also listed under: Structure functions. History: ColdFusion MX: Changed behavior: this function can be used on XML objects.
- `StructKeyExists(structure, "key")` (Ref p710) Returns: True, if key is in structure; if structure does not exist, ColdFusion throws an exception. Also listed under: Structure functions.
- `YesNoFormat(value)` (Ref p748) Returns: Yes, for a non-zero value; No, otherwise. Also listed under: Display and formatting functions.

**Display and formatting functions** (17)

- `Cjustify(string, length)` (Ref p412) Returns: String, center-justified by adding spaces before or after the input parameter. If length is less than the length of the input parameter string, the ... Also listed under: String functions.
- `DecimalFormat(number)` (Ref p460) Returns: A number as a string formatted with two decimal places and a thousands separator.
- `DollarFormat(number)` (Ref p465) Returns: A number as a string, formatted with two decimal places, thousands separator, and dollar sign. If number is negative, the return value is enclosed in ...
- `FormatBaseN(number, radix)` (Ref p478) Returns: String that represents number, in the base radix. Also listed under: Mathematical functions, String functions.
- `GetLocale()` (Ref p496) Returns: The current locale value, as a string. Also listed under: International functions, System functions. History: ColdFusion MX: Changed behavior: this function determines whether a locale value is set. (The value is set with the SetLocale function.) • If the locale value is present, the function now returns it. • If the locale has not been explicitly ...
- `HTMLCodeFormat(string [, version ])` (Ref p515) Returns: HTML-escaped string string, enclosed in <pre> and </pre> tags. Returns are removed from string. Special characters (> < " &) are escaped.
- `HTMLEditFormat(string [, version ])` (Ref p516) Returns: HTML-escaped string string. Returns are removed from string. Special characters (for example, < " &) are escaped.
- `LJustify(string, length)` (Ref p594) Returns: A copy of a string, left-justified. Also listed under: String functions.
- `LSCurrencyFormat(number [, type ])` (Ref p597) Returns: A formatted currency value. Also listed under: International functions. History: ColdFusion MX: Changed formatting behavior: this function might return different formatting than in earlier releases. If a negative number is passed to it, it returns a negative number. If type = "local", it returns the value in the ...
- `LSEuroCurrencyFormat(currency-number [, type ])` (Ref p602) Returns: A formatted currency value. For countries in the Euro currency zone, the function uses the locale’s rule’s for formatting currency in euros. Also listed under: International functions. History: ColdFusion MX: Changed formatting behavior: this function might return different formatting than in earlier releases. This function uses Java locale formatting rules on all platforms, except that it uses the rule detailed in the Usage ...
- `LSIsCurrency(string)` (Ref p605) Returns: True, if the parameter is formatted as a valid currency amount, including the appropriate currency indicator. Returns True for amounts in the local, ... Also listed under: Decision functions, International functions. History: ColdFusion MX: Changed formatting behavior: this function might return a different result than in earlier releases. This function uses Java standard locale formatting rules on all platforms; the results might vary depending upon the JVM; ...
- `LSNumberFormat(number [, mask ])` (Ref p610) Returns: A formatted number. • If no mask is specified, it returns the number formatted as an integer • If no mask is specified, truncates the decimal part; ... Also listed under: International functions. History: ColdFusion MX: • Changed behavior: if the specified mask format cannot correctly mask a number, this function returns the number unchanged. (In earlier releases, it truncated the number or threw an error.) (If no mask is specified, ...
- `LTrim(string)` (Ref p623) Returns: A copy of the string, without leading spaces. Also listed under: String functions.
- `NumberFormat(number [, mask ])` (Ref p631) Returns: A formatted number value: • If no mask is specified, returns the value as an integer with a thousands separator. • If the parameter value is "" (an ... History: ColdFusion MX: Changed behavior: if the mask format cannot correctly mask a number, this function returns the number unchanged. (It does not truncate the number nor throw an error.) (If no mask is selected, ColdFusion MX rounds the decimal ...
- `ParagraphFormat(string)` (Ref p634) Returns: A copy of the string, with characters converted. Also listed under: String functions.
- `RJustify(string, length)` (Ref p670) Returns: A copy of a string, right-justified in the specified field length. Also listed under: String functions.
- `StripCR(string)` (Ref p688) Returns: A copy of string, after removing return characters. Also listed under: Other functions, String functions.

**Dynamic evaluation functions** (3)

- `DE(string)` (Ref p458) Returns: Parameter, surrounded by double quotation marks, with any inner double quotation marks escaped.
- `Evaluate(string_expression1 [, string_expression2 [, … ] ] )` (Ref p468) Returns: An object; the result of the evaluation(s).
- `SetVariable(name, value)` (Ref p680) Returns: The new value of the variable.

**Extensibility functions** (7)

- `CreateObject(type, class, context, serverName) CreateObject(type, component-name) CreateObject(type, context, class, locale) CreateObject(type, class) CreateObject(type, urltowsdl)` (Ref p423) Returns: An object, of the specified type. Note: You can enable and disable this function in the ColdFusion Administrator, ColdFusion Basic Security, Tag ... History: ColdFusion MX: • Changed instantiation behavior: this function, and the cfobject tag, can instantiate ColdFusion components and web services. Executing operations on a CFC object executes CFML code that implements the CFC's method in the ...
- `ReleaseComObject(objectName)` (Ref p657) Returns: Nothing. History: ColdFusion MX 6.1: Added this function.
- `XmlChildPos(elem, childName, N)` (Ref p739) Returns: The position, in an XmlChildren array, of the Nth child that has the specified name. Also listed under: XML functions. History: ColdFusion MX: Added this function.
- `XmlElemNew(xmlObj, childName)` (Ref p740) Returns: An XML document object element. Also listed under: XML functions. History: ColdFusion MX: Added this function.
- `XmlFormat(string)` (Ref p741) Returns: A copy of string that is safe to use with XML. Also listed under: String functions, XML functions. History: ColdFusion MX: Added this function.
- `XmlNew([caseSensitive])` (Ref p742) Returns: An empty XML document object. Also listed under: XML functions. History: ColdFusion MX: Added this function.
- `XmlSearch(xmlDoc, xPathString)` (Ref p745) Returns: An array of XML object nodes that match the search criteria. Also listed under: XML functions. History: ColdFusion MX: Added this function.

**Full-text search functions** (2)

- `GetK2ServerDocCount()` (Ref p494) Returns: The number of collection metadata items stored in Verity collections. Also listed under: Query functions. History: ColdFusion MX 6.1: Deprecated this function. It might not work, and it might cause an error, in later releases. ColdFusion MX: Added this function.
- `GetK2ServerDocCountLimit()` (Ref p495) Returns: Number of collection metadata items that the K2 server permits, as an integer Also listed under: Query functions. History: ColdFusion MX 6.1: Deprecated this function. It might not work, and it might cause an error, in later releases. ColdFusion MX: Added this function.

**International functions** (6)

- `GetEncoding(scope_name)` (Ref p487) Returns: String; the character encoding of the specified scope. Also listed under: System functions. History: ColdFusion MX: Added this function.
- `LSParseCurrency(string)` (Ref p613) Returns: A formatted number (string representation of a number) that matches the value of the parameter. Also listed under: String functions. History: ColdFusion MX: Changed formatting behavior: this function might return different formatting than in earlier releases. This function uses Java standard locale formatting rules on all platforms.
- `LSParseEuroCurrency(currency-string)` (Ref p617) Returns: A formatted number that matches the value of the string. Also listed under: String functions. History: ColdFusion MX: Changed formatting behavior: this function might return different formatting than in earlier releases. This function uses Java locale formatting rules on all platforms, except that it uses the rule detailed in the Usage ...
- `LSParseNumber(string)` (Ref p619) Returns: A formatted number that matches the value of the string. Also listed under: String functions. History: ColdFusion MX: Changed formatting behavior: this function might return different formatting than in earlier releases. This function uses Java standard locale formatting rules on all platforms.
- `SetEncoding(scope_name,charset)` (Ref p674) Returns: None Also listed under: System functions. History: ColdFusion MX: Added this function.
- `SetLocale(new_locale)` (Ref p676) Returns: The locale value prior to setting the new locale, as a string. Also listed under: System functions. History: ColdFusion MX: • Changed formatting behavior: this function might return a different value than in earlier releases. This function uses Java standard locale determination and formatting rules on all platforms. • Deprecated the Spanish ...

**List functions** (21)

- `GetClientVariablesList()` (Ref p483) Returns: Comma-delimited list of non-read-only client variables, as a string. Also listed under: Other functions.
- `ListAppend(list, value [, delimiters ])` (Ref p561) Returns: A copy of the list, with value appended. If delimiter = "", returns a copy of the list, unchanged.
- `ListChangeDelims(list, new_delimiter [, delimiters ])` (Ref p563) Returns: A copy of the list, with each delimiter character replaced by new_delimiter.
- `ListContains(list, substring [, delimiters ])` (Ref p564) Returns: Index of the first list element that contains substring. If not found, returns zero.
- `ListContainsNoCase(list, substring [, delimiters ])` (Ref p566) Returns: Index of the first list element that contains substring, regardless of case. If not found, returns zero.
- `ListDeleteAt(list, position [, delimiters ])` (Ref p567) Returns: A copy of the list, without the specified element.
- `ListFind(list, value [, delimiters ])` (Ref p569) Returns: Index of the first list element that contains value, with matching case. If not found, returns zero. The search is case-sensitive.
- `ListFindNoCase(list, value [, delimiters ])` (Ref p571) Returns: Index of the first list element that contains value. If not found, returns zero. The search is case- insensitive.
- `ListFirst(list [, delimiters ])` (Ref p573) Returns: The first element of a list. If the list is empty, returns an empty string.
- `ListGetAt(list, position [, delimiters ])` (Ref p574) Returns: Index of the list element at position position.
- `ListInsertAt(list, position, value [, delimiters ])` (Ref p576) Returns: A copy of the list, with value inserted at the specified position.
- `ListLast(list [, delimiters ])` (Ref p577) Returns: The last element of the list.
- `ListLen(list [, delimiters ])` (Ref p579)
- `ListPrepend(list, value [, delimiters ])` (Ref p580) Returns: A copy of the list, with value inserted at the first position.
- `ListQualify(list, qualifier [, delimiters ] [, elements ])` (Ref p582) Returns: A copy of the list, with qualifier before and after the specified element(s). History: ColdFusion MX: Changed behavior: as the elements parameter value, you must specify "all" or "char"; otherwise, ColdFusion throws an exception. (In earlier releases, the function ignored an invalid value, and used "all"; this was ...
- `ListRest(list [, delimiters ])` (Ref p584) Returns: A copy of list, without the first element. If list has one element, returns an empty list.
- `ListSetAt(list, position, value [, delimiters ])` (Ref p585) Returns: A copy of a list, with a new value assigned to the element at a specified position. History: ColdFusion MX: Changed delimiter modification: ColdFusion MX does not modify delimiters in the list. (In earlier releases, in some cases, replaced delimiters with the first character in the delimiters parameter.)
- `ListSort(list, sort_type [, sort_order] [, delimiters ])` (Ref p587) Returns: A copy of a list, sorted. History: ColdFusion MX: Changed the order in which sorted elements are returned: in a textnocase, descending sort, this function might return elements in a different sort order than in earlier releases. If sort_type = "textnocase" and sort_order = ...
- `ListValueCount(list, value [, delimiters ])` (Ref p590) Returns: The number of instances of value in the list. Also listed under: String functions.
- `ListValueCountNoCase(list, value [, delimiters ])` (Ref p592) Returns: The number of instances of value in the list.
- `ReplaceList(string, list1, list2)` (Ref p661) Returns: A copy of the string, after making replacements. Also listed under: String functions.

**Mathematical functions** (34)

- `Abs(number)` (Ref p374) Returns: The absolute value of a number.
- `ACos(number)` (Ref p375) Returns: The arccosine, in radians, of a number.
- `ASin(number)` (Ref p396) Returns: The arcsine, in radians, of a number.
- `Atn(number)` (Ref p398) Returns: The arctangent, in radians, of a number.
- `BitAnd(number1, number2)` (Ref p401) Returns: The bitwise AND of two long integers.
- `BitMaskClear(number, start, length)` (Ref p402) Returns: A number, bitwise cleared, with length bits beginning at start.
- `BitMaskRead(number, start, length)` (Ref p403) Returns: An integer, created from length bits of number, beginning at start.
- `BitMaskSet(number, mask, start, length)` (Ref p404) Returns: A number, bitwise masked with length bits of mask beginning at start.
- `BitNot(number)` (Ref p405) Returns: A number; the bitwise NOT of a long integer.
- `BitOr(number1, number2)` (Ref p406) Returns: A number; the bitwise OR of two long integers.
- `BitSHLN(number, count)` (Ref p407) Returns: A number, bitwise shifted without rotation to the left by count bits.
- `BitSHRN(number, count)` (Ref p408) Returns: A number, bitwise shifted, without rotation, to the right by count bits.
- `BitXor(number1, number2)` (Ref p409) Returns: Bitwise XOR of two long integers.
- `Ceiling(number)` (Ref p410) Returns: The closest integer that is greater than a given number.
- `Cos(number)` (Ref p417) Returns: A number; the cosine of the angle.
- `DecrementValue(number)` (Ref p461) Returns: Integer part of number, decremented by one.
- `Exp(number)` (Ref p469) Returns: The constant e, raised to the power of number.
- `Fix(number)` (Ref p477) Returns: If number is greater than or equal to 0, the closest integer less than number. If number is less than 0, the closest integer greater than number.
- `IncrementValue(number)` (Ref p520) Returns: The integer part of number, incremented by one.
- `InputBaseN(string, radix)` (Ref p521) Returns: A number in the range 2-36, as a string.
- `Int(number)` (Ref p523) Returns: An integer, as a string.
- `Log(number)` (Ref p595) Returns: The natural logarithm of a number.
- `Log10(number)` (Ref p596) Returns: Number; the logarithm of number, to base 10.
- `Max(number1, number2)` (Ref p624) Returns: The greater of two numbers.
- `Min(number1, number2)` (Ref p626) Returns: The lesser of two numbers.
- `Pi()` (Ref p638) Returns: The number 3.14159265358979.
- `Rand()` (Ref p648) Returns: A random decimal number, in the range 0 – 1.
- `Randomize(number)` (Ref p649) Returns: A non-random decimal number, in the range 0 – 1.
- `RandRange(number1, number2)` (Ref p650) Returns: A random integer
- `Round(number)` (Ref p671) Returns: An integer.
- `Sgn(number)` (Ref p682) Returns: • 1, if number is positive. • 0, if number is 0. • -1, if number is negative.
- `Sin(number)` (Ref p683) Returns: A number; the sine of the angle.
- `Sqr(number)` (Ref p687) Returns: Number; square root of number.
- `Tan(number)` (Ref p717) Returns: A number; the tangent of an angle.

**No category line in the entry (obsolete or deprecated; see cross-check)** (7)

- `AuthenticatedContext` (Ref p399) History: ColdFusion MX: This function is obsolete. It does not work in ColdFusion MX and later ColdFusion releases.
- `AuthenticatedUser` (Ref p400) History: ColdFusion MX: This function is obsolete. It does not work in ColdFusion MX and later ColdFusion releases. BitAnd
- `GetTemplatePath` (Ref p507) History: ColdFusion MX: Deprecated this function. It might not work, and it might cause an error, in later releases.
- `IsAuthenticated` (Ref p525) History: ColdFusion MX: This function is obsolete. It does not work in ColdFusion MX and later ColdFusion releases.
- `IsAuthorized` (Ref p526) History: ColdFusion MX: This function is obsolete. It does not work in ColdFusion MX and later releases. IsBinary
- `IsProtected` (Ref p543) History: ColdFusion MX: This function is obsolete. It does not work in ColdFusion MX and later releases.
- `ParameterExists` (Ref p635) History: ColdFusion MX: Deprecated this function. It might not work, and might cause an error, in later releases.

**Other functions** (11)

- `CreateUUID()` (Ref p438) Returns: A ColdFusion format UUID, in the format xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxxxxxx, where x is a hexadecimal digit (0-9 or A-F). (The character groups are ...
- `Decrypt(encrypted_string, seed)` (Ref p462) Returns: String, unencrypted. Also listed under: String functions.
- `DeleteClientVariable("name")` (Ref p463) Returns: True, if the variable is successfully deleted; false, otherwise. History: ColdFusion MX: Changed behavior: if the variable is not present, this function now returns False. (In earlier releases, it threw an error.)
- `Encrypt(string, seed)` (Ref p467) Returns: String; can be much longer than the original string. Also listed under: String functions.
- `GetBaseTagData(tagname [, instancenumber ] )` (Ref p480) Returns: An object that contains data (variables, scopes, and so on) from an ancestor tag. If there is no ancestor by the specified name, or if the ancestor ...
- `GetBaseTagList()` (Ref p481) Returns: A comma-delimited list of uppercase ancestor tag names, as a string. The first list element is the current tag. If the current tag is nested, the ...
- `GetBaseTemplatePath()` (Ref p482) Returns: The absolute path of the application base page, as a string. Also listed under: System functions.
- `PreserveSingleQuotes(variable)` (Ref p639) Returns: (None) History: ColdFusion MX: Changed behavior: ColdFusion automatically escapes simple-variable, array- variable, and structure-variable references within a cfquery tag body or block. (Earlier releases did not automatically escape array-variable ...
- `URLSessionFormat(request_URL)` (Ref p733) Returns: A URL; if cookies are disabled for the browser, client and session data are appended.
- `ValueList(query.column [, delimiter ])` (Ref p735) Returns: A delimited list of the values of each record returned from an executed query. Also listed under: Query functions.
- `WriteOutput(string)` (Ref p738)

**Query functions** (5)

- `QueryAddColumn(query, column-name, array-name)` (Ref p642) Returns: The number of the column that was added. History: ColdFusion MX: Changed behavior: if a user attempts to add a column whose name is invalid, ColdFusion throws an error. (In earlier releases, ColdFusion permitted the add operation, but the user could not reference the column after adding ...
- `QueryAddRow(query [, number ])` (Ref p644) Returns: The number of rows in the query
- `QueryNew(columnlist)` (Ref p645) Returns: An empty query with a set of named columns, or an empty query.
- `QuerySetCell(query, column_name, value [, row_number ])` (Ref p646) Returns: True, if successful; False, otherwise.
- `QuotedValueList(query.column [, delimiter ])` (Ref p647) Returns: A delimited list of the values of each record returned from an executed query. Each value is enclosed in single quotation marks.

**String functions** (31)

- `Asc(string)` (Ref p395) Returns: The value of the first character of a string; if string is empty, returns zero. History: ColdFusion MX: Changed Unicode support: ColdFusion supports the Java UCS-2 representation of Unicode characters, up to a value of 65536. (Earlier releases supported 1-255.)
- `Chr(number)` (Ref p411) Returns: A character with the specified UCS-2 character code. History: ColdFusion MX: Changed Unicode support: ColdFusion supports the Java UCS-2 representation of Unicode characters, up to a value of 65535. (Earlier releases supported 1-255.)
- `Compare(string1, string2)` (Ref p413) Returns: • -1, if string1 is less than string2 • 0, if string1 is equal to string2 • 1, if string1 is greater than string2
- `CompareNoCase(string1, string2)` (Ref p415) Returns: An indicator of the difference: • A negative number, if string1 is less than string2 • 0, if string1 is equal to string2 • A positive number, if ...
- `Find(substring, string [, start ])` (Ref p473) Returns: A number; the position of substring in string; or 0, if substring is not in string.
- `FindNoCase(substring, string [, start ])` (Ref p474) Returns: The position of substring in string; or 0, if substring is not in string.
- `FindOneOf(set, string [, start ])` (Ref p475) Returns: The position of the first member of set found in string; or 0, if no member of set is found in string.
- `GetToken(string, index [, delimiters ])` (Ref p510) Returns: The token found at position index of the string, as a string. If index is greater than the number of tokens in the string, returns an empty string.
- `Insert(substring, string, position)` (Ref p522) Returns: A string.
- `JavaCast(type, variable)` (Ref p554) Returns: The variable, as type type.
- `JSStringFormat(string)` (Ref p556) Returns: A string that is safe to use with JavaScript.
- `LCase(string)` (Ref p557) Returns: A string, converted to lowercase.
- `Left(string, count)` (Ref p558) Returns: String; the first count characters in the string parameter.
- `Len(string or binary object)` (Ref p560) Returns: Number; length of a string or a binary object. History: ColdFusion MX: Changed Unicode support: ColdFusion supports the Java UCS-2 representation of Unicode character values 0–65535. (ColdFusion 5 and earlier releases supported ASCII values 1–255. When calculating a length, some ...
- `Mid(string, start, count)` (Ref p625) Returns: A string; the set of characters from string, beginning at start, of length count.
- `REFind(reg_expression, string [, start ] [, returnsubexpressions ] )` (Ref p651) Returns: Depends on the value of the returnsubexpressions parameter: • If returnsubexpressions = "False": ■The position in the string where the match begins ...
- `REFindNoCase(reg_expression, string [, start] [, returnsubexpressions] )` (Ref p654) Returns: Depends on the value of the returnsubexpressions parameter: • If returnsubexpressions = "False": ■The position in the string where the match begins ...
- `RemoveChars(string, start, count)` (Ref p658) Returns: A copy of the string, with count characters removed from the specified start position. If no characters are found, returns zero.
- `RepeatString(string, count)` (Ref p659) Returns: A string.
- `Replace(string, substring1, substring2 [, scope ])` (Ref p660) Returns: The string, after making replacements.
- `ReplaceNoCase(string, substring1, substring2 [, scope ])` (Ref p663) Returns: A copy of the string, after making replacements.
- `REReplace(string, reg_expression, substring [, scope ])` (Ref p664) Returns: If the scope attribute is set to one, returns a string with the first occurrence of the regular expression replaced by the value of substring. If the ... History: ColdFusion MX: Added supports for the following special codes in a replacement substring, to control case conversion: • \u - uppercase the next character • \l - lowercase the next character • \U - uppercase until \E • \L - lowercase until ...
- `REReplaceNoCase(string, reg_expression, substring [, scope ])` (Ref p666) Returns: • If scope = "one": returns a string with the first occurrence of the regular expression replaced by the value of substring. • If scope = "all": ... History: ColdFusion MX: Changed behavior: this function inserts the following special characters in regular expression replacement strings, to control case conversion: \u, \U, \l, \L, and \E. If any of these strings is present in a ColdFusion 5 ...
- `Reverse(string)` (Ref p668) Returns: A copy of string, with the characters in reverse order.
- `Right(string, count)` (Ref p669) Returns: • If the length of the string is greater than or equal to count, the rightmost count characters of the string • If count is greater than the length ...
- `RTrim(string)` (Ref p672) Returns: A copy of string, after removing trailing spaces.
- `SpanExcluding(string, set)` (Ref p685) Returns: A string; characters from string, from the beginning to a character that is in set.
- `SpanIncluding(string, set)` (Ref p686) Returns: A string; characters from string, from the beginning to a character that is not in set.
- `Trim(string)` (Ref p727) Returns: A copy of string, after removing leading and trailing spaces.
- `UCase(string)` (Ref p728) Returns: A copy of a string, converted to uppercase.
- `Wrap(string, limit[, strip])` (Ref p737) Returns: String containing the wrapped text. History: ColdFusion MX 6.1: Added this function

**Structure functions** (16)

- `Duplicate(variable_name)` (Ref p466) Returns: A clone of a variable. Also listed under: System functions. History: ColdFusion MX: Changed behavior: this function can be used on XML objects.
- `StructAppend(struct1, struct2, overwriteFlag)` (Ref p689) Returns: True, upon successful completion; False, otherwise. History: ColdFusion MX: Changed behavior: this function can be used on XML objects.
- `StructClear(structure)` (Ref p691) Returns: True, on successful execution; False, otherwise. History: ColdFusion MX: Changed behavior: this function can be used on XML objects.
- `StructCopy(structure)` (Ref p693) Returns: A copy of a structure, with the same keys and values; if structure does not exist, throws an exception.
- `StructCount(structure)` (Ref p697) Returns: A number; if structure does not exist, throws an exception. History: ColdFusion MX: Changed behavior: this function can be used on XML objects.
- `StructDelete(structure, key [, indicatenotexisting ])` (Ref p698) Returns: Boolean value. The value depends on the indicatenotexisting parameter value. History: ColdFusion MX: Changed behavior: this function can be used on XML objects.
- `StructFind(structure, key)` (Ref p700) Returns: The value associated with a key in a structure; if structure does not exist, throws an exception.
- `StructFindKey(top, value, scope)` (Ref p701) Returns: An array that contains structures with values that match value.
- `StructFindValue( top, value [, scope])` (Ref p702) Returns: An array that contains structures with values that match the search key value. If none are found, returns an array of size 0.
- `StructGet(pathDesired)` (Ref p703) Returns: An alias to the variable in the pathDesired parameter. If necessary, StructGet creates structures or arrays to make pathDesired a valid variable ... History: ColdFusion MX: • Changed behavior: this function can be used on XML objects. • Changed behavior: if there is no structure or array present in oathDesired, this function creates structures or arrays to make pathDesired a valid variable ...
- `StructInsert(structure, key, value [, allowoverwrite ])` (Ref p705) Returns: True, upon successful completion. If structure does not exist, or if key exists and allowoverwrite = "False", ColdFusion throws an exception. History: ColdFusion MX: Changed behavior: this function can be used on XML objects.
- `StructKeyArray(structure)` (Ref p708) Returns: An array of keys; if structure does not exist, ColdFusion throws an exception.
- `StructKeyList(structure [, delimiter])` (Ref p711) Returns: A list of keys; if structure does not exist, ColdFusion throws an exception.
- `StructNew()` (Ref p713) Returns: A structure.
- `StructSort(base, sortType, sortOrder, pathToSubElement)` (Ref p714) Returns: An array of top-level key names (strings), sorted by the value of the specified subelement.
- `StructUpdate(structure, key, value)` (Ref p716) Returns: True, on successful execution; if the structure does not exist, ColdFusion throws an error. History: ColdFusion MX: Changed behavior: this function can be used on XML objects.

**System functions** (17)

- `DirectoryExists(absolute_path)` (Ref p464) Returns: Yes, if the specified directory exists; No, otherwise.
- `ExpandPath(relative_path)` (Ref p470) Returns: A string. If the relative path contains a trailing forward slash or backward slash, the return value contains the same trailing character. History: ColdFusion MX: Changed behavior for the relative_path attribute: this function can now accept an absolute or relative path in the relative_path attribute. To resolve a path, this function uses virtual mappings that are defined in the ...
- `FileExists(absolute_path)` (Ref p472) Returns: Yes, if the file specified in the parameter exists; No, otherwise. Also listed under: Decision functions.
- `GetCurrentTemplatePath()` (Ref p484) Returns: The absolute path of the page that contains the call to this function, as a string.
- `GetDirectoryFromPath(path)` (Ref p485) Returns: Absolute path, without the filename. The last character is a forward or backward slash, depending on the operating system.
- `GetException` (Ref p488) Returns: Any Java exception object raised by a previous method call on the Java object.
- `GetFileFromPath(path)` (Ref p489) Returns: Filename, as a string.
- `GetFunctionList()` (Ref p490) Returns: A structure of functions.
- `GetHttpRequestData()` (Ref p491) Returns: A ColdFusion structure.
- `GetMetaData(object) or, if used within a ColdFusion component: GetMetaData(this)` (Ref p497) Returns: Key-value pairs, as a component descriptor data structure or as structured XML History: ColdFusion MX: Added this function.
- `GetMetricData(mode)` (Ref p499) Returns: ColdFusion structure that contains metric data, depending on the mode value. History: ColdFusion MX: Deprecated the cachepops parameter. It might not work, and it might cause an error, in later releases.
- `GetPageContext()` (Ref p501) Returns: The current ColdFusion MX Java PageContext Java object. History: ColdFusion MX: Added this function.
- `GetProfileSections(iniFile)` (Ref p502) Returns: An initialization file, as a struct whose format is as follows: • Each initialization file section name is a key in the struct • Each list of entries ... History: ColdFusion MX: Added this function.
- `GetProfileString(iniPath, section, entry)` (Ref p503) Returns: An entry in an initialization file, as a string. If there is no value, returns an empty string.
- `GetTempDirectory()` (Ref p505) Returns: The absolute pathname of a directory, including a trailing slash, as a string. History: ColdFusion MX: Changed behavior: on Windows, this function now returns the temporary directory of the embedded Java application server. On other platforms, it returns the temporary directory of the operating system.
- `GetTempFile(dir, prefix)` (Ref p506) Returns: Name of a temporary file, as a string.
- `SetProfileString(iniPath, section, entry, value)` (Ref p678) Returns: An empty string, upon successful execution; otherwise, an error message.


### Inferences

- The manual has no category called "XML functions", "Security functions" or "Conversion" in the sense the brief used: XML functions are filed under "Extensibility functions" (and some under Conversion or Decision); security functions are under "Authentication functions"; the old security functions have no category.

### Gaps

- Return value text is clipped to about 150 characters and history to about 240 characters in the generated list; read the cited page for the full text.

## Database: what do cfquery, cfqueryparam, cfstoredproc, cftransaction and the query functions offer in 6.1?

### Takeaway

6.1 has parameterised queries, stored procedures, simple transactions and SELECT-only query of queries. It has no `result` attribute, so the manual documents no way to get generated keys or affected row counts from the tag.

### Cited Findings

**cfquery** [CFML Reference p282-285](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- Attributes: `name` (required), `dataSource` (required unless `dbtype="query"`), `dbtype` (only useful value: `query`), `username`, `password`, `maxRows` (default -1, all rows), `blockFactor` (default 1, range 1 to 100), `timeout` (seconds), `cachedAfter` (date), `cachedWithin` (CreateTimeSpan value), `debug`.
- There is no `result` attribute. The tag sets `cfquery.ExecutionTime` (milliseconds).
- Query variables: `queryname.CurrentRow`, `queryname.RecordCount`, `queryname.ColumnList`. [CFML Reference p25-28](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- History: MX changed query of queries to support a larger SQL subset; `connectString`, `dbName`, `dbServer`, `provider`, `providerDSN`, `sql` and all `dbtype` values except `query` are deprecated and do not work.
- Example:

```cfm
<cfquery name="qUser" datasource="#Application.dsn#" maxrows="1">
    SELECT id, email FROM users
    WHERE id = <cfqueryparam value="#Arguments.id#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfif qUser.RecordCount EQ 1><cfset email = qUser.email[1]></cfif>
```

**cfqueryparam** [CFML Reference p286-288](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- Attributes: `value` (required), `CFSQLType` (default `CF_SQL_CHAR`), `maxLength`, `scale` (default 0), `null` (default No; Yes ignores `value` and binds NULL), `list` (default No), `separator` (default comma).
- Types: CF_SQL_BIGINT, CF_SQL_BIT, CF_SQL_CHAR, CF_SQL_BLOB, CF_SQL_CLOB, CF_SQL_DATE, CF_SQL_DECIMAL, CF_SQL_DOUBLE, CF_SQL_FLOAT, CF_SQL_IDSTAMP, CF_SQL_INTEGER, CF_SQL_LONGVARCHAR, CF_SQL_MONEY, CF_SQL_MONEY4, CF_SQL_NUMERIC, CF_SQL_REAL, CF_SQL_REFCURSOR, CF_SQL_SMALLINT, CF_SQL_TIME, CF_SQL_TIMESTAMP, CF_SQL_TINYINT, CF_SQL_VARCHAR.
- Gotcha: the `CF_SQL_` prefix is required in 6.1 (omitting it is allowed only from ColdFusion 11, see the "Not in 6.1" table).

**cfstoredproc, cfprocparam, cfprocresult** [CFML Reference p328-329](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [CFML Reference p274-278](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- cfstoredproc attributes: `procedure` (required), `dataSource` (required), `username`, `password`, `blockFactor`, `debug`, `returnCode` (default No). Sets `cfstoredproc.statusCode` (when `returnCode="Yes"`) and `cfstoredproc.ExecutionTime`. No `result` attribute.
- cfprocparam attributes: `type` (in, out, inout; default in), `variable` (required for out and inout), `value` (required for in and inout), `CFSQLType` (required), `maxLength`, `scale`, `null`. `dbvarname` is ignored in MX: parameters are positional, so cfprocparam tags must be in the procedure's parameter order. `maxrows` is obsolete.
- cfprocresult attributes: `name` (required), `resultSet` (default 1), `maxRows` (default -1).

**cftransaction** [CFML Reference p343](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- Attributes: `action` (begin, commit, rollback; default begin), `isolation` (read_uncommitted, read_committed, repeatable_read, serializable).
- No savepoints. Use nested `<cftransaction action="commit"/>` or `action="rollback"` inside the outer tag.
- Example:

```cfm
<cftransaction>
    <cftry>
        <cfquery datasource="#dsn#" name="q1">UPDATE a SET x = 1</cfquery>
        <cfquery datasource="#dsn#" name="q2">UPDATE b SET y = 2</cfquery>
        <cfcatch type="database">
            <cftransaction action="rollback"/>
            <cfrethrow>
        </cfcatch>
    </cftry>
</cftransaction>
```

**Query functions**

- `QueryNew(columnlist)` returns an empty query; there is no column type list argument in 6.1. [CFML Reference p645](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `QueryAddRow(query [, number])` returns the total number of rows; `QuerySetCell(query, column_name, value [, row_number])` returns True, default row is the last row; `QueryAddColumn(query, column-name, array-name)` returns the column number. [CFML Reference p642-646](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `ValueList(query.column [, delimiter])`, `QuotedValueList(query.column [, delimiter])`, `PreserveSingleQuotes(variable)`. [CFML Reference p735](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [CFML Reference p647](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [CFML Reference p639](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `IsQuery(value)` is the only query test. Columns are addressed as `q.col[row]` or `q["col"][row]`. [CFML Reference p544](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- Example:

```cfm
<cfset q = QueryNew("id,name")>
<cfset QueryAddRow(q, 2)>
<cfset QuerySetCell(q, "id", 1, 1)>
<cfset QuerySetCell(q, "name", "first", 1)>
```

**Query of queries (dbtype="query")** [Developing ColdFusion MX Applications p451-475](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)

- SELECT only. Grammar: SELECT [ALL | DISTINCT] columns FROM table list [WHERE] [GROUP BY] [HAVING] [UNION [ALL]] [ORDER BY]. [Developing ColdFusion MX Applications p474-475](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)
- Joins only between two tables, written as a comma list in FROM plus a WHERE condition. No INNER JOIN syntax and no OUTER JOIN. [Developing ColdFusion MX Applications p462-463](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)
- No table aliases. Column aliases are allowed and can be reused in ORDER BY, GROUP BY and HAVING. [Developing ColdFusion MX Applications p470](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)
- Conditions: comparison operators (=, <>, !=, <, <=, >, >=), IS [NOT] NULL, BETWEEN, IN, LIKE, and Boolean tests. [Developing ColdFusion MX Applications p465-466](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)
- Aggregates: COUNT, AVG, SUM, MIN, MAX. Expressions are limited to literals, column references and + - * /. The grammar lists no scalar functions such as UPPER, LOWER or CAST. [Developing ColdFusion MX Applications p474-475](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)
- Comparisons against NULL need an explicit IS NOT NULL guard. [Developing ColdFusion MX Applications p471](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)
- Reserved words used as column names are escaped with square brackets; escapes cannot be nested. [Developing ColdFusion MX Applications p471-472](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)
- ODBC-formatted dates are not supported inside query of queries. [Developing ColdFusion MX Applications p463](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)

**Shipped database drivers** [Configuring and Administering ColdFusion MX p38-39](cfmx_6.1_docs_en/cfmx61_config_admin.pdf)

- DB2 Universal Database 6.x, 7.2 and OS/390 (type 4), Informix 9.x (type 4), Microsoft Access (type 3), Microsoft Access with Unicode (type 2), Microsoft SQL Server 7.x and 2000 (type 4), MySQL (type 4), ODBC Socket (type 3), Oracle 8.1.7 and 9i (type 4), Sybase 11.5, 11.9, 12.0, 12.5 (type 4), and "Other" for any JDBC driver.
- Not every type 4 driver is in the Standard Edition. Data source names `service`, `jms_provider`, `comp`, `jms` are reserved.
- No PostgreSQL driver is listed; it would have to be added through "Other" with a JDBC driver.
- `cfcatch.SQLState` and `cfcatch.NativeErrorCode` are available for database exceptions; the SQLSTATE value depends on the driver type. [CFML Reference p64](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

### Inferences

- Generated keys: because there is no `result` attribute, the only route is database-specific SQL in the same connection, for example a second statement such as `SELECT @@IDENTITY` or `SELECT LAST_INSERT_ID()` inside the same `cftransaction`. This is not described in the 6.1 manuals; it follows from the absence of any other mechanism.
- Affected row count: same reasoning; use database-specific SQL (for example `SELECT @@ROWCOUNT` in the same batch on SQL Server) or a stored procedure output parameter.
- Whether one cfquery may contain two statements depends on the driver and database, not on CFML.

### Gaps

- No manual page confirms that two cfquery tags inside one cftransaction always use the same physical connection; this is the usual assumption behind the identity workaround and should be tested on the target server.
- The JDBC driver version of the bundled MySQL driver, and which MySQL server versions it can talk to, was not looked up.

## HTTP and output: headers, content, redirects, cookies, cfhttp and request data

### Takeaway

6.1 can set any header and status code with cfheader, but cflocation always sends a 302, cfcookie cannot set HttpOnly, and cfhttp has no `result` attribute and no PATCH method.

### Cited Findings

**cfheader** [CFML Reference p171](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- Two forms: `name` + `value` (optional `charset`, default UTF-8), or `statusCode` + optional `statusText`.
- Throws an error if used after cfflush.
- Example of a 301 redirect, which cflocation cannot do in 6.1:

```cfm
<cfheader statuscode="301" statustext="Moved Permanently">
<cfheader name="Location" value="#newUrl#">
<cfabort>
```

**cfcontent** [CFML Reference p87-89](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- Attributes: `type` (MIME type, may include `; charset=`), `file` (absolute path to send), `deleteFile` (default No), `reset` (default Yes: discards output generated before the tag).
- No `variable` attribute, so binary data held in memory cannot be sent with this tag; write it to a file first and use `file`.
- The tag can be disabled in the Administrator (sandbox or basic security).

**cflocation** [CFML Reference p220](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- Attributes: `url` (required), `addToken` (default Yes: appends CFID and CFTOKEN when client or session management is on).
- No `statusCode` attribute. Has no effect after cfflush. Processing of the page stops at the tag.
- Set `addToken="No"` to keep CFID and CFTOKEN out of redirect URLs.

**cfcookie** [CFML Reference p91-92](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- Attributes: `name` (required), `value`, `expires` (date, number of days, `now`, `never`), `secure` (Yes or No), `path`, `domain` (must start with a period; required when `path` is used).
- No `httpOnly` attribute. Cookie names are stored upper case.
- HttpOnly workaround: send the cookie yourself with `<cfheader name="Set-Cookie" value="...; HttpOnly">`.

**cfflush** [CFML Reference p130](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- Attribute: `interval` (bytes). After the first flush these fail or throw: cfcontent, cfcookie, cfform, cfheader, cfhtmlhead, cflocation, and SetLocale.

**cfhtmlhead** [CFML Reference p173](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): attribute `text`; writes into the head of the page. Not usable after cfflush.

**cfcache** [CFML Reference p59-61](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `action` (cache, flush, clientcache, servercache, optimal), `directory`, `timespan`, `expireURL`, `username`, `password`, `port`, `protocol`.

**cfhttp** [CFML Reference p174-182](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- Attributes: `url` (required), `port`, `method` (GET default; POST, PUT, DELETE, HEAD, TRACE, OPTIONS), `proxyServer`, `proxyPort` (80), `proxyUser`, `proxyPassword`, `username`, `password`, `userAgent` (default "ColdFusion"), `charset`, `resolveURL` (No), `throwOnError` (No), `redirect` (Yes; follows up to 4 redirects), `timeout` (seconds), `getAsBinary` (No, Auto, Yes), `multipart` (No), `path`, `file`, `name`, `columns`, `firstrowasheaders` (Yes), `delimiter`, `textQualifier`.
- No `result` attribute. Results are always in the `cfhttp` structure: `cfhttp.charSet`, `cfhttp.errorDetail`, `cfhttp.fileContent`, `cfhttp.header` (raw), `cfhttp.mimeType`, `cfhttp.responseHeader` (structure), `cfhttp.statusCode` (for example "200 OK"), `cfhttp.text` (Boolean).
- No PATCH method. No client certificate attributes.
- Gotcha: because the result variable is always named `cfhttp`, copy the fields you need before making a second request.

**cfhttpparam** [CFML Reference p183-185](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- Attributes: `type` (Header, CGI, Body, XML, File, URL, FormField, Cookie), `name`, `value`, `file`, `encoded` (default Yes; applies to FormField and CGI), `mimeType` (File).
- `type="body"` and `type="xml"` send the value as the request body.
- Example:

```cfm
<cfhttp url="http://example.com/api" method="POST" timeout="10" charset="utf-8">
    <cfhttpparam type="header" name="Accept" value="text/xml">
    <cfhttpparam type="formfield" name="q" value="#term#">
</cfhttp>
<cfset status = Val(cfhttp.statusCode)>
<cfset body = cfhttp.fileContent>
```

**GetHttpRequestData()** [CFML Reference p491](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- Returns a structure with `content` (string when the content type starts with "text/" or is application/x-www-form-urlencoded, otherwise binary), `headers` (structure), `method`, `protocol`.
- This is the way to read arbitrary request headers and a raw request body.

**GetPageContext()** [CFML Reference p501](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- New in MX. Returns the Java PageContext object for the request; the manual documents `include` and `forward`, for example `GetPageContext().include("hello.jsp?name=Bobby")`.

**Other**

- `GetHttpTimeString(date_time_object)` exists in 6.1 and returns an RFC 1123 time string in UTC. [CFML Reference p493](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `GetEncoding(scope_name)` for Form or URL, and `SetEncoding(scope_name, charset)`. [CFML Reference p487](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [CFML Reference p674](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `URLSessionFormat(request_URL)` appends session identifiers when cookies are off. [CFML Reference p733](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

### Inferences

- `GetPageContext().getResponse()` and `getRequest()` return the servlet response and request objects (standard javax.servlet.jsp.PageContext behaviour), which gives access to methods such as `setStatus`, `setHeader`, `getOutputStream`. The 6.1 manual only shows `include` and `forward`, so anything beyond those is undocumented territory on 6.1.
- A 303, 307 or 301 redirect needs cfheader plus cfabort.

### Gaps

- Whether a cookie set with cfcookie on the same page as a cflocation is delivered was not checked in the 6.1 manual; test it on the target server.
- HTTPS support details of cfhttp (certificate store, TLS versions of the bundled JVM) were not researched.

## Files: cffile, cfdirectory and the path functions

### Takeaway

All file work in 6.1 goes through the cffile and cfdirectory tags. There are no File* or Directory* functions other than FileExists and DirectoryExists, no `result` attribute and no recursive directory listing.

### Cited Findings

**cffile** [CFML Reference p110-129](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- Actions: `append`, `copy`, `delete`, `move`, `read`, `readBinary`, `rename`, `upload`, `write`.
- Attributes by action:
  - read: `file`, `variable`, `charset`.
  - readBinary: `file`, `variable`.
  - write and append: `file`, `output`, `addNewLine` (default Yes), `attributes`, `mode` (UNIX), `charset`.
  - copy, move, rename: `source`, `destination`, `attributes`, `mode`.
  - delete: `file`.
  - upload: `fileField`, `destination`, `nameConflict` (Error default, Skip, Overwrite, MakeUnique), `accept` (MIME type list), `attributes`, `mode`.
- `attributes` values: readOnly, hidden, normal.
- No `result` attribute. Upload status is always in the `cffile` structure: attemptedServerFile, clientDirectory, clientFile, clientFileExt, clientFileName, contentSubType, contentType, dateLastAccessed, fileExisted, fileSize, fileWasAppended, fileWasOverwritten, fileWasRenamed, fileWasSaved, oldFileSize, serverDirectory, serverFile, serverFileExt, serverFileName, timeCreated, timeLastModified.
- 6.1 changes: a relative path is resolved against the ColdFusion temporary directory returned by GetTempDirectory(), so always pass absolute paths; on read, a byte order mark is used to determine the encoding.
- Example:

```cfm
<cffile action="read" file="#ExpandPath('./data.txt')#" variable="txt" charset="utf-8">
<cffile action="write" file="#GetTempDirectory()#out.txt" output="#txt#" addnewline="No" charset="utf-8">
```

**cfdirectory** [CFML Reference p95-97](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- Attributes: `action` (list default, create, delete, rename), `directory` (required, absolute), `name` (query name for list), `filter` (one pattern such as `*.cfm`), `mode`, `sort` (for example `name ASC, size DESC`), `newDirectory` (rename).
- List result columns: name, size, type, dateLastModified, attributes, mode.
- No `recurse` attribute; recursion must be written by hand (a recursive function calling cfdirectory).

**Functions**

- `FileExists(absolute_path)`, `DirectoryExists(absolute_path)`. [CFML Reference p472](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [CFML Reference p464](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `ExpandPath(relative_path)` returns the absolute platform path for a relative or mapped path. [CFML Reference p470](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `GetTempDirectory()`, `GetTempFile(dir, prefix)` (creates the file and returns its name; only the first three characters of the prefix are used). [CFML Reference p505-506](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `GetDirectoryFromPath(path)`, `GetFileFromPath(path)`. [CFML Reference p485](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [CFML Reference p489](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `GetBaseTemplatePath()` is the top-level requested page; `GetCurrentTemplatePath()` is the page that contains the call (an included file or a component file). [CFML Reference p482](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [CFML Reference p484](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `GetTemplatePath()` is deprecated. [CFML Reference p507](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `GetProfileString`, `SetProfileString`, `GetProfileSections` read and write .ini files. [CFML Reference p502-503](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [CFML Reference p678](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

### Inferences

- Anything the tags cannot do (streaming, file size without a directory listing, recursive delete, checking canonical paths) can be done with `CreateObject("java", "java.io.File")`, since Java objects are fully supported by CreateObject.
- File metadata for a single file: use cfdirectory with `filter` set to the file name.

### Gaps

- Maximum upload size limits and the behaviour of `accept` matching were not read in detail.
- Whether cfdirectory delete removes a non-empty directory, and whether a cftransaction may span more than one data source, were not checked in the manual.
- Whether the fixed result structures (`cfhttp`, `cffile`, `cfquery`, `cfstoredproc`) can be made function-local with `var` in 6.1 was not checked; concurrent use inside shared components is a thread-safety risk to test.

## Mail: cfmail, cfmailparam, cfmailpart

### Takeaway

6.1 sends mail over plain SMTP with optional SMTP AUTH. cfmailpart (new in 6.1) gives multipart text plus HTML. The manual documents no SSL or TLS attributes.

### Cited Findings

**cfmail** [CFML Reference p240-245](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- Required: `to`, `from`, `subject`.
- Optional: `cc`, `bcc`, `replyto`, `failto`, `username`, `password` (both must be given together), `wraptext` (column to wrap at; default no wrapping), `charset` (default from the Administrator, UTF-8 out of the box), `type` (text/plain default; `text`, `plain`, `html` or a MIME type), `mimeattach` (file path), `query`, `group`, `groupcasesensitive`, `startrow` (1), `maxrows`, `server`, `port`, `mailerid` (default "ColdFusion MX Application Server"), `timeout`, `spoolenable`.
- `server` accepts `[user:password@]server[:port]` and a comma list; multiple servers need the Enterprise edition.
- `spoolenable="Yes"` (default) writes the message to the spool on disk and returns; `No` sends immediately and a delivery error throws an Application exception.
- Gotcha: with spooling, attachments are read when the spooler delivers, not when the tag runs, so do not delete an attached file right after the tag.
- New in 6.1: `charset`, `failto`, `replyto`, `username`, `password`, `wraptext`, multiple servers.

**cfmailparam** [CFML Reference p246](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): either `file` (attachment) with optional `type` (MIME type, new in 6.1), or `name` + `value` (a mail header).

**cfmailpart** [CFML Reference p248](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): new in 6.1. Attributes: `type` (required; text, plain, html or MIME type), `charset`, `wraptext`. For multipart mail all body content must be inside cfmailpart tags; put the simplest part (plain text) first.

Example:

```cfm
<cfmail to="#rcpt#" from="#sender#" subject="#subj#" server="#smtpHost#" port="25"
        username="#smtpUser#" password="#smtpPass#" charset="utf-8" spoolenable="Yes">
    <cfmailparam name="X-Mailer" value="app">
    <cfmailpart type="text" wraptext="72">#textBody#</cfmailpart>
    <cfmailpart type="html">#htmlBody#</cfmailpart>
</cfmail>
```

### Inferences

- With no `useSSL` or `useTLS` attribute, SMTP over SSL or STARTTLS is not available through cfmail on 6.1; a local relay or JavaMail through CreateObject would be needed.

### Gaps

- Whether the 6.1 JVM mail properties can be set to force SSL was not researched. `priority` is not an attribute in 6.1; use cfmailparam with an `X-Priority` header (header name is standard mail practice, not from the manual).

## Strings and patterns

### Takeaway

6.1 has Perl-style regular expressions through REFind and REReplace only (no REMatch), MD5-only Hash, a weak proprietary Encrypt, and list functions that always ignore empty elements.

### Cited Findings

**Regular expression functions**

- `REFind(reg_expression, string [, start] [, returnsubexpressions])` returns the match position (0 if none), or with `returnsubexpressions=True` a structure with arrays `len` and `pos` (element 1 is the whole match, then each subexpression). `REFindNoCase` is the same, case-insensitive. [CFML Reference p651-655](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `REReplace(string, reg_expression, substring [, scope])`, scope `one` (default) or `all`; in the replacement `\1` to `\9` are backreferences and `\u`, `\l`, `\U`, `\L`, `\E` change case. `REReplaceNoCase` likewise. [CFML Reference p664-666](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- There is no REMatch. To extract all matches, loop on REFind with `returnsubexpressions` and `Mid`.
- Engine (MX is Perl-compatible): character classes, POSIX classes such as `[[:space:]]`, `[[:alnum:]]`, `[[:upper:]]`; escapes `\w \W \d \D \s \S \b \B \A \Z`; `(?i)`, `(?m)`, `(?x)` at the start of the expression; non-capturing `(?:...)`; positive lookahead `(?=...)`; negative lookahead `(?!...)`; backreferences in the pattern; minimal matching `*?`, `+?`, `??`, `{min,}?`, `{min,max}?`. [Developing ColdFusion MX Applications p143-162](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)
- Example (collect all matches):

```cfm
<cfset matches = ArrayNew(1)>
<cfset pos = 1>
<cfloop condition="true">
    <cfset m = REFind("[0-9]+", str, pos, true)>
    <cfif m.pos[1] EQ 0><cfbreak></cfif>
    <cfset ArrayAppend(matches, Mid(str, m.pos[1], m.len[1]))>
    <cfset pos = m.pos[1] + m.len[1]>
</cfloop>
```

**Find and replace**

- `Find(substring, string [, start])`, `FindNoCase`, `FindOneOf(set, string [, start])` return a position or 0. [CFML Reference p473-475](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `Replace(string, substring1, substring2 [, scope])`, `ReplaceNoCase`, scope `one` (default) or `all`. `ReplaceList(string, list1, list2)`. [CFML Reference p660-663](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- Other: `Left`, `Right`, `Mid(string, start, count)`, `Len`, `Trim`, `LTrim`, `RTrim`, `UCase`, `LCase`, `Reverse`, `RepeatString`, `Insert`, `RemoveChars`, `SpanIncluding`, `SpanExcluding`, `Compare`, `CompareNoCase`, `StripCR`, `Chr(number)`, `Asc(string)`, `Val(string)`, `Wrap(string, limit [, strip])` (6.1). See the inventory for signatures.

**List functions and delimiter rules**

- Empty elements are ignored: `"a,b,c,,,d"` has 4 elements. A delimiters string of several characters means each character is a delimiter, not a multi-character delimiter. [CFML Reference p579](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `ListToArray(list [, delimiters])` has no option to keep empty fields. [CFML Reference p589](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `ListAppend(list, value [, delimiters])` uses only the first character of `delimiters` when adding. [CFML Reference p561](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- Also: `ListChangeDelims`, `ListContains`, `ListContainsNoCase`, `ListDeleteAt`, `ListFind`, `ListFindNoCase`, `ListFirst`, `ListGetAt`, `ListInsertAt`, `ListLast`, `ListLen`, `ListPrepend`, `ListQualify`, `ListRest`, `ListSetAt`, `ListSort`, `ListValueCount`, `ListValueCountNoCase`. [CFML Reference p561-592](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- Gotcha: to split a string while keeping empty fields, do not use list functions; walk the string with Find and Mid, or call `string.split()` on the underlying Java string (see Inferences).

**Encoding, hashing, encryption**

- `Hash(string)`: MD5 only, returns 32 hexadecimal characters. No algorithm or encoding argument. [CFML Reference p513](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `Encrypt(string, seed)` and `Decrypt(encrypted_string, seed)`: a proprietary seed-based algorithm with no algorithm choice; output can contain non-printable characters, so wrap with `ToBase64` or `URLEncodedFormat` for transport. [CFML Reference p467](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [CFML Reference p462](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `CreateUUID()`: 35 characters in the form 8-4-4-16, which is not the standard 8-4-4-4-12 layout. [CFML Reference p438](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `ToBase64(string or binary_object [, encoding])`, `ToBinary(base64 or binary)`, `ToString(any_value [, encoding])`. [CFML Reference p721-725](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `URLEncodedFormat(string [, charset])`, `URLDecode(urlEncodedString [, charset])`. [CFML Reference p729-731](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `HTMLEditFormat(string [, version])` escapes special characters (the manual says "for example, < \" &") and removes carriage returns; the `version` argument is ignored; `HTMLCodeFormat` does the same and wraps the text in a pre tag; `JSStringFormat(string)`; `XmlFormat(string)` escapes `<`, `>`, `&`, `'`, `"`. [CFML Reference p515-516](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [CFML Reference p556](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [CFML Reference p741](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `JavaCast(type, variable)` with types boolean, int, long, float, double, String; for calls to overloaded Java methods. [CFML Reference p554](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- There are no CharsetEncode, CharsetDecode, BinaryEncode, BinaryDecode or GenerateSecretKey functions.

**Formatting and locale**

- `NumberFormat`, `DecimalFormat`, `DollarFormat`, `DateFormat(date [, mask])`, `TimeFormat(time [, mask])`, `YesNoFormat`, `ParagraphFormat`, `FormatBaseN`, `LJustify`, `RJustify`, `CJustify`. [CFML Reference p367-371](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- Locale-sensitive: `LSCurrencyFormat`, `LSDateFormat`, `LSEuroCurrencyFormat`, `LSIsCurrency`, `LSIsDate`, `LSIsNumeric`, `LSNumberFormat`, `LSParseCurrency`, `LSParseDateTime`, `LSParseEuroCurrency`, `LSParseNumber`, `LSTimeFormat`. [CFML Reference p593-621](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `GetLocale()` returns the current locale name; `SetLocale(new_locale)` returns the previous locale. Locale names are in the form "English (US)"; the supported list is in `Server.ColdFusion.SupportedLocales`. SetLocale fails after cfflush. [CFML Reference p496](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [CFML Reference p676](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- Character set control: `cfprocessingdirective pageEncoding`, `cfcontent type="text/html; charset=utf-8"`, `SetEncoding`, `GetEncoding`, and the `charset` attributes of cffile, cfhttp, cfmail, cfheader.

### Inferences

- CFML strings are java.lang.String objects in MX, so Java methods can be called on them (for example `str.split(",")`, `str.getBytes("UTF-8")`). This is common practice on MX but is not a documented guarantee in the 6.1 manuals.
- Stronger hashes (SHA-1, SHA-256) on 6.1 need `CreateObject("java", "java.security.MessageDigest")`; real encryption needs javax.crypto through CreateObject.
- Lookbehind (`(?<=...)`) is not mentioned in the 6.1 regular expression chapter, so it should be assumed unsupported.

### Gaps

- The manual does not give the full list of characters HTMLEditFormat escapes (only "for example, < \" &"); whether the single quote is escaped is not stated, so do not rely on it for attribute values in single quotes.
- Page numbers for the less used string functions are in the generated inventory, not repeated here.

## Collections: arrays and structures

### Takeaway

Arrays and structures are built only through functions (ArrayNew, StructNew); most mutating functions return True, not the collection. There are no literals, no search functions for arrays and no iteration functions.

### Cited Findings

**Array functions (complete set in 6.1)** [CFML Reference p376-394](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- `ArrayNew(dimension)` returns an array (1 to 3 dimensions).
- `ArrayLen(array)` number; `ArrayIsEmpty(array)` Boolean; `IsArray(value [, number])` Boolean.
- Return True on success: `ArrayAppend(array, value)`, `ArrayPrepend(array, value)`, `ArrayInsertAt(array, position, value)`, `ArrayDeleteAt(array, position)`, `ArrayClear(array)`, `ArrayResize(array, minimum_size)`, `ArraySet(array, start_pos, end_pos, value)`, `ArraySwap(array, position1, position2)`, `ArraySort(array, sort_type [, sort_order])` (sort_type numeric, text, textnocase; order asc or desc).
- `ArrayToList(array [, delimiter])` string; `ListToArray(list [, delimiters])` array.
- `ArrayAvg`, `ArrayMax`, `ArrayMin`, `ArraySum` return a number (0 for an empty array).
- Function arguments: integers, real numbers, strings (including lists), date-time objects and arrays are passed by value (the function gets a copy); queries, structures and external objects such as COM objects are passed by reference. [Developing ColdFusion MX Applications p202](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)

**Structure functions (complete set in 6.1)** [CFML Reference p689-716](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

- `StructNew()` structure; `StructCount(structure)` number; `StructIsEmpty(structure)` Boolean; `IsStruct(variable)` Boolean (also True for java.util.Map objects).
- `StructKeyExists(structure, "key")` Boolean; throws if the structure itself does not exist. [CFML Reference p710](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `StructInsert(structure, key, value [, allowoverwrite])` True (throws if the key exists and allowoverwrite is False, the default); `StructUpdate(structure, key, value)` True (throws if the key is missing); `StructAppend(struct1, struct2, overwriteFlag)` True (overwriteFlag default Yes); `StructClear(structure)` True; `StructDelete(structure, key [, indicatenotexisting])` Boolean. [CFML Reference p698](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `StructFind(structure, key)` value (throws if missing); `StructFindKey(top, value, scope)` and `StructFindValue(top, value [, scope])` return arrays of structures.
- `StructKeyArray(structure)` array; `StructKeyList(structure [, delimiter])` list; `StructSort(base, sortType, sortOrder, pathToSubElement)` array of keys.
- `StructCopy(structure)` copies the top level only (nested structures are shared); `Duplicate(variable_name)` makes a deep copy but cannot duplicate COM, CORBA or Java objects. [CFML Reference p693](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [CFML Reference p466](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `StructGet(pathDesired)` returns the structure at a path and creates missing levels.
- Keys are case-insensitive; key order is not preserved; keys written with dot notation are stored upper case.

**StructKeyExists versus IsDefined**

- `IsDefined("variable_name")` takes a string, searches scopes, and in MX accepts only simple variable names and dot notation; it returns False for bracket or array notation such as `IsDefined("myArray[3]")`. [CFML Reference p533](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `StructKeyExists(scope_or_struct, "key")` tests exactly one structure and accepts any key string. Scopes such as Variables, Form, URL, Arguments, Session, Application and Request can be passed as the structure.

**Not available in 6.1**: array and structure literals; ArrayContains, ArrayFind, ArrayIsDefined, ArrayDelete, ArraySlice, ArrayEach, ArrayMap, ArrayFilter; StructEach, StructMap; ListRemoveDuplicates; member functions. See the "Not in 6.1" table for versions.

Example:

```cfm
<cfset a = ArrayNew(1)>
<cfset ArrayAppend(a, "x")>
<cfset s = StructNew()>
<cfset s.name = "n">
<cfset s["mixedCase"] = 1>
<cfloop collection="#s#" item="k">
    <cfoutput>#k#=#s[k]#</cfoutput>
</cfloop>
<cfloop index="i" from="1" to="#ArrayLen(a)#"><cfoutput>#a[i]#</cfoutput></cfloop>
```

### Inferences

- Testing whether an array index holds a value (ArrayIsDefined) has no 6.1 function; wrap the access in cftry or keep arrays dense.
- Searching an array for a value needs a loop, or `ListFind(ArrayToList(a), value)` for simple values without delimiters in them.

### Gaps

- The statements about key case and key order come from general MX behaviour described in the Developing guide chapter on structures; the exact page was not recorded.

## Decision functions

### Takeaway

6.1 has type tests for the basic CFML types only. There is no general validator, no null test and no JSON or XML string test.

### Cited Findings

- Present in 6.1: `IsArray`, `IsBinary`, `IsBoolean`, `IsCustomFunction`, `IsDate`, `IsDebugMode`, `IsDefined`, `IsLeapYear`, `IsNumeric`, `IsNumericDate`, `IsObject`, `IsQuery`, `IsSimpleValue`, `IsStruct`, `IsUserInRole`, `IsWDDX`, `IsXmlDoc`, `IsXmlElem`, `IsXmlRoot`, `LSIsCurrency`, `LSIsDate`, `LSIsNumeric`, plus `DirectoryExists`, `FileExists`, `StructKeyExists`, `StructIsEmpty`, `ArrayIsEmpty`, `YesNoFormat`. Deprecated or obsolete but present: `ParameterExists`, `IsK2Server*`, `IsAuthenticated`, `IsAuthorized`, `IsProtected`. [CFML Reference p367-371](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- Absent from the 6.1 function list: `IsValid`, `IsNull`, `IsInstanceOf`, `IsJSON`, `IsXML`, `IsImage`, `IsClosure`, `IsUserLoggedIn`, `IsUserInAnyRole`, `IsLocalHost`. [CFML Reference p374-748](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- Arrival versions: IsValid 7, IsXML 7, IsInstanceOf 8, IsJSON 8, IsNull 9. [cfdocs isvalid](https://cfdocs.org/isvalid) [cfdocs isxml](https://cfdocs.org/isxml) [cfdocs isinstanceof](https://cfdocs.org/isinstanceof) [cfdocs isjson](https://cfdocs.org/isjson) [cfdocs isnull](https://cfdocs.org/isnull)

### Inferences

- An integer test on 6.1: `IsNumeric(x) AND x EQ Int(x)` or a regular expression such as `REFind("^-?[0-9]+$", x)`.
- An instance test on 6.1: walk `GetMetaData(obj)` and its `extends` chain comparing `name`.

### Gaps

- None beyond the versions cited.

## Serialisation: WDDX, XML and saved content

### Takeaway

The only built-in serialisation formats are WDDX and XML. There is no JSON support of any kind.

### Cited Findings

- **cfwddx** [CFML Reference p358](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `action` (cfml2wddx, wddx2cfml, cfml2js, wddx2js), `input` (required), `output` (variable name; required for wddx2cfml), `topLevelVariable` (for the two js actions), `useTimeZoneInfo` (default Yes), `validate` (default No). WDDX packets are UTF-8. `IsWDDX(value)` tests a packet.
- **cfxml** [CFML Reference p361](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `variable` (required), `caseSensitive` (default No). The tag body is the XML text; do not put an `<?xml ?>` declaration in it.
- **XML functions** (new in MX): `XmlParse(xmlString [, caseSensitive])`, `XmlNew([caseSensitive])`, `XmlElemNew(xmlObj, childName)`, `XmlChildPos(elem, childName, N)`, `XmlSearch(xmlDoc, xPathString)` (array of elements), `XmlTransform(xmlString | xmlObj, xslString)` (string), `XmlFormat(string)`, `IsXmlDoc`, `IsXmlElem`, `IsXmlRoot`, and `ToString(xmlDoc)` to serialise. [CFML Reference p739-748](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- **cfsavecontent** [CFML Reference p300](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `variable` (required); captures everything generated in the body, including included pages and custom tag output.
- No SerializeJSON, DeserializeJSON or IsJSON in the function list. [CFML Reference p374-748](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

Example:

```cfm
<cfwddx action="cfml2wddx" input="#data#" output="packet">
<cfwddx action="wddx2cfml" input="#packet#" output="copy">
<cfsavecontent variable="html"><cfinclude template="view.cfm"></cfsavecontent>
```

### Inferences

- JSON on 6.1 must be written in CFML (a recursive encoder over IsSimpleValue, IsArray, IsStruct, IsQuery, and a hand-written parser). Number versus string detection is ambiguous because CFML simple values are untyped.

### Gaps

- XmlValidate and XmlGetNodeType arrived in version 7 ([cfdocs xmlvalidate](https://cfdocs.org/xmlvalidate), [cfdocs xmlgetnodetype](https://cfdocs.org/xmlgetnodetype)); DTD or schema validation on 6.1 was not researched.

## Runtime and system tags and functions

### Takeaway

The application framework in 6.1 is Application.cfm plus OnRequestEnd.cfm and the cfapplication tag. Components, user-defined functions, Java objects, locking, logging and structured exceptions all exist; threads, timers and script-based components do not.

### Cited Findings

- **cfapplication** [CFML Reference p51](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `name` (required for application and session scopes), `loginStorage` (cookie default, or session; 6.1), `clientManagement` (No), `clientStorage`, `setClientCookies` (Yes), `sessionManagement` (No), `sessionTimeout`, `applicationTimeout` (CreateTimeSpan values), `setDomainCookies` (No). Normally placed in Application.cfm. There is no Application.cfc.
- **cfsetting** [CFML Reference p321](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `enableCFoutputOnly` (required), `showDebugOutput` (Yes), `requestTimeOut` (seconds; replaces the RequestTimeout URL parameter of ColdFusion 5). Nested `enableCFoutputOnly="Yes"` calls are counted and must be balanced by the same number of "No" calls.
- **cflock** [CFML Reference p221](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `timeout` (required, seconds), `scope` (Application, Server, Session) or `name` (mutually exclusive), `throwOnTimeout` (Yes), `type` (readOnly or exclusive; default exclusive).
- **cflog** [CFML Reference p226](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `text` (required), `log` (Application or Scheduler), `file` (base name only, no path or extension; written to the ColdFusion logs directory), `type` (Information default, Warning, Error, Fatal), `application` (Yes). `thread`, `date`, `time` are deprecated.
- **cftrace** [CFML Reference p341](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `abort`, `category`, `inline`, `text`, `type`, `var`; needs debugging enabled in the Administrator. New in MX.
- **cfdump** [CFML Reference p98](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `var` (required), `expand` (Yes), `label`. No `abort`, `output`, `top`, `format`.
- **cfthrow** [CFML Reference p338](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `type` (default Application), `message`, `detail`, `errorCode`, `extendedInfo`, or `object` alone (a Java exception object).
- **cftry and cfcatch** [CFML Reference p353](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [CFML Reference p64](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): cfcatch `type` values application, database, template, security, object, missingInclude, expression, lock, searchengine, a custom type, or any (default). A custom dotted type is matched by its prefixes (`a.b.c` is caught by `a.b`). cfcatch variables: Type, Message, Detail, TagContext (array of structures), and by type ErrorCode, ExtendedInfo, NativeErrorCode, SQLState, ErrNumber, MissingFileName, LockName, LockOperation. No cffinally.
- **cfrethrow** [CFML Reference p297](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): rethrows the current exception from inside cfcatch.
- **cferror** [CFML Reference p102](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `type` (exception, validation, request), `template`, `mailTo`, `exception`.
- **cfexecute** [CFML Reference p106](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `name` (absolute path of the program), `arguments` (string or array), `outputFile`, `variable` (6.1), `timeout` (seconds; default 0, which is non-blocking mode: ColdFusion does not wait for the program, so set a timeout to capture output). No attribute for the error stream.
- **cfschedule** [CFML Reference p301](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `action` (update, delete, run), `task`, `operation` (HTTPRequest), `url`, `startDate`, `startTime`, `endDate`, `endTime`, `interval` (once, daily, weekly, monthly, or seconds), `requestTimeOut`, `port` (80), `publish`, `file`, `path`, `username`, `password`, `proxyServer`, `proxyPort`, `proxyUser`, `proxyPassword`, `resolveURL`.
- **cfregistry** [CFML Reference p290](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): actions getAll, get, set, delete; Windows only in practice (deprecated on UNIX).
- **cfobject** and **CreateObject** [CFML Reference p253-261](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [CFML Reference p423-429](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): types COM, component, CORBA, Java, web service. `CreateObject("component", "dotted.path")`, `CreateObject("java", "class.name")` (call `init(...)` to run a constructor; static members are usable without init), `CreateObject("webservice", wsdlUrl)`, `CreateObject("com", ...)`, `CreateObject("corba", ...)`.
- **cfinvoke** and **cfinvokeargument** [CFML Reference p208-213](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `component` (name or instance), `method`, `returnVariable`, `argumentCollection` (structure), extra attributes as named arguments; or `webservice` with `username`, `password`, `timeout`, proxy attributes.
- **cfcomponent** [CFML Reference p85](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `extends`, `output`, `displayname`, `hint`. **cffunction** [CFML Reference p146](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `name`, `returnType`, `roles`, `access` (private, package, public default, remote), `output`, `displayName`, `hint`. **cfargument** [CFML Reference p54](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `name`, `type`, `required` (No), `default`, `displayname`, `hint`. **cfreturn** [CFML Reference p298](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): an expression. **cfproperty** [CFML Reference p280](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): metadata only.
- **cfmodule** [CFML Reference p250](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `template` or `name`, `attributeCollection`, plus custom attributes. **cfimport** [CFML Reference p190](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `taglib` (a directory of CFML custom tags or a JSP tag library) and `prefix`; must be on each page that uses the prefix. **cfinclude** [CFML Reference p192](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `template` (relative path or a mapped path). **cfassociate** [CFML Reference p56](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf), **cfexit** [CFML Reference p108](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) (`method` exitTag, exitTemplate, loop).
- **cfsilent** [CFML Reference p323](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): suppresses all output in its body. **cfsavecontent** [CFML Reference p300](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf). **cfprocessingdirective** [CFML Reference p271](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `pageEncoding` (a literal, must be in the first 4096 bytes, applied at compile time) and `suppressWhiteSpace`.
- **cfparam** [CFML Reference p265](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `name`, `default`, `type` (any, array, binary, boolean, date, guid, numeric, query, string, struct, UUID, variableName).
- **cfabort** [CFML Reference p47](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `showError`. **cfflush**, **cfhtmlhead**: see HTTP section.
- **var scoping** [Developing ColdFusion MX Applications p198](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf) [Developing ColdFusion MX Applications p244](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf): "All var statements must be at the top of the function declaration"; in a cffunction, all `<cfset var x = ...>` lines must come before any other tag except cfargument. A var declaration must assign a value.
- **cfscript** [CFML Reference p304](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [Developing ColdFusion MX Applications p127-141](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf): statements if / else, switch / case / default (constant cases), for, for-in (structures), while, do-while, break, continue, try / catch(Type var), function, var, return. No finally, no throw, no elseif keyword (write `else if`), no tags inside script, no function-level features such as access or return type (use cffunction for those). Comparison operators are the word operators (`LT`, `GTE`, `EQ`, `NEQ`); "there is no < operator in CFScript". [Developing ColdFusion MX Applications p130-139](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)
- **Operators (whole language)** [Developing ColdFusion MX Applications p83-90](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf): arithmetic `+ - * / \ MOD ^`; string `&`; decision `IS`, `EQ`, `EQUAL`, `IS NOT`, `NEQ`, `NOT EQUAL`, `GT`, `GREATER THAN`, `LT`, `LESS THAN`, `GTE`, `GE`, `LTE`, `LE`, `CONTAINS`, `DOES NOT CONTAIN`; Boolean `NOT`, `AND`, `OR`, `XOR`, `EQV`, `IMP`. String comparison is case-insensitive.
- **Functions**: `GetTickCount()` milliseconds counter [CFML Reference p508](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf); `GetCurrentTemplatePath()` [CFML Reference p484](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf); `GetBaseTemplatePath()` [CFML Reference p482](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf); `GetFunctionList()` returns a structure whose keys are function names [CFML Reference p490](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf); `GetMetaData(object)` returns a structure with name, path, extends, functions (each with name and parameters) and other attributes [CFML Reference p497](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf); `GetTimeZoneInfo()` returns utcTotalOffset (seconds, positive west of UTC), utcHourOffset, utcMinuteOffset, isDSTOn [CFML Reference p509](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf); `CreateTimeSpan(days, hours, minutes, seconds)`; `Duplicate`; `Evaluate`, `IIf`, `DE`, `SetVariable`; `WriteOutput(string)` [CFML Reference p738](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf); `GetBaseTagList`, `GetBaseTagData`; `GetException(object)`; `GetMetricData(mode)`.
- **Sleep**: no Sleep function in the 6.1 list. [CFML Reference p374-748](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- **Server scope** [CFML Reference p23-31](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `Server.ColdFusion.ProductName`, `ProductVersion`, `ProductLevel`, `SerialNumber`, `SupportedLocales`; `Server.OS.Name`, `AdditionalInformation`, `Version`, `BuildNumber`.
- **CGI variables** [CFML Reference p29-31](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): the usual server and client variables (SERVER_NAME, SERVER_PORT, SCRIPT_NAME, PATH_INFO, QUERY_STRING, REQUEST_METHOD, REMOTE_ADDR, HTTP_HOST, HTTP_REFERER, HTTP_USER_AGENT, HTTP_COOKIE, HTTPS, CONTENT_TYPE, CONTENT_LENGTH and so on). A CGI variable always exists; test for an empty string, not with IsDefined.
- **Other built-in variables** [CFML Reference p23-31](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `Client.CFID`, `CFToken`, `HitCount`, `LastVisit`, `TimeCreated`, `URLToken`; `Session.CFID`, `CFToken`, `URLToken`; `Application.ApplicationName`; `ThisTag.ExecutionMode`, `HasEndTag`, `GeneratedContent`, `AssocAttribs`; `Form.FieldNames`; `Error.*` on cferror pages.

Example (component, 6.1 style):

```cfm
<cfcomponent output="false">
    <cffunction name="init" access="public" returntype="any" output="false">
        <cfargument name="dsn" type="string" required="true">
        <cfset Variables.dsn = Arguments.dsn>
        <cfreturn this>
    </cffunction>
    <cffunction name="elapsed" access="public" returntype="numeric" output="false">
        <cfargument name="start" type="numeric" required="true">
        <cfset var now = GetTickCount()>
        <cfreturn now - Arguments.start>
    </cffunction>
</cfcomponent>
<!--- caller --->
<cfset svc = CreateObject("component", "lib.Service").init(Application.dsn)>
```

### Inferences

- Sleep on 6.1: `CreateObject("java", "java.lang.Thread").sleep(JavaCast("long", 500))`.
- Because there is no onMissingMethod or onError hook, a front controller on 6.1 has to be an ordinary .cfm page wrapped in cftry, with Application.cfm for setup and OnRequestEnd.cfm for teardown (OnRequestEnd.cfm is skipped when the page aborts or redirects).

### Gaps

- The attribute lists for cfcomponent, cffunction, cfargument, cfschedule and cferror are summaries; open the cited page for the full attribute tables.

## Security: cflogin, cfloginuser, cflogout, IsUserInRole, GetAuthUser

### Takeaway

6.1 has a small built-in login framework tied to the application name; it stores the login in a memory-only cookie unless `loginStorage="session"` is set.

### Cited Findings

- **cflogin** [CFML Reference p228](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `idletimeout` (seconds, default 1800), `applicationToken` (default the application name), `cookieDomain`. The body runs only when no user is logged in. Inside it, the `cflogin` structure has `name` and `password` when the request carries form fields `j_username` and `j_password`, or HTTP Basic, Digest or NTLM credentials.
- **cfloginuser** [CFML Reference p230](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): `name`, `password`, `roles` (all required; roles is a comma list in which spaces are significant).
- **cflogout** [CFML Reference p231](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf): no attributes; logs the current user out.
- `IsUserInRole("role_name")` Boolean; `GetAuthUser()` returns the logged-in user name or an empty string. [CFML Reference p548](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [CFML Reference p479](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `cffunction roles="..."` restricts a component method to users in those roles. [CFML Reference p146](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- Login storage: a memory-only cookie by default; `cfapplication loginStorage="session"` (6.1) keeps it in the Session scope. [CFML Reference p51](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- Obsolete security features: cfauthenticate, cfimpersonate, IsAuthenticated, IsAuthorized, IsProtected, AuthenticatedContext, AuthenticatedUser. [CFML Reference p42-46](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

### Inferences

- Most frameworks ignore cflogin and keep their own user record in the Session scope; nothing in 6.1 requires the built-in framework.

### Gaps

- No password hashing helper exists beyond MD5 Hash; salted or iterated hashing needs Java through CreateObject.

## Loops: which cfloop forms exist?

### Takeaway

cfloop has five forms in 6.1: index, conditional, query, list and collection. There is no array, file or characters form, and no cfcontinue.

### Cited Findings

- Index loop: `index`, `from`, `to`, `step` (default 1). `to` is evaluated once, before the loop starts. [CFML Reference p233](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- Conditional loop: `condition` (an expression string, evaluated before each pass). [CFML Reference p235](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- Query loop: `query`, `startRow`, `endRow`. [CFML Reference p236](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- List loop: `index`, `list`, `delimiters`. The manual calls this "looping over a list or file" only because the list value may be file content read with cffile; there is no `file` attribute. [CFML Reference p238](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- Collection loop: `collection`, `item`, for a structure or COM collection. [CFML Reference p239](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- The attribute tables contain no `array`, `file` or `characters` attribute. [CFML Reference p232-239](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)
- `cfbreak` exists [CFML Reference p58](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf); there is no cfcontinue tag in the tag list [CFML Reference p34-38](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf). CFScript does have `continue` and `break`. [Developing ColdFusion MX Applications p130-139](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)
- `cfoutput query=` also loops: `query`, `group`, `groupCaseSensitive`, `startRow`, `maxRows`. [CFML Reference p263](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)

Example (array loop and "continue" in tags):

```cfm
<cfloop index="i" from="1" to="#ArrayLen(items)#">
    <cfif items[i] NEQ "">
        <cfset process(items[i])>
    </cfif>
</cfloop>
```

### Inferences

- "Continue" inside a tag loop is expressed by wrapping the rest of the body in cfif, or by writing the loop in cfscript.
- Reading a file line by line: cffile read, then a list loop with `delimiters="#Chr(10)##Chr(13)#"`; blank lines are skipped because empty list elements are ignored.

### Gaps

- None.

## What commonly used later features are NOT in 6.1, when did each arrive, and what is the 6.1 way?

### Takeaway

Almost everything a modern CFML developer writes by habit (Application.cfc, script components, `[]` and `{}` literals, `==` and `++`, `result=` attributes, JSON, File* functions, cfthread, member functions, closures) arrived in ColdFusion 7 to 11. On 6.1 the code must be tag-based components, Application.cfm, word operators and function-built collections.

### Cited Findings

How to read the "Source" column: "cfdocs X" is the cfdocs.org reference entry for X (the minimum ColdFusion version field or a "CFn+" note in the attribute description; read from the cfdocs data repository). "Adobe X" is the History section of the current Adobe CFML reference page. Absence from 6.1 is confirmed for every row by the 6.1 tag list ([CFML Reference p34-38](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)), function list ([CFML Reference p374-748](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)) or the attribute table of the tag's own 6.1 entry.

**Application framework and components**

| Feature | Arrived | Source | The 6.1 way |
|---|---|---|---|
| Application.cfc and event methods onApplicationStart, onApplicationEnd, onSessionStart, onSessionEnd, onRequestStart, onRequest, onRequestEnd, onError | 7 | [cfdocs application-cfc](https://cfdocs.org/application-cfc), [cfdocs onapplicationstart](https://cfdocs.org/onapplicationstart), [cfdocs onerror](https://cfdocs.org/onerror) | Application.cfm (runs before each page), OnRequestEnd.cfm, cfapplication, cferror, and `IsDefined("Application.init")` guarded by cflock for one-time setup |
| onMissingTemplate | 8 | [cfdocs onmissingtemplate](https://cfdocs.org/onmissingtemplate) | Web server 404 handler or the Administrator missing template handler |
| onServerStart (Server.cfc) | 9 | [cfdocs onserverstart](https://cfdocs.org/onserverstart) | None; initialise lazily in Application.cfm |
| onMissingMethod | 8 | [cfdocs onmissingmethod](https://cfdocs.org/onmissingmethod) | None; define every method explicitly, or dispatch through one method that takes the action name |
| cfinterface and `implements` on cfcomponent | 8 | [cfdocs cfinterface](https://cfdocs.org/cfinterface), [cfdocs cfcomponent](https://cfdocs.org/cfcomponent) | Convention only; a base component whose methods throw "not implemented" |
| Per-application mappings and custom tag paths (`This.mappings`, `This.customTagPaths`) | 8 | [Forta, per-application settings](https://forta.com/blog/coldfusion-per-application-settings-v2) (search result summary; page not opened) | Mappings and custom tag paths set in the ColdFusion Administrator; cfimport or cfmodule `template` with relative paths; components resolved from the calling directory, the web root or a mapping |
| Script-based components (`component { }`), `new` operator | 9 | [cfdocs versions guide](https://cfdocs.org/coldfusion-versions), [cfdocs new](https://cfdocs.org/new) | cfcomponent and cffunction tags; `CreateObject("component", "path").init()` |
| `local` scope; `var` anywhere in a function | 9 | [cfdocs versions guide](https://cfdocs.org/coldfusion-versions) | `<cfset var x = "">` at the top of the function ([Developing ColdFusion MX Applications p198](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)); a common idiom is `<cfset var local = StructNew()>` |
| cffunction `returnFormat` | 8 | [cfdocs cffunction](https://cfdocs.org/cffunction) | Not applicable; remote methods return WDDX |
| GetComponentMetaData | 8 | [cfdocs getcomponentmetadata](https://cfdocs.org/getcomponentmetadata) | `GetMetaData(CreateObject("component", path))` |
| GetFunctionCalledName | 9 | [cfdocs getfunctioncalledname](https://cfdocs.org/getfunctioncalledname) | None |
| IsInstanceOf | 8 | [cfdocs isinstanceof](https://cfdocs.org/isinstanceof) | Walk `GetMetaData(obj).extends` |
| Invoke() function | 10 | [cfdocs invoke](https://cfdocs.org/invoke) | cfinvoke tag with `component`, `method`, `argumentCollection` |
| ORM (Hibernate), `entityLoad` and related | 9 | [cfdocs entityload](https://cfdocs.org/entityload), [cfdocs versions guide](https://cfdocs.org/coldfusion-versions) | Hand-written SQL in cfquery |
| GetApplicationMetadata, ApplicationStop | 10, 9 | [cfdocs getapplicationmetadata](https://cfdocs.org/getapplicationmetadata), [cfdocs applicationstop](https://cfdocs.org/applicationstop) | None |

**Language and syntax**

| Feature | Arrived | Source | The 6.1 way |
|---|---|---|---|
| Operators `++ -- += -= *= /= %= % && \|\| !` (usable in tags and script) | 8 | [Ben Nadel, Learning ColdFusion 8](https://www.bennadel.com/blog/741-learning-coldfusion-8-all-hail-the-new-operator.htm), [Wikipedia CFScript](https://en.wikipedia.org/wiki/CFScript) | `x = x + 1`, `MOD`, `AND`, `OR`, `NOT` ([Developing ColdFusion MX Applications p83-90](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)) |
| Operators `== != < <= > >=` (cfscript only, even later) | 8 | [cfdocs operators](https://cfdocs.org/operators), [Ben Nadel](https://www.bennadel.com/blog/741-learning-coldfusion-8-all-hail-the-new-operator.htm) | `EQ`, `NEQ`, `LT`, `LTE`, `GT`, `GTE` ([Developing ColdFusion MX Applications p130-139](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)) |
| `&=` concatenating assignment | 8 | [cfdocs operators](https://cfdocs.org/operators) | `s = s & "x"` |
| Implicit array and struct creation (`[1,2,3]`, `{a=1}`) | 8 | [cfdocs versions guide](https://cfdocs.org/coldfusion-versions) | `ArrayNew(1)` + `ArrayAppend`; `StructNew()` + assignments; `ListToArray("a,b,c")` for simple arrays |
| Nested implicit literals, literals as function arguments | UNCONFIRMED (believed 9) | none found | Same as above |
| Ternary operator `c ? a : b` | 9 | [Ben Nadel, Learning ColdFusion 9: the ternary operator](https://www.bennadel.com/blog/1643-learning-coldfusion-9-the-ternary-operator.htm) (search result summary; page not opened) | cfif / cfelse, or `IIf(c, DE(a), DE(b))` (IIf evaluates strings; use with care) |
| Elvis operator `a ?: b` | 11 | [cfdocs elvis](https://cfdocs.org/elvis) | `IsDefined` or `StructKeyExists` test, or cfparam |
| Null support (`null` keyword, real nulls) | 2018 | [Wikipedia Adobe ColdFusion](https://en.wikipedia.org/wiki/Adobe_ColdFusion) | No nulls; a null from Java or a query makes the variable undefined or an empty string; test with IsDefined or StructKeyExists |
| IsNull | 9 | [cfdocs isnull](https://cfdocs.org/isnull) | `NOT IsDefined("x")` or `NOT StructKeyExists(scope, "x")` |
| cfscript `throw` | 9 | [cfdocs throw](https://cfdocs.org/throw), [cfdocs cfthrow](https://cfdocs.org/cfthrow) | Write a UDF with cffunction that wraps `<cfthrow>` and call it from script |
| cfscript `finally`, cffinally tag | 9 | [cfdocs cffinally](https://cfdocs.org/cffinally) | Duplicate the cleanup in the try body and in each cfcatch (then cfrethrow) |
| cfcontinue tag | 9 | [cfdocs cfcontinue](https://cfdocs.org/cfcontinue) | cfif around the rest of the loop body; `continue` exists in cfscript ([Developing ColdFusion MX Applications p130-139](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf)) |
| Script equivalents WriteDump, WriteLog, Location | 9 | [cfdocs writedump](https://cfdocs.org/writedump), [cfdocs writelog](https://cfdocs.org/writelog), [cfdocs location](https://cfdocs.org/location) | UDF wrappers written with tags |
| Tags as script functions (`cfhttp(...)`), full script support | 11 | [cfdocs versions guide](https://cfdocs.org/coldfusion-versions), [Wikipedia CFScript](https://en.wikipedia.org/wiki/CFScript) | Tags only; no CFML tags inside cfscript |
| for-in over arrays (9.0.1), lists and queries (10) | 9.0.1 / 10 | [cfdocs for](https://cfdocs.org/for) | `for (i = 1; i LTE ArrayLen(a); i = i + 1)`; for-in works on structures only |
| Member functions (`arr.len()`, `str.ucase()`) | 11 | [cfdocs member](https://cfdocs.org/member) | Built-in functions: `ArrayLen(arr)`, `UCase(str)` |
| Closures, function expressions, ArrayEach, ArrayFilter, StructEach | 10 | [cfdocs closures](https://cfdocs.org/closures), [cfdocs arrayeach](https://cfdocs.org/arrayeach), [cfdocs structeach](https://cfdocs.org/structeach) | Named UDFs and explicit loops; a UDF can be passed as a value and called, but cannot capture variables |
| ArrayMap, ArrayReduce, StructMap, ListEach | 11 | [cfdocs arraymap](https://cfdocs.org/arraymap), [cfdocs arrayreduce](https://cfdocs.org/arrayreduce), [cfdocs structmap](https://cfdocs.org/structmap), [cfdocs listeach](https://cfdocs.org/listeach) | Explicit loops |
| argumentCollection in a direct function call (`f(argumentCollection=s)`) | UNCONFIRMED for 6.1 | not documented in the 6.1 manuals; only the cfinvoke attribute is ([Developing ColdFusion MX Applications p228](cfmx_6.1_docs_en/cfmx61_dev_cf_apps.pdf), [CFML Reference p208-213](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)) | Use cfinvoke with `argumentCollection`; test the direct-call form on the target server before relying on it |
| `attributeCollection` on built-in tags | UNCONFIRMED (believed 8) | none found | Write the attributes out; cfmodule does accept `attributeCollection` in 6.1 ([CFML Reference p250](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)) |
| Ordered or case-sensitive structs (`StructNew("ordered")`) | 2016 | [cfdocs structnew](https://cfdocs.org/structnew) | Keep a separate array or list of keys |

**Tags that do not exist in 6.1**

| Feature | Arrived | Source | The 6.1 way |
|---|---|---|---|
| cftimer | 7 | [cfdocs cftimer](https://cfdocs.org/cftimer) | `GetTickCount()` before and after |
| cfdocument (HTML to PDF) | 7 | [cfdocs cfdocument](https://cfdocs.org/cfdocument) | None built in; cfreport runs Crystal Reports only |
| cfform `format` (Flash, XML forms), cfformgroup, cfformitem, cftextarea, cfcalendar | 7 | [Adobe cfform](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/cfform.html), [cfdocs cfcalendar](https://cfdocs.org/cfcalendar) | HTML forms; cfform exists with Java applet controls only |
| cfreport with Report Builder | 7 | [Adobe cfreport](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/cfreport.html) | cfreport for Crystal Reports ([CFML Reference p295](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)) |
| cfntauthenticate | 7 | [cfdocs cfntauthenticate](https://cfdocs.org/cfntauthenticate) | cfldap or web server authentication |
| cfthread | 8 | [cfdocs cfthread](https://cfdocs.org/cfthread) | None; cfschedule or an HTTP call to another page for background work; Sleep via java.lang.Thread |
| cfimage, Image* functions | 8 | [cfdocs cfimage](https://cfdocs.org/cfimage), [cfdocs imagenew](https://cfdocs.org/imagenew) | Java (java.awt, javax.imageio) through CreateObject |
| cfpdf, cfpdfform | 8 | [cfdocs cfpdf](https://cfdocs.org/cfpdf), [cfdocs cfpdfform](https://cfdocs.org/cfpdfform) | None |
| cfzip | 8 | [cfdocs cfzip](https://cfdocs.org/cfzip) | java.util.zip through CreateObject |
| cffeed | 8 | [cfdocs cffeed](https://cfdocs.org/cffeed) | cfhttp + XmlParse |
| cfajaxproxy, cfdiv, cfwindow, cflayout, cfpod, cftooltip, cfmenu and other AJAX UI tags | 8 | [cfdocs cfajaxproxy](https://cfdocs.org/cfajaxproxy), [cfdocs cfdiv](https://cfdocs.org/cfdiv), [cfdocs cfwindow](https://cfdocs.org/cfwindow), [cfdocs cflayout](https://cfdocs.org/cflayout) | Hand-written HTML and JavaScript |
| cfdbinfo | 8 | [cfdocs cfdbinfo](https://cfdocs.org/cfdbinfo) | Query the database's own catalog tables, or JDBC metadata through Java |
| cfpresentation, cfprint, cfexchangemail, cfexchangeconnection | 8 | [cfdocs cfpresentation](https://cfdocs.org/cfpresentation), [cfdocs cfprint](https://cfdocs.org/cfprint), [cfdocs cfexchangemail](https://cfdocs.org/cfexchangemail) | None |
| cfspreadsheet, cfimap, cfmap, cfmediaplayer, cffileupload, cfprogressbar, cfsharepoint | 9 | [cfdocs cfspreadsheet](https://cfdocs.org/cfspreadsheet), [cfdocs cfimap](https://cfdocs.org/cfimap) | None |
| cfwebsocket | 10 | [cfdocs cfwebsocket](https://cfdocs.org/cfwebsocket) | None |
| cfhtmltopdf | 11 | [cfdocs cfhtmltopdf](https://cfdocs.org/cfhtmltopdf) | None |

**Attributes missing from tags that do exist in 6.1**

| Feature | Arrived | Source | The 6.1 way |
|---|---|---|---|
| cfquery `result` (sql, recordcount, cached, sqlparameters, columnlist) | 7 | [Adobe cfquery](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/cfquery.html) (cfdocs labels it CF8+) | `queryname.RecordCount`, `cfquery.ExecutionTime` ([CFML Reference p282-285](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)) |
| cfquery result generated key (identity) | 8 | [Adobe cfquery](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/cfquery.html) | Database-specific SQL in the same transaction |
| cfquery without `datasource` (application default) | 9 | [Adobe cfquery](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/cfquery.html) | Always pass `datasource` |
| cfqueryparam `cfsqltype` without the `CF_SQL_` prefix | 11 | [cfdocs cfqueryparam](https://cfdocs.org/cfqueryparam) | Always write `CF_SQL_...` |
| cfstoredproc `result` | 7 | [Adobe cfstoredproc](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/cfstoredproc.html) | `cfstoredproc.statusCode`, `cfstoredproc.ExecutionTime` |
| cfstoredproc `timeout` | 10 | [Adobe cfstoredproc](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/cfstoredproc.html) | None |
| cfstoredproc `cachedWithin`, `cachedAfter` | UNCONFIRMED | not in the Adobe history section read | None |
| cfprocparam `dbvarname` (named parameters) honoured again | 11 Update 3 | [cfdocs cfprocparam](https://cfdocs.org/cfprocparam) | Positional parameters ([CFML Reference p274-275](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)) |
| cftransaction savepoints (`setsavepoint`, `savepoint`) | UNCONFIRMED (cfdocs lists the attribute with no version) | [cfdocs cftransaction](https://cfdocs.org/cftransaction) | Commit or rollback of the whole transaction |
| cflocation `statusCode` | 8 | [cfdocs cflocation](https://cfdocs.org/cflocation) | cfheader `statusCode` + cfheader `Location` + cfabort |
| cfdirectory `recurse` | 7 | [Adobe cfdirectory](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/cfdirectory.html) (search result summary; page not opened) | Recursive UDF over cfdirectory |
| cfdirectory `listinfo`, `type` | UNCONFIRMED (believed 8) | [cfdocs cfdirectory](https://cfdocs.org/cfdirectory) lists them with no version | Filter the result with a query of queries |
| cffile `result`, `fixnewline` | 7 | [Adobe cffile](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/cffile.html) | The fixed `cffile` structure ([CFML Reference p110-129](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)) |
| cffile `action="uploadAll"` | 9 | [Adobe cffile](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/cffile.html) | One cffile upload per form field |
| cfhttp `result` | 7 | [cfdocs cfhttp](https://cfdocs.org/cfhttp) | The fixed `cfhttp` structure ([CFML Reference p174-182](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)) |
| cfhttp `clientCert`, `compression` | UNCONFIRMED (cfdocs lists them with no version) | [cfdocs cfhttp](https://cfdocs.org/cfhttp) | None |
| cfcontent `variable` | 7 | [Adobe cfcontent](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/cfcontent.html) | Write to a temporary file and use `file` with `deleteFile="Yes"` |
| cfcookie `httpOnly` | 9 | [cfdocs cfcookie](https://cfdocs.org/cfcookie) | cfheader `Set-Cookie` |
| cfdump `top` | 7 | [cfdocs cfdump](https://cfdocs.org/cfdump) | None |
| cfdump `output`, `format`, `showUDFs`, `metainfo` | 8 | [cfdocs cfdump](https://cfdocs.org/cfdump) | cfsavecontent around cfdump, then cffile write |
| cfdump `abort` | 9 | [cfdocs cfdump](https://cfdocs.org/cfdump) | cfdump followed by cfabort |
| cfloop `array`, `file`, `characters` | 8 | [cfdocs cfloop](https://cfdocs.org/cfloop) | Index loop to `ArrayLen`; cffile read + list loop |
| cfloop `group` | 10 | [cfdocs cfloop](https://cfdocs.org/cfloop) | cfoutput `query` + `group` |
| cfparam `min`, `max`, `pattern` and types creditcard, email, eurodate, float, integer, range, regex, regular_expression, ssn, social_security_number, time, URL, USdate, XML, zipcode | 7 | [Adobe cfparam](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/cfparam.html) | 6.1 types only: any, array, binary, boolean, date, guid, numeric, query, string, struct, UUID, variableName ([CFML Reference p265](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)); validate by hand |
| cfmail `useSSL`, `useTLS`, `priority` | 8 | [Adobe cfmail](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/cfmail.html) | Plain SMTP; `X-Priority` header through cfmailparam |
| cfmailparam `contentID`, `disposition` (inline images) | UNCONFIRMED (believed 7) | [cfdocs cfmailparam](https://cfdocs.org/cfmailparam) lists them with no version | None in 6.1 |
| cfexecute `errorVariable`, `errorFile` | UNCONFIRMED (believed 8) | [cfdocs cfexecute](https://cfdocs.org/cfexecute) lists them with no version | Redirect stderr in the command itself |
| cfapplication `scriptProtect` | UNCONFIRMED (believed 7) | [cfdocs cfapplication](https://cfdocs.org/cfapplication) lists it with no version | Validate and escape input by hand |
| cfinclude `runOnce` | 10 | [cfdocs cfinclude](https://cfdocs.org/cfinclude) | A Request-scope flag |
| cfoutput `encodefor` | 2016 | [cfdocs cfoutput](https://cfdocs.org/cfoutput) | HTMLEditFormat on each value |
| cfftp `secure` (SFTP), cfpop `secure` | 8, 10 | [cfdocs cfftp](https://cfdocs.org/cfftp), [cfdocs cfpop](https://cfdocs.org/cfpop) | None |

**Functions that do not exist in 6.1**

| Feature | Arrived | Source | The 6.1 way |
|---|---|---|---|
| IsValid | 7 | [cfdocs isvalid](https://cfdocs.org/isvalid) | IsNumeric, IsDate, IsBoolean, REFind patterns |
| IsXML, XmlValidate | 7 | [cfdocs isxml](https://cfdocs.org/isxml), [cfdocs xmlvalidate](https://cfdocs.org/xmlvalidate) | cftry around XmlParse |
| SerializeJSON, DeserializeJSON, IsJSON | 8 | [cfdocs serializejson](https://cfdocs.org/serializejson), [cfdocs deserializejson](https://cfdocs.org/deserializejson), [cfdocs isjson](https://cfdocs.org/isjson) | Hand-written CFML encoder and parser; WDDX for internal storage |
| Hash with algorithm and encoding arguments (SHA and others) | 7 | [cfdocs hash](https://cfdocs.org/hash) | `Hash(string)` is MD5 only ([CFML Reference p513](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)); java.security.MessageDigest for others |
| Encrypt and Decrypt with algorithm (AES, DES, Blowfish) and encoding | 7 | [cfdocs encrypt](https://cfdocs.org/encrypt) | Proprietary `Encrypt(string, seed)` ([CFML Reference p467](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)); javax.crypto through CreateObject |
| GenerateSecretKey | 7 | [cfdocs generatesecretkey](https://cfdocs.org/generatesecretkey) | javax.crypto.KeyGenerator through CreateObject |
| CharsetEncode, CharsetDecode, BinaryEncode, BinaryDecode | 7 | [cfdocs charsetencode](https://cfdocs.org/charsetencode), [cfdocs charsetdecode](https://cfdocs.org/charsetdecode), [cfdocs binaryencode](https://cfdocs.org/binaryencode), [cfdocs binarydecode](https://cfdocs.org/binarydecode) | `ToBase64`, `ToBinary`, `ToString(binary, encoding)` ([CFML Reference p721-725](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)); Java String methods |
| HMAC, EncodeForHTML, Canonicalize, CSRFGenerateToken, SessionRotate, SessionInvalidate | 10 | [cfdocs hmac](https://cfdocs.org/hmac), [cfdocs encodeforhtml](https://cfdocs.org/encodeforhtml), [cfdocs canonicalize](https://cfdocs.org/canonicalize), [cfdocs csrfgeneratetoken](https://cfdocs.org/csrfgeneratetoken), [cfdocs sessionrotate](https://cfdocs.org/sessionrotate), [cfdocs sessioninvalidate](https://cfdocs.org/sessioninvalidate) | HTMLEditFormat, XmlFormat, JSStringFormat, URLEncodedFormat; hand-written tokens; javax.crypto.Mac |
| GetSafeHTML | 11 | [cfdocs getsafehtml](https://cfdocs.org/getsafehtml) | None |
| QueryNew with column type list | 7 | [Adobe QueryNew](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/querynew.html) | `QueryNew(columnlist)` ([CFML Reference p645](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)); cast values when reading |
| QueryNew with row data | 10 | [Adobe QueryNew](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/querynew.html) | QueryAddRow + QuerySetCell |
| QueryExecute | 11 | [cfdocs queryexecute](https://cfdocs.org/queryexecute) | cfquery + cfqueryparam inside a cffunction |
| QueryEach, QueryFilter, QuerySort, ValueArray | 2016 | [cfdocs queryeach](https://cfdocs.org/queryeach), [cfdocs queryfilter](https://cfdocs.org/queryfilter), [cfdocs querysort](https://cfdocs.org/querysort), [cfdocs valuearray](https://cfdocs.org/valuearray) | Query loop; query of queries; `ListToArray(ValueList(q.col))` |
| ArrayIsDefined | 8 | [cfdocs arrayisdefined](https://cfdocs.org/arrayisdefined) | cftry around the element access |
| ArrayContains, ArrayFind, ArrayFindNoCase, ArrayDelete | 9 | [cfdocs arraycontains](https://cfdocs.org/arraycontains), [cfdocs arrayfind](https://cfdocs.org/arrayfind), [cfdocs arrayfindnocase](https://cfdocs.org/arrayfindnocase), [cfdocs arraydelete](https://cfdocs.org/arraydelete) | Loop, or ListFind on ArrayToList for simple values |
| ArraySlice | 10 | [cfdocs arrayslice](https://cfdocs.org/arrayslice) | Loop copying elements |
| ListRemoveDuplicates | 10 | [cfdocs listremoveduplicates](https://cfdocs.org/listremoveduplicates) | Loop with a struct of seen keys |
| ListToArray `includeEmptyFields` | UNCONFIRMED (believed 8) | [cfdocs listtoarray](https://cfdocs.org/listtoarray) lists it with no version | Manual split with Find and Mid |
| ListToArray `multiCharacterDelimiter` | 9 | [Adobe ListToArray](https://guides.adobe.com/coldfusion/en/docs/cfml-reference/__references__/listtoarray.html) | Replace the multi-character delimiter with a single unused character first |
| REMatch, REMatchNoCase | 8 | [cfdocs rematch](https://cfdocs.org/rematch), [cfdocs rematchnocase](https://cfdocs.org/rematchnocase) | REFind with `returnsubexpressions` in a loop |
| ReplaceListNoCase | 2016 | [cfdocs replacelistnocase](https://cfdocs.org/replacelistnocase) | Loop of ReplaceNoCase |
| DateTimeFormat | 10 | [cfdocs datetimeformat](https://cfdocs.org/datetimeformat) | `DateFormat(d, mask) & " " & TimeFormat(d, mask)` |
| FileRead, FileWrite, FileOpen, FileDelete and the other File* functions | 8 | [cfdocs fileread](https://cfdocs.org/fileread), [cfdocs filewrite](https://cfdocs.org/filewrite), [cfdocs fileopen](https://cfdocs.org/fileopen), [cfdocs filedelete](https://cfdocs.org/filedelete) | cffile; java.io through CreateObject |
| DirectoryList, DirectoryCreate | 9 | [cfdocs directorylist](https://cfdocs.org/directorylist), [cfdocs directorycreate](https://cfdocs.org/directorycreate) | cfdirectory |
| Sleep | 8 | [cfdocs sleep](https://cfdocs.org/sleep) | `CreateObject("java", "java.lang.Thread").sleep(ms)` |
| GetContextRoot | 7 | [cfdocs getcontextroot](https://cfdocs.org/getcontextroot) | `GetPageContext().getRequest().getContextPath()` (standard servlet API; not shown in the 6.1 manual) |
| GetLocaleDisplayName | 7 | [cfdocs getlocaledisplayname](https://cfdocs.org/getlocaledisplayname) | GetLocale |
| IsUserLoggedIn, IsUserInAnyRole, GetUserRoles | 8 | [cfdocs isuserloggedin](https://cfdocs.org/isuserloggedin), [cfdocs isuserinanyrole](https://cfdocs.org/isuserinanyrole), [cfdocs getuserroles](https://cfdocs.org/getuserroles) | `GetAuthUser() NEQ ""`; several IsUserInRole calls |
| IsImage, IsPDFFile | 8 | [cfdocs isimage](https://cfdocs.org/isimage), [cfdocs ispdffile](https://cfdocs.org/ispdffile) | None |
| PrecisionEvaluate | 8 | [cfdocs precisionevaluate](https://cfdocs.org/precisionevaluate) | java.math.BigDecimal through CreateObject |
| IsLocalHost | 7.0.1 | [cfdocs islocalhost](https://cfdocs.org/islocalhost) | Compare `CGI.REMOTE_ADDR` |
| CachePut, CacheGet (Ehcache functions) | 9 | [cfdocs cacheput](https://cfdocs.org/cacheput) | Application scope with cflock |
| IsClosure | 10 | [cfdocs isclosure](https://cfdocs.org/isclosure) | Not applicable; `IsCustomFunction` exists |

**Checked and found present in 6.1 (not later additions)**

- `GetHttpTimeString` exists in 6.1 ([CFML Reference p493](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf)); cfdocs dates it to 4.5 ([cfdocs gethttptimestring](https://cfdocs.org/gethttptimestring)).
- `GetPageContext` (MX 6.0), `GetMetaData` (MX 6.0), `Wrap` and `ReleaseComObject` (6.1), cfmailpart (6.1) are in 6.1. [CFML Reference p372-373](cfmx_6.1_docs_en/cfmx61_cfml_reference.pdf) [cfdocs wrap](https://cfdocs.org/wrap) [cfdocs cfmailpart](https://cfdocs.org/cfmailpart)
- `cfinvoke argumentCollection`, `cfmodule attributeCollection`, `cfqueryparam list`, `cfthrow object`, `cfsetting requestTimeout`, `cfexecute variable`, `cflock scope`, `cfsavecontent`, `cfsilent`, `cfrethrow`, `StructGet`, `GetException`, `Duplicate` are all in 6.1 (see the detailed entries above).

**Version timeline used in this table**: ColdFusion MX 6.0 June 2002; MX 7 February 2005; 8 July 2007; 9 October 2009; 10 May 2012; 11 April 2014; 2016 February 2016; 2018 July 2018. [cfdocs versions guide](https://cfdocs.org/coldfusion-versions), [Wikipedia Adobe ColdFusion](https://en.wikipedia.org/wiki/Adobe_ColdFusion)

### Inferences

- A feature whose cfdocs entry shows a minimum version of 7 or later, and which is absent from the 6.1 manual lists, is safely "not in 6.1" even where the exact arrival version is marked unconfirmed; the unconfirmed part is only the arrival version.
- The cfdocs entry for the cfquery `result` attribute says "CF8+" while Adobe's own history says MX 7 added it and 8 added the generated key variable; the Adobe history is taken as correct.
- A framework port from PHP that needs an "insert id", "affected rows", JSON, strong hashing, HTTP status redirects, HttpOnly cookies or recursive directory scans will need a small compatibility layer on 6.1 built from cfheader, database-specific SQL, Java objects through CreateObject and hand-written CFML.

### Gaps

- Rows marked UNCONFIRMED have no source for the arrival version: nested implicit literals, `attributeCollection` on built-in tags, cfstoredproc `cachedWithin`, cftransaction savepoints, cfdirectory `listinfo` and `type`, cfhttp `clientCert`, cfmailparam `contentID` and `disposition`, cfexecute `errorVariable`, cfapplication `scriptProtect`, ListToArray `includeEmptyFields`.
- Three sources were seen only as search result summaries and the pages were not opened: Forta on per-application settings (version 8), Ben Nadel on the ternary operator (version 9), and the Adobe cfdirectory history (recurse in MX 7).
- helpx.adobe.com pages returned HTTP 403 to the fetch tool; the mirror at guides.adobe.com was used for the Adobe history sections.
- cfdocs minimum versions were read from the cfdocs data repository (github.com/foundeo/cfdocs, `data/en/<name>.json`); the cfdocs.org page for each name shows the same data but the rendered pages were not opened one by one.
- Whether `f(argumentCollection=struct)` works for direct UDF and component method calls on 6.1 is not stated in the 6.1 manuals and needs a test on the server.
- ColdFusion MX 6.1 release date is not given in the sources read (the manual set is dated 2003).
- Nothing in these notes was executed on a ColdFusion MX 6.1 server.

