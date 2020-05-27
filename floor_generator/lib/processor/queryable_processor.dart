import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/embedded_processor.dart';
import 'package:floor_generator/processor/error/queryable_processor_error.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/embedded.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/fieldable.dart';
import 'package:floor_generator/value_object/queryable.dart';
import 'package:floor_generator/extension/field_element_extension.dart';
import 'package:meta/meta.dart';

abstract class QueryableProcessor<T extends Queryable> extends Processor<T> {
  final QueryableProcessorError _queryableProcessorError;

  @protected
  final ClassElement classElement;
  @protected
  final List<FieldElement> _fields;

  @protected
  QueryableProcessor(this.classElement)
      : assert(classElement != null),
        _queryableProcessorError = QueryableProcessorError(classElement),
        _fields = [
          ...classElement.fields,
          ...classElement.allSupertypes.expand((type) => type.element.fields),
        ];

  @nonNull
  @protected
  List<Field> getFields() {
    if (classElement.mixins.isNotEmpty) {
      throw _queryableProcessorError.prohibitedMixinUsage;
    }

    return _fields
        .where((fieldElement) => fieldElement.shouldBeIncluded())
        .map((field) => FieldProcessor(field).process())
        .toList();
  }

  @nonNull
  @protected
  List<Embedded> getEmbeddeds() {
    return _fields
        .where((fieldElement) => fieldElement.isEmbedded)
        .map((embedded) => EmbeddedProcessor(embedded).process())
        .toList();
  }

  @nonNull
  @protected
  String getConstructor(final List<Fieldable> items) {
    final buffer = StringBuffer();

    void write(final ClassElement classElement, final List<Fieldable> items) {
      final parameters = classElement.constructors.first.parameters;

      buffer.write('${classElement.displayName}(');

      parameters.asMap().forEach((index, parameter) {
        final parameterName = parameter.displayName;

        if (parameter.isNamed) {
          buffer.write('$parameterName: ');
        }

        final item = items.firstWhere(
          (item) => item.fieldElement.displayName == parameterName,
          // whenever field is `@ignored`
          orElse: () {
            buffer.write('null');
            return null;
          },
        );

        if (item is Field) {
          final parameterValue = "row['${item.columnName}']";
          final castedParameterValue = _castParameterValue(
              parameter.type, parameterValue, item.isNullable);
          buffer.write(castedParameterValue);
        }

        if (item is Embedded)
          write(item.classElement, [...item.fields, ...item.children]);

        /// ignore comma seprator if reach end
        if (parameters.length - 1 != index) buffer.write(', ');
      });

      buffer.write(')');
    }

    write(classElement, items);

    return buffer.toString();
  }

  @nonNull
  String _castParameterValue(
    final DartType parameterType,
    final String parameterValue,
    final bool isNullable,
  ) {
    if (parameterType.isDartCoreBool) {
      if (isNullable) {
        // maps int to bool
        // if the value is null, return null. If the value is not null, interpret 1 as true and 0 as false.
        return '$parameterValue == null ? null : ($parameterValue as int) != 0';
      } else {
        return '($parameterValue as int) != 0'; // maps int to bool
      }
    } else if (parameterType.isDartCoreString) {
      return '$parameterValue as String';
    } else if (parameterType.isDartCoreInt) {
      return '$parameterValue as int';
    } else if (parameterType.isUint8List) {
      return '$parameterValue as Uint8List';
    } else {
      return '$parameterValue as double'; // must be double
    }
  }
}
