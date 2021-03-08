import 'package:floor_generator/misc/extension/dart_type_extension.dart';
import 'package:test/test.dart';

import '../../test_utils.dart';

void main() {
  test('nullable string is nullable', () async {
    final type = await getDartTypeFromDeclaration("final String? foo = '';");

    final actual = type.isNullable;

    expect(actual, isTrue);
  });

  test('non-nullable string is non-nullable', () async {
    final type = await getDartTypeFromDeclaration("final String foo = '';");

    final actual = type.isNullable;

    expect(actual, isFalse);
  });
}
