import 'package:floor_generator/processor/deletion_method_processor.dart';
import 'package:floor_generator/processor/error/change_method_processor_error.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('expected errors', () {
    test('when not returning Future', () async {
      final deletionMethod = await '''
      @delete
      void deletePerson(Person person);
    '''
          .asDaoMethodElement();
      final entities = await getPersonEntity();

      final actual =
          () => DeletionMethodProcessor(deletionMethod, [entities]).process();

      expect(
          actual,
          throwsInvalidGenerationSourceError(
              ChangeMethodProcessorError(deletionMethod, 'Deletion')
                  .doesNotReturnFuture));
    });
    test('when returning a List', () async {
      final deletionMethod = await '''
      @delete
      Future<List<int>> deletePerson(Person person);
    '''
          .asDaoMethodElement();
      final entities = await getPersonEntity();

      final actual =
          () => DeletionMethodProcessor(deletionMethod, [entities]).process();

      expect(
          actual,
          throwsInvalidGenerationSourceError(
              ChangeMethodProcessorError(deletionMethod, 'Deletion')
                  .shouldNotReturnList));
    });
    test('when not returning int or void', () async {
      final deletionMethod = await '''
      @delete
      Future<bool> deletePerson(Person person);
    '''
          .asDaoMethodElement();
      final entities = await getPersonEntity();

      final actual =
          () => DeletionMethodProcessor(deletionMethod, [entities]).process();

      expect(
          actual,
          throwsInvalidGenerationSourceError(
              ChangeMethodProcessorError(deletionMethod, 'Deletion')
                  .doesNotReturnVoidNorInt));
    });
  });
}
