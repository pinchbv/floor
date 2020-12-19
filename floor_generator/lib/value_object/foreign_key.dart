// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:collection/collection.dart';
import 'package:floor_annotation/floor_annotation.dart' show ForeignKeyAction;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/extension/foreign_key_action_extension.dart';

class ForeignKey {
  final String parentName;
  final List<String> parentColumns;
  final List<String> childColumns;
  final ForeignKeyAction onUpdate;
  final ForeignKeyAction onDelete;

  ForeignKey(
    this.parentName,
    this.parentColumns,
    this.childColumns,
    this.onUpdate,
    this.onDelete,
  );

  String getDefinition() {
    final escapedChildColumns =
        childColumns.map((column) => '`$column`').join(', ');
    final escapedParentColumns =
        parentColumns.map((column) => '`$column`').join(', ');

    return 'FOREIGN KEY ($escapedChildColumns)'
        ' REFERENCES `$parentName` ($escapedParentColumns)'
        ' ON UPDATE ${onUpdate.toSql()}'
        ' ON DELETE ${onDelete.toSql()}';
  }

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
