import 'package:analyzer/dart/element/element.dart';
import 'package:flat_annotation/flat_annotation.dart' as annotations;
import 'package:flat_generator/misc/constants.dart';
import 'package:flat_generator/misc/extension/class_element_extension.dart';
import 'package:flat_generator/misc/extension/dart_type_extension.dart';
import 'package:flat_generator/misc/extension/field_element_extension.dart';
import 'package:flat_generator/misc/extension/set_extension.dart';
import 'package:flat_generator/misc/extension/type_converter_element_extension.dart';
import 'package:flat_generator/misc/extension/type_converters_extension.dart';
import 'package:flat_generator/misc/type_utils.dart';
import 'package:flat_generator/processor/error/embedded_processor_error.dart';
import 'package:flat_generator/processor/field_processor.dart';
import 'package:flat_generator/processor/processor.dart';
import 'package:flat_generator/value_object/embedded.dart';
import 'package:flat_generator/value_object/field.dart';
import 'package:flat_generator/value_object/type_converter.dart';

class EmbeddedProcessor extends Processor<Embedded> {
  final ClassElement _classElement;
  final FieldElement _fieldElement;
  final String _prefix;
  final Set<TypeConverter> _typeConverters;
  final EmbeddedProcessorError _processorError;

  EmbeddedProcessor(
      final FieldElement fieldElement, final Set<TypeConverter> typeConverters,
      {final String prefix = ''})
      : _fieldElement = fieldElement,
        _classElement = fieldElement.type.element as ClassElement,
        _processorError =
            EmbeddedProcessorError(fieldElement.type.element as ClassElement),
        _prefix = prefix,
        _typeConverters = typeConverters +
            fieldElement.type.element!
                .getTypeConverters(TypeConverterScope.embedded);

  @override
  Embedded process() {
    try {
      final name = _fieldElement.name;
      final isNullable = _fieldElement.type.isNullable;

      return Embedded(
        _fieldElement,
        name,
        _getFields(),
        _getEmbedded(),
        isNullable,
      );
    } on StackOverflowError catch (_) {
      throw _processorError.possibleCyclicEmbeddedDependency;
    }
  }

  String _getPrefix() {
    final _currentPrefix = _fieldElement
            .getAnnotation(annotations.Embedded)
            ?.getField(AnnotationField.prefix)
            ?.toStringValue() ??
        '';
    return _prefix + _currentPrefix;
  }

  List<Field> _getFields() {
    final fields = _classElement.getFields();
    return fields.where((field) => !field.isEmbedded()).map((field) {
      final converter = _typeConverters.getClosestOrNull(field.type);
      return FieldProcessor(field, converter, prefix: _getPrefix()).process();
    }).toList();
  }

  List<Embedded> _getEmbedded() => _classElement.fields
      .where((field) => field.isEmbedded())
      .map((embedded) =>
          EmbeddedProcessor(embedded, _typeConverters, prefix: _getPrefix())
              .process())
      .toList();
}
