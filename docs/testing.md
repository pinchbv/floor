# Testing

Simply instantiate an in-memory database and run the database tests on your local development machine as shown in the following snippet.
For more test references, check out the [project's tests](https://github.com/vitusortner/floor/tree/develop/floor/test/integration).

In case you're running Linux, make sure to have sqlite3 and libsqlite3-dev installed.

```dart
import 'package:floor/floor.dart';
import 'package:flutter_test/flutter_test.dart';

// your imports follow here
import 'dao/person_dao.dart';
import 'database.dart';
import 'entity/person.dart';

void main() {
  group('database tests', () {
    TestDatabase database;
    PersonDao personDao;

    setUp(() async {
      database = await $FloorTestDatabase
          .inMemoryDatabaseBuilder()
          .build();
      personDao = database.personDao;
    });

    tearDown(() async {
      await database.close();
    });

    test('find person by id', () async {
      final person = Person(1, 'Simon');
      await personDao.insertPerson(person);

      final actual = await personDao.findPersonById(person.id);

      expect(actual, equals(person));
    });
  }
}
```
