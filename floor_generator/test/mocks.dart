import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:mockito/mockito.dart';

class MockClassElement extends Mock implements ClassElement {}

class MockFieldElement extends Mock implements FieldElement {}

class MockDartType extends Mock implements DartType {}

class MockDartObject extends Mock implements DartObject {
  @override
  String toString() => 'Null (null)';
}
