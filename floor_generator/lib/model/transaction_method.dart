import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

class TransactionMethod {
  final MethodElement method;
  final String databaseName;

  TransactionMethod(this.method, this.databaseName);

  DartType get returnType => method.returnType;

  String get name => method.displayName;

  List<ParameterElement> get parameters => method.parameters;
}
