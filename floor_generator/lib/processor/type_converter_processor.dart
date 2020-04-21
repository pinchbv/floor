import 'package:analyzer/dart/element/element.dart';
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
    final typeArguments = _classElement.supertype.typeArguments;
    return TypeConverter(
      _classElement.displayName,
      typeArguments[0],
      typeArguments[1],
      _typeConverterScope,
    );
  }
}
