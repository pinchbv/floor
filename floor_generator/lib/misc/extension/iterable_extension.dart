// TODO #375 test
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    try {
      return first;
    } catch (e) {
      return null;
    }
  }

  T? firstOrNullWhere(bool Function(T element) predicate) {
    for (T element in this) {
      if (predicate(element)) return element;
    }
    return null;
  }

  Iterable<T> sortedByDescending(Comparable Function(T element) selector) {
    return toList()..sort((b, a) => selector(a).compareTo(selector(b)));
  }

  Iterable<R> mapNotNull<R>(R? Function(T element) transform) {
    return map((element) => transform(element))
        .where((element) => element != null)
        .map((element) => element!);
  }
}

extension NullableIterableExtension<T> on Iterable<T?> {
  Iterable<T> whereNotNull() {
    return where((element) => element != null).map((element) => element!);
  }
}
