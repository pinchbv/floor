import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/foreign_key_action.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/entity_processor_error.dart';
import 'package:floor_generator/processor/queryable_processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/foreign_key.dart';
import 'package:floor_generator/value_object/index.dart';
import 'package:floor_generator/value_object/primary_key.dart';

class EntityProcessor extends QueryableProcessor<Entity> {
  final EntityProcessorError _processorError;

  EntityProcessor(final ClassElement classElement)
      : _processorError = EntityProcessorError(classElement),
        super(classElement);

  @nonNull
  @override
  Entity process() {
    final name = _getName();
    final fields = getFields();

    return Entity(
      classElement,
      name,
      fields,
      _getPrimaryKey(fields),
      _getForeignKeys(),
      _getIndices(fields, name),
      getConstructor(fields),
    );
  }

  @nonNull
  String _getName() {
    return classElement
            .getAnnotation(annotations.Entity)
            .getField(AnnotationField.ENTITY_TABLE_NAME)
            .toStringValue() ??
        classElement.displayName;
  }

  @nonNull
  List<ForeignKey> _getForeignKeys() {
    return classElement
            .getAnnotation(annotations.Entity)
            .getField(AnnotationField.ENTITY_FOREIGN_KEYS)
            ?.toListValue()
            ?.map((foreignKeyObject) {
          final parentType = foreignKeyObject
                  .getField(ForeignKeyField.ENTITY)
                  ?.toTypeValue() ??
              (throw _processorError.FOREIGN_KEY_NO_ENTITY);

          final parentElement = parentType.element;
          final parentName = parentElement is ClassElement
              ? parentElement
                      .getAnnotation(annotations.Entity)
                      .getField(AnnotationField.ENTITY_TABLE_NAME)
                      ?.toStringValue() ??
                  parentType.getDisplayString()
              : throw _processorError.FOREIGN_KEY_DOES_NOT_REFERENCE_ENTITY;

          final childColumns =
              _getColumns(foreignKeyObject, ForeignKeyField.CHILD_COLUMNS);
          if (childColumns.isEmpty) {
            throw _processorError.MISSING_CHILD_COLUMNS;
          }

          final parentColumns =
              _getColumns(foreignKeyObject, ForeignKeyField.PARENT_COLUMNS);
          if (parentColumns.isEmpty) {
            throw _processorError.MISSING_PARENT_COLUMNS;
          }

          final onUpdateAnnotationValue = foreignKeyObject
              .getField(ForeignKeyField.ON_UPDATE)
              ?.toIntValue();
          final onUpdate = ForeignKeyAction.getString(onUpdateAnnotationValue);

          final onDeleteAnnotationValue = foreignKeyObject
              .getField(ForeignKeyField.ON_DELETE)
              ?.toIntValue();
          final onDelete = ForeignKeyAction.getString(onDeleteAnnotationValue);

          return ForeignKey(
            parentName,
            parentColumns,
            childColumns,
            onUpdate,
            onDelete,
          );
        })?.toList() ??
        [];
  }

  @nonNull
  List<Index> _getIndices(final List<Field> fields, final String tableName) {
    return classElement
            .getAnnotation(annotations.Entity)
            .getField(AnnotationField.ENTITY_INDICES)
            ?.toListValue()
            ?.map((indexObject) {
          final unique = indexObject.getField(IndexField.UNIQUE)?.toBoolValue();

          final values = indexObject
              .getField(IndexField.VALUE)
              ?.toListValue()
              ?.map((valueObject) => valueObject.toStringValue())
              ?.toList();

          if (values == null || values.isEmpty) {
            throw _processorError.MISSING_INDEX_COLUMN_NAME;
          }

          final indexColumnNames = fields
              .map((field) => field.columnName)
              .where((columnName) => values.any((value) => value == columnName))
              .toList();

          if (indexColumnNames.isEmpty) {
            throw _processorError.noMatchingColumn(values);
          }

          final name = indexObject.getField(IndexField.NAME)?.toStringValue() ??
              _generateIndexName(tableName, indexColumnNames);

          return Index(name, tableName, unique, indexColumnNames);
        })?.toList() ??
        [];
  }

  @nonNull
  String _generateIndexName(
    final String tableName,
    final List<String> columnNames,
  ) {
    return Index.DEFAULT_PREFIX + tableName + '_' + columnNames.join('_');
  }

  @nonNull
  List<String> _getColumns(
    final DartObject object,
    final String foreignKeyField,
  ) {
    return object
            .getField(foreignKeyField)
            ?.toListValue()
            ?.map((object) => object.toStringValue())
            ?.toList() ??
        [];
  }

  @nonNull
  PrimaryKey _getPrimaryKey(final List<Field> fields) {
    final compoundPrimaryKey = _getCompoundPrimaryKey(fields);

    if (compoundPrimaryKey != null) {
      return compoundPrimaryKey;
    } else {
      return _getPrimaryKeyFromAnnotation(fields);
    }
  }

  @nullable
  PrimaryKey _getCompoundPrimaryKey(final List<Field> fields) {
    final compoundPrimaryKeyColumnNames = classElement
        .getAnnotation(annotations.Entity)
        .getField(AnnotationField.ENTITY_PRIMARY_KEYS)
        ?.toListValue()
        ?.map((object) => object.toStringValue());

    if (compoundPrimaryKeyColumnNames == null ||
        compoundPrimaryKeyColumnNames.isEmpty) {
      return null;
    }

    final compoundPrimaryKeyFields = fields.where((field) {
      return compoundPrimaryKeyColumnNames.any(
          (primaryKeyColumnName) => field.columnName == primaryKeyColumnName);
    }).toList();

    if (compoundPrimaryKeyFields.isEmpty) {
      throw _processorError.MISSING_PRIMARY_KEY;
    }

    return PrimaryKey(compoundPrimaryKeyFields, false);
  }

  @nonNull
  PrimaryKey _getPrimaryKeyFromAnnotation(final List<Field> fields) {
    final primaryKeyField = fields.firstWhere(
        (field) => field.fieldElement.hasAnnotation(annotations.PrimaryKey),
        orElse: () => throw _processorError.MISSING_PRIMARY_KEY);

    final autoGenerate = primaryKeyField.fieldElement
            .getAnnotation(annotations.PrimaryKey)
            .getField(AnnotationField.PRIMARY_KEY_AUTO_GENERATE)
            ?.toBoolValue() ??
        false;

    return PrimaryKey([primaryKeyField], autoGenerate);
  }
}
