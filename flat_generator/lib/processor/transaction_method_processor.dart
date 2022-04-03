import 'package:analyzer/dart/element/element.dart';
import 'package:flat_generator/processor/error/transaction_method_processor_error.dart';
import 'package:flat_generator/processor/processor.dart';
import 'package:flat_generator/value_object/transaction_method.dart';

class TransactionMethodProcessor implements Processor<TransactionMethod> {
  final MethodElement _methodElement;
  final String _daoGetterName;
  final String _databaseName;

  TransactionMethodProcessor(
    final MethodElement methodElement,
    final String daoGetterName,
    final String databaseName,
  )   : _methodElement = methodElement,
        _daoGetterName = daoGetterName,
        _databaseName = databaseName;

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
