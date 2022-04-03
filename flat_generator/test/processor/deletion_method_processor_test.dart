import 'package:flat_generator/processor/deletion_method_processor.dart';
import 'package:flat_generator/processor/error/change_method_processor_error.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('expected errors', () {
    test('when not accepting Parameter', () async {
      final deletionMethod = await '''
      @delete
      Future<void> deletePerson();
    '''
          .asDaoMethodElement();
      final entities = await getPersonEntity();

      final actual =
          () => DeletionMethodProcessor(deletionMethod, [entities]).process();

      expect(
          actual,
          throwsInvalidGenerationSourceError(InvalidGenerationSourceError(
            'There is no parameter supplied for this method. Please add one.',
            element: deletionMethod,
          )));
    });
    test('when accepting more than one Parameter', () async {
      final deletionMethod = await '''
      @delete
      Future<void> deletePerson(Person p1, Person p2);
    '''
          .asDaoMethodElement();
      final entities = await getPersonEntity();

      final actual =
          () => DeletionMethodProcessor(deletionMethod, [entities]).process();

      expect(
          actual,
          throwsInvalidGenerationSourceError(InvalidGenerationSourceError(
            'Only one parameter is allowed on this.',
            element: deletionMethod,
          )));
    });
    test('when not accepting an Entity', () async {
      final deletionMethod = await '''
      @delete
      Future<void> deletePerson(int p2);
    '''
          .asDaoMethodElement();
      final entities = await getPersonEntity();

      final actual =
          () => DeletionMethodProcessor(deletionMethod, [entities]).process();

      expect(
          actual,
          throwsInvalidGenerationSourceError(InvalidGenerationSourceError(
            'You are trying to change an object which is not an entity.',
            element: deletionMethod,
          )));
    });
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
