// Mocks generated by Mockito 5.0.0 from annotations
// in floor/test/adapter/migration_adapter_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:sqflite_common/sqlite_api.dart' as _i2;

// ignore_for_file: comment_references
// ignore_for_file: unnecessary_parenthesis

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
      returnValueForMissingStub: Future.value()) as _i3.Future<void>);
  @override
  _i3.Future<T> transaction<T>(_i3.Future<T> Function(_i2.Transaction)? action,
          {bool? exclusive}) =>
      (super.noSuchMethod(
          Invocation.method(#transaction, [action], {#exclusive: exclusive}),
          returnValue: Future.value(null)) as _i3.Future<T>);
  @override
  _i3.Future<int> getVersion() =>
      (super.noSuchMethod(Invocation.method(#getVersion, []),
          returnValue: Future.value(0)) as _i3.Future<int>);
  @override
  _i3.Future<void> setVersion(int? version) =>
      (super.noSuchMethod(Invocation.method(#setVersion, [version]),
          returnValue: Future.value(null),
          returnValueForMissingStub: Future.value()) as _i3.Future<void>);
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
}
