import 'package:code_builder/code_builder.dart';
import 'package:flat_generator/value_object/transaction_method.dart';
import 'package:flat_generator/writer/transaction_method_writer.dart';
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

  test('Generate transaction method with integer return', () async {
    final transactionMethod = await _createTransactionMethod('''
      @transaction
      Future<int> replacePersons(List<Person> persons) async {
        return 4;
      }
    ''');

    final actual = TransactionMethodWriter(transactionMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<int> replacePersons(List<Person> persons) async {
        if (database is sqflite.Transaction) {
          return super.replacePersons(persons);
        } else {
          return (database as sqflite.Database)
              .transaction<int>((transaction) async {
            final transactionDatabase = _$TestDatabase(changeListener)
              ..database = transaction;
            return transactionDatabase.personDao.replacePersons(persons);
          });
        }
      }
    '''));
  });

  test('Generate transaction method with object return', () async {
    final transactionMethod = await _createTransactionMethod('''
      @transaction
      Future<Person> replacePersons(List<Person> persons) async {
        return null;
      }
    ''');

    final actual = TransactionMethodWriter(transactionMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<Person> replacePersons(List<Person> persons) async {
        if (database is sqflite.Transaction) {
          return super.replacePersons(persons);
        } else {
          return (database as sqflite.Database)
              .transaction<Person>((transaction) async {
            final transactionDatabase = _$TestDatabase(changeListener)
              ..database = transaction;
            return transactionDatabase.personDao.replacePersons(persons);
          });
        }
      }
    '''));
  });

  test('Generate transaction method with nullable future return', () async {
    final transactionMethod = await _createTransactionMethod('''
      @transaction
      Future<Person>? replacePersons(List<Person> persons) async {
        return null;
      }
    ''');

    final actual = TransactionMethodWriter(transactionMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<Person>? replacePersons(List<Person> persons) async {
        if (database is sqflite.Transaction) {
          return super.replacePersons(persons);
        } else {
          return (database as sqflite.Database)
              .transaction<Person>((transaction) async {
            final transactionDatabase = _$TestDatabase(changeListener)
              ..database = transaction;
            return transactionDatabase.personDao.replacePersons(persons);
          });
        }
      }
    '''));
  });

  test('Generate transaction method with nullable return type parameter',
      () async {
    final transactionMethod = await _createTransactionMethod('''
      @transaction
      Future<Person?> replacePersons(List<Person> persons) async {
        return null;
      }
    ''');

    final actual = TransactionMethodWriter(transactionMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<Person?> replacePersons(List<Person> persons) async {
        if (database is sqflite.Transaction) {
          return super.replacePersons(persons);
        } else {
          return (database as sqflite.Database)
              .transaction<Person>((transaction) async {
            final transactionDatabase = _$TestDatabase(changeListener)
              ..database = transaction;
            return transactionDatabase.personDao.replacePersons(persons);
          });
        }
      }
    '''));
  });

  test('Generate transaction method with nullable parameter', () async {
    final transactionMethod = await _createTransactionMethod('''
      @transaction
      Future<Person>? replacePersons(Person? person) async {
        return null;
      }
    ''');

    final actual = TransactionMethodWriter(transactionMethod).write();

    expect(actual, equalsDart(r'''
      @override
      Future<Person>? replacePersons(Person? person) async {
        if (database is sqflite.Transaction) {
          return super.replacePersons(person);
        } else {
          return (database as sqflite.Database)
              .transaction<Person>((transaction) async {
            final transactionDatabase = _$TestDatabase(changeListener)
              ..database = transaction;
            return transactionDatabase.personDao.replacePersons(person);
          });
        }
      }
    '''));
  });
}

Future<TransactionMethod> _createTransactionMethod(
  final String methodSignature,
) async {
  final dao = await createDao(methodSignature);
  return dao.transactionMethods.first;
}
