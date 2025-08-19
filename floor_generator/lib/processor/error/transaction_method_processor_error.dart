import 'package:analyzer/dart/element/element2.dart';
import 'package:source_gen/source_gen.dart';

class TransactionMethodProcessorError {
  final MethodElement2 _methodElement;

  TransactionMethodProcessorError(this._methodElement);

  InvalidGenerationSourceError get shouldReturnFuture {
    return InvalidGenerationSourceError('Transaction method should return `Future<>`',
        todo: 'Please wrap your return value in a `Future`. `Stream`s are not allowed.', element: _methodElement);
  }
}
