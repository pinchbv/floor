import 'dart:core';

import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/misc/extension/string_extension.dart';
import 'package:floor_generator/misc/extension/type_converters_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/query_method_writer_error.dart';
import 'package:floor_generator/value_object/query.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/queryable.dart';
import 'package:floor_generator/value_object/view.dart';
import 'package:floor_generator/writer/writer.dart';

class QueryMethodWriter implements Writer {
  final QueryMethod _queryMethod;

  QueryMethodWriter(final QueryMethod queryMethod) : _queryMethod = queryMethod;

  @override
  Method write() {
    final builder = MethodBuilder()
      ..annotations.add(overrideAnnotationExpression)
      ..returns = refer(_queryMethod.rawReturnType.getDisplayString(
        withNullability: true,
      ))
      ..name = _queryMethod.name
      ..requiredParameters.addAll(_generateMethodParameters())
      ..body = Code(_generateMethodBody());

    if (!_queryMethod.returnsStream || _queryMethod.returnsVoid) {
      builder..modifier = MethodModifier.async;
    }
    return builder.build();
  }

  List<Parameter> _generateMethodParameters() {
    return _queryMethod.parameters.map((parameter) {
      return Parameter((builder) => builder
        ..name = parameter.name
        ..type = refer(parameter.type.getDisplayString(
          // processor disallows nullable method parameters and throws if found,
          // still interested in nullability here to future-proof codebase
          withNullability: true,
        )));
    }).toList();
  }

  String _generateMethodBody() {
    final _methodBody = StringBuffer();

    // generate the variable definitions which will store the sqlite argument
    // lists, e.g. '?5,?6,?7,?8'. These have to be generated for each call to
    // the query method to accommodate for different list sizes. This is
    // necessary to guarantee that each single value is inserted at the right
    // place and only via SQLite's escape-mechanism.
    // If no [List] parameters are present, Nothing will be written.
    _methodBody.write(_generateListConvertersForQuery());

    final arguments = _generateArguments();
    final query = _generateQueryString();
    final returnType = _queryMethod.flattenedReturnType;
    final queryable = _queryMethod.queryable;

    if (_queryMethod.returnsVoid) {
      _methodBody.write(_generateNoReturnQuery(query, arguments));
    } else if (queryable != null || returnType.isDefaultSqlType) {
      _methodBody
          .write(_generateQuery(query, arguments, queryable, returnType));
    } else {
      throw QueryMethodWriterError(_queryMethod.methodElement)
          .queryMethodReturnType();
    }

    return _methodBody.toString();
  }

  String _generateListConvertersForQuery() {
    final code = StringBuffer();
    // because we ultimately want to give a query with numbered variables to sqflite, we have to compute them dynamically when working with lists.
    // We establish the conventions that we provide the fixed parameters first and then append the list parameters one by one.
    // parameters 1,2,... start-1 are already used by fixed (non-list) parameters.
    final start = _queryMethod.parameters
            .where((param) => !param.type.isDartCoreList)
            .length +
        1;

    String? lastParam;
    for (final listParam in _queryMethod.parameters
        .where((param) => param.type.isDartCoreList)) {
      if (lastParam == null) {
        //make start final if it is only used once, fixes a lint
        final constInt =
            (start == _queryMethod.parameters.length) ? 'const' : 'int';
        code.writeln('$constInt offset = $start;');
      } else {
        code.writeln('offset += $lastParam.length;');
      }
      final currentParamName = listParam.displayName;
      // dynamically generate strings of the form '?4,?5,?6,?7,?8' which we can
      // later insert into the query at the marked locations.
      code.write('final _sqliteVariablesFor${currentParamName.capitalize()}=');
      code.write('Iterable<String>.generate(');
      code.write("$currentParamName.length, (i)=>'?\${i+offset}'");
      code.writeln(").join(',');");

      lastParam = currentParamName;
    }
    return code.toString();
  }

  List<String> _generateParameters() {
    //first, take fixed parameters, then insert list parameters.
    return [
      ..._queryMethod.parameters
          .where((parameter) => !parameter.type.isDartCoreList)
          .map((parameter) {
        final type = parameter.type;
        final displayName = parameter.displayName;

        if (type.isDartCoreBool) {
          // query method parameters can't be null
          return '$displayName ? 1 : 0';
        } else if (type.isEnumType) {
          return '$displayName.index';
        } else if (type.isDefaultSqlType) {
          return displayName;
        } else {
          final typeConverter = _queryMethod.typeConverters.getClosest(type);
          return '_${typeConverter.name.decapitalize()}.encode($displayName)';
        }
      }),
      ..._queryMethod.parameters
          .where((parameter) => parameter.type.isDartCoreList)
          .map((parameter) {
        // TODO #403 what about type converters that map between e.g. string and list?
        final DartType flatType = parameter.type.flatten();
        final displayName = parameter.displayName;

        if (flatType.isDefaultSqlType || flatType.isEnumType) {
          return '...$displayName';
        } else {
          final typeConverter =
              _queryMethod.typeConverters.getClosest(flatType);
          return '...$displayName.map((element) => _${typeConverter.name.decapitalize()}.encode(element))';
        }
      })
    ];
  }

  String? _generateArguments() {
    final parameters = _generateParameters();
    return parameters.isNotEmpty ? '[${parameters.join(', ')}]' : null;
  }

  String _generateQueryString() {
    final code = StringBuffer();
    int start = 0;
    final originalQuery = _queryMethod.query.sql;
    for (final listParameter in _queryMethod.query.listParameters) {
      code.write(
          originalQuery.substring(start, listParameter.position).toLiteral());
      code.write(' + _sqliteVariablesFor${listParameter.name.capitalize()} + ');
      start = listParameter.position + varlistPlaceholder.length;
    }
    code.write(originalQuery.substring(start).toLiteral());

    return code.toString();
  }

  String _generateNoReturnQuery(final String query, final String? arguments) {
    final parameters = StringBuffer(query);
    if (arguments != null) parameters.write(', arguments: $arguments');
    return 'await _queryAdapter.queryNoReturn($parameters);';
  }

  String _generateQuery(
    final String query,
    final String? arguments,
    final Queryable? queryable,
    final DartType returnType,
  ) {
    final mapper = queryable == null
        ? _generateDartCoreMapper(returnType)
        : _generateMapper(queryable);
    final parameters = StringBuffer(query)..write(', mapper: $mapper');
    if (arguments != null) parameters.write(', arguments: $arguments');

    if (_queryMethod.returnsStream) {
      // for streamed queries, we need to provide the queryable to know which
      // entity to monitor. For views, we monitor all entities.
      parameters
        ..write(", queryableName: '${_parseTableName(query)}'")
        ..write(', isView: ${queryable is View}');
    }

    final list = _queryMethod.returnsList ? 'List' : '';
    final stream = _queryMethod.returnsStream ? 'Stream' : '';

    return 'return _queryAdapter.query$list$stream($parameters);';
  }

  String _generateDartCoreMapper(final DartType returnType) {
    final nonNullReturnType = returnType.getDisplayString(
      withNullability: false,
    );
    final mapperPredicate = returnType.isDartCoreBool
        ? '(row.values.first as int) == 1'
        : 'row.values.first as $nonNullReturnType';
    return '(Map<String, Object?> row) => $mapperPredicate';
  }

  String _parseTableName(String query) {
    return RegExp(r'(?<=FROM )\w+', caseSensitive: false)
            .firstMatch(query)
            ?.group(0) ??
        'no_table_name';
  }
}

String _generateMapper(Queryable queryable) {
  final constructor = queryable.constructor;
  return '(Map<String, Object?> row) => $constructor';
}
