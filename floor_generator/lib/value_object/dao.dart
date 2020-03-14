import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/value_object/deletion_method.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/insertion_method.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/transaction_method.dart';
import 'package:floor_generator/value_object/update_method.dart';

class Dao {
  final ClassElement classElement;
  final String name;
  final List<QueryMethod> queryMethods;
  final List<InsertionMethod> insertionMethods;
  final List<UpdateMethod> updateMethods;
  final List<DeletionMethod> deletionMethods;
  final List<TransactionMethod> transactionMethods;
  final List<Entity> streamEntities;

  Dao(
    this.classElement,
    this.name,
    this.queryMethods,
    this.insertionMethods,
    this.updateMethods,
    this.deletionMethods,
    this.transactionMethods,
    this.streamEntities,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dao &&
          runtimeType == other.runtimeType &&
          classElement == other.classElement &&
          name == other.name &&
          queryMethods == other.queryMethods &&
          insertionMethods == other.insertionMethods &&
          updateMethods == other.updateMethods &&
          deletionMethods == other.deletionMethods &&
          transactionMethods == other.transactionMethods &&
          streamEntities == other.streamEntities;

  @override
  int get hashCode =>
      classElement.hashCode ^
      name.hashCode ^
      queryMethods.hashCode ^
      insertionMethods.hashCode ^
      updateMethods.hashCode ^
      deletionMethods.hashCode ^
      transactionMethods.hashCode ^
      streamEntities.hashCode;

  @override
  String toString() {
    return 'NewDao{classElement: $classElement, name: $name, queryMethods: $queryMethods, insertionMethods: $insertionMethods, updateMethods: $updateMethods, deletionMethods: $deletionMethods, transactionMethods: $transactionMethods, streamEntities: $streamEntities}';
  }
}
