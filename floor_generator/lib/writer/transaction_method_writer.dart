import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/model/transaction_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';

class TransactionMethodWriter implements Writer {
  final LibraryReader library;
  final TransactionMethod method;

  TransactionMethodWriter(this.library, this.method);

  @override
  Method write() {
    return Method((builder) => builder
      ..annotations.add(overrideAnnotationExpression)
      ..returns = refer(method.returnType.displayName)
      ..name = method.name
      ..requiredParameters.addAll(_generateParameters())
      ..modifier = MethodModifier.async
      ..body = Code(_generateMethodBody()));
  }

  String _generateMethodBody() {
    final parameters =
        method.parameters.map((parameter) => parameter.name).join(', ');
    final methodCall = '${method.name}($parameters)';

    return '''
    if (database is sqflite.Transaction) {
      await super.$methodCall;
    } else {
      await (database as sqflite.Database).transaction<void>((transaction) async {
        final transactionDatabase = _\$${method.databaseName}()..database = transaction;
        await transactionDatabase.$methodCall;
      });
    }
    ''';
  }

  List<Parameter> _generateParameters() {
    return method.parameters.map((parameter) {
      return Parameter((builder) => builder
        ..name = parameter.name
        ..type = refer(parameter.type.displayName));
    }).toList();
  }
}
