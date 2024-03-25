import 'package:floor_common/floor_common.dart';

@DatabaseView(
  '''
    SELECT custom_name as name 
    FROM person 
    UNION SELECT name from dog
  ''',
  viewName: 'multiline_query_names',
)
class MultilineQueryName {
  final String name;

  MultilineQueryName(this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultilineQueryName &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return 'MultilineQueryName{name: $name}';
  }
}
