import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_generator/processor/error/transaction_method_processor_error.dart';
import 'package:floor_generator/processor/transaction_method_processor.dart';
import 'package:floor_generator/value_object/transaction_method.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('successfully process transaction method', () async {
    const daoGetterName = 'foo';
    const databaseName = 'bar';
    final methodElement = await _generateMethodElement('''
      Future<void> replacePersons(String foo) {
      }
    ''');

    final actual =
        TransactionMethodProcessor(methodElement, daoGetterName, databaseName)
            .process();

    final returnType = methodElement.returnType;
    final parameterElements = methodElement.parameters;
    expect(
        actual,
        equals(TransactionMethod(
          methodElement,
          'replacePersons',
          returnType,
          parameterElements,
          daoGetterName,
          databaseName,
        )));
  });

  test('throw error while processing transaction method with wrong return type',
      () async {
    const daoGetterName = 'foo';
    const databaseName = 'bar';
    final methodElement = await _generateMethodElement('''
      void replacePersons(String foo) {
      }
    ''');

    final actual = () =>
        TransactionMethodProcessor(methodElement, daoGetterName, databaseName)
            .process();

    expect(
        actual,
        throwsInvalidGenerationSourceError(
            TransactionMethodProcessorError(methodElement).shouldReturnFuture));
  });
}

Future<MethodElement> _generateMethodElement(final String method) async {
  final library = await resolveSource('''
      library test;
      
      class Foo {
        $method
      }
      ''', (resolver) async {
    return resolver
        .findLibraryByName('test')
        .then((value) => ArgumentError.checkNotNull(value))
        .then((value) => LibraryReader(value));
  });

  return library.classes.first.methods.first;
}
