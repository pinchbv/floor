import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

bool isString(DartType type) {
  return type.displayName == SupportedType.STRING && _isDartCore(type);
}

bool isBool(DartType type) {
  return type.displayName == SupportedType.BOOL && _isDartCore(type);
}

bool isInt(DartType type) {
  return type.isDartCoreInt;
}

bool isDouble(DartType type) {
  return type.displayName == SupportedType.DOUBLE && _isDartCore(type);
}

bool isList(DartType type) {
  return type.name == 'List' && _isDartCore(type);
}

bool isSupportedType(DartType type) {
  return [
        SupportedType.STRING,
        SupportedType.BOOL,
        SupportedType.INT,
        SupportedType.DOUBLE
      ].any((typeName) => typeName == type.displayName) &&
      _isDartCore(type);
}

bool isEntityAnnotation(ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == Annotation.ENTITY;
}

bool isDatabaseAnnotation(ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == Annotation.DATABASE;
}

bool isColumnInfoAnnotation(ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == Annotation.COLUMN_INFO;
}

bool isPrimaryKeyAnnotation(ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == Annotation.PRIMARY_KEY;
}

bool isQueryAnnotation(ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == Annotation.QUERY;
}

DartType flattenList(DartType type) {
  return (type as ParameterizedType).typeArguments.first;
}

bool _isDartCore(DartType type) {
  return type.element.library.isDartCore;
}

String _getAnnotationName(ElementAnnotation annotation) {
  return annotation.computeConstantValue().type.displayName;
}

abstract class SupportedType {
  static const STRING = 'String';
  static const BOOL = 'bool';
  static const INT = 'int';
  static const DOUBLE = 'double';
}

abstract class Annotation {
  static const ENTITY = 'Entity';
  static const DATABASE = 'Database';
  static const COLUMN_INFO = 'ColumnInfo';
  static const PRIMARY_KEY = 'PrimaryKey';
  static const QUERY = 'Query';
}

abstract class AnnotationField {
  static const QUERY_VALUE = 'value';
}
