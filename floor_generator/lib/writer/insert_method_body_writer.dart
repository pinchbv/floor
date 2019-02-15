import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/insert_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class InsertMethodBodyWriter implements Writer {
  final LibraryReader library;
  final InsertMethod method;

  InsertMethodBodyWriter(this.library, this.method);

  @override
  Code write() {
    return Code(_generateMethodBody());
  }

  String _generateMethodBody() {
    final entity = method.getEntity(library);

    final columnNames = entity.columns.map((column) => column.name).toList();
    final constructorParameters =
        method.flattenedParameterClass.constructors.first.parameters;

    final keyValueList = <String>[];

    for (var i = 0; i < constructorParameters.length; i++) {
      final valueMapping = _getValueMapping(constructorParameters[i]);
      keyValueList.add("'${columnNames[i]}': $valueMapping");
    }

    final entityName = entity.name;
    final methodSignatureParameterName = method.parameter.displayName;

    if (method.returnsInt) {
      return _generateIntReturnMethodBody(
        methodSignatureParameterName,
        keyValueList,
        entityName,
      );
    } else if (method.returnsVoid) {
      return _generateVoidReturnMethodBody(
        methodSignatureParameterName,
        keyValueList,
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
    final List<String> keyValueList,
    final String entityName,
  ) {
    if (method.changesMultipleItems) {
      return '''
      final batch = database.batch();
      for (final item in $methodSignatureParameterName) {
        final values = <String, dynamic>{
          ${keyValueList.join(', ')}
        };
        batch.insert('$entityName', values);
      }
      await batch.commit(noResult: true);
      ''';
    } else {
      return '''
      final item = $methodSignatureParameterName;
      final values = <String, dynamic>{
        ${keyValueList.join(', ')}
      };
      await database.insert('$entityName', values);
      ''';
    }
  }

  String _generateIntReturnMethodBody(
    final String methodSignatureParameterName,
    final List<String> keyValueList,
    final String entityName,
  ) {
    if (method.changesMultipleItems) {
      return '''
      final batch = database.batch();
      for (final item in $methodSignatureParameterName) {
        final values = <String, dynamic>{
          ${keyValueList.join(', ')}
        };
        batch.insert('$entityName', values);
      }
      return (await batch.commit(noResult: false)).cast<int>();
      ''';
    } else {
      return '''
      final item = $methodSignatureParameterName;
      final values = <String, dynamic>{
        ${keyValueList.join(', ')}
      };
      return database.insert('$entityName', values);
      ''';
    }
  }

  String _getValueMapping(final ParameterElement parameter) {
    final parameterName = parameter.displayName;

    return isBool(parameter.type)
        ? 'item.$parameterName ? 1 : 0'
        : 'item.$parameterName';
  }
}
