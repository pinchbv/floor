import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:sqlparser/sqlparser.dart';

class AnalyzeResult{


  final AnalyzerEngine engine;

  final String processedQuery;

  final AnalysisContext analysisContext;

  Set<String> get willChange {

    return null;//todo
  }

  Set<String> get dependencies {

    return null;//todo
  }

  List<SqlType> get outputTypes {

    return null;//todo
  }

  //map name to int as start of span with fixed width
  final Map<int,String> listInsertionPositions;

  AnalyzeResult(this.processedQuery, this.listInsertionPositions, this.analysisContext, this.engine);

}


