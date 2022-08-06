import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/misc/extension/dart_type_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/base_query_method_processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/queryable.dart';

abstract class BaseQueryMethodProcessor extends Processor<QueryMethod> {
  final MethodElement _methodElement;
  final List<Queryable> _queryables;
  final BaseQueryMethodProcessorError _processorError;

  BaseQueryMethodProcessor(
    final MethodElement methodElement,
    final List<Queryable> queryables,
  )   : _methodElement = methodElement,
        _queryables = queryables,
        _processorError = BaseQueryMethodProcessorError(methodElement);

  @override
  QueryMethod process() {
    final name = _methodElement.displayName;
    final parameters = _methodElement.parameters;
    final returnType = _methodElement.returnType;
    final returnsStream = returnType.isStream;
    _assertReturnsFutureOrStream(returnType, returnsStream);
    final returnsList = _getReturnsList(returnType, returnsStream);

    final flattenedReturnType = _getFlattenedReturnType(
      returnType,
      returnsStream,
      returnsList,
    );

    _assertReturnsNullableSingle(
      returnsStream,
      returnsList,
      flattenedReturnType,
    );

    final queryable = _queryables.firstWhereOrNull((queryable) =>
        queryable.classElement.displayName ==
        flattenedReturnType.getDisplayString(withNullability: false));

    return onProcess(
      _methodElement,
      name,
      returnType,
      flattenedReturnType,
      parameters,
      queryable,
    );
  }

  DartType _getFlattenedReturnType(
    final DartType rawReturnType,
    final bool returnsStream,
    final bool returnsList,
  ) {
    final type = returnsStream
        ? _methodElement.returnType.flatten()
        : _methodElement.library.typeSystem.flatten(rawReturnType);
    return returnsList ? type.flatten() : type;
  }

  bool _getReturnsList(final DartType returnType, final bool returnsStream) {
    final type = returnsStream
        ? returnType.flatten()
        : _methodElement.library.typeSystem.flatten(returnType);

    return type.isDartCoreList;
  }

  void _assertReturnsFutureOrStream(
    final DartType rawReturnType,
    final bool returnsStream,
  ) {
    if (!rawReturnType.isDartAsyncFuture && !returnsStream) {
      throw _processorError.doesNotReturnFutureNorStream;
    }
  }

  void _assertReturnsNullableSingle(
    final bool returnsStream,
    final bool returnsList,
    final DartType flattenedReturnType,
  ) {
    if (!returnsList &&
        !flattenedReturnType.isVoid &&
        !flattenedReturnType.isNullable) {
      returnsStream
          ? throw _processorError.doesNotReturnNullableStream
          : throw _processorError.doesNotReturnNullableFuture;
    }
  }

  QueryMethod onProcess(
    MethodElement methodElement,
    String name,
    DartType returnType,
    DartType flattenedReturnType,
    List<ParameterElement> parameters,
    Queryable? queryable,
  );
}
