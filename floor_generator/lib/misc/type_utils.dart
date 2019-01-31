import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/constants.dart';

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
