import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/value_object/change_method.dart';

class DeleteMethod extends ChangeMethod {
  DeleteMethod(final MethodElement method) : super(method);
}
