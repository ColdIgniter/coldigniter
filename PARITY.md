# Parity with CodeIgniter 4

ColdIgniter is a CFML port of CodeIgniter 4. This page shows how much of the `system/` folder of CodeIgniter 4.7.6 has a matching file in ColdIgniter.

The list is made by file name only:

- A file that counts as ported can still miss some methods. The comment at the top of each file says what is not ported yet.
- CFML on ColdFusion MX 6.1 has no interfaces. An interface is ported as a plain component where the code needs one. An interface with no matching file counts as not ported.
- A trait whose methods are written into the component that uses it has no file of its own, so it is listed as "without a match". Examples: `HTTP/MessageTrait`, `HTTP/ResponseTrait` and `Traits/ConditionalTrait`.
- Some files will never be ported, because they belong to another platform: Composer scripts, the command line, and handlers for Redis, Predis, Memcached, APCu and Wincache.
- `ThirdParty/` is left out.

ColdIgniter has its own version numbers. They do not follow the numbers of CodeIgniter. See `CHANGELOG.md`.

Total: 242 of 492 files.

| Area | Files in CodeIgniter | Ported | State |
|---|---|---|---|
| `(top level)` | 11 | 7 | Part |
| `API` | 4 | 4 | All |
| `Autoloader` | 4 | 3 | Part |
| `Cache` | 14 | 7 | Part |
| `CLI` | 8 | 0 | None |
| `Commands` | 61 | 0 | None |
| `Config` | 12 | 10 | Part |
| `Cookie` | 5 | 5 | All |
| `Database` | 52 | 24 | Part |
| `DataCaster` | 15 | 14 | Part |
| `DataConverter` | 1 | 1 | All |
| `Debug` | 18 | 16 | Part |
| `Email` | 1 | 0 | None |
| `Encryption` | 7 | 6 | Part |
| `Entity` | 17 | 16 | Part |
| `Events` | 1 | 1 | All |
| `Exceptions` | 16 | 4 | Part |
| `Files` | 6 | 3 | Part |
| `Filters` | 12 | 11 | Part |
| `Format` | 5 | 5 | All |
| `Helpers` | 15 | 11 | Part |
| `Honeypot` | 2 | 2 | All |
| `HotReloader` | 3 | 0 | None |
| `HTTP` | 33 | 21 | Part |
| `I18n` | 5 | 5 | All |
| `Images` | 6 | 0 | None |
| `Language` | 32 | 17 | Part |
| `Log` | 7 | 6 | Part |
| `Modules` | 1 | 1 | All |
| `Pager` | 7 | 7 | All |
| `Publisher` | 3 | 0 | None |
| `RESTful` | 3 | 3 | All |
| `Router` | 15 | 3 | Part |
| `Security` | 4 | 3 | Part |
| `Session` | 12 | 9 | Part |
| `Test` | 44 | 3 | Part |
| `Throttle` | 2 | 2 | All |
| `Traits` | 2 | 0 | None |
| `Typography` | 1 | 0 | None |
| `Validation` | 14 | 12 | Part |
| `View` | 11 | 2 | Part |

## Files without a match

### (top level)

- `ComposerScripts.php`
- `bootstrap.php`
- `rewrite.php`
- `util_bootstrap.php`

### Autoloader

- `FileLocatorInterface.php`

### Cache

- `FactoriesCache.php`
- `FactoriesCache/FileVarExportHandler.php`
- `Handlers/ApcuHandler.php`
- `Handlers/MemcachedHandler.php`
- `Handlers/PredisHandler.php`
- `Handlers/RedisHandler.php`
- `Handlers/WincacheHandler.php`

### CLI

- `BaseCommand.php`
- `CLI.php`
- `Commands.php`
- `Console.php`
- `Exceptions/CLIException.php`
- `GeneratorTrait.php`
- `InputOutput.php`
- `SignalTrait.php`

### Commands

- `Cache/ClearCache.php`
- `Cache/InfoCache.php`
- `Database/CreateDatabase.php`
- `Database/Migrate.php`
- `Database/MigrateRefresh.php`
- `Database/MigrateRollback.php`
- `Database/MigrateStatus.php`
- `Database/Seed.php`
- `Database/ShowTableInfo.php`
- `Encryption/GenerateKey.php`
- `Generators/CellGenerator.php`
- `Generators/CommandGenerator.php`
- `Generators/ConfigGenerator.php`
- `Generators/ControllerGenerator.php`
- `Generators/EntityGenerator.php`
- `Generators/FilterGenerator.php`
- `Generators/MigrationGenerator.php`
- `Generators/ModelGenerator.php`
- `Generators/ScaffoldGenerator.php`
- `Generators/SeederGenerator.php`
- `Generators/TestGenerator.php`
- `Generators/TransformerGenerator.php`
- `Generators/ValidationGenerator.php`
- `Generators/Views/cell.tpl.php`
- `Generators/Views/cell_view.tpl.php`
- `Generators/Views/command.tpl.php`
- `Generators/Views/config.tpl.php`
- `Generators/Views/controller.tpl.php`
- `Generators/Views/entity.tpl.php`
- `Generators/Views/filter.tpl.php`
- `Generators/Views/migration.tpl.php`
- `Generators/Views/model.tpl.php`
- `Generators/Views/seeder.tpl.php`
- `Generators/Views/test.tpl.php`
- `Generators/Views/transformer.tpl.php`
- `Generators/Views/validation.tpl.php`
- `Help.php`
- `Housekeeping/ClearDebugbar.php`
- `Housekeeping/ClearLogs.php`
- `ListCommands.php`
- `Server/Serve.php`
- `Translation/LocalizationFinder.php`
- `Translation/LocalizationSync.php`
- `Utilities/ConfigCheck.php`
- `Utilities/Environment.php`
- `Utilities/FilterCheck.php`
- `Utilities/Namespaces.php`
- `Utilities/Optimize.php`
- `Utilities/PhpIniCheck.php`
- `Utilities/Publish.php`
- `Utilities/Routes.php`
- `Utilities/Routes/AutoRouteCollector.php`
- `Utilities/Routes/AutoRouterImproved/AutoRouteCollector.php`
- `Utilities/Routes/AutoRouterImproved/ControllerMethodReader.php`
- `Utilities/Routes/ControllerFinder.php`
- `Utilities/Routes/ControllerMethodReader.php`
- `Utilities/Routes/FilterCollector.php`
- `Utilities/Routes/FilterFinder.php`
- `Utilities/Routes/SampleURIGenerator.php`
- `Worker/WorkerInstall.php`
- `Worker/WorkerUninstall.php`

### Config

- `Factory.php`
- `Publisher.php`

### Database

- `BasePreparedQuery.php`
- `MySQLi/Builder.php`
- `MySQLi/Connection.php`
- `MySQLi/Forge.php`
- `MySQLi/PreparedQuery.php`
- `MySQLi/Result.php`
- `MySQLi/Utils.php`
- `OCI8/Builder.php`
- `OCI8/Connection.php`
- `OCI8/Forge.php`
- `OCI8/PreparedQuery.php`
- `OCI8/Result.php`
- `OCI8/Utils.php`
- `Postgre/Builder.php`
- `Postgre/Connection.php`
- `Postgre/Forge.php`
- `Postgre/PreparedQuery.php`
- `Postgre/Result.php`
- `Postgre/Utils.php`
- `PreparedQueryInterface.php`
- `SQLSRV/PreparedQuery.php`
- `SQLite3/Builder.php`
- `SQLite3/Connection.php`
- `SQLite3/Forge.php`
- `SQLite3/PreparedQuery.php`
- `SQLite3/Result.php`
- `SQLite3/Table.php`
- `SQLite3/Utils.php`

### DataCaster

- `Cast/EnumCast.php`

### Debug

- `ExceptionHandlerInterface.php`
- `Iterator.php`

### Email

- `Email.php`

### Encryption

- `Handlers/SodiumHandler.php`

### Entity

- `Cast/EnumCast.php`

### Exceptions

- `BadFunctionCallException.php`
- `BadMethodCallException.php`
- `CriticalError.php`
- `DebugTraceableTrait.php`
- `DownloadException.php`
- `ExceptionInterface.php`
- `HTTPExceptionInterface.php`
- `HasExitCodeInterface.php`
- `InvalidArgumentException.php`
- `LogicException.php`
- `RuntimeException.php`
- `TestException.php`

### Files

- `Exceptions/ExceptionInterface.php`
- `FileCollection.php`
- `FileSizeUnit.php`

### Filters

- `PerformanceMetrics.php`

### Helpers

- `date_helper.php`
- `filesystem_helper.php`
- `kint_helper.php`
- `test_helper.php`

### HotReloader

- `DirectoryHasher.php`
- `HotReloader.php`
- `IteratorFilter.php`

### HTTP

- `CLIRequest.php`
- `CURLRequest.php`
- `DownloadResponse.php`
- `Exceptions/BadRequestException.php`
- `Exceptions/ExceptionInterface.php`
- `MessageInterface.php`
- `MessageTrait.php`
- `OutgoingRequestInterface.php`
- `RequestInterface.php`
- `ResponsableInterface.php`
- `ResponseInterface.php`
- `ResponseTrait.php`

### Images

- `Exceptions/ImageException.php`
- `Handlers/BaseHandler.php`
- `Handlers/GDHandler.php`
- `Handlers/ImageMagickHandler.php`
- `Image.php`
- `ImageHandlerInterface.php`

### Language

- `en/CLI.php`
- `en/Cookie.php`
- `en/Core.php`
- `en/Email.php`
- `en/Errors.php`
- `en/Fabricator.php`
- `en/Filters.php`
- `en/Images.php`
- `en/Language.php`
- `en/Log.php`
- `en/Publisher.php`
- `en/Router.php`
- `en/Session.php`
- `en/Test.php`
- `en/View.php`

### Log

- `Handlers/ChromeLoggerHandler.php`

### Publisher

- `ContentReplacer.php`
- `Exceptions/PublisherException.php`
- `Publisher.php`

### Router

- `Attributes/Cache.php`
- `Attributes/Filter.php`
- `Attributes/Restrict.php`
- `Attributes/RouteAttributeInterface.php`
- `AutoRouter.php`
- `AutoRouterImproved.php`
- `AutoRouterInterface.php`
- `Exceptions/ExceptionInterface.php`
- `Exceptions/MethodNotFoundException.php`
- `Exceptions/RouterException.php`
- `RouteCollectionInterface.php`
- `RouterInterface.php`

### Security

- `CheckPhpIni.php`

### Session

- `Handlers/MemcachedHandler.php`
- `Handlers/RedisHandler.php`
- `PersistsConnection.php`

### Test

- `CIUnitTestCase.php`
- `ConfigFromArrayTrait.php`
- `Constraints/SeeInDatabase.php`
- `ControllerTestTrait.php`
- `DOMParser.php`
- `DatabaseTestTrait.php`
- `Fabricator.php`
- `FeatureTestTrait.php`
- `FilterTestTrait.php`
- `Filters/CITestStreamFilter.php`
- `IniTestTrait.php`
- `Interfaces/FabricatorModel.php`
- `Mock/MockAppConfig.php`
- `Mock/MockAutoload.php`
- `Mock/MockBuilder.php`
- `Mock/MockCLIConfig.php`
- `Mock/MockCURLRequest.php`
- `Mock/MockCache.php`
- `Mock/MockCodeIgniter.php`
- `Mock/MockCommon.php`
- `Mock/MockEmail.php`
- `Mock/MockEvents.php`
- `Mock/MockFileLogger.php`
- `Mock/MockIncomingRequest.php`
- `Mock/MockInputOutput.php`
- `Mock/MockLanguage.php`
- `Mock/MockLogger.php`
- `Mock/MockResourceController.php`
- `Mock/MockResourcePresenter.php`
- `Mock/MockResponse.php`
- `Mock/MockSecurity.php`
- `Mock/MockServices.php`
- `Mock/MockSession.php`
- `Mock/MockTable.php`
- `PhpStreamWrapper.php`
- `ReflectionHelper.php`
- `StreamFilterTrait.php`
- `TestLogger.php`
- `TestResponse.php`
- `Utilities/NativeHeadersStack.php`
- `bootstrap.php`

### Traits

- `ConditionalTrait.php`
- `PropertiesTrait.php`

### Typography

- `Typography.php`

### Validation

- `CreditCardRules.php`
- `StrictRules/CreditCardRules.php`

### View

- `Cell.php`
- `Cells/Cell.php`
- `Exceptions/ViewException.php`
- `Filters.php`
- `Plugins.php`
- `RendererInterface.php`
- `Table.php`
- `ViewDecoratorInterface.php`
- `ViewDecoratorTrait.php`
