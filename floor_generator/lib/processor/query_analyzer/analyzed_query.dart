
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/processor/query_analyzer/engine.dart';

abstract class AnalyzeResult{


  //final AnalyzerEngine engine;

//  AnalyzeResult(this.engine);

  Set<String> get willChange;

  Set<String> get dependencies;

  List<SqlType> get outputTypes;

  String get processedQuery;

  //an ordered list marking the spans on where to insert the lists.
  List<int> get listInsertionSpans;
}


