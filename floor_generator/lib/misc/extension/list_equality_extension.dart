// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:collection/collection.dart';

extension ListEqualityExtension<T> on List<T> {
  bool equals(List<T> other) => ListEquality<T>().equals(this, other);
}
