// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:floor_generator/misc/string_utils.dart';
import 'package:test/test.dart';

void main() {
  test('decapitalize word (first letter to lowercase)', () {
    final actual = 'FOO'.decapitalize();

    expect(actual, 'fOO');
  });
}
