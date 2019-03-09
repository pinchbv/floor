import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:source_gen/source_gen.dart';

@nonNull
TypeChecker typeChecker(final Type type) => TypeChecker.fromRuntime(type);

final _stringTypeChecker = typeChecker(String);

final _boolTypeChecker = typeChecker(bool);

final _intTypeChecker = typeChecker(int);

final _doubleTypeChecker = typeChecker(double);

final _streamTypeChecker = typeChecker(Stream);

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
  return type.name == 'List' && _isDartCore(type);
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

bool isEntityAnnotation(final ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == Annotation.ENTITY;
}

bool isColumnInfoAnnotation(final ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == Annotation.COLUMN_INFO;
}

bool isPrimaryKeyAnnotation(final ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == Annotation.PRIMARY_KEY;
}

bool isQueryAnnotation(final ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == Annotation.QUERY;
}

bool isInsertAnnotation(final ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == Annotation.INSERT;
}

bool isUpdateAnnotation(final ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == Annotation.UPDATE;
}

bool isDeleteAnnotation(final ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == Annotation.DELETE;
}

bool isTransactionAnnotation(final ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == Annotation.TRANSACTION;
}

DartType flattenList(final DartType type) {
  return (type as ParameterizedType).typeArguments.first;
}

DartType flattenStream(final DartType type) {
  return (type as ParameterizedType).typeArguments.first;
}

bool _isDartCore(final DartType type) {
  return type.element.library.isDartCore;
}

String _getAnnotationName(final ElementAnnotation annotation) {
  return annotation.computeConstantValue().type.displayName;
}
