import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class TransactionMethodProcessorError {
  final MethodElement _methodElement;

  TransactionMethodProcessorError(this._methodElement);

  InvalidGenerationSourceError get shouldReturnFuture {
    return InvalidGenerationSourceError(
        'Transaction method should return `Future<>`',
        todo:
            'Please wrap your return value in a `Future`. `Stream`s are not allowed.',
        element: _methodElement);
  }
}
