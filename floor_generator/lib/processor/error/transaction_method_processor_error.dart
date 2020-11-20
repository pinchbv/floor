// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class TransactionMethodProcessorError {
  final MethodElement _methodElement;

  TransactionMethodProcessorError(final this._methodElement)
      : assert(_methodElement != null);

  InvalidGenerationSourceError get shouldReturnFuture {
    return InvalidGenerationSourceError(
        'Transaction method should return `Future<>`',
        todo:
            'Please wrap your return value in a `Future`. `Stream`s are not allowed.',
        element: _methodElement);
  }
}
