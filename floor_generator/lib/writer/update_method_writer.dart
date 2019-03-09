import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/change_method_writer_helper.dart';
import 'package:floor_generator/misc/string_utils.dart';
import 'package:floor_generator/value_object/update_method.dart';
import 'package:floor_generator/writer/writer.dart';

class UpdateMethodWriter implements Writer {
  final UpdateMethod _method;
  final ChangeMethodWriterHelper _helper;

  UpdateMethodWriter(
    final UpdateMethod method, [
    final ChangeMethodWriterHelper helper,
  ])  : assert(method != null),
        _method = method,
        _helper = helper ?? ChangeMethodWriterHelper(method);

  @nonNull
  @override
  Method write() {
    final methodBuilder = MethodBuilder()..body = Code(_generateMethodBody());
    _helper.addChangeMethodSignature(methodBuilder);
    return methodBuilder.build();
  }

  @nonNull
  String _generateMethodBody() {
    final entityName = decapitalize(_method.entity.name);
    final methodSignatureParameterName = _method.parameterElement.displayName;

    if (_method.flattenedReturnType.isVoid) {
      return _generateVoidReturnMethodBody(
        methodSignatureParameterName,
        entityName,
      );
    } else {
      // if not void then must be int return
      return _generateIntReturnMethodBody(
        methodSignatureParameterName,
        entityName,
      );
    }
  }

  @nonNull
  String _generateIntReturnMethodBody(
    final String methodSignatureParameterName,
    final String entityName,
  ) {
    if (_method.changesMultipleItems) {
      return 'return _${entityName}UpdateAdapter.updateListAndReturnChangedRows($methodSignatureParameterName, ${_method.onConflict});';
    } else {
      return 'return _${entityName}UpdateAdapter.updateAndReturnChangedRows($methodSignatureParameterName, ${_method.onConflict});';
    }
  }

  @nonNull
  String _generateVoidReturnMethodBody(
    final String methodSignatureParameterName,
    final String entityName,
  ) {
    if (_method.changesMultipleItems) {
      return 'await _${entityName}UpdateAdapter.updateList($methodSignatureParameterName, ${_method.onConflict});';
    } else {
      return 'await _${entityName}UpdateAdapter.update($methodSignatureParameterName, ${_method.onConflict});';
    }
  }
}
