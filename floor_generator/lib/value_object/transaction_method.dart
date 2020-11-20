// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

class TransactionMethod {
  final MethodElement methodElement;
  final String name;
  final DartType returnType;
  final List<ParameterElement> parameterElements;
  final String daoFieldName;
  final String databaseName;

  TransactionMethod(
    this.methodElement,
    this.name,
    this.returnType,
    this.parameterElements,
    this.daoFieldName,
    this.databaseName,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionMethod &&
          runtimeType == other.runtimeType &&
          methodElement == other.methodElement &&
          name == other.name &&
          returnType == other.returnType &&
          parameterElements == other.parameterElements &&
          daoFieldName == other.daoFieldName &&
          databaseName == other.databaseName;

  @override
  int get hashCode =>
      methodElement.hashCode ^
      name.hashCode ^
      returnType.hashCode ^
      parameterElements.hashCode ^
      daoFieldName.hashCode ^
      databaseName.hashCode;

  @override
  String toString() {
    return 'NewTransactionMethod{methodElement: $methodElement, name: $name, returnType: $returnType, parameterElements: $parameterElements, daoFieldName: $daoFieldName, databaseName: $databaseName}';
  }
}
