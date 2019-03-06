import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/value_object/insert_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class InsertMethodBodyWriter implements Writer {
  final LibraryReader library;
  final InsertMethod method;

  InsertMethodBodyWriter(final this.library, final this.method);

  @override
  Code write() {
    return Code(_generateMethodBody());
  }

  String _generateMethodBody() {
    final entityName = method.getEntity(library).name;
    final methodSignatureParameterName = method.parameter.displayName;

    if (method.returnsInt) {
      return _generateIntReturnMethodBody(
        methodSignatureParameterName,
        entityName,
      );
    } else if (method.returnsVoid) {
      return _generateVoidReturnMethodBody(
        methodSignatureParameterName,
        entityName,
      );
    } else {
      throw InvalidGenerationSourceError(
        'Insert methods have to return a Future of either void, int or List<int>.',
        element: method.method,
      );
    }
  }

  String _generateVoidReturnMethodBody(
    final String methodSignatureParameterName,
    final String entityName,
  ) {
    if (method.changesMultipleItems) {
      return 'await _${entityName}InsertionAdapter.insertList($methodSignatureParameterName, ${method.onConflict});';
    } else {
      return 'await _${entityName}InsertionAdapter.insert($methodSignatureParameterName, ${method.onConflict});';
    }
  }

  String _generateIntReturnMethodBody(
    final String methodSignatureParameterName,
    final String entityName,
  ) {
    if (method.changesMultipleItems) {
      return 'return _${entityName}InsertionAdapter.insertListAndReturnIds($methodSignatureParameterName, ${method.onConflict});';
    } else {
      return 'return _${entityName}InsertionAdapter.insertAndReturnId($methodSignatureParameterName, ${method.onConflict});';
    }
  }
}
