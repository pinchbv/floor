import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/column.dart';
import 'package:floor_generator/model/foreign_key.dart';
import 'package:source_gen/source_gen.dart';

class Entity {
  final ClassElement clazz;

  Entity(final this.clazz);

  String _nameCache;

  String get name {
    return _nameCache ??= clazz.metadata
            .firstWhere(isEntityAnnotation)
            .computeConstantValue()
            .getField(AnnotationField.ENTITY_TABLE_NAME)
            .toStringValue() ??
        clazz.displayName;
  }

  List<FieldElement> _fieldsCache;

  List<FieldElement> get fields {
    return _fieldsCache ??=
        clazz.fields.where((field) => field.displayName != 'hashCode').toList();
  }

  List<Column> _columnsCache;

  List<Column> get columns {
    return _columnsCache ??= fields.map((field) => Column(field)).toList();
  }

  Column _primaryKeyColumnCache;

  Column get primaryKeyColumn {
    return _primaryKeyColumnCache ??= columns.firstWhere(
      (column) => column.isPrimaryKey,
      orElse: () => throw InvalidGenerationSourceError(
            'There is no primary key defined on the entity $name.',
            element: clazz,
          ),
    );
  }

  List<ForeignKey> _foreignKeysCache;

  List<ForeignKey> get foreignKeys {
    return _foreignKeysCache ??= clazz.metadata
            .firstWhere(isEntityAnnotation)
            .computeConstantValue()
            .getField(AnnotationField.ENTITY_FOREIGN_KEYS)
            ?.toListValue()
            ?.map((object) => ForeignKey(clazz, object))
            ?.toList() ??
        [];
  }

  String _createTableStatementsCache;

  String getCreateTableStatement(final LibraryReader library) {
    if (_createTableStatementsCache != null) return _createTableStatementsCache;

    final databaseDefinition =
        columns.map((column) => column.definition).toList();

    final foreignKeyDefinitions = foreignKeys
        .map((foreignKey) => foreignKey.getDefinition(library))
        .toList();

    databaseDefinition.addAll(foreignKeyDefinitions);

    return _createTableStatementsCache ??=
        "'CREATE TABLE IF NOT EXISTS `$name` (${databaseDefinition.join(', ')})'";
  }

  String _constructorCache;

  String getConstructor(final LibraryReader library) {
    if (_constructorCache != null) return _constructorCache;

    final columnNames = columns.map((column) => column.name).toList();
    final constructorParameters = clazz.constructors.first.parameters;

    final parameterValues = <String>[];

    for (var i = 0; i < constructorParameters.length; i++) {
      final parameterValue = "row['${columnNames[i]}']";
      final castedParameterValue =
          _castParameterValue(constructorParameters[i].type, parameterValue);

      if (castedParameterValue != null) {
        parameterValues.add(castedParameterValue);
      }
    }

    return _constructorCache ??=
        '${clazz.displayName}(${parameterValues.join(', ')})';
  }

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

  String _valueMappingCache;

  String getValueMapping(final LibraryReader library) {
    if (_valueMappingCache != null) return _valueMappingCache;

    final columnNames = columns.map((column) => column.name).toList();
    final constructorParameters = clazz.constructors.first.parameters;

    final keyValueList = <String>[];

    for (var i = 0; i < constructorParameters.length; i++) {
      final valueMapping = _getValueMapping(constructorParameters[i]);
      keyValueList.add("'${columnNames[i]}': $valueMapping");
    }

    return _valueMappingCache ??=
        '<String, dynamic>{${keyValueList.join(', ')}}';
  }

  String _getValueMapping(final ParameterElement parameter) {
    final parameterName = parameter.displayName;

    return isBool(parameter.type)
        ? 'item.$parameterName ? 1 : 0'
        : 'item.$parameterName';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity &&
          runtimeType == other.runtimeType &&
          clazz == other.clazz;

  @override
  int get hashCode => clazz.hashCode;
}
