import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/value_object/transaction_method.dart';
import 'package:floor_generator/writer/transaction_method_writer.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  useDartfmt();

  test('Generate transaction method', () async {
    final transactionMethod = await _createTransactionMethod('''
      @transaction
      Future<void> replacePersons(List<Person> persons) async {
      }
    ''');

    final actual = TransactionMethodWriter(transactionMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<void> replacePersons(List<Person> persons) async {
        if (database is sqflite.Transaction) {
          await super.replacePersons(persons);
        } else {
          await (database as sqflite.Database)
              .transaction<void>((transaction) async {
            final transactionDatabase = _$TestDatabase(changeListener)
              ..database = transaction;
            await transactionDatabase.personDao.replacePersons(persons);
          });
        }
      }
    '''));
  });
}

Future<TransactionMethod> _createTransactionMethod(
  final String methodSignature,
) async {
  final dao = await createDaoMethod(methodSignature);
  return dao.transactionMethods.first;
}
