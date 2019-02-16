import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/model/change_method.dart';

class InsertMethod extends ChangeMethod {
  InsertMethod(final MethodElement method) : super(method);
}
