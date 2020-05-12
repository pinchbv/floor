import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations
    show Embedded;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/embedded.dart';
import 'package:floor_generator/value_object/field.dart';

class EmbeddedProcessor extends Processor<Embedded> {
  final ClassElement _classElement;
  final FieldElement _fieldElement;

  EmbeddedProcessor(final FieldElement fieldElement)
      : assert(fieldElement != null),
        _fieldElement = fieldElement,
        _classElement = fieldElement.type.element as ClassElement;

  @nonNull
  @override
  Embedded process() {
    return Embedded(
      _fieldElement,
      _getFields(),
    );
  }

  @nonNull
  String _getPrefix() {
    return _fieldElement
            .getAnnotation(annotations.Embedded)
            .getField(AnnotationField.embeddedPrefix)
            ?.toStringValue() ??
        '';
  }

  @nonNull
  List<Field> _getFields() {
    return _classElement.fields
        .map((fieldElement) =>
            FieldProcessor(fieldElement, _getPrefix()).process())
        .toList();
  }
}
