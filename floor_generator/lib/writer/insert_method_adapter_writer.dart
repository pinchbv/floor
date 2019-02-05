import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/insert_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class InsertMethodWriterAdapter implements Writer {
  final LibraryReader library;
  final InsertMethod method;

  InsertMethodWriterAdapter(this.library, this.method);

  @override
  Code write() {
    return Code(_generateMethodBody());
  }

  String _generateMethodBody() {
    final parameter = method.parameter;
    final methodHeadParameterName = parameter.displayName;

    final keyValueList = (parameter.type.element as ClassElement)
        .constructors
        .first
        .parameters
        .map((parameter) {
      final valueMapping = _getValueMapping(parameter, methodHeadParameterName);

      return "'${parameter.displayName}': $valueMapping";
    }).join(', ');

    final entity = method.getEntity(library);

    return '''
    final values = <String, dynamic>{
      $keyValueList
    };
    await this.database.insert('${entity.name}', values);
    ''';
  }

  String _getValueMapping(
    ParameterElement parameter,
    String methodParameterName,
  ) {
    final parameterName = parameter.displayName;

    if (isBool(parameter.type)) {
      return '$methodParameterName.$parameterName ? 1 : 0';
    } else {
      return '$methodParameterName.$parameterName';
    }
  }
}
