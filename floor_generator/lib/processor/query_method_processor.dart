import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:source_gen/source_gen.dart';

class QueryMethodProcessor extends Processor<QueryMethod> {
  final MethodElement _methodElement;
  final List<Entity> _entities;

  QueryMethodProcessor(
    final MethodElement methodElement,
    final List<Entity> entities,
  )   : assert(methodElement != null),
        assert(entities != null),
        _methodElement = methodElement,
        _entities = entities;

  @override
  QueryMethod process() {
    final name = _methodElement.displayName;
    final parameters = _methodElement.parameters;
    final rawReturnType = _methodElement.returnType;

    final query = _getQuery();
    final returnsStream = isStream(rawReturnType);

    _assertReturnsFutureOrStream(rawReturnType, returnsStream);
    _assertQueryParameters(query, parameters);

    final flattenedReturnType = _getFlattenedReturnType(
      rawReturnType,
      returnsStream,
    );

    final entity = _entities.firstWhere(
        (entity) =>
            entity.classElement.displayName == flattenedReturnType.displayName,
        orElse: () => null); // doesn't return an entity

    return QueryMethod(
      _methodElement,
      name,
      query,
      rawReturnType,
      flattenedReturnType,
      parameters,
      entity,
    );
  }

  String _getQuery() {
    final query = _methodElement.metadata
        .firstWhere(isQueryAnnotation)
        .computeConstantValue()
        .getField(AnnotationField.QUERY_VALUE)
        .toStringValue();

    if (query.isEmpty || query == null) {
      throw InvalidGenerationSourceError(
        "You didn't define a query.",
        element: _methodElement,
      );
    }
    return query.replaceAll(RegExp(':'), r'$');
  }

  List<String> _getQueryParameterNames(final String query) {
    return RegExp(r'\$.[^\s]+')
        .allMatches(query)
        .map((match) => match.group(0).replaceFirst(RegExp(r'\$'), ''))
        .toList();
  }

  DartType _getFlattenedReturnType(
    final DartType rawReturnType,
    final bool returnsStream,
  ) {
    final returnsList = _getReturnsList(rawReturnType, returnsStream);

    final type = returnsStream
        ? flattenStream(_methodElement.returnType)
        : rawReturnType.flattenFutures(_methodElement.context.typeSystem);
    if (returnsList) {
      return flattenList(type);
    }
    return type;
  }

  bool _getReturnsList(final DartType returnType, final bool returnsStream) {
    final type = returnsStream
        ? flattenStream(returnType)
        : returnType.flattenFutures(_methodElement.context.typeSystem);

    return isList(type);
  }

  void _assertReturnsFutureOrStream(
    final DartType rawReturnType,
    final bool returnsStream,
  ) {
    if (!rawReturnType.isDartAsyncFuture && !returnsStream) {
      throw InvalidGenerationSourceError(
        'All queries have to return a Future or Stream.',
        element: _methodElement,
      );
    }
  }

  void _assertQueryParameters(
    final String query,
    final List<ParameterElement> parameterElements,
  ) {
    final queryParameterNames = _getQueryParameterNames(query);

    final methodSignatureParameterNames =
        parameterElements.map((parameter) => parameter.name).toList();

    final sameAmountParameters =
        queryParameterNames.length == methodSignatureParameterNames.length;

    final allParametersAreAvailable = queryParameterNames.every(
        (parameterName) =>
            methodSignatureParameterNames.any((name) => name == parameterName));

    if (!allParametersAreAvailable || !sameAmountParameters) {
      throw InvalidGenerationSourceError(
        "Parameters of method signature don't match with parameters in the query.",
        element: _methodElement,
      );
    }
  }
}
