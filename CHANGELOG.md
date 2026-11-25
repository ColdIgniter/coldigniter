# Changelog

ColdIgniter uses [semantic versioning](https://semver.org/): MAJOR.MINOR.PATCH.

- PATCH: fixes that change no behaviour an application relies on.
- MINOR: new features, such as a newly ported class.
- MAJOR: changes that can break an application.

The numbers are ColdIgniter's own. They do not follow the numbers of CodeIgniter. Each release says which version of CodeIgniter its code was ported from. `PARITY.md` shows how much of CodeIgniter is ported.

## 4.1.0

Unreleased. Ported from CodeIgniter 4.7.6, for ColdFusion MX 6.1.

What is in it:

- Helpers: html and text. `highlight_code()` is not ported, and throws.
- Response: `setCache()`, `setLastModified()` and `setDate()`. A Cache-Control map may hold directives without a value, as keys that are numbers.
- Redirects: `RedirectException` holds its response, and `ColdIgniter::run()` catches it and sends the redirect. `force_https()` called from a controller now redirects instead of showing a 500 page.
- Exceptions: the exception classes and interfaces of `system/Exceptions` (`LogicException`, `RuntimeException`, `DownloadException`, `TestException` and the others) and `Debug\ExceptionHandlerInterface`. `Debug\Exceptions` reads the exit code of the exception types that have one.
- `Debug\Exceptions`: `isDeprecationError()` and `handleDeprecationError()` are ported. CFML has no deprecation errors, so nothing calls them.
- Log: `ChromeLoggerHandler`, and the `{session_vars}` placeholder of the logger.
- Throttle: the `Throttler`, a token bucket rate limiter on the cache, and the `throttler` service.
- Config: `ForeignCharacters`, used by `convert_accented_characters()`.
- Autoloader: `FileLocator` and `FileLocatorCached`, the `locator` service, `Config\Optimize` (only `locatorCacheEnabled` is used), and classmap loading and `sanitizeFilename()` in the autoloader. `helper()`, namespaced views, the Parser and the class search of `Factories` now find their files through the locator.
- `Config\DocTypes` now decides whether `img()` and the other html tags close with ` /`.
- Router: reverse routing with named routes (`reverseRoute()`, `route_to()`, `url_to()` and `redirect()->route()`), and the `{locale}` placeholder with `useSupportedLocalesOnly()`.
- Router: `AutoRouterImproved`, with `RouterException` and `MethodNotFoundException`. The old `AutoRouter` is not ported, so with `autoRoutesImproved` off, auto-routing finds no route.
- Common functions: `app_timezone()`, `cookie_()` (the name has an underscore, as `cookie` is a scope), `cookies()`, `function_usable()`, `is_cli()`, `is_really_writable()`, `is_windows()`, `response()`, `single_service()` and `timer()`. `esc()` has the `css` context and the encoding argument (new `ThirdParty\Escaper\Escaper`).
- `Config\BaseService`: `serviceExists()`, `reset()`, `resetSingle()`, `injectMock()`, `resetServicesCache()`, `set()` and `override()`. Module discovery is not ported.
- `Timer::record()`, and `View::render()` with the `cache` and `cache_name` options.
- Config: `Factory`. `Factories` now follows CodeIgniter: `define()`, `getOptions()`, `setOptions()`, `reset()`, `injectMock()` and the options `component`, `path`, `instanceOf`, `getShared` and `preferApp`. `model()` is added.
- Fix: `config("Config\App")` and then `config("App")` made two objects. Now they share one.
- Fix: RESTful resource controllers now get their model through `model()`, so the shared instance and not a new one each time.
- Fix: the default ellipsis of `ellipsize()` is `&hellip;`, as in CodeIgniter. It was `&amp;hellip;`.

## 4.0.0

The first release. Ported from CodeIgniter 4.7.6, for ColdFusion MX 6.1.

What is in it:

- Core: boot, the autoloader, services, factories and modules, routing, controllers, views and the view parser, events, filters, the exception handler and error views, `.env`, the logger with the file and error log handlers.
- HTTP: request input and input filters, JSON input, locales, headers, the user agent, content negotiation, method spoofing, uploaded files, redirects, the content security policy, and the CORS, honeypot, force HTTPS, secure headers and invalid characters filters.
- Database: the database core, the query builder, the forge, migrations and the seeder, with the SQLSRV driver for Microsoft SQL Server 2000.
- Models and data: Model and BaseModel, Entity with its casts, DataCaster and DataConverter, the pager.
- Sessions and cookies, with the file, database and array handlers.
- Security: the security library with CSRF protection, Encryption with the OpenSSL handler and key rotation. The default cipher is AES with a 128-bit key.
- Validation: the rules, the upload file rules and the language lines.
- Cache: the cache library with the file handler, and page caching.
- REST: resource and presenter routes, ResourceController and ResourcePresenter, the API response trait and transformers, the format classes.
- I18n: Time, TimeDifference and TimeLegacy.
- Helpers: array, cookie, form, inflector, number, security, url and xml.
- The debug toolbar, with the database collector.

ColdIgniter stores nothing in the `server` scope, so one application can run on several servers behind a load balancer.
