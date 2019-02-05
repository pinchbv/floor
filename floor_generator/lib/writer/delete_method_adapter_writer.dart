import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/model/delete_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class DeleteMethodWriterAdapter implements Writer {
  final LibraryReader library;
  final DeleteMethod method;

  DeleteMethodWriterAdapter(this.library, this.method);

  @override
  Code write() {
    return Code(_generateMethodBody());
  }

  String _generateMethodBody() {
    final entity = method.getEntity(library);
    final primaryKeyColumn =
        entity.columns.firstWhere((column) => column.isPrimaryKey);
    final methodHeadParameterName = method.parameter.name;

    return '''
    await this.database.rawDelete('DELETE FROM ${entity.name} WHERE ${primaryKeyColumn.name} = \${$methodHeadParameterName.${primaryKeyColumn.field.displayName}}');
    ''';
  }
}
