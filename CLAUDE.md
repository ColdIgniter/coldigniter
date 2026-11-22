# ColdIgniter

A CFML port of CodeIgniter 4. The code must run on **ColdFusion MX 6.1** (2003), so most modern CFML
habits do not compile here. Read this file before writing any CFML, and look things up in the reference
instead of trusting memory of newer engines.

## Where the documentation is

| File | Use it for |
|---|---|
| `contributing/cfml/reference.md` | The standing reference: language rules, component conventions, what exists and what does not, how each CodeIgniter 4 part maps to 6.1, platform pitfalls, and the list of things still untested. Read the relevant section before starting a piece of work. |
| `contributing/cfml/notes/server_probe_results.md` | Facts tested on the real 6.1 server. When a manual, a web page or memory disagrees with it, the server result wins. |
| `contributing/cfml/notes/tags_and_functions.md` | Every tag and function in 6.1 with signatures, and the "not in 6.1" table. Check here before using any tag attribute or function. |
| `contributing/cfml/notes/core_language.md`, `cfcs.md`, `codeigniter_mapping.md`, `platform_pitfalls_editor.md` | The detailed research behind the reference, with manual page numbers. |

The upstream being ported is CodeIgniter 4 at tag `v4.7.6`. Keep its folder names, file names and method
names; one PHP class becomes one `.cfc` with the same name, and other PHP files become `.cfm`.

## Rules that are easy to get wrong

1. Tags, not script. Write components with `cfcomponent`, `cffunction`, `cfargument`. CFScript cannot
   contain tags and has no `throw`.
2. Word operators only: `EQ NEQ GT GTE LT LTE AND OR NOT MOD`. No `==`, `!=`, `&&`, `||`, `!`, `++`, `+=`,
   no ternary, no `[]` or `{}` literals, no `new`, no `local` scope, no null.
3. No `Application.cfc` (it is ignored). Only `Application.cfm` and `cfapplication`.
4. Every component and every function gets `output="no"`.
5. Every local variable gets a `<cfset var name = value>` line, and all of those lines come first in the
   function (after `cfargument`). A missing `var` writes into the shared instance.
6. Constructors are `__construct()` methods that end with `<cfreturn this>`; create an object with
   `new_("ColdIgniter\HTTP\URI", ...)` and reach a static class with `static_("Config\Services")`.
   `CreateObject("component", ...)` is left to the `autoload.cfm` files and the few boot files.
7. Calls through `super` take positional arguments only. Named arguments and `argumentCollection` fail there.
8. `access="private"` means protected (children can call it). There are no interfaces, abstract or static
   members; the reference lists the stand-ins.
9. Never `Duplicate()` a component, and never change `arguments.someArray` in place (arrays are not copied
   on the way in; copy to a `var` first).
10. Struct keys have no order, and `s.name` upper-cases the key. Use arrays of structs where order matters
    and `s["name"]` where case matters.
11. `EQ` is loose and case-insensitive. Use `Compare(a, b) EQ 0` for tokens, hashes and keys.
12. List functions skip empty elements; do not parse paths, CSV or query strings with them when an empty
    part has meaning.
13. Never render a view from a shared, long-lived component: a `cfinclude` inside a method copies that
    method's locals into the instance. Use one throwaway object per render.
14. Paths come from `GetCurrentTemplatePath()`, never from `ExpandPath("/")`.
15. Keep source files ASCII-only until the encoding rule is decided.
16. No ColdFusion mapping, ever. A component name can only reach its own folder and below, so never write
    a name that crosses into another folder tree in `extends`, `CreateObject` or `type`. Each tree
    (`system`, `app`, a vendor package) creates its own components, and folders are found by path.
    See "How components are located" in the reference.
17. A function, also a component method, cannot have the name of a built-in function (`initialize`,
    `setLocale`). Add a trailing underscore: `initialize_`. The same goes for a property that has the name
    of a public method (`this.params_`) and for anything named like a scope (`this.request_`, argument
    `request_`).
18. Properties live in `this`, in upstream order. A parent in another folder tree is named with
    `<cfcomponent parent="ColdIgniter\Controller">` and called as `parent.method()`.
19. Nothing can be written from inside the framework: the response leaves its body in
    `request.ColdIgniter.output` and `public/index.cfm` writes it.

"How the port is written today" in the reference has the full list.

## Checking work

Nothing proves 6.1 compatibility except the real server. The main checkout is synced to the test site
automatically (see `tools/devsync.py`); a small probe page fetched with curl is the quickest check.
If something is not marked as verified on the server in the reference, test it there and add the result
to `contributing/cfml/notes/server_probe_results.md` and to the reference.

## Repository conventions

- Commits: lower-case conventional commits. Default branch is `trunk`; work on a branch and open a pull request.
- Describe the project as "a CFML port of CodeIgniter 4".
- Version: `CI_VERSION` in `system/ColdIgniter.cfc` is the only place it is written. ColdIgniter has its own
  version line (major 4), not upstream's. Between releases it ends in `-dev`; a release is a `vX.Y.Z` tag on `trunk`.
- Build in small steps, a few things at a time, following the order in the reference.
