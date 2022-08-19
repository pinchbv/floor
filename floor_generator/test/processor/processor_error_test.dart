import 'package:floor_generator/processor/error/processor_error.dart';
import 'package:test/test.dart';

import '../fakes.dart';
import '../test_utils.dart';

void main() {
  test('toString with source element', () async {
    final insertionMethod = await '''
      @Insert(onConflict: OnConflictStrategy.replace)
      Future<void> insertPerson(Person person);
    '''
        .asDaoMethodElement();
    final error = ProcessorError(
        message: 'mymessage', todo: 'mytodo', element: insertionMethod);
    expect(
        error.toString(),
        equals('mymessage mytodo\n'
            'package:_resolve_source/_resolve_source.dart:9:20\n'
            '  ╷\n'
            '9 │       Future<void> insertPerson(Person person);\n'
            '  │                    ^^^^^^^^^^^^\n'
            '  ╵'));
  });
  test('toString with empty source element', () async {
    final element = FakeClassElement();
    final error =
        ProcessorError(message: 'mymessage', todo: 'mytodo', element: element);
    expect(
        error.toString(),
        equals('mymessage mytodo\n'
            'Cause: Instance of \'FakeClassElement\'\n'));
  });
}
