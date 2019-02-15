import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/model/column.dart';
import 'package:floor_generator/model/delete_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class DeleteMethodBodyWriter implements Writer {
  final LibraryReader library;
  final DeleteMethod method;

  DeleteMethodBodyWriter(this.library, this.method);

  @override
  Code write() {
    return Code(_generateMethodBody());
  }

  String _generateMethodBody() {
    _assertMethodReturnsNoList();

    final entity = method.getEntity(library);
    final entityName = entity.name;
    final primaryKeyColumn = entity.primaryKeyColumn;
    final methodSignatureParameterName = method.parameter.name;

    if (method.returnsInt) {
      return _generateIntReturnMethodBody(
        methodSignatureParameterName,
        entityName,
        primaryKeyColumn,
      );
    } else if (method.returnsVoid) {
      return _generateVoidReturnMethodBody(
        methodSignatureParameterName,
        entityName,
        primaryKeyColumn,
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
    final Column primaryKeyColumn,
  ) {
    if (method.changesMultipleItems) {
      return '''
      final batch = database.batch();
      for (final item in $methodSignatureParameterName) {
        batch.delete('$entityName', where: '${primaryKeyColumn.name} = ?', whereArgs: <int>[item.${primaryKeyColumn.field.displayName}]);
      }
      await batch.commit(noResult: true);
      ''';
    } else {
      return '''
      final item = $methodSignatureParameterName;
      await database.delete('$entityName', where: '${primaryKeyColumn.name} = ?', whereArgs: <int>[item.${primaryKeyColumn.field.displayName}]);
      ''';
    }
  }

  String _generateIntReturnMethodBody(
    final String methodSignatureParameterName,
    final String entityName,
    final Column primaryKeyColumn,
  ) {
    if (method.changesMultipleItems) {
      return '''
      final batch = database.batch();
      for (final item in $methodSignatureParameterName) {
        batch.delete('$entityName', where: '${primaryKeyColumn.name} = ?', whereArgs: <int>[item.${primaryKeyColumn.field.displayName}]);
      }
      return (await batch.commit(noResult: false))
          .cast<int>()
          .reduce((first, second) => first + second);
      ''';
    } else {
      return '''
      final item = $methodSignatureParameterName;
      return database.delete('$entityName', where: '${primaryKeyColumn.name} = ?', whereArgs: <int>[item.${primaryKeyColumn.field.displayName}]);
      ''';
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
