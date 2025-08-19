import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';

class TransactionMethod {
  final MethodElement2 methodElement;
  final String name;
  final DartType returnType;
  final List<FormalParameterElement> parameterElements;
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
          const DeepCollectionEquality().equals(parameterElements, other.parameterElements) &&
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
