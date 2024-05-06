# Changelog

## 1.5.0

### Changes

* Dependency updates
* Analyzer issues
* Web support
* Independence of Flutter

## 1.4.2

* Changed TypeConverters priority
* Ignore ordering of constructors to always take the public, non-factory constructor
* Return result of table modifications through queries

## 1.4.1

### Changes

* Fix issue with nullable enum declaration in entity

## 1.4.0

### Changes

* Update to Analyzer 5
* Add Enum support
* Add primitive Dart type support in queries

## 1.3.0

### Changes

* Remove Slack invite links

### 🛠 Maintenance

* Update Analyzer to 4.1.0
* Allow release drafter to create GitHub releases
* Support latest analyzer

## 1.2.0

### Changes

* Improve escaping by using library

### 🐛 Bug Fixes

* Bugfix/nullable transaction return

### 🛠 Maintenance

* Update dependencies

## 1.1.0

All credits for this release go to mqus.

### Changes

* Update deps
* Increase test coverage
* Bump locked floor_generator version to 1.0.1

### 🚀 Features

* Add onConfigure callback

### 🐛 Bug Fixes

* Retain index ordering

## 1.0.1

### Changes

* Bump mockito to 5.0.3
* Update dependencies to null-safe versions

### 🚀 Features

* Improved Parameter mapping for query methods

## 1.0.0

### Changes

* Use stable Dart 2.12.0

### 🚀 Features

* Make floor null-safe

## 0.19.1

### Changes

* Remove floor example to pass static analysis

## 0.19.0

### Changes

* Update website theme
* Update license with all authors
* Fix getting started syntax highlighting
* Improve FTS documentation
* Introduce tab navigation to website
* Fix typo in doc title
* Improve website
* Slim down README
* Create MkDocs website
* Add isolates section to README
* Run CI only on pushes to develop
* Use GitHub Discussions for ideas and feedback
* Add example to floor package

### 🚀 Features

* Add Full-text Search support

### 🐛 Bug Fixes

* Fix desktop database path retrieval

## 0.18.0

* Documentation update on DateTimeConverter sample
* Change ForeignKeyAction to enum in the generator
* Add primary key auto increment test

### 🚀 Features

* Add support for WITH statements for DatabaseViews

### 🐛 Bug Fixes

* More tolerant query with list parameter parsing

## 0.17.0

### 🐛 Bug Fixes

* Generate distinct type converter instances
* Fix generation of DAO method with list argument using type converters

## 0.16.0

### 🚀 Features

* Add **experimental** support for type converters

## 0.15.0

### Changes

* Update dependencies

### 🚀 Features

* Add support for WITHOUT ROWID tables
* Check transaction method return types and allow non-void returns

## 0.14.0

### Changes

* Document entity inheritance and add integration test
* Raise minimum sqflite version to 1.3.0
* add integration test for transaction rollback
* Mention missing null propagation in streams
* Fix types (integer instead of real)

## 0.13.0

### ⚠️ Breaking Changes

**You need to migrate the explicit usages of `OnConflictStrategy` and `ForeignKeyAction` from snake
case to camel case.**

* Apply camel case to constants

### Changes

* Mention SQL centricity of Floor in README
* Add banner to README
* Update the description of the library
* Migrate OnConflictStrategy to enum
* Add more precise limitations of entity class and streams to README
* Add DAO inheritance example to README
* Fix database and DAO usage example in the README
* Update README.md
* Assert example app's behavior
* Mention that floor uses first constructor found in entity class
* Remove snapshot version instructions from README

### 🚀 Features

* Support Linux, macOS, Windows
* Implement simple Streams on DatabaseViews, fix multi-dao changelistener

### 🐛 Bug Fixes

* Await database path retrieval
* Fix boolean conversion issues, add regression test, fix indentation
* Fix wrongly parsed arguments in @Query

## 0.12.0

### Changes

* Ignore Getters&Setters
* Use Flutter bundled pub to get and upgrade project dependencies
* Generate database implementation on every CI run
* Throw exception when querying for unsupported type
* Add generated code for example app
* Add workflow scripts
* Run real database tests on development machine and CI

### 🚀 Features

* Support ByteArrays/Blobs
* Support inherited fields for entities and views
* Support database views
* Support inherited DAO methods
* Support asynchronous migrations

### 🐛 Bug Fixes

* Fix failing SQLite installation process on CI
* Fix failing stream query test

## 0.11.0

### Changes

* Refactor string utility function into extension function
* Refactor annotation check functions to use extension functions
* Refactor type check functions to use extension functions

### 🚀 Features

* Ignore fields of entities by adding ignore annotation
* Handle named constructor parameters and ignore field order
* Exclude static fields from entity mapping

## 0.10.0

### Changes

* Update dependencies
* Update README with correct instructions to initialize in memory database

### 🐛 Bug Fixes

* Make in-memory database actually be just in memory

## 0.9.0

### 🐛 Bug Fixes

* Make IN clauses work with strings
* Fix foreign key action string representation

## 0.8.0

### Changes

* Update README with clear package import instructions

### 🚀 Features

* Introduce static 'to map' functions
* Add optional callback functions when opening database

### 🐛 Bug Fixes

* Allow int and string (composite) primary keys

## 0.7.0

### 🐛 Bug Fixes

* Retain reactivity when using transactions

## 0.6.0

### 🚀 Features

* Add support for IN clauses in query statements
* Enable compound primary keys

## 0.5.0

### Changes

* Make tasks deletable in example app

### 🚀 Features

* Allow multiline string queries
* Allow void-return queries with arguments

## 0.4.2

### 🐛 Bug Fixes

* Fix query parameter substitution regex

## 0.4.0

### Changes

* Enable coverage report
* Simplify type assertions and add tests

### 🚀 Features

* Allow more convenient database initialization

### 🐛 Bug Fixes

* Use query argument binding instead of manual binding

## 0.3.0

### Changes

* Use TypeChecker for all annotations
* Add publishing instructions
* Remove unused annotation names
* Simplify the mapping from an entity to a map
* Fix database writer test
* Make stream emit query result on subscription
* Update example to use StreamBuilder
* Update README

### 🐛 Bug Fixes

* Correct mapper instance name referenced by generated query methods
* Fix adapter instances naming

## 0.2.0

### Changes

* Add database adapters
* Run floor Flutter tests
* Move value objects to value_objects directory
* Map source elements into value objects in processors
* Use GeneratorForAnnotation and TypeChecker to verify annotations
* Throw more specific errors on obfuscated database annotation

### 🚀 Features

* Add support for migrations
* Add support for returning Streams as query result
* Support accessing data from Data Access Objects
* Add entity classes to database annotation
* Add support for indices

## 0.1.0

### 🚀 Features

* Support conflict strategies when inserting and updating records
* Add support for running queries that return void
* Add support for foreign keys
* Add parameter verification for query methods
* Return deleted row count on delete
* Return updated rows count on update
* Return ID/s of inserted item/s
* Add support for transactions
* Add support for changing (insert, update, delete) lists
* Support custom entity name
* Enable NOT NULL columns
* Enable custom column name mapping
* Add delete methods code generation and fix update methods
* Add update methods code generation
* Add insert methods code generation
* Add code generator for query methods
* Code generation for database creation
