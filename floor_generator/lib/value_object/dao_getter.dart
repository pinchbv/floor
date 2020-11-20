// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/value_object/dao.dart';

/// Representation of a DAO getter method defined in the database class.
class DaoGetter {
  final FieldElement fieldElement;
  final String name;
  final Dao dao;

  DaoGetter(this.fieldElement, this.name, this.dao);
}
