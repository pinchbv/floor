// TODO #165 documentation
abstract class TypeConverter<T, S> {
  S encode(T value);

  T decode(S databaseValue);
}
