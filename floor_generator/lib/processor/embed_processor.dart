import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/extension/field_element_extension.dart';
import 'package:floor_generator/misc/extension/type_converters_extension.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/embed.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/type_converter.dart';

class EmbedProcessor extends Processor<Embed> {
  final ClassElement _classElement;
  Set<TypeConverter> typeConverters;

  EmbedProcessor(this._classElement, this.typeConverters);

  @override
  Embed process() {
    return Embed(
      _classElement,
      _getFields(),
    );
  }

  List<Field> _getFields() {
    final fields = _classElement.fields
        .where((fieldElement) => fieldElement.shouldBeIncluded())
        .map((field) => FieldProcessor(field, typeConverters.getClosestOrNull(field.type), null).process())
        .toList();

    return fields;
  }
}