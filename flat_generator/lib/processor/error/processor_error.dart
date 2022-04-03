import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class ProcessorError extends Error {
  /// Description of the error.
  final String message;

  /// What could have been changed in the source code to resolve this error.
  final String todo;

  /// The code element associated with this error.
  final Element element;

  ProcessorError({
    required this.message,
    required this.todo,
    required this.element,
  });

  @override
  String toString() {
    final buffer = StringBuffer('$message $todo');

    try {
      final span = spanForElement(element);
      buffer
        ..writeln()
        ..writeln(span.start.toolString)
        ..write(span.highlight());
    } catch (_) {
      // Source for `element` wasn't found, it must be in a summary with no
      // associated source. We can still give the name.
      buffer
        ..writeln()
        ..writeln('Cause: $element');
    }

    return buffer.toString();
  }
}
