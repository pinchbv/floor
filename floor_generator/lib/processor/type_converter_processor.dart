import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/type_converter.dart';

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
    final supertype = _classElement.supertype;
    if (supertype == null) {
      throw ProcessorError(
        message:
            'Only classes that inherit from TypeConverter can be used as type converters.',
        todo: 'Make sure use a class that inherits from TypeConverter.',
        element: _classElement,
      );
    }
    final typeArguments = supertype.typeArguments;
    final fieldType = typeArguments[0];
    final databaseType = typeArguments[1];

    if (!databaseType.isDefaultSqlType) {
      throw ProcessorError(
        message:
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
