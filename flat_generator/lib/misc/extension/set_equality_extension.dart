import 'package:collection/collection.dart';

extension SetEqualityExtension<T> on Set<T> {
  bool equals(Set<T> other) => SetEquality<T>().equals(this, other);
}
