# Migrations

Whenever you are doing changes to your entities, you're required to also migrate the old data.

First, update your entity.
Next, Increase the database version.
Define a `Migration` which specifies a `startVersion`, an `endVersion` and a function that executes SQL to migrate the data.
At last, use `addMigrations()` on the obtained database builder to add migrations.
Don't forget to trigger the code generator again, to create the code for handling the new entity.

```dart
// update entity with new 'nickname' field
@Entity(tableName: 'person')
class Person {
  @PrimaryKey(autoGenerate: true)
  final int id;

  @ColumnInfo(name: 'custom_name')
  final String name;

  final String nickname;

  Person(this.id, this.name, this.nickname);
}

// bump up database version
@Database(version: 2)
abstract class AppDatabase extends FlatDatabase {
  PersonDao get personDao;
}

// create migration
final migration1to2 = Migration(1, 2, (database) async {
  await database.execute('ALTER TABLE person ADD COLUMN nickname TEXT');
});

final database = await $FlatAppDatabase
    .databaseBuilder('app_database.db')
    .addMigrations([migration1to2])
    .build();
```
