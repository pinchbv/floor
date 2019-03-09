import 'package:analyzer/dart/element/element.dart';
import 'package:build_test/build_test.dart';
import 'package:floor_generator/processor/transaction_method_processor.dart';
import 'package:floor_generator/value_object/transaction_method.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  test('successfully process transaction method', () async {
    const daoGetterName = 'foo';
    const databaseName = 'bar';
    final methodElement = await _generateMethodElement('''
      void replacePersons(String foo) {
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
}

Future<MethodElement> _generateMethodElement(final String method) async {
  final library = await resolveSource('''
      library test;
      
      class Foo {
        $method
      }
      ''', (resolver) async {
    return LibraryReader(await resolver.findLibraryByName('test'));
  });

  return library.classes.first.methods.first;
}
