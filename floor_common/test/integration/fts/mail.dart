import 'package:floor_common/floor_common.dart';

@Entity(
  tableName: 'mail',
)
@Fts4(tokenizer: FtsTokenizer.unicode61)
class Mail {
  @PrimaryKey()
  @ColumnInfo(name: 'rowid')
  final int id;

  @ColumnInfo(name: 'text')
  final String text;

  Mail(this.id, this.text);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mail &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text;

  @override
  int get hashCode => id.hashCode ^ text.hashCode;

  @override
  String toString() {
    return 'Task{id: $id, message: $text}';
  }
}
