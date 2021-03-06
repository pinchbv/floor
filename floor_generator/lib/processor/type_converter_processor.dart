// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:source_gen/source_gen.dart';

class TypeConverterProcessor extends Processor<TypeConverter> {
  final ClassElement _classElement;
  final TypeConverterScope _typeConverterScope;

  TypeConverterProcessor(
    final ClassElement classElement,
    final TypeConverterScope typeConverterScope,
  )   : _classElement = classElement,
        _typeConverterScope = typeConverterScope;

  @override
  TypeConverter process() {
    final typeArguments = _classElement.supertype!.typeArguments;
    final fieldType = typeArguments[0];
    final databaseType = typeArguments[1];

    if (!databaseType.isDefaultSqlType) {
      throw InvalidGenerationSourceError(
        'Type converters have to convert to a database-compatible type.',
        todo:
            'Make the class convert to either int, double, String, bool or Uint8List.',
        element: _classElement,
      );
    }

    return TypeConverter(
      _classElement.displayName,
      fieldType,
      databaseType,
      _typeConverterScope,
    );
  }
}
