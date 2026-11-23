# ColdIgniter

A CFML port of CodeIgniter 4.

## Why CFML 6.1

The goal is to build a modern website with a retro language, using that language's own syntax to recreate CodeIgniter in it.

The target moved several times before it settled on ColdFusion MX 6.1:

- **4.0** was the original target. It has `cftry`/`cfcatch` and `cflock`, but no user-defined functions and no Java integration, and its Expression Evaluator sample application let remote users read, upload and delete files on the server (Allaire bulletin ASB99-01).
- **4.5** was tried next. It added the first Java integration, but still had no way to define a function.
- **5.0** came after that. It added user-defined functions and `cfsavecontent`, but a function could only be written in CFScript, which cannot contain tags, and there were no components and no inheritance.
- **MX 6.0** turned out to be the minimum. It is the Java rewrite of the server and the first release with `cfcomponent`, `cffunction` and `cfargument`. Every class in `system/` is a component built from those tags.
- **MX 6.1** became the target. It added `super` for calling a parent's method, overhauled the compiler, fixed more than 400 bugs, and ships with Java 1.4.2 where 6.0 shipped with 1.3.1. Java 1.4 is the release that added `java.util.LinkedHashMap` and `java.util.regex`, which the port uses throughout.

## License

MIT
