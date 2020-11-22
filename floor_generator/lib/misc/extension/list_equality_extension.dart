import 'package:collection/collection.dart';

extension ListEqualityExtension<T> on List<T> {
  bool equals(List<T> other) => ListEquality<T>().equals(this, other);
}
