import 'package:analyzer/dart/element/element.dart';
import 'package:flat_generator/value_object/dao.dart';

/// Representation of a DAO getter method defined in the database class.
class DaoGetter {
  final FieldElement fieldElement;
  final String name;
  final Dao dao;

  DaoGetter(this.fieldElement, this.name, this.dao);
}
