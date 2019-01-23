import 'dart:async';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class FloorGenerator implements Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    return "const yay = 'Hello world!';";
  }
}
