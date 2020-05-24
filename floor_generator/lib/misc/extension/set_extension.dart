extension SetExtension<T> on Set<T> {
  Set<T> operator +(Set<T> other) {
    return <T>{}..addAll(this)..addAll(other);
  }
}
