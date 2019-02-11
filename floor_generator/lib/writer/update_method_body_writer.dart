import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/type_utils.dart';
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
    final methodHeadParameterName = method.parameter.displayName;
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

    if (method.changesMultipleItems) {
      final primaryKeyColumn = entity.primaryKeyColumn;
      return '''
      final batch = database.batch();
      for (final item in $methodHeadParameterName) {
        final values = <String, dynamic>{
          ${keyValueList.join(', ')}
        };
        batch.update('$entityName', values, where: '${primaryKeyColumn.name} = ?', whereArgs: <int>[item.${primaryKeyColumn.field.displayName}]);
      }
      await batch.commit(noResult: true);
      ''';
    } else {
      return '''
      final item = $methodHeadParameterName;
      final values = <String, dynamic>{
        ${keyValueList.join(', ')}
      };
      await database.update('$entityName', values);
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
