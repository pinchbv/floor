// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:collection/collection.dart';

extension SetEqualityExtension<T> on Set<T> {
  bool equals(Set<T> other) => SetEquality<T>().equals(this, other);
}
