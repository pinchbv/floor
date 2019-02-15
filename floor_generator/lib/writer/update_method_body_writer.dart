import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/column.dart';
import 'package:floor_generator/model/update_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class UpdateMethodBodyWriter implements Writer {
  final LibraryReader library;
  final UpdateMethod method;

  UpdateMethodBodyWriter(this.library, this.method);

  @override
  Code write() {
    return Code(_generateMethodBody());
  }

  String _generateMethodBody() {
    _assertMethodReturnsNoList();

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
    final primaryKeyColumn = entity.primaryKeyColumn;

    if (method.returnsInt) {
      return _generateIntReturnMethodBody(
        methodSignatureParameterName,
        keyValueList,
        entityName,
        primaryKeyColumn,
      );
    } else if (method.returnsVoid) {
      return _generateVoidReturnMethodBody(
        methodSignatureParameterName,
        keyValueList,
        entityName,
        primaryKeyColumn,
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
    final List<String> keyValueList,
    final String entityName,
    final Column primaryKeyColumn,
  ) {
    if (method.changesMultipleItems) {
      return '''
      final batch = database.batch();
      for (final item in $methodSignatureParameterName) {
        final values = <String, dynamic>{
          ${keyValueList.join(', ')}
        };
        batch.update('$entityName', values, where: '${primaryKeyColumn.name} = ?', whereArgs: <int>[item.${primaryKeyColumn.field.displayName}]);
      }
      return (await batch.commit(noResult: false))
          .cast<int>()
          .reduce((first, second) => first + second);
      ''';
    } else {
      return '''
      final item = $methodSignatureParameterName;
      final values = <String, dynamic>{
        ${keyValueList.join(', ')}
      };
      return database.update('$entityName', values, where: '${primaryKeyColumn.name} = ?', whereArgs: <int>[item.${primaryKeyColumn.field.displayName}]);
      ''';
    }
  }

  String _generateVoidReturnMethodBody(
    final String methodSignatureParameterName,
    final List<String> keyValueList,
    final String entityName,
    final Column primaryKeyColumn,
  ) {
    if (method.changesMultipleItems) {
      return '''
      final batch = database.batch();
      for (final item in $methodSignatureParameterName) {
        final values = <String, dynamic>{
          ${keyValueList.join(', ')}
        };
        batch.update('$entityName', values, where: '${primaryKeyColumn.name} = ?', whereArgs: <int>[item.${primaryKeyColumn.field.displayName}]);
      }
      await batch.commit(noResult: true);
      ''';
    } else {
      return '''
      final item = $methodSignatureParameterName;
      final values = <String, dynamic>{
        ${keyValueList.join(', ')}
      };
      await database.update('$entityName', values, where: '${primaryKeyColumn.name} = ?', whereArgs: <int>[item.${primaryKeyColumn.field.displayName}]);
      ''';
    }
  }

  String _getValueMapping(final ParameterElement parameter) {
    final parameterName = parameter.displayName;

    return isBool(parameter.type)
        ? 'item.$parameterName ? 1 : 0'
        : 'item.$parameterName';
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
