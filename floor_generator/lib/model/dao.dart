import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/delete_method.dart';
import 'package:floor_generator/model/entity.dart';
import 'package:floor_generator/model/insert_method.dart';
import 'package:floor_generator/model/query_method.dart';
import 'package:floor_generator/model/transaction_method.dart';
import 'package:floor_generator/model/update_method.dart';
import 'package:source_gen/source_gen.dart';

class Dao {
  final ClassElement clazz;
  final String daoFieldName;
  final String databaseName;

  Dao(final this.clazz, final this.daoFieldName, final this.databaseName);

  String get name => _nameCache ??= clazz.displayName;

  String _nameCache;

  List<MethodElement> get methods => _methodsCache ??= clazz.methods;

  List<MethodElement> _methodsCache;

  List<QueryMethod> get queryMethods {
    return _queryMethodsCache ??= methods
        .where((method) => method.metadata.any(isQueryAnnotation))
        .map((method) => QueryMethod(method))
        .toList();
  }

  List<QueryMethod> _queryMethodsCache;

  List<InsertMethod> get insertMethods {
    return _insertMethodCache ??= methods
        .where((method) => method.metadata.any(isInsertAnnotation))
        .map((method) => InsertMethod(method))
        .toList();
  }

  List<InsertMethod> _insertMethodCache;

  List<UpdateMethod> get updateMethods {
    return _updateMethodCache ??= methods
        .where((method) => method.metadata.any(isUpdateAnnotation))
        .map((method) => UpdateMethod(method))
        .toList();
  }

  List<UpdateMethod> _updateMethodCache;

  List<DeleteMethod> get deleteMethods {
    return _deleteMethodCache ??= methods
        .where((method) => method.metadata.any(isDeleteAnnotation))
        .map((method) => DeleteMethod(method))
        .toList();
  }

  List<DeleteMethod> _deleteMethodCache;

  List<TransactionMethod> get transactionMethods {
    return _transactionMethodCache ??= methods
        .where((method) => method.metadata.any(isTransactionAnnotation))
        .map((method) => TransactionMethod(method, daoFieldName, databaseName))
        .toList();
  }

  List<TransactionMethod> _transactionMethodCache;

  List<Entity> getStreamEntities(final LibraryReader library) {
    return _streamEntitiesCache ??= queryMethods
        .where((method) => method.returnsStream)
        .map((method) => method.getEntity(library))
        .toList();
  }

  List<Entity> _streamEntitiesCache;
}
