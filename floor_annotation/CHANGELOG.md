# Changelog

# 1.0.0-nullsafety.0

### 🚀 Features

* Make floor null safe

# 0.11.0

* Change `ForeignKeyAction` int constants to enum

# 0.10.0

* Add experimental  `TypeConverter` abstract class and `TypeConverters` annotation

# 0.9.0

* Update meta package

# 0.8.0

**⚠️ You need to migrate the explicit usages of `OnConflictStrategy` and `ForeignKeyAction` from snake case to camel
case.**

* Apply camel case to constants

# 0.7.0

* Add @DatabaseView annotation

# 0.6.0

* Add @ignore annotation

# 0.5.0

* Update dependency

# 0.4.0

* Add primary key field to @Entity annotation

# 0.3.1

### Changes

* Revert meta package to version 1.1.6

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

* Support conflict strategies when inserting and updating records (#67) @vitusortner
* Add support for running queries that return void (#61) @vitusortner
* Add support for foreign keys (#59) @vitusortner
* Add parameter verification for query methods (#57) @vitusortner
* Return deleted row count on delete (#53) @vitusortner
* Return updated rows count on update (#52) @vitusortner
* Return ID/s of inserted item/s (#51) @vitusortner
* Add support for transactions (#49) @vitusortner
* Add support for changing (insert, update, delete) lists (#42) @vitusortner
* Support custom entity name (#41) @vitusortner
* Enable NOT NULL columns (#40) @vitusortner
* Enable custom column name mapping (#39) @vitusortner
* Add delete methods code generation and fix update methods (#22) @vitusortner
* Add update methods code generation (#21) @vitusortner
* Add insert methods code generation (#20) @vitusortner
* Add code generator for query methods (#17) @vitusortner
* Code generation for database creation (#13) @vitusortner
