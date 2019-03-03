import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/model/column.dart';
import 'package:floor_generator/model/delete_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class DeleteMethodBodyWriter implements Writer {
  final LibraryReader library;
  final DeleteMethod method;

  DeleteMethodBodyWriter(final this.library, final this.method);

  @override
  Code write() {
    return Code(_generateMethodBody());
  }

  String _generateMethodBody() {
    _assertMethodReturnsNoList();

    final entityName = method.getEntity(library).name;
    final methodSignatureParameterName = method.parameter.name;

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
        'Delete methods have to return a Future of either void or int.',
        element: method.method,
      );
    }
  }

  String _generateVoidReturnMethodBody(
    final String methodSignatureParameterName,
    final String entityName,
  ) {
    if (method.changesMultipleItems) {
      return 'await _${entityName}DeletionAdapter.deleteList($methodSignatureParameterName);';
    } else {
      return 'await _${entityName}DeletionAdapter.delete($methodSignatureParameterName);';
    }
  }

  String _generateIntReturnMethodBody(
    final String methodSignatureParameterName,
    final String entityName,
  ) {
    if (method.changesMultipleItems) {
      return 'return _${entityName}DeletionAdapter.deleteListAndReturnChangedRows($methodSignatureParameterName);';
    } else {
      return 'return _${entityName}DeletionAdapter.deleteAndReturnChangedRows($methodSignatureParameterName);';
    }
  }

  void _assertMethodReturnsNoList() {
    if (method.returnsList) {
      throw InvalidGenerationSourceError(
        'Delete methods have to return a Future of either void or int but not a list.',
        element: method.method,
      );
    }
  }
}
