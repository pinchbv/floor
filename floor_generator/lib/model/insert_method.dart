import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/change_method.dart';

class InsertMethod extends ChangeMethod {
  InsertMethod(final MethodElement method) : super(method);

  String get onConflict {
    final strategy = method.metadata
        .firstWhere(isInsertAnnotation)
        .computeConstantValue()
        .getField(AnnotationField.ON_CONFLICT)
        .toIntValue();

    return 'sqflite.ConflictAlgorithm.${OnConflictStrategy.getConflictAlgorithm(strategy)}';
  }
}
