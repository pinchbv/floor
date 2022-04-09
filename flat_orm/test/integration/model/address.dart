class Address {
  final String city;

  final String street;

  Address(this.city, this.street);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address &&
          runtimeType == other.runtimeType &&
          city == other.city &&
          street == other.street;

  @override
  int get hashCode => city.hashCode ^ street.hashCode;

  @override
  String toString() {
    return 'Address{city: $city, street: $street}';
  }
}
