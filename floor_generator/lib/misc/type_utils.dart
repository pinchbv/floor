import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:source_gen/source_gen.dart';

@nonNull
bool isString(final DartType type) {
  return type.isDartCoreString;
}

@nonNull
bool isBool(final DartType type) {
  return type.isDartCoreBool;
}

@nonNull
bool isInt(final DartType type) {
  return type.isDartCoreInt;
}

@nonNull
bool isDouble(final DartType type) {
  return type.isDartCoreDouble;
}

@nonNull
bool isList(final DartType type) {
  return type.isDartCoreList;
}

@nonNull
bool isSupportedType(final DartType type) {
  return TypeChecker.any([
    _stringTypeChecker,
    _boolTypeChecker,
    _intTypeChecker,
    _doubleTypeChecker
  ]).isExactlyType(type);
}

@nonNull
bool isStream(final DartType type) {
  return _streamTypeChecker.isExactlyType(type);
}

@nonNull
DartType flattenList(final DartType type) {
  return (type as ParameterizedType).typeArguments.first;
}

@nonNull
DartType flattenStream(final DartType type) {
  return (type as ParameterizedType).typeArguments.first;
}

extension AnnotationChecker on Element {
  @nonNull
  bool hasAnnotation(final Type type) {
    return _typeChecker(type).hasAnnotationOfExact(this);
  }

  /// Returns the first annotation object found on [type]
  @nonNull
  DartObject getAnnotation(final Type type) {
    return _typeChecker(type).firstAnnotationOfExact(this);
  }
}

@nonNull
TypeChecker _typeChecker(final Type type) => TypeChecker.fromRuntime(type);

final _stringTypeChecker = _typeChecker(String);

final _boolTypeChecker = _typeChecker(bool);

final _intTypeChecker = _typeChecker(int);

final _doubleTypeChecker = _typeChecker(double);

final _streamTypeChecker = _typeChecker(Stream);
