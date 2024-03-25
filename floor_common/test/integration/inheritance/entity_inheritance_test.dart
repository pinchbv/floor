import 'dart:async';

import 'package:floor_common/floor_common.dart';
import 'package:sqflite_common/sqlite_api.dart' as sqflite;
import 'package:test/test.dart';

import '../../test_util/database_factory.dart';

part 'entity_inheritance_test.g.dart';

void main() {
  group('entity inheritance tests', () {
    late TestDatabase database;
    late CommentDao commentDao;

    setUp(() async {
      database = await $FloorTestDatabase.inMemoryDatabaseBuilder().build();
      commentDao = database.commentDao;
    });

    tearDown(() async {
      await database.close();
    });

    test('use inherited entity object by inserting and finding', () async {
      final comment = Comment(1, 'Simon');
      await commentDao.addComment(comment);

      final actual = await commentDao.findCommentById(comment.id);

      expect(actual, equals(comment));
    });
  });
}

// data models:
class BaseObject {
  @primaryKey
  final int id;

  @ColumnInfo(name: 'create_time')
  final String createTime;

  @ColumnInfo(name: 'update_time')
  final String? updateTime;

  BaseObject(
    this.id, {
    this.updateTime,
    String? createTime,
  }) : createTime = createTime ?? DateTime.now().toString();
}

@Entity(tableName: 'comments')
class Comment extends BaseObject {
  final String author;

  final String content;

  Comment(
    int id,
    this.author, {
    this.content = '',
    String? createTime,
    String? updateTime,
  }) : super(id, updateTime: updateTime, createTime: createTime);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          author == other.author &&
          content == other.content &&
          createTime == other.createTime &&
          updateTime == other.updateTime;

  @override
  int get hashCode =>
      id.hashCode ^
      author.hashCode ^
      content.hashCode ^
      createTime.hashCode ^
      updateTime.hashCode;

  @override
  String toString() {
    return 'Comment{id: $id, author: $author, content: $content, createTime: $createTime, updateTime: $updateTime}';
  }
}

// daos:
@Database(version: 1, entities: [Comment])
abstract class TestDatabase extends FloorDatabase {
  CommentDao get commentDao;
}

@dao
abstract class CommentDao {
  @Query('SELECT * FROM comments WHERE id = :id')
  Future<Comment?> findCommentById(int id);

  @insert
  Future<void> addComment(Comment c);

  @delete
  Future<void> removeComment(Comment c);
}
