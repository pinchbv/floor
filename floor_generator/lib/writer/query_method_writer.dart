// ignore_for_file: import_of_legacy_library_into_null_safe
import 'dart:core';

import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/misc/extension/string_extension.dart';
import 'package:floor_generator/misc/extension/type_converters_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
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

    final valueLists = _generateInClauseValueLists();
    if (valueLists.isNotEmpty) {
      _methodBody.write(valueLists.join(''));
    }

    final arguments = _generateArguments();
    final query = _generateQueryString();

    final queryable = _queryMethod.queryable;
    // null queryable implies void-returning query method
    if (_queryMethod.returnsVoid || queryable == null) {
      _methodBody.write(_generateNoReturnQuery(query, arguments));
    } else {
      _methodBody.write(_generateQuery(query, arguments, queryable));
    }

    return _methodBody.toString();
  }

  List<String> _generateInClauseValueLists() {
    return _queryMethod.parameters
        .where((parameter) => parameter.type.isDartCoreList)
        .mapIndexed((index, parameter) {
      // TODO #403 what about type converters that map between e.g. string and list?
      final flattenedParameterType = parameter.type.flatten();
      String value;
      if (flattenedParameterType.isDefaultSqlType) {
        value = '\$value';
      } else {
        final typeConverter =
            _queryMethod.typeConverters.getClosest(flattenedParameterType);
        value = '\${_${typeConverter.name.decapitalize()}.encode(value)}';
      }
      return '''final valueList$index = ${parameter.displayName}.map((value) => "'$value'").join(', ');''';
    }).toList();
  }

  List<String> _generateParameters() {
    return _queryMethod.parameters
        .where((parameter) => !parameter.type.isDartCoreList)
        .map((parameter) {
      if (parameter.type.isDefaultSqlType) {
        if (parameter.type.isDartCoreBool) {
          // query method parameters can't be null
          return '${parameter.displayName} ? 1 : 0';
        } else {
          return parameter.displayName;
        }
      } else {
        final typeConverter =
            _queryMethod.typeConverters.getClosest(parameter.type);
        return '_${typeConverter.name.decapitalize()}.encode(${parameter.displayName})';
      }
    }).toList();
  }

  String? _generateArguments() {
    final parameters = _generateParameters();
    return parameters.isNotEmpty ? '[${parameters.join(', ')}]' : null;
  }

  String _generateQueryString() {
    //TODO insert better parameter mappings
    return "'${_queryMethod.query}'";
  }

  String _generateNoReturnQuery(final String query, final String? arguments) {
    final parameters = StringBuffer(query);
    if (arguments != null) parameters.write(', arguments: $arguments');
    return 'await _queryAdapter.queryNoReturn($parameters);';
  }

  String _generateQuery(
    final String query,
    final String? arguments,
    final Queryable queryable,
  ) {
    final mapper = _generateMapper(queryable);
    final parameters = StringBuffer(query)..write(', mapper: $mapper');
    if (arguments != null) parameters.write(', arguments: $arguments');

    if (_queryMethod.returnsStream) {
      // for streamed queries, we need to provide the queryable to know which
      // entity to monitor. For views, we monitor all entities.
      parameters
        ..write(", queryableName: '${queryable.name}'")
        ..write(', isView: ${queryable is View}');
    }

    final list = _queryMethod.returnsList ? 'List' : '';
    final stream = _queryMethod.returnsStream ? 'Stream' : '';

    return 'return _queryAdapter.query$list$stream($parameters);';
  }
}

String _generateMapper(Queryable queryable) {
  final constructor = queryable.constructor;
  return '(Map<String, Object?> row) => $constructor';
}
