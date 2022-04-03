# Transactions

Transactions are useful when you want to perform multiple operations.
With Flat you have two options to start a transaction:

1. Inside a DAO:

    You can annotate a method with `@transaction` and make that method `async`. Also you have to `await` for every database call you make inside that method.

    ```dart
    @transaction
    Future<void> replacePersons(List<Person> persons) async {
      await deleteAllPersons();
      await insertPersons(persons);
    }
    ```

2. On database:

    You can call `transaction` on your database with a callback which will get called whenever transaction created with a database object for you to do your operations on. Again it's required to `await` for every database call.

    ```dart
    await database.transaction<void>((dynamic db) async {
      if (db is AppDatabase) {
        await db.personDao.deleteAllPersons();
        await db.personDao.insertPersons(persons);
      }
    });
    ```

!!! attention
    - Transactions can return objects