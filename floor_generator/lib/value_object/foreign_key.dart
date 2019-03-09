import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/annotations.dart';

class ForeignKey {
  final ClassElement classElement;
  final DartObject object;
  final String parentName;
  final List<String> parentColumns;
  final List<String> childColumns;
  final String onUpdate;
  final String onDelete;

  ForeignKey(
    this.classElement,
    this.object,
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
          classElement == other.classElement &&
          object == other.object &&
          parentName == other.parentName &&
          parentColumns == other.parentColumns &&
          childColumns == other.childColumns &&
          onUpdate == other.onUpdate &&
          onDelete == other.onDelete;

  @override
  int get hashCode =>
      classElement.hashCode ^
      object.hashCode ^
      parentName.hashCode ^
      parentColumns.hashCode ^
      childColumns.hashCode ^
      onUpdate.hashCode ^
      onDelete.hashCode;

  @override
  String toString() {
    return 'ForeignKey{classElement: $classElement, object: $object, parentName: $parentName, parentColumns: $parentColumns, childColumns: $childColumns, onUpdate: $onUpdate, onDelete: $onDelete}';
  }
}
