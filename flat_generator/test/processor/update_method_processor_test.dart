import 'package:flat_generator/processor/error/change_method_processor_error.dart';
import 'package:flat_generator/processor/update_method_processor.dart';
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

  group('expected errors', () {
    test('on wrong onConflict value', () async {
      final updateMethod = await '''
      @Update(onConflict: OnConflictStrategy.doesnotexist)
      Future<void> updatePerson(Person person);
   '''
          .asDaoMethodElement();
      final entities = await getPersonEntity();

      final actual =
          () => UpdateMethodProcessor(updateMethod, [entities]).process();

      expect(
          actual,
          throwsInvalidGenerationSourceError(
              ChangeMethodProcessorError(updateMethod, 'Update')
                  .wrongOnConflictValue));
    });
    test('when not returning Future', () async {
      final updateMethod = await '''
      @update
      void updatePerson(Person person);
    '''
          .asDaoMethodElement();
      final entities = await getPersonEntity();

      final actual =
          () => UpdateMethodProcessor(updateMethod, [entities]).process();

      expect(
          actual,
          throwsInvalidGenerationSourceError(
              ChangeMethodProcessorError(updateMethod, 'Update')
                  .doesNotReturnFuture));
    });
    test('when returning a List', () async {
      final updateMethod = await '''
      @update
      Future<List<int>> updatePerson(Person person);
    '''
          .asDaoMethodElement();
      final entities = await getPersonEntity();

      final actual =
          () => UpdateMethodProcessor(updateMethod, [entities]).process();

      expect(
          actual,
          throwsInvalidGenerationSourceError(
              ChangeMethodProcessorError(updateMethod, 'Update')
                  .shouldNotReturnList));
    });
    test('when not returning int or void', () async {
      final updateMethod = await '''
      @update
      Future<bool> updatePerson(Person person);
    '''
          .asDaoMethodElement();
      final entities = await getPersonEntity();

      final actual =
          () => UpdateMethodProcessor(updateMethod, [entities]).process();

      expect(
          actual,
          throwsInvalidGenerationSourceError(
              ChangeMethodProcessorError(updateMethod, 'Update')
                  .doesNotReturnVoidNorInt));
    });
  });
}
