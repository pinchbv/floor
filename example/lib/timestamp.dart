import 'package:floor/floor.dart';

class Timestamp {
  @ColumnInfo(name: 'created_at')
  String createdAt;

  @ColumnInfo(name: 'updated_at')
  String updatedAt;

  Timestamp({this.createdAt, this.updatedAt});

  Timestamp.now()
      : createdAt = DateTime.now().toString(),
        updatedAt = DateTime.now().toString();
}
