import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:source_gen/source_gen.dart';

@nonNull
TypeChecker typeChecker(final Type type) => TypeChecker.fromRuntime(type);

bool isString(final DartType type) {
  return _stringTypeChecker.isExactlyType(type);
}

bool isBool(final DartType type) {
  return _boolTypeChecker.isExactlyType(type);
}

bool isInt(final DartType type) {
  return type.isDartCoreInt;
}

bool isDouble(final DartType type) {
  return _doubleTypeChecker.isExactlyType(type);
}

bool isList(final DartType type) {
  // TODO this weirdly fails when using a TypeChecker
  return type.name == 'List' && type.element.library.isDartCore;
}

bool isSupportedType(final DartType type) {
  return TypeChecker.any([
    _stringTypeChecker,
    _boolTypeChecker,
    _intTypeChecker,
    _doubleTypeChecker
  ]).isExactlyType(type);
}

bool isStream(final DartType type) {
  return _streamTypeChecker.isExactlyType(type);
}

DartType flattenList(final DartType type) {
  return (type as ParameterizedType).typeArguments.first;
}

DartType flattenStream(final DartType type) {
  return (type as ParameterizedType).typeArguments.first;
}

final _stringTypeChecker = typeChecker(String);

final _boolTypeChecker = typeChecker(bool);

final _intTypeChecker = typeChecker(int);

final _doubleTypeChecker = typeChecker(double);

final _streamTypeChecker = typeChecker(Stream);
