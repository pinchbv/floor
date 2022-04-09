import 'package:analyzer/dart/element/element.dart';
import 'package:flat_generator/misc/extension/field_element_extension.dart';

extension ClassElementExtension on ClassElement {
  Iterable<FieldElement> getFields() => [
        ...fields,
        ...allSupertypes.expand((type) => type.element.fields),
      ].where((fieldElement) => fieldElement.shouldBeIncluded());
}
