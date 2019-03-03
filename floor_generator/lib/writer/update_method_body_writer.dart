import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/model/update_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class UpdateMethodBodyWriter implements Writer {
  final LibraryReader library;
  final UpdateMethod method;

  UpdateMethodBodyWriter(final this.library, final this.method);

  @override
  Code write() {
    return Code(_generateMethodBody());
  }

  String _generateMethodBody() {
    _assertMethodReturnsNoList();

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
        'Update methods have to return a Future of either void or int.',
        element: method.method,
      );
    }
  }

  String _generateIntReturnMethodBody(
    final String methodSignatureParameterName,
    final String entityName,
  ) {
    if (method.changesMultipleItems) {
      return 'return _${entityName}UpdateAdapter.updateListAndReturnChangedRows($methodSignatureParameterName, ${method.onConflict});';
    } else {
      return 'return _${entityName}UpdateAdapter.updateAndReturnChangedRows($methodSignatureParameterName, ${method.onConflict});';
    }
  }

  String _generateVoidReturnMethodBody(
    final String methodSignatureParameterName,
    final String entityName,
  ) {
    if (method.changesMultipleItems) {
      return 'await _${entityName}UpdateAdapter.updateList($methodSignatureParameterName, ${method.onConflict});';
    } else {
      return 'await _${entityName}UpdateAdapter.update($methodSignatureParameterName, ${method.onConflict});';
    }
  }

  void _assertMethodReturnsNoList() {
    if (method.returnsList) {
      throw InvalidGenerationSourceError(
        'Update methods have to return a Future of either void or int but not a list.',
        element: method.method,
      );
    }
  }
}
