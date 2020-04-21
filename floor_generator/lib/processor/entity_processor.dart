import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:dartx/dartx.dart';
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
import 'package:floor_generator/value_object/type_converter.dart';

class EntityProcessor extends QueryableProcessor<Entity> {
  final EntityProcessorError _processorError;

  EntityProcessor(
    final ClassElement classElement,
    final List<TypeConverter> typeConverters,
  )   : _processorError = EntityProcessorError(classElement),
        super(classElement, typeConverters);

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
      _getValueMapping(fields),
    );
  }

  @nonNull
  String _getName() {
    return classElement
            .getAnnotation(annotations.Entity)
            .getField(AnnotationField.entityTableName)
            .toStringValue() ??
        classElement.displayName;
  }

  @nonNull
  List<ForeignKey> _getForeignKeys() {
    return classElement
            .getAnnotation(annotations.Entity)
            .getField(AnnotationField.entityForeignKeys)
            ?.toListValue()
            ?.map((foreignKeyObject) {
          final parentType = foreignKeyObject
                  .getField(ForeignKeyField.entity)
                  ?.toTypeValue() ??
              (throw _processorError.foreignKeyNoEntity);

          final parentElement = parentType.element;
          final parentName = parentElement is ClassElement
              ? parentElement
                      .getAnnotation(annotations.Entity)
                      .getField(AnnotationField.entityTableName)
                      ?.toStringValue() ??
                  parentType.getDisplayString()
              : throw _processorError.foreignKeyDoesNotReferenceEntity;

          final childColumns =
              _getColumns(foreignKeyObject, ForeignKeyField.childColumns);
          if (childColumns.isEmpty) {
            throw _processorError.missingChildColumns;
          }

          final parentColumns =
              _getColumns(foreignKeyObject, ForeignKeyField.parentColumns);
          if (parentColumns.isEmpty) {
            throw _processorError.missingParentColumns;
          }

          final onUpdateAnnotationValue =
              foreignKeyObject.getField(ForeignKeyField.onUpdate)?.toIntValue();
          final onUpdate = ForeignKeyAction.getString(onUpdateAnnotationValue);

          final onDeleteAnnotationValue =
              foreignKeyObject.getField(ForeignKeyField.onDelete)?.toIntValue();
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
            .getField(AnnotationField.entityIndices)
            ?.toListValue()
            ?.map((indexObject) {
          final unique = indexObject.getField(IndexField.unique)?.toBoolValue();

          final values = indexObject
              .getField(IndexField.value)
              ?.toListValue()
              ?.map((valueObject) => valueObject.toStringValue())
              ?.toList();

          if (values == null || values.isEmpty) {
            throw _processorError.missingIndexColumnName;
          }

          final indexColumnNames = fields
              .map((field) => field.columnName)
              .where((columnName) => values.any((value) => value == columnName))
              .toList();

          if (indexColumnNames.isEmpty) {
            throw _processorError.noMatchingColumn(values);
          }

          final name = indexObject.getField(IndexField.name)?.toStringValue() ??
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
    return Index.defaultPrefix + tableName + '_' + columnNames.join('_');
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
        .getField(AnnotationField.entityPrimaryKeys)
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
      throw _processorError.missingPrimaryKey;
    }

    return PrimaryKey(compoundPrimaryKeyFields, false);
  }

  @nonNull
  PrimaryKey _getPrimaryKeyFromAnnotation(final List<Field> fields) {
    final primaryKeyField = fields.firstWhere(
        (field) => field.fieldElement.hasAnnotation(annotations.PrimaryKey),
        orElse: () => throw _processorError.missingPrimaryKey);

    final autoGenerate = primaryKeyField.fieldElement
            .getAnnotation(annotations.PrimaryKey)
            .getField(AnnotationField.primaryKeyAutoGenerate)
            ?.toBoolValue() ??
        false;

    return PrimaryKey([primaryKeyField], autoGenerate);
  }

  @nonNull
  @nonNull
  String _getValueMapping(final List<Field> fields) {
    final keyValueList = fields.map((field) {
      final columnName = field.columnName;
      final attributeValue = _getAttributeValue(field.fieldElement);
      return "'$columnName': $attributeValue";
    }).toList();

    return '<String, dynamic>{${keyValueList.join(', ')}}';
  }

  @nonNull
  String _getAttributeValue(final FieldElement fieldElement) {
    final parameterName = fieldElement.displayName;
    final fieldType = fieldElement.type;

    if (!fieldType.isDefaultSqlType) {
      // TODO #165 should field instead have type converter as member?
      print('Type c $allTypeConverters');

      final typeConverter = allTypeConverters
          .sortedByDescending((typeConverter) =>
              typeConverter.scope.index) // TODO #165 extract and reuse
          .firstWhere((typeConverter) =>
              typeConverter.fieldType == fieldType); // TODO #165 error handling
      final typeConverterName = '${typeConverter.name}()';
      return typeConverter.databaseType.isDartCoreBool
          ? '$typeConverterName.encode(item.$parameterName) ? 1 : 0'
          : '$typeConverterName.encode(item.$parameterName)';
    } else {
      return fieldType.isDartCoreBool
          ? 'item.$parameterName ? 1 : 0'
          : 'item.$parameterName';
    }
  }
}
