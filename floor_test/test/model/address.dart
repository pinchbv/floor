part of '../database.dart';

class Address {
  final String street;
  final String city;

  Address(this.street, this.city);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Address &&
              runtimeType == other.runtimeType &&
              street == other.street &&
              city == other.city;

  @override
  int get hashCode => street.hashCode ^ city.hashCode;

  @override
  String toString() {
    return 'Address{street: $street, city: $city}';
  }
}
