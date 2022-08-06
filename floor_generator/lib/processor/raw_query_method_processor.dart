import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/extension/dart_type_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/base_query_method_processor.dart';
import 'package:floor_generator/processor/error/raw_query_method_processor_error.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/queryable.dart';

class RawQueryMethodProcessor extends BaseQueryMethodProcessor {
  final RawQueryMethodProcessorError _processorError;
  final MethodElement _methodElement;

  RawQueryMethodProcessor(
    final MethodElement methodElement,
    final List<Queryable> queryables,
  )   : _methodElement = methodElement,
        _processorError = RawQueryMethodProcessorError(methodElement),
        super(methodElement, queryables);

  void _assertRawQueryParameters(
    final List<ParameterElement> parameterElements,
  ) {
    final parametersLength = parameterElements.length;
    if (parametersLength > 1 || parametersLength == 0) {
      throw _processorError.queryArgumentsShouldBeSingle;
    }

    final parameter = parameterElements[0];
    final type = parameter.type;
    if (type.isNullable) {
      throw _processorError.queryMethodParameterIsNullable(parameter);
    }
    if (!type.isDartCoreString && !type.isSQLiteQuery) {
      throw _processorError.queryArgumentsShouldBeSingle;
    }
  }

  @override
  QueryMethod onProcess(
    MethodElement methodElement,
    String name,
    DartType returnType,
    DartType flattenedReturnType,
    List<ParameterElement> parameters,
    Queryable? queryable,
  ) {
    _assertRawQueryParameters(parameters);

    return QueryMethod(
      _methodElement,
      name,
      null,
      returnType,
      flattenedReturnType,
      parameters,
      queryable,
      {},
    );
  }
}
