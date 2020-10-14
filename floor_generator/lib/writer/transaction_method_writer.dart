import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/value_object/transaction_method.dart';
import 'package:floor_generator/writer/writer.dart';

class TransactionMethodWriter implements Writer {
  final TransactionMethod method;

  TransactionMethodWriter(final this.method);

  @override
  Method write() {
    return Method((builder) => builder
      ..annotations.add(overrideAnnotationExpression)
      ..returns = refer(method.returnType.getDisplayString(
        withNullability: false,
      ))
      ..name = method.name
      ..requiredParameters.addAll(_generateParameters())
      ..modifier = MethodModifier.async
      ..body = Code(_generateMethodBody()));
  }

  String _generateMethodBody() {
    final parameters =
        method.parameterElements.map((parameter) => parameter.name).join(', ');
    final methodCall = '${method.name}($parameters)';
    final innerType = method.returnType.flatten();
    final innerTypeName = innerType.getDisplayString(withNullability: false);
    final ret = innerType.isVoid ? '' : 'return ';

    return '''
    if (database is sqflite.Transaction) {
      $ret super.$methodCall;
    } else {
      $ret (database as sqflite.Database).transaction<$innerTypeName>((transaction) async {
        final transactionDatabase = _\$${method.databaseName}(changeListener)..database = transaction;
        $ret transactionDatabase.${method.daoFieldName}.$methodCall;
      });
    }
    ''';
  }

  List<Parameter> _generateParameters() {
    return method.parameterElements.map((parameter) {
      return Parameter((builder) => builder
        ..name = parameter.name
        ..type = refer(parameter.type.getDisplayString(
          withNullability: false,
        )));
    }).toList();
  }
}
