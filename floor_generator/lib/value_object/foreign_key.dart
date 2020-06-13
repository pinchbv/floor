import 'package:collection/collection.dart';
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
    final escapedChildColumns =
        childColumns.map((column) => '`$column`').join(', ');
    final escapedParentColumns =
        parentColumns.map((column) => '`$column`').join(', ');

    return 'FOREIGN KEY ($escapedChildColumns)'
        ' REFERENCES `$parentName` ($escapedParentColumns)'
        ' ON UPDATE $onUpdate'
        ' ON DELETE $onDelete';
  }

  // The following foreignKeyActions could change the child table, `NO ACTION` and `RESTRICT` will not.
  static const updateActions = {'SET NULL', 'SET DEFAULT', 'CASCADE'};
  bool get canChangeChild =>
      updateActions.contains(onUpdate) || updateActions.contains(onDelete);

  final _listEquality = const ListEquality<String>();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForeignKey &&
          runtimeType == other.runtimeType &&
          parentName == other.parentName &&
          _listEquality.equals(parentColumns, other.parentColumns) &&
          _listEquality.equals(childColumns, other.childColumns) &&
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
