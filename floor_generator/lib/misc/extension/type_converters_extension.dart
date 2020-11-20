import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/extension/iterable_extension.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:source_gen/source_gen.dart';

extension TypeConvertersExtension on Iterable<TypeConverter> {
  /// Returns the [TypeConverter] in the closest [TypeConverterScope] or null
  TypeConverter? get closestOrNull {
    return sortedByDescending((typeConverter) => typeConverter.scope.index)
        .firstOrNull;
  }

  /// Returns the [TypeConverter] in the closest [TypeConverterScope] for
  /// [dartType] or null
  TypeConverter? getClosestOrNull(DartType dartType) {
    return sortedByDescending((typeConverter) => typeConverter.scope.index)
        .firstOrNullWhere(
            (typeConverter) => typeConverter.fieldType == dartType);
  }

  /// Returns the [TypeConverter] in the closest [TypeConverterScope] for
  /// [dartType]
  TypeConverter getClosest(DartType dartType) {
    final closest = getClosestOrNull(dartType);
    if (closest == null) {
      throw InvalidGenerationSourceError(
        'Column type is not supported for $dartType',
        todo: 'Either use a supported type or supply a type converter.',
      );
    }
    return closest;
  }
}
