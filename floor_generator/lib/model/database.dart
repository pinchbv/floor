import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/delete_method.dart';
import 'package:floor_generator/model/entity.dart';
import 'package:floor_generator/model/insert_method.dart';
import 'package:floor_generator/model/query_method.dart';
import 'package:floor_generator/model/transaction_method.dart';
import 'package:floor_generator/model/update_method.dart';
import 'package:source_gen/source_gen.dart';

class Database {
  final ClassElement clazz;

  Database(final this.clazz);

  String get name => clazz.displayName;

  int get version {
    final databaseVersion = clazz.metadata
        .firstWhere(isDatabaseAnnotation)
        .computeConstantValue()
        .getField(AnnotationField.DATABASE_VERSION)
        ?.toIntValue();

    return databaseVersion != null
        ? databaseVersion
        : throw InvalidGenerationSourceError(
            'No version for this database specified even though it is required.',
            element: clazz,
          );
  }

  List<MethodElement> get methods => clazz.methods;

  List<QueryMethod> get queryMethods {
    return methods
        .where((method) => method.metadata.any(isQueryAnnotation))
        .map((method) => QueryMethod(method))
        .toList();
  }

  List<InsertMethod> get insertMethods {
    return methods
        .where((method) => method.metadata.any(isInsertAnnotation))
        .map((method) => InsertMethod(method))
        .toList();
  }

  List<UpdateMethod> get updateMethods {
    return methods
        .where((method) => method.metadata.any(isUpdateAnnotation))
        .map((method) => UpdateMethod(method))
        .toList();
  }

  List<DeleteMethod> get deleteMethods {
    return methods
        .where((method) => method.metadata.any(isDeleteAnnotation))
        .map((method) => DeleteMethod(method))
        .toList();
  }

  List<TransactionMethod> get transactionMethods {
    return methods
        .where((method) => method.metadata.any(isTransactionAnnotation))
        .map((method) => TransactionMethod(method, name))
        .toList();
  }

  List<Entity> getEntities(final LibraryReader library) {
    return library.classes
        .where((clazz) =>
            !clazz.isAbstract && clazz.metadata.any(isEntityAnnotation))
        .map((entity) => Entity(entity))
        .toList();
  }
}
