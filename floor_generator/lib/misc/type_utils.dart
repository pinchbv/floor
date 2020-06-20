import 'dart:typed_data';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:source_gen/source_gen.dart';

extension SupportedTypeChecker on DartType {
  @nonNull
  bool get isSupported {
    return TypeChecker.any([
      _stringTypeChecker,
      _boolTypeChecker,
      _intTypeChecker,
      _doubleTypeChecker,
      _uint8ListTypeChecker
    ]).isExactlyType(isDartCoreList ? flatten() : this);
  }
}

extension Uint8ListTypeChecker on DartType {
  @nonNull
  bool get isUint8List => getDisplayString() == 'Uint8List';
}

extension StreamTypeChecker on DartType {
  @nonNull
  bool get isStream => _streamTypeChecker.isExactlyType(this);
}

extension FlattenUtil on DartType {
  @nonNull
  DartType flatten() {
    return (this as ParameterizedType).typeArguments.first;
  }
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

  /// Returns the first annotation object with type [type]
  ElementAnnotation getAnnotationElement(final Type type) {
    for (var i = 0; i < metadata.length; i++) {
      final annotation = metadata[i];
      final value = annotation.computeConstantValue();

      //maybe:  if value=null, annotation could not be resolved

      if (value?.type != null && _typeChecker(type).isExactlyType(value.type)) {
        return annotation;
      }
    }
    return null;
  }
}

@nonNull
TypeChecker _typeChecker(final Type type) => TypeChecker.fromRuntime(type);

final _stringTypeChecker = _typeChecker(String);

final _boolTypeChecker = _typeChecker(bool);

final _intTypeChecker = _typeChecker(int);

final _doubleTypeChecker = _typeChecker(double);

final _uint8ListTypeChecker = _typeChecker(Uint8List);

final _streamTypeChecker = _typeChecker(Stream);
