import 'package:floor_generator/processor/error/change_method_processor_error.dart';
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

  group('expected errors', () {
    test('on wrong onConflict value', () async {
      final insertionMethod = await '''
      @Insert(onConflict: OnConflictStrategy.doesnotexist)
      Future<void> insertPerson(Person person);
    '''
          .asDaoMethodElement();
      final entities = await getPersonEntity();

      final actual =
          () => InsertionMethodProcessor(insertionMethod, [entities]).process();

      expect(
          actual,
          throwsInvalidGenerationSourceError(
              ChangeMethodProcessorError(insertionMethod, 'Insertion')
                  .wrongOnConflictValue));
    });
    test('when not returning Future', () async {
      final insertionMethod = await '''
      @insert
      void insertPerson(Person person);
    '''
          .asDaoMethodElement();
      final entities = await getPersonEntity();

      final actual =
          () => InsertionMethodProcessor(insertionMethod, [entities]).process();

      expect(
          actual,
          throwsInvalidGenerationSourceError(
              ChangeMethodProcessorError(insertionMethod, 'Insertion')
                  .doesNotReturnFuture));
    });
    test('when not returning int or void or List<int>', () async {
      final insertionMethod = await '''
      @insert
      Future<bool> insertPerson(Person person);
    '''
          .asDaoMethodElement();
      final entities = await getPersonEntity();

      final actual =
          () => InsertionMethodProcessor(insertionMethod, [entities]).process();

      expect(
          actual,
          throwsInvalidGenerationSourceError(
              ChangeMethodProcessorError(insertionMethod, 'Insertion')
                  .doesNotReturnVoidNorIntNorListInt));
    });
  });
}
