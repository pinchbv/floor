import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/misc/extension/iterable_extension.dart';
import 'package:floor_generator/value_object/embed.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:source_gen/source_gen.dart';

extension EmbedsExtension on Iterable<Embed> {
  // /// Returns the [Embed] in the closest [TypeConverterScope] or null
  // Embed? get closestOrNull {
  //   return sortedByDescending((embed) => embed.scope.index)
  //       .firstOrNull;
  // }

  /// Returns the [Embed] in the closest [TypeConverterScope] for
  /// [dartType] or null
  Embed? getClosestOrNull(DartType dartType) {
    return toList()
        .firstWhereOrNull(
            (embed) => embed.classElement.name == dartType.toString());
  }

  // /// Returns the [Embed] in the closest [TypeConverterScope] for
  // /// [dartType]
  // Embed getClosest(DartType dartType) {
  //   final closest = getClosestOrNull(dartType);
  //   if (closest == null) {
  //     throw InvalidGenerationSourceError(
  //       'Column type is not supported for $dartType',
  //       todo: 'Either use a supported type or supply a type converter.',
  //     );
  //   }
  //   return closest;
  // }
}
