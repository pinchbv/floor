import 'package:floor_generator/processor/insertion_method_processor.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('Collects on conflict strategy', () async {
    final insertionMethod = await '''
      @Insert(onConflict: OnConflictStrategy.replace)
      Future<void> insertPerson(Person person);
    '''
        .asDaoMethodElement();
    final entities = await getPersonEntity();

    final actual = InsertionMethodProcessor(insertionMethod, [entities])
        .process()
        .onConflict;

    expect(actual, equals('OnConflictStrategy.replace'));
  });
}
