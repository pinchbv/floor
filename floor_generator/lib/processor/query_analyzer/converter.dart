import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:sqlparser/sqlparser.dart';

//todo single test for testing engine registrations and dependencies
//todo test dependency graph
//todo test visitors with example queries
//todo add tests
//TODO test: check converter by parallel construction: field, entity

extension ToTableColumn on Field {
  TableColumn asTableColumn() {
    final boolHint =
        fieldElement.type.isDartCoreBool ? const IsBoolean() : null;

    return TableColumn(
      columnName,
      ResolvedType(
          type: sqlToBasicType[sqlType],
          nullable: isNullable,
          isArray: false,
          hint: boolHint),
    );
  }
}

extension ToTable on Entity {
  static ReferenceAction _toReferenceAction(String action) {
    switch (action) {
      case 'RESTRICT':
        return ReferenceAction.restrict;
      case 'SET NULL':
        return ReferenceAction.setNull;
      case 'SET DEFAULT':
        return ReferenceAction.setDefault;
      case 'CASCADE':
        return ReferenceAction.cascade;
      case 'NO ACTION':
      default:
        return ReferenceAction.noAction;
    }
  }

  Table asTable() {
    final List<TableConstraint> constraints = [];

    //Add foreign keys
    constraints.addAll(foreignKeys
        .asMap()
        .map((i, f) => MapEntry(
            i,
            ForeignKeyTableConstraint(
              '${name}FKConstraint$i', //just a unique name
              columns: f.childColumns
                  .map((col) => Reference(tableName: name, columnName: col))
                  .toList(growable: false),
              clause: ForeignKeyClause(
                foreignTable: TableReference(f.parentName),
                columnNames: f.parentColumns
                    .map((col) =>
                        Reference(tableName: f.parentName, columnName: col))
                    .toList(growable: false),
                onDelete: _toReferenceAction(f.onDelete),
                onUpdate: _toReferenceAction(f.onUpdate),
              ),
            )))
        .values);

    //Add indices
    constraints.addAll(indices
        .asMap()
        .map((i, index) => MapEntry(
            i,
            KeyClause(
              '${name}IdxConstraint$i', //just a unique name
              indexedColumns: index.columnNames
                  .map((col) => Reference(tableName: name, columnName: col))
                  .toList(growable: false),
              isPrimaryKey: false,
            )))
        .values);

    //Add primary key
    constraints.add(KeyClause(
      '${name}PrimaryKey', //just a unique name
      indexedColumns: primaryKey.fields
          .map((field) =>
              Reference(tableName: name, columnName: field.columnName))
          .toList(growable: false),
      isPrimaryKey: true,
    ));

    return Table(
      name: name,
      resolvedColumns:
          fields.map((field) => field.asTableColumn()).toList(growable: false),
      tableConstraints: constraints,
    );
  }
}

const sqlToBasicType = {
  SqlType.blob: BasicType.blob,
  SqlType.integer: BasicType.int,
  SqlType.real: BasicType.real,
  SqlType.text: BasicType.text,
};
