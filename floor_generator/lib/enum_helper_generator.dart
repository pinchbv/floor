// ignore_for_file: import_of_legacy_library_into_null_safe
import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:source_gen/source_gen.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;

class EnumHelperGenerator extends Generator {
  final TypeChecker hasEnumValueAnnotation = const TypeChecker.fromRuntime(annotations.EnumValue);
  final TypeChecker hasDescriptionAnnotation = const TypeChecker.fromRuntime(Description);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    final lib = Library(
          (b) => b
        ..body.addAll(
          library.enums.map((e) => Code(_codeForEnum(e))),
        ),
    );
    final emitter = DartEmitter();
    return lib.accept(emitter).toString();
  }

  String _codeForEnum(ClassElement enumElement) {
    final enumValueAnnotations = enumElement.annotatedWith(hasEnumValueAnnotation);
    final descriptionAnnotations = enumElement.annotatedWith(hasDescriptionAnnotation);
    if (enumValueAnnotations.isEmpty && descriptionAnnotations.isEmpty) {
      return '';
    }

    final typeReturnIsString = !enumValueAnnotations.every((e) => !e.annotation.read(EnumValueField.value).isString);
    var typeReturn = enumValueAnnotations.first.annotation.read(EnumValueField.value).literalValue.runtimeType;
    if (typeReturn == Null) {
      for (final item in enumValueAnnotations) {
        final runtimeType = item.annotation.read(EnumValueField.value).literalValue.runtimeType;
        if (runtimeType != Null) {
          typeReturn = runtimeType;
        }
      }
    }

    final str = StringBuffer();
    str.writeln('    extension ${enumElement.name}ValueExtension on ${enumElement.name} {');

    if (enumValueAnnotations.isNotEmpty) {
      final extension = """
      $typeReturn get value {
        switch (this) {
          ${enumValueAnnotations.map((f) => """
          case ${enumElement.name}.${f.element.name}:
            return ${typeReturnIsString ? '\'${f.annotation.read("value").literalValue}\'' : f.annotation.read("value").literalValue};""").join()}
        }
      }""";
      str.writeln(extension);
    }

    if (descriptionAnnotations.isNotEmpty) {
      final extension = """
      String get description {
        switch (this) {
          ${descriptionAnnotations.map((f) => """
          case ${enumElement.name}.${f.element.name}:
            return '${f.annotation.read(DescriptionField.description).stringValue}';""").join()}
        }
      }""";
      str.writeln(extension);
    }

    str.writeln('    }');
    return str.toString();
  }
}

extension _EnumElementExtension on ClassElement {
  Iterable<AnnotatedElement> annotatedWith(TypeChecker checker) {
    return fields
        .map((f) {
      final annotation = checker.firstAnnotationOf(f, throwOnUnresolved: true);
      // ignore: unnecessary_null_comparison
      return (annotation != null) ? AnnotatedElement(ConstantReader(annotation), f) : null;
    })
        .where((e) => e != null)
        .cast();
  }
}
