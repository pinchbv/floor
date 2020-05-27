import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/writer/writer.dart';

class ExtensionWriter implements Writer {
  ExtensionWriter();

  @override
  Code write() {
    final extensions = [
      _boolExtension(),
    ];

    return Code(extensions.join());
  }

  String _boolExtension() {
    return '''
      extension on bool {
        int toInt() => this == null ? null : (this ? 1 : 0);
      }
    ''';
  }
}
