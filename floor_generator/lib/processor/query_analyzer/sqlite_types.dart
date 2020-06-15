import 'package:floor_generator/misc/annotations.dart';
import 'package:sqlparser/sqlparser.dart';

class SqlResultColumn {
  @nonNull
  final String name;

  final BasicType sqltype;

  final bool isNullable;

  @nonNull
  final bool isResolved;

  SqlResultColumn(this.name, ResolveResult type)
      : assert(type != null),
        sqltype = type.type?.type,
        isNullable = type.type?.nullable,
        isResolved = !type.unknown;
}

//class SqlReturnType {
//  /// The types of the returned columns in order.
//  /// If the list is empty, the query can only return void/null.
//  final List<SqlResultColumn> columnTypes;
//
//  /// Signals if a query can only return a single Row
//  /// (e.g. because it is a DELETE statement)
//  final bool multipleRows;
//
//  SqlReturnType(this.columnTypes, {this.multipleRows = true});
//
//  SqlReturnType.fromIterable(Iterable<SqlResultColumn> types,
//      {this.multipleRows = true})
//      : assert(types != null),
//        columnTypes = types.toList();
//}
