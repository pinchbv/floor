extension IterableExtension<T> on Iterable<T> {
  Iterable<T> sortedByDescending(Comparable Function(T element) selector) {
    return toList()..sort((b, a) => selector(a).compareTo(selector(b)));
  }

  Iterable<R> mapNotNull<R>(R? Function(T element) transform) sync* {
    for (final element in this) {
      final transformed = transform(element);
      if (transformed != null) yield transformed;
    }
  }
}
