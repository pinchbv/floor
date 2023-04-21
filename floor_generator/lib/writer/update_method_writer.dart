import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/change_method_writer_helper.dart';
import 'package:floor_generator/misc/extension/string_extension.dart';
import 'package:floor_generator/value_object/update_method.dart';
import 'package:floor_generator/writer/writer.dart';

class UpdateMethodWriter implements Writer {
  final UpdateMethod _method;
  final ChangeMethodWriterHelper _helper;

  UpdateMethodWriter(
    final UpdateMethod method, [
    final ChangeMethodWriterHelper? helper,
  ])  : _method = method,
        _helper = helper ?? ChangeMethodWriterHelper(method);

  @override
  Method write() {
    final methodBuilder = MethodBuilder()..body = Code(_generateMethodBody());
    _helper.addChangeMethodSignature(methodBuilder);
    return methodBuilder.build();
  }

  String _generateMethodBody() {
    final entityClassName =
        _method.entity.classElement.displayName.decapitalize();
    final methodSignatureParameterName = _method.parameterElement.displayName;

    if (_method.flattenedReturnType is VoidType) {
      return _generateVoidReturnMethodBody(
        methodSignatureParameterName,
        entityClassName,
      );
    } else {
      // if not void then must be int return
      return _generateIntReturnMethodBody(
        methodSignatureParameterName,
        entityClassName,
      );
    }
  }

  String _generateIntReturnMethodBody(
    final String methodSignatureParameterName,
    final String entityClassName,
  ) {
    if (_method.changesMultipleItems) {
      return 'return _${entityClassName}UpdateAdapter.updateListAndReturnChangedRows($methodSignatureParameterName, ${_method.onConflict});';
    } else {
      return 'return _${entityClassName}UpdateAdapter.updateAndReturnChangedRows($methodSignatureParameterName, ${_method.onConflict});';
    }
  }

  String _generateVoidReturnMethodBody(
    final String methodSignatureParameterName,
    final String entityClassName,
  ) {
    if (_method.changesMultipleItems) {
      return 'await _${entityClassName}UpdateAdapter.updateList($methodSignatureParameterName, ${_method.onConflict});';
    } else {
      return 'await _${entityClassName}UpdateAdapter.update($methodSignatureParameterName, ${_method.onConflict});';
    }
  }
}
