import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/foreign_key.dart';
import 'package:floor_generator/value_object/primary_key.dart';
import 'package:source_gen/source_gen.dart';

class EntityProcessor extends Processor<Entity> {
  final ClassElement _classElement;

  EntityProcessor(final ClassElement classElement)
      : assert(classElement != null),
        _classElement = classElement;

  @nonNull
  @override
  Entity process() {
    final fields = _getFields();

    return Entity(
      _classElement,
      _getName(),
      fields,
      _getPrimaryKey(fields),
      _getForeignKeys(),
      _getConstructor(fields),
    );
  }

  @nonNull
  String _getName() {
    return _classElement.metadata
            .firstWhere(isEntityAnnotation)
            .computeConstantValue()
            .getField(AnnotationField.ENTITY_TABLE_NAME)
            .toStringValue() ??
        _classElement.displayName;
  }

  @nonNull
  List<Field> _getFields() {
    return _classElement.fields
        .where(_isNotHashCode)
        .map((field) => FieldProcessor(field).process())
        .toList();
  }

  @nonNull
  bool _isNotHashCode(final FieldElement fieldElement) {
    return fieldElement.displayName != 'hashCode';
  }

  @nonNull
  List<ForeignKey> _getForeignKeys() {
    return _classElement.metadata
            .firstWhere(isEntityAnnotation)
            .computeConstantValue()
            .getField(AnnotationField.ENTITY_FOREIGN_KEYS)
            ?.toListValue()
            ?.map((foreignKeyObject) {
          final parentType = foreignKeyObject
                  .getField(ForeignKeyField.ENTITY)
                  ?.toTypeValue() ??
              (throw InvalidGenerationSourceError(
                'No entity defined for foreign key',
                element: _classElement,
              ));

          final parentElement = parentType.element;
          final parentName = parentElement is ClassElement
              ? parentElement.metadata
                      .firstWhere(isEntityAnnotation,
                          orElse: () => throw InvalidGenerationSourceError(
                              'The foreign key is not referencing an enttity.',
                              element: _classElement))
                      .computeConstantValue()
                      .getField(AnnotationField.ENTITY_TABLE_NAME)
                      ?.toStringValue() ??
                  parentType.displayName
              : throw InvalidGenerationSourceError(
                  "The foreign key doesn't reference an entity class.",
                  element: _classElement);

          final childColumns =
              _getColumns(foreignKeyObject, ForeignKeyField.CHILD_COLUMNS);
          if (childColumns.isEmpty) {
            throw InvalidGenerationSourceError(
              'No child columns defined for foreign key',
              element: _classElement,
            );
          }

          final parentColumns =
              _getColumns(foreignKeyObject, ForeignKeyField.PARENT_COLUMNS);
          if (parentColumns.isEmpty) {
            throw InvalidGenerationSourceError(
              'No parent columns defined for foreign key',
              element: _classElement,
            );
          }

          final onUpdateAnnotationValue = foreignKeyObject
              .getField(ForeignKeyField.ON_UPDATE)
              ?.toIntValue();
          final onUpdate = _getAction(onUpdateAnnotationValue);

          final onDeleteAnnotationValue = foreignKeyObject
              .getField(ForeignKeyField.ON_DELETE)
              ?.toIntValue();
          final onDelete = _getAction(onDeleteAnnotationValue);

          return ForeignKey(
            _classElement,
            foreignKeyObject,
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
  String _getAction(@nullable final int action) {
    switch (action) {
      case ForeignKeyAction.RESTRICT:
        return 'RESTRICT';
      case ForeignKeyAction.SET_NULL:
        return 'SET_NULL';
      case ForeignKeyAction.SET_DEFAULT:
        return 'SET_DEFAULT';
      case ForeignKeyAction.CASCADE:
        return 'CASCADE';
      case ForeignKeyAction.NO_ACTION:
      default:
        return 'NO ACTION';
    }
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
    final primaryKeyField = fields.firstWhere(
      (field) => field.isPrimaryKey,
      orElse: () => throw InvalidGenerationSourceError(
            'There is no primary key defined on the entity ${_classElement.displayName}.',
            element: _classElement,
          ),
    );

    final autoGenerate = primaryKeyField.fieldElement.metadata
            .firstWhere(isPrimaryKeyAnnotation)
            .computeConstantValue()
            .getField(AnnotationField.PRIMARY_KEY_AUTO_GENERATE)
            .toBoolValue() ??
        false;

    return PrimaryKey(primaryKeyField, autoGenerate);
  }

  @nonNull
  String _getConstructor(final List<Field> fields) {
    final columnNames = fields.map((field) => field.columnName).toList();
    final constructorParameters = _classElement.constructors.first.parameters;

    final parameterValues = <String>[];

    for (var i = 0; i < constructorParameters.length; i++) {
      final parameterValue = "row['${columnNames[i]}']";
      final castedParameterValue =
          _castParameterValue(constructorParameters[i].type, parameterValue);

      if (castedParameterValue != null) {
        parameterValues.add(castedParameterValue);
      }
    }

    return '${_classElement.displayName}(${parameterValues.join(', ')})';
  }

  @nullable
  String _castParameterValue(
    final DartType parameterType,
    final String parameterValue,
  ) {
    if (isBool(parameterType)) {
      return '($parameterValue as int) != 0'; // maps int to bool
    } else if (isString(parameterType)) {
      return '$parameterValue as String';
    } else if (isInt(parameterType)) {
      return '$parameterValue as int';
    } else if (isDouble(parameterType)) {
      return '$parameterValue as double';
    } else {
      return null;
    }
  }
}
