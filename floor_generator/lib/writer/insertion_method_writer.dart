import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/change_method_writer_helper.dart';
import 'package:floor_generator/misc/string_utils.dart';
import 'package:floor_generator/value_object/insertion_method.dart';
import 'package:floor_generator/writer/writer.dart';

class InsertionMethodWriter implements Writer {
  final InsertionMethod _method;
  final ChangeMethodWriterHelper _helper;

  InsertionMethodWriter(
    final InsertionMethod method, [
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
    final decapitalizedEntityName = decapitalize(_method.entity.name);
    final methodSignatureParameterName = _method.parameterElement.displayName;

    if (_method.flattenedReturnType.isVoid) {
      return _generateVoidReturnMethodBody(
        methodSignatureParameterName,
        decapitalizedEntityName,
      );
    } else {
      // if not void then must be int return
      return _generateIntReturnMethodBody(
        methodSignatureParameterName,
        decapitalizedEntityName,
      );
    }
  }

  @nonNull
  String _generateVoidReturnMethodBody(
    final String methodSignatureParameterName,
    final String entityName,
  ) {
    if (_method.changesMultipleItems) {
      return 'await _${entityName}InsertionAdapter.insertList($methodSignatureParameterName, ${_method.onConflict});';
    } else {
      return 'await _${entityName}InsertionAdapter.insert($methodSignatureParameterName, ${_method.onConflict});';
    }
  }

  @nonNull
  String _generateIntReturnMethodBody(
    final String methodSignatureParameterName,
    final String entityName,
  ) {
    if (_method.changesMultipleItems) {
      return 'return _${entityName}InsertionAdapter.insertListAndReturnIds($methodSignatureParameterName, ${_method.onConflict});';
    } else {
      return 'return _${entityName}InsertionAdapter.insertAndReturnId($methodSignatureParameterName, ${_method.onConflict});';
    }
  }
}
