import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/misc/extension/set_equality_extension.dart';
import 'package:floor_generator/value_object/deletion_method.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/insertion_method.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/transaction_method.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:floor_generator/value_object/update_method.dart';
import 'package:floor_generator/value_object/view.dart';

class Dao {
  final ClassElement classElement;
  final String name;
  final List<QueryMethod> queryMethods;
  final List<InsertionMethod> insertionMethods;
  final List<UpdateMethod> updateMethods;
  final List<DeletionMethod> deletionMethods;
  final List<TransactionMethod> transactionMethods;
  final Set<Entity> streamEntities;
  final Set<View> streamViews;
  final Set<TypeConverter> typeConverters;

  Dao(
    this.classElement,
    this.name,
    this.queryMethods,
    this.insertionMethods,
    this.updateMethods,
    this.deletionMethods,
    this.transactionMethods,
    this.streamEntities,
    this.streamViews,
    this.typeConverters,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dao &&
          runtimeType == other.runtimeType &&
          classElement == other.classElement &&
          name == other.name &&
          queryMethods.equals(other.queryMethods) &&
          insertionMethods.equals(other.insertionMethods) &&
          updateMethods.equals(other.updateMethods) &&
          deletionMethods.equals(other.deletionMethods) &&
          transactionMethods.equals(other.transactionMethods) &&
          streamEntities.equals(streamEntities) &&
          streamViews.equals(other.streamViews) &&
          typeConverters.equals(other.typeConverters);

  @override
  int get hashCode =>
      classElement.hashCode ^
      name.hashCode ^
      queryMethods.hashCode ^
      insertionMethods.hashCode ^
      updateMethods.hashCode ^
      deletionMethods.hashCode ^
      transactionMethods.hashCode ^
      streamEntities.hashCode ^
      streamViews.hashCode ^
      typeConverters.hashCode;

  @override
  String toString() {
    return 'Dao{classElement: $classElement, name: $name, queryMethods: $queryMethods, insertionMethods: $insertionMethods, updateMethods: $updateMethods, deletionMethods: $deletionMethods, transactionMethods: $transactionMethods, streamEntities: $streamEntities, streamViews: $streamViews, typeConverters: $typeConverters}';
  }
}
