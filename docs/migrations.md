# Migrations

Whenever you are doing changes to your entities, you're required to also migrate the old data.

First, update your entity.
Next, Increase the database version.
Define a `Migration` which specifies a `startVersion`, an `endVersion` and a function that executes SQL to migrate the data.
At last, use `addMigrations()` on the obtained database builder to add migrations.
Don't forget to trigger the code generator again, to create the code for handling the new entity.

```dart
////////////////////////////////////////
// version 1   
// create base table posts
////////////////////////////////////////
@Entity(tableName: 'posts')
class PostEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final String content;

  PostEntity(this.id, this.content);
}

@Database(version: 1, entities: [PostEntity])
abstract class AppDatabase extends FloorDatabase {
  // dao...
}

// version 1 can auto create table
final database = await $FloorAppDatabase
    .databaseBuilder('app_database.db')
    .build();
    
////////////////////////////////////////
// version 2
// => add new comments table
////////////////////////////////////////
+@Entity(tableName: 'comments')
+class CommentEntity {
+  @PrimaryKey(autoGenerate: true)
+  final int id;
+
+  final String content;
+
+  CommentEntity(this.id, this.content);
+}

// version 1 => 2, entities => add CommentEntity
// here, floor can auto create all table on new install app
// !!! If is to upgrade, need your own hand writing logic
+@Database(version: 2, entities: [PostEntity, CommentEntity])
abstract class AppDatabase extends FloorDatabase {
  // dao...
}

+final migration1to2 = Migration(1, 2, (database) async {
+ // you can copy database.g.dart generate sql code
+ await database.execute('create table comments');
+});

final database = await $FloorAppDatabase
    .databaseBuilder('app_database.db')
+   .addMigrations([migration1to2])
    .build();
 
////////////////////////////////////////
// version 3
// => update entity with new 'nickname' field
////////////////////////////////////////
@Entity(tableName: 'comments')
class CommentEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final String content;
  
+ final String nickname;

+ CommentEntity(this.id, this.content, this.nickname);
}

// version 2 => 3
// here, floor can auto create all table on new install app (Including the newly added field nickname)
// !!! If is to upgrade, need your own hand writing logic
+@Database(version: 3, entities: [PostEntity, CommentEntity])
abstract class AppDatabase extends FloorDatabase {
  // dao...
}

+final migration2to3 = Migration(2, 3, (database) async {
+  await database.execute('ALTER TABLE person ADD COLUMN nickname TEXT');
+});

// now has 3 case
// case 1: new install  => floor can auto create all table (You don't need to care about anything)
// case 2: 1 upgrade 3  => floor can exec migration1to2 and migration2to3
// case 3: 2 upgrade 3  => floor only exec migration2to3
final database = await $FloorAppDatabase
    .databaseBuilder('app_database.db')
+   .addMigrations([migration1to2, migration2to3])
    .build();
```
