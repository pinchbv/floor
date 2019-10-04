# Changelog

# 0.9.0

### 🐛 Bug Fixes

* Make IN clauses work with strings
* Fix foreign key action string representation

# 0.8.0

### Changes

* Update README with clear package import instructions

### 🚀 Features

* Introduce static 'to map' functions
* Add optional callback functions when opening database

### 🐛 Bug Fixes

* Allow int and string (composite) primary keys

# 0.7.0

### 🐛 Bug Fixes

* Retain reactivity when using transactions

# 0.6.0

### 🚀 Features

* Add support for IN clauses in query statements
* Enable compound primary keys

# 0.5.0

### Changes

* Make tasks deletable in example app

### 🚀 Features

* Allow multiline string queries
* Allow void-return queries with arguments

# 0.4.2

### 🐛 Bug Fixes

* Fix query parameter substitution regex

# 0.4.0

### Changes

* Enable coverage report
* Simplify type assertions and add tests

### 🚀 Features

* Allow more convenient database initialization

### 🐛 Bug Fixes

* Use query argument binding instead of manual binding

# 0.3.0

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

# 0.2.0

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

# 0.1.0

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
