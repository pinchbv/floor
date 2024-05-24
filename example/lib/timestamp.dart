import 'package:floor/floor.dart';
import 'package:intl/intl.dart';

@Embed()
class Timestamp {
  @ColumnInfo(name: 'created_at')
  final DateTime createdAt;

  @ColumnInfo(name: 'updated_at')
  final DateTime updatedAt;

  Timestamp({required this.createdAt, required this.updatedAt});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Timestamp &&
              runtimeType == other.runtimeType &&
              createdAt == other.createdAt &&
              updatedAt == other.updatedAt;

  @override
  int get hashCode => createdAt.hashCode ^ updatedAt.hashCode;

  @override
  String toString() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedCreatedAt = formatter.format(createdAt);
    final String formattedUpdatedAt = formatter.format(updatedAt);
    return 'Timestamp{createdAt: $formattedCreatedAt, updatedAt: $formattedUpdatedAt}';
  }
}
