import 'dart:io';

Future<void> simulateDoingSomethingElse([int seconds]) async {
  sleep(Duration(seconds: seconds ?? 1));
}
