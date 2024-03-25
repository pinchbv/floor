import 'package:floor_common/floor_common.dart';

@DatabaseView(
    'SELECT custom_name as name FROM person UNION SELECT name from dog',
    viewName: 'names')
class Name {
  final String name;

  Name(this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Name && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return 'Name{name: $name}';
  }
}
