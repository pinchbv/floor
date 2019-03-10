import 'package:floor_generator/misc/annotations.dart';

class ForeignKey {
  final String parentName;
  final List<String> parentColumns;
  final List<String> childColumns;
  final String onUpdate;
  final String onDelete;

  ForeignKey(
    this.parentName,
    this.parentColumns,
    this.childColumns,
    this.onUpdate,
    this.onDelete,
  );

  @nonNull
  String getDefinition() {
    return 'FOREIGN KEY (${childColumns.join(', ')}) '
        ' REFERENCES `$parentName` (${parentColumns.join(', ')})'
        ' ON UPDATE $onUpdate'
        ' ON DELETE $onDelete';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForeignKey &&
          runtimeType == other.runtimeType &&
          parentName == other.parentName &&
          parentColumns == other.parentColumns &&
          childColumns == other.childColumns &&
          onUpdate == other.onUpdate &&
          onDelete == other.onDelete;

  @override
  int get hashCode =>
      parentName.hashCode ^
      parentColumns.hashCode ^
      childColumns.hashCode ^
      onUpdate.hashCode ^
      onDelete.hashCode;

  @override
  String toString() {
    return 'ForeignKey{parentName: $parentName, parentColumns: $parentColumns, childColumns: $childColumns, onUpdate: $onUpdate, onDelete: $onDelete}';
  }
}
