import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:sqflite_common/sqlite_api.dart' as _i2;
import 'package:sqflite_common/src/sql_builder.dart' as _i4;

// ignore_for_file: comment_references
// ignore_for_file: unnecessary_parenthesis

class _FakeBatch extends _i1.Fake implements _i2.Batch {}

class _FakeStreamSink<S> extends _i1.Fake implements _i3.StreamSink<S> {}

/// A class which mocks [DatabaseExecutor].
///
/// See the documentation for Mockito's code generation for more information.
class MockDatabaseExecutor extends _i1.Mock implements _i2.DatabaseExecutor {
  MockDatabaseExecutor() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> execute(String? sql, [List<Object?>? arguments]) =>
      (super.noSuchMethod(Invocation.method(#execute, [sql, arguments]),
          returnValue: Future.value(null),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);

  @override
  _i3.Future<int> rawInsert(String? sql, [List<Object?>? arguments]) =>
      (super.noSuchMethod(Invocation.method(#rawInsert, [sql, arguments]),
          returnValue: Future.value(0)) as _i3.Future<int>);

  @override
  _i3.Future<int> insert(String? table, Map<String, Object?>? values,
          {String? nullColumnHack, _i4.ConflictAlgorithm? conflictAlgorithm}) =>
      (super.noSuchMethod(
          Invocation.method(#insert, [
            table,
            values
          ], {
            #nullColumnHack: nullColumnHack,
            #conflictAlgorithm: conflictAlgorithm
          }),
          returnValue: Future.value(0)) as _i3.Future<int>);

  @override
  _i3.Future<List<Map<String, Object?>>> query(String? table,
          {bool? distinct,
          List<String>? columns,
          String? where,
          List<Object?>? whereArgs,
          String? groupBy,
          String? having,
          String? orderBy,
          int? limit,
          int? offset}) =>
      (super.noSuchMethod(
              Invocation.method(#query, [
                table
              ], {
                #distinct: distinct,
                #columns: columns,
                #where: where,
                #whereArgs: whereArgs,
                #groupBy: groupBy,
                #having: having,
                #orderBy: orderBy,
                #limit: limit,
                #offset: offset
              }),
              returnValue: Future.value(<Map<String, Object?>>[]))
          as _i3.Future<List<Map<String, Object?>>>);

  @override
  _i3.Future<List<Map<String, Object?>>> rawQuery(String? sql,
          [List<Object?>? arguments]) =>
      (super.noSuchMethod(Invocation.method(#rawQuery, [sql, arguments]),
              returnValue: Future.value(<Map<String, Object?>>[]))
          as _i3.Future<List<Map<String, Object?>>>);

  @override
  _i3.Future<int> rawUpdate(String? sql, [List<Object?>? arguments]) =>
      (super.noSuchMethod(Invocation.method(#rawUpdate, [sql, arguments]),
          returnValue: Future.value(0)) as _i3.Future<int>);

  @override
  _i3.Future<int> update(String? table, Map<String, Object?>? values,
          {String? where,
          List<Object?>? whereArgs,
          _i4.ConflictAlgorithm? conflictAlgorithm}) =>
      (super.noSuchMethod(
          Invocation.method(#update, [
            table,
            values
          ], {
            #where: where,
            #whereArgs: whereArgs,
            #conflictAlgorithm: conflictAlgorithm
          }),
          returnValue: Future.value(0)) as _i3.Future<int>);

  @override
  _i3.Future<int> rawDelete(String? sql, [List<Object?>? arguments]) =>
      (super.noSuchMethod(Invocation.method(#rawDelete, [sql, arguments]),
          returnValue: Future.value(0)) as _i3.Future<int>);

  @override
  _i3.Future<int> delete(String? table,
          {String? where, List<Object?>? whereArgs}) =>
      (super.noSuchMethod(
          Invocation.method(
              #delete, [table], {#where: where, #whereArgs: whereArgs}),
          returnValue: Future.value(0)) as _i3.Future<int>);

  @override
  _i2.Batch batch() => (super.noSuchMethod(Invocation.method(#batch, []),
      returnValue: _FakeBatch()) as _i2.Batch);
}

/// A class which mocks [Batch].
///
/// See the documentation for Mockito's code generation for more information.
class MockBatch extends _i1.Mock implements _i2.Batch {
  MockBatch() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<Object?>> commit(
          {bool? exclusive, bool? noResult, bool? continueOnError}) =>
      (super.noSuchMethod(
          Invocation.method(#commit, [], {
            #exclusive: exclusive,
            #noResult: noResult,
            #continueOnError: continueOnError
          }),
          returnValue: Future.value(<Object?>[])) as _i3.Future<List<Object?>>);

  @override
  void rawInsert(String? sql, [List<Object?>? arguments]) =>
      super.noSuchMethod(Invocation.method(#rawInsert, [sql, arguments]),
          returnValueForMissingStub: null);

  @override
  void insert(String? table, Map<String, Object?>? values,
          {String? nullColumnHack, _i4.ConflictAlgorithm? conflictAlgorithm}) =>
      super.noSuchMethod(
          Invocation.method(#insert, [
            table,
            values
          ], {
            #nullColumnHack: nullColumnHack,
            #conflictAlgorithm: conflictAlgorithm
          }),
          returnValueForMissingStub: null);

  @override
  void rawUpdate(String? sql, [List<Object?>? arguments]) =>
      super.noSuchMethod(Invocation.method(#rawUpdate, [sql, arguments]),
          returnValueForMissingStub: null);

  @override
  void update(String? table, Map<String, Object?>? values,
          {String? where,
          List<Object?>? whereArgs,
          _i4.ConflictAlgorithm? conflictAlgorithm}) =>
      super.noSuchMethod(
          Invocation.method(#update, [
            table,
            values
          ], {
            #where: where,
            #whereArgs: whereArgs,
            #conflictAlgorithm: conflictAlgorithm
          }),
          returnValueForMissingStub: null);

  @override
  void rawDelete(String? sql, [List<Object?>? arguments]) =>
      super.noSuchMethod(Invocation.method(#rawDelete, [sql, arguments]),
          returnValueForMissingStub: null);

  @override
  void delete(String? table, {String? where, List<Object?>? whereArgs}) =>
      super.noSuchMethod(
          Invocation.method(
              #delete, [table], {#where: where, #whereArgs: whereArgs}),
          returnValueForMissingStub: null);

  @override
  void execute(String? sql, [List<Object?>? arguments]) =>
      super.noSuchMethod(Invocation.method(#execute, [sql, arguments]),
          returnValueForMissingStub: null);

  @override
  void query(String? table,
          {bool? distinct,
          List<String>? columns,
          String? where,
          List<Object?>? whereArgs,
          String? groupBy,
          String? having,
          String? orderBy,
          int? limit,
          int? offset}) =>
      super.noSuchMethod(
          Invocation.method(#query, [
            table
          ], {
            #distinct: distinct,
            #columns: columns,
            #where: where,
            #whereArgs: whereArgs,
            #groupBy: groupBy,
            #having: having,
            #orderBy: orderBy,
            #limit: limit,
            #offset: offset
          }),
          returnValueForMissingStub: null);

  @override
  void rawQuery(String? sql, [List<Object?>? arguments]) =>
      super.noSuchMethod(Invocation.method(#rawQuery, [sql, arguments]),
          returnValueForMissingStub: null);
}

/// A class which mocks [StreamController].
///
/// See the documentation for Mockito's code generation for more information.
class MockStreamController<T> extends _i1.Mock
    implements _i3.StreamController<T> {
  MockStreamController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Stream<T> get stream => (super.noSuchMethod(Invocation.getter(#stream),
      returnValue: Stream<T>.empty()) as _i3.Stream<T>);

  @override
  _i3.StreamSink<T> get sink => (super.noSuchMethod(Invocation.getter(#sink),
      returnValue: _FakeStreamSink<T>()) as _i3.StreamSink<T>);

  @override
  bool get isClosed =>
      (super.noSuchMethod(Invocation.getter(#isClosed), returnValue: false)
          as bool);

  @override
  bool get isPaused =>
      (super.noSuchMethod(Invocation.getter(#isPaused), returnValue: false)
          as bool);

  @override
  bool get hasListener =>
      (super.noSuchMethod(Invocation.getter(#hasListener), returnValue: false)
          as bool);

  @override
  _i3.Future<dynamic> get done => (super.noSuchMethod(Invocation.getter(#done),
      returnValue: Future.value(null)) as _i3.Future<dynamic>);

  @override
  void add(T? event) => super.noSuchMethod(Invocation.method(#add, [event]),
      returnValueForMissingStub: null);

  @override
  void addError(Object? error, [StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#addError, [error, stackTrace]),
          returnValueForMissingStub: null);

  @override
  _i3.Future<dynamic> close() =>
      (super.noSuchMethod(Invocation.method(#close, []),
          returnValue: Future.value(null)) as _i3.Future<dynamic>);

  @override
  _i3.Future<dynamic> addStream(_i3.Stream<T>? source, {bool? cancelOnError}) =>
      (super.noSuchMethod(
          Invocation.method(
              #addStream, [source], {#cancelOnError: cancelOnError}),
          returnValue: Future.value(null)) as _i3.Future<dynamic>);
}

/// A class which mocks [Database].
///
/// See the documentation for Mockito's code generation for more information.
class MockDatabase extends _i1.Mock implements _i2.Database {
  MockDatabase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get path =>
      (super.noSuchMethod(Invocation.getter(#path), returnValue: '') as String);

  @override
  bool get isOpen =>
      (super.noSuchMethod(Invocation.getter(#isOpen), returnValue: false)
          as bool);

  @override
  _i3.Future<void> close() => (super.noSuchMethod(Invocation.method(#close, []),
      returnValue: Future.value(null),
      returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);

  @override
  _i3.Future<T> transaction<T>(_i3.Future<T> Function(_i2.Transaction)? action,
          {bool? exclusive}) =>
      (super.noSuchMethod(
          Invocation.method(#transaction, [action], {#exclusive: exclusive}),
          returnValue: Future.value(null)) as _i3.Future<T>);

  @override
  _i3.Future<T> devInvokeMethod<T>(String? method, [dynamic arguments]) =>
      (super.noSuchMethod(
          Invocation.method(#devInvokeMethod, [method, arguments]),
          returnValue: Future.value(null)) as _i3.Future<T>);

  @override
  _i3.Future<T> devInvokeSqlMethod<T>(String? method, String? sql,
          [List<Object?>? arguments]) =>
      (super.noSuchMethod(
          Invocation.method(#devInvokeSqlMethod, [method, sql, arguments]),
          returnValue: Future.value(null)) as _i3.Future<T>);

  @override
  _i3.Future<void> execute(String? sql, [List<Object?>? arguments]) =>
      (super.noSuchMethod(Invocation.method(#execute, [sql, arguments]),
          returnValue: Future.value(null),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);

  @override
  _i3.Future<int> rawInsert(String? sql, [List<Object?>? arguments]) =>
      (super.noSuchMethod(Invocation.method(#rawInsert, [sql, arguments]),
          returnValue: Future.value(0)) as _i3.Future<int>);

  @override
  _i3.Future<int> insert(String? table, Map<String, Object?>? values,
          {String? nullColumnHack, _i4.ConflictAlgorithm? conflictAlgorithm}) =>
      (super.noSuchMethod(
          Invocation.method(#insert, [
            table,
            values
          ], {
            #nullColumnHack: nullColumnHack,
            #conflictAlgorithm: conflictAlgorithm
          }),
          returnValue: Future.value(0)) as _i3.Future<int>);

  @override
  _i3.Future<List<Map<String, Object?>>> query(String? table,
          {bool? distinct,
          List<String>? columns,
          String? where,
          List<Object?>? whereArgs,
          String? groupBy,
          String? having,
          String? orderBy,
          int? limit,
          int? offset}) =>
      (super.noSuchMethod(
              Invocation.method(#query, [
                table
              ], {
                #distinct: distinct,
                #columns: columns,
                #where: where,
                #whereArgs: whereArgs,
                #groupBy: groupBy,
                #having: having,
                #orderBy: orderBy,
                #limit: limit,
                #offset: offset
              }),
              returnValue: Future.value(<Map<String, Object?>>[]))
          as _i3.Future<List<Map<String, Object?>>>);

  @override
  _i3.Future<List<Map<String, Object?>>> rawQuery(String? sql,
          [List<Object?>? arguments]) =>
      (super.noSuchMethod(Invocation.method(#rawQuery, [sql, arguments]),
              returnValue: Future.value(<Map<String, Object?>>[]))
          as _i3.Future<List<Map<String, Object?>>>);

  @override
  _i3.Future<int> rawUpdate(String? sql, [List<Object?>? arguments]) =>
      (super.noSuchMethod(Invocation.method(#rawUpdate, [sql, arguments]),
          returnValue: Future.value(0)) as _i3.Future<int>);

  @override
  _i3.Future<int> update(String? table, Map<String, Object?>? values,
          {String? where,
          List<Object?>? whereArgs,
          _i4.ConflictAlgorithm? conflictAlgorithm}) =>
      (super.noSuchMethod(
          Invocation.method(#update, [
            table,
            values
          ], {
            #where: where,
            #whereArgs: whereArgs,
            #conflictAlgorithm: conflictAlgorithm
          }),
          returnValue: Future.value(0)) as _i3.Future<int>);

  @override
  _i3.Future<int> rawDelete(String? sql, [List<Object?>? arguments]) =>
      (super.noSuchMethod(Invocation.method(#rawDelete, [sql, arguments]),
          returnValue: Future.value(0)) as _i3.Future<int>);

  @override
  _i3.Future<int> delete(String? table,
          {String? where, List<Object?>? whereArgs}) =>
      (super.noSuchMethod(
          Invocation.method(
              #delete, [table], {#where: where, #whereArgs: whereArgs}),
          returnValue: Future.value(0)) as _i3.Future<int>);

  @override
  _i2.Batch batch() => (super.noSuchMethod(Invocation.method(#batch, []),
      returnValue: _FakeBatch()) as _i2.Batch);
}
