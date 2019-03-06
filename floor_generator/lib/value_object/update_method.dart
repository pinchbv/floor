import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/value_object/change_method.dart';

class UpdateMethod extends ChangeMethod {
  UpdateMethod(final MethodElement method) : super(method);

  String get onConflict {
    final strategy = method.metadata
        .firstWhere(isUpdateAnnotation)
        .computeConstantValue()
        .getField(AnnotationField.ON_CONFLICT)
        .toIntValue();

    return 'sqflite.ConflictAlgorithm.${OnConflictStrategy.getConflictAlgorithm(strategy)}';
  }
}
