import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/value_object/embed.dart';
import 'package:floor_generator/value_object/type_converter.dart';

extension EmbedsExtension on Iterable<Embed> {
  /// Returns the [Embed] in the closest [TypeConverterScope] for
  /// [dartType] or null
  Embed? getClosestOrNull(DartType dartType) {
    return toList()
        .firstWhereOrNull(
            (embed) => embed.classElement.name == dartType.toString());
  }
}