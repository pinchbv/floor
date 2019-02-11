import 'package:code_builder/code_builder.dart';
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
    final entity = method.getEntity(library);
    final primaryKeyColumn = entity.primaryKeyColumn;
    final methodHeadParameterName = method.parameter.name;

    if (method.changesMultipleItems) {
      return '''
      final batch = database.batch();
      for (final item in $methodHeadParameterName) {
        batch.delete('${entity.name}', where: '${primaryKeyColumn.name} = ?', whereArgs: <int>[item.${primaryKeyColumn.field.displayName}]);
      }
      await batch.commit(noResult: true);
      ''';
    } else {
      return '''
      final item = $methodHeadParameterName;
      await database.delete('${entity.name}', where: '${primaryKeyColumn.name} = ?', whereArgs: <int>[item.${primaryKeyColumn.field.displayName}]);
      ''';
    }
  }
}
