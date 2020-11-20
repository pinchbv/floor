// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
extension SetExtension<T> on Set<T> {
  Set<T> operator +(Set<T> other) {
    return this..addAll(other);
  }
}
