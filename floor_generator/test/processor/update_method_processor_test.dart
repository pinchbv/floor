// TODO #375 delete once dependencies have migrated
// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:floor_generator/processor/update_method_processor.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('Collects on conflict strategy', () async {
    final insertionMethod = await '''
      @Update(onConflict: OnConflictStrategy.replace)
      Future<void> updatePerson(Person person);
    '''
        .asDaoMethodElement();
    final entities = await getPersonEntity();

    final actual =
        UpdateMethodProcessor(insertionMethod, [entities]).process().onConflict;

    expect(actual, equals('OnConflictStrategy.replace'));
  });
}
