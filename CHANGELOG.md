# Changelog

ColdIgniter uses [semantic versioning](https://semver.org/): MAJOR.MINOR.PATCH.

- PATCH: fixes that change no behaviour an application relies on.
- MINOR: new features, such as a newly ported class.
- MAJOR: changes that can break an application.

The numbers are ColdIgniter's own. They do not follow the numbers of CodeIgniter. Each release says which version of CodeIgniter its code was ported from. `PARITY.md` shows how much of CodeIgniter is ported.

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
