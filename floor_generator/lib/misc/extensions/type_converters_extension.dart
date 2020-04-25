import 'package:analyzer/dart/element/type.dart';
import 'package:dartx/dartx.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:source_gen/source_gen.dart';

extension TypeConvertersExtension on Iterable<TypeConverter> {
  @nullable
  TypeConverter get closestOrNull {
    return sortedByDescending((typeConverter) => typeConverter.scope.index)
        .firstOrNull;
  }

  @nullable
  TypeConverter getClosestOrNull(DartType dartType) {
    return sortedByDescending((typeConverter) => typeConverter.scope.index)
        .firstOrNullWhere(
            (typeConverter) => typeConverter.fieldType == dartType);
  }

  @nonNull
  TypeConverter getClosest(DartType dartType) {
    final closest = getClosestOrNull(dartType);
    if (closest == null)
      throw InvalidGenerationSourceError(
        'Column type is not supported for $dartType',
        todo: 'Either use a supported type or supply a type converter.',
      );
    return closest;
  }
}
