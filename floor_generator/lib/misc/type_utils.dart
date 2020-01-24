import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:source_gen/source_gen.dart';

@nonNull
TypeChecker typeChecker(final Type type) => TypeChecker.fromRuntime(type);

extension SupportedTypeChecker on DartType {
  @nonNull
  bool get isSupported {
    return TypeChecker.any([
      _stringTypeChecker,
      _boolTypeChecker,
      _intTypeChecker,
      _doubleTypeChecker
    ]).isExactlyType(this);
  }
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

final _stringTypeChecker = typeChecker(String);

final _boolTypeChecker = typeChecker(bool);

final _intTypeChecker = typeChecker(int);

final _doubleTypeChecker = typeChecker(double);

final _streamTypeChecker = typeChecker(Stream);
