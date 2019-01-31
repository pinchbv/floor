import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:source_gen/source_gen.dart';

/// Raps a method annotated with Query
/// to enable easy access to code generation relevant data.
class QueryMethod {
  final MethodElement method;

  QueryMethod(this.method);

  /// Query as defined in by user in Dart code.
  String get rawQuery {
    final query = method.metadata
        .firstWhere(isQueryAnnotation)
        .computeConstantValue()
        .getField(AnnotationField.QUERY_VALUE)
        .toStringValue();

    if (query.isEmpty) {
      throw InvalidGenerationSourceError("You didn't define a query.",
          element: method);
    }

    return query;
  }

  /// Query where ':' got replaced with '$'.
  String get query => rawQuery.replaceAll(RegExp(':'), '\$');

  String get name => method.displayName;

  DartType get rawReturnType => method.returnType;

  /// Flattened return type.
  ///
  /// E.g.
  /// Future<T> -> T,
  /// Future<List<T>> -> T
  DartType get flattenedReturnType {
    final type = method.returnType.flattenFutures(method.context.typeSystem);
    if (returnsList) {
      return flattenList(type);
    }
    return type;
  }

  List<ParameterElement> get parameters => method.parameters;

  bool get returnsList {
    final type = method.returnType.flattenFutures(method.context.typeSystem);
    return isList(type);
  }

  bool returnsEntity(LibraryReader library) {
    final entities = library.classes
        .where((clazz) =>
            !clazz.isAbstract && clazz.metadata.any(isEntityAnnotation))
        .map((clazz) => clazz.displayName)
        .toList();

    return entities.any((entity) => entity == flattenedReturnType.displayName);
  }
}
