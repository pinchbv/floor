import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

bool isInt(DartType type) {
  return type.isDartCoreInt;
}

bool isString(DartType type) {
  return type.displayName == 'String' && _isDartCore(type);
}

bool isBoolean(DartType type) {
  return type.displayName == 'bool' && _isDartCore(type);
}

bool isDouble(DartType type) {
  return type.displayName == 'double' && _isDartCore(type);
}

bool isEntityAnnotation(ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == 'Entity';
}

bool isDatabaseAnnotation(ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == 'Database';
}

bool isColumnInfoAnnotation(ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == 'ColumnInfo';
}

bool isPrimaryKeyAnnotation(ElementAnnotation annotation) {
  return _getAnnotationName(annotation) == 'PrimaryKey';
}

bool _isDartCore(DartType type) {
  return type.element.library.isDartCore;
}

String _getAnnotationName(ElementAnnotation annotation) {
  return annotation.computeConstantValue().type.displayName;
}
