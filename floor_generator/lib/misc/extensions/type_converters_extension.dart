import 'package:analyzer/dart/element/type.dart';
import 'package:dartx/dartx.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:source_gen/source_gen.dart';

extension TypeConvertersExtension on List<TypeConverter> {
  @nullable
  TypeConverter getClosestOrNull(DartType dartType) {
    return sortedByDescending((typeConverter) => typeConverter.scope.index)
        .firstOrNullWhere(
            (typeConverter) => typeConverter.fieldType == dartType);
  }

  @nonNull
  TypeConverter getClosest(DartType dartType) {
    final closest = getClosestOrNull(dartType);
    if (closest == null) throw InvalidGenerationSourceError(''); // TODO #165
    return closest;
  }
}
