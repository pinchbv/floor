import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/constants.dart';

bool isString(final DartType type) {
  return type.displayName == SupportedType.STRING && _isDartCore(type);
}

bool isBool(final DartType type) {
  return type.displayName == SupportedType.BOOL && _isDartCore(type);
}

bool isInt(final DartType type) {
  return type.isDartCoreInt;
}

bool isDouble(final DartType type) {
  return type.displayName == SupportedType.DOUBLE && _isDartCore(type);
}

bool isList(final DartType type) {
  return type.name == 'List' && _isDartCore(type);
}

bool isSupportedType(final DartType type) {
  return [
        SupportedType.STRING,
        SupportedType.BOOL,
        SupportedType.INT,
        SupportedType.DOUBLE
      ].any((typeName) => typeName == type.displayName) &&
      _isDartCore(type);
}

bool isEntityAnnotation(final ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == Annotation.ENTITY;
}

bool isDatabaseAnnotation(final ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == Annotation.DATABASE;
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

bool _isDartCore(final DartType type) {
  return type.element.library.isDartCore;
}

String _getAnnotationName(final ElementAnnotation annotation) {
  return annotation.computeConstantValue().type.displayName;
}
