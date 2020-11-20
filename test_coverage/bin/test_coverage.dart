import 'dart:async';
import 'dart:io';

import 'package:test_coverage/test_coverage.dart';

Future main(List<String> arguments) async {
  final packageRoot = Directory.current;
  final testFiles = findTestFiles(packageRoot);
  print('Found ${testFiles.length} test files.');

  generateMainScript(packageRoot, testFiles);
  print('Generated test-all script in test/.test_coverage.dart.');

  await runTestsAndCollect(Directory.current.path);
}
