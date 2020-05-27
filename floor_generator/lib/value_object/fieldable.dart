import 'package:analyzer/dart/element/element.dart';

abstract class Fieldable {
  final FieldElement fieldElement;

  Fieldable(this.fieldElement);
}
