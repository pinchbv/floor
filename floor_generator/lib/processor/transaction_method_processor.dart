import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/processor/error/transaction_method_processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/transaction_method.dart';

class TransactionMethodProcessor implements Processor<TransactionMethod> {
  final MethodElement _methodElement;
  final String _daoGetterName;
  final String _databaseName;

  TransactionMethodProcessor(
    final MethodElement methodElement,
    final String daoGetterName,
    final String databaseName,
  )   : assert(methodElement != null),
        assert(daoGetterName != null),
        assert(daoGetterName != null),
        _methodElement = methodElement,
        _daoGetterName = daoGetterName,
        _databaseName = databaseName;

  @nonNull
  @override
  TransactionMethod process() {
    final name = _methodElement.displayName;
    final returnType = _methodElement.returnType;
    final parameterElements = _methodElement.parameters;

    if (!returnType.isDartAsyncFuture) {
      throw TransactionMethodProcessorError(_methodElement).shouldReturnFuture;
    }

    return TransactionMethod(
      _methodElement,
      name,
      returnType,
      parameterElements,
      _daoGetterName,
      _databaseName,
    );
  }
}
