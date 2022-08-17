import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/processor/error/queryable_processor_error.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/processor/queryable_processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/queryable.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:test/test.dart';

import '../dart_type.dart';
import '../test_utils.dart';

void main() {
  test('Process Queryable', () async {
    final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

    final actual = TestProcessor(classElement).process();

    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement, null).process())
        .toList();
    const constructor = "Person(row['id'] as int, row['name'] as String)";
    final expected = TestQueryable(
      classElement,
      fields,
      constructor,
    );
    expect(actual, equals(expected));
  });

  group('type converters', () {
    test('process queryable with external type converter', () async {
      final typeConverter = TypeConverter(
        'TypeConverter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.database,
      );
      final classElement = await createClassElement('''
      class Order {
        final int id;
      
        final DateTime dateTime;
      
        Order(this.id, this.dateTime);
      }
    ''');

      final actual = TestProcessor(classElement, {typeConverter}).process();

      final idField = FieldProcessor(classElement.fields[0], null).process();
      final dateTimeField =
          FieldProcessor(classElement.fields[1], typeConverter).process();
      final fields = [idField, dateTimeField];
      const constructor =
          "Order(row['id'] as int, _typeConverter.decode(row['dateTime'] as int))";
      final expected = TestQueryable(
        classElement,
        fields,
        constructor,
      );
      expect(actual, equals(expected));
    });

    test('process queryable with local type converter', () async {
      final classElement = await createClassElement('''
      @TypeConverters([DateTimeConverter])
      class Order {
        final int id;
      
        final DateTime dateTime;
      
        Order(this.id, this.dateTime);
      }
      
      class DateTimeConverter extends TypeConverter<DateTime, int> {
        @override
        DateTime decode(int databaseValue) {
          return DateTime.fromMillisecondsSinceEpoch(databaseValue);
        }
            
        @override
        int encode(DateTime value) {
          return value.millisecondsSinceEpoch;
        }
      }
    ''');

      final actual = TestProcessor(classElement).process();

      final typeConverter = TypeConverter(
        'DateTimeConverter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.queryable,
      );
      final idField = FieldProcessor(classElement.fields[0], null).process();
      final dateTimeField =
          FieldProcessor(classElement.fields[1], typeConverter).process();
      final fields = [idField, dateTimeField];
      const constructor =
          "Order(row['id'] as int, _dateTimeConverter.decode(row['dateTime'] as int))";
      final expected = TestQueryable(
        classElement,
        fields,
        constructor,
      );
      expect(actual, equals(expected));
    });

    test('process queryable and prefer local type converter over external',
        () async {
      final externalTypeConverter = TypeConverter(
        'ExternalConverter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.database,
      );
      final classElement = await createClassElement('''
      @TypeConverters([DateTimeConverter])
      class Order {
        final int id;
      
        final DateTime dateTime;
      
        Order(this.id, this.dateTime);
      }
      
      class DateTimeConverter extends TypeConverter<DateTime, int> {
        @override
        DateTime decode(int databaseValue) {
          return DateTime.fromMillisecondsSinceEpoch(databaseValue);
        }
            
        @override
        int encode(DateTime value) {
          return value.millisecondsSinceEpoch;
        }
      }
    ''');

      final actual =
          TestProcessor(classElement, {externalTypeConverter}).process();

      final typeConverter = TypeConverter(
        'DateTimeConverter',
        await dateTimeDartType,
        await intDartType,
        TypeConverterScope.queryable,
      );
      final idField = FieldProcessor(classElement.fields[0], null).process();
      final dateTimeField =
          FieldProcessor(classElement.fields[1], typeConverter).process();
      final fields = [idField, dateTimeField];
      const constructor =
          "Order(row['id'] as int, _dateTimeConverter.decode(row['dateTime'] as int))";
      final expected = TestQueryable(
        classElement,
        fields,
        constructor,
      );
      expect(actual, equals(expected));
    });
  });

  group('Field inheritance', () {
    test('Inherits fields from abstract parent class', () async {
      final classElement = await createClassElement('''
      class TestEntity extends AbstractEntity {
        final String name;
      
        TestEntity(int id, this.name) : super(id);
      }
      
      abstract class AbstractEntity {
        @primaryKey
        final int id;
      
        AbstractEntity(this.id);
      }           
    ''');

      final actual = TestProcessor(classElement).process();
      final fieldNames = actual.fields.map((field) => field.name).toList();

      final expectedFieldNames = ['id', 'name'];
      const expectedConstructor =
          "TestEntity(row['id'] as int, row['name'] as String)";
      expect(fieldNames, containsAll(expectedFieldNames));
      expect(actual.constructor, equals(expectedConstructor));
    });

    test('Inherits fields from abstract parent class', () async {
      final classElement = await createClassElement('''
        class TestEntity extends AnotherAbstractEntity {
          final String name;
        
          TestEntity(int id, double foo, this.name) : super(id, foo);
        }
        
        abstract class AnotherAbstractEntity extends AbstractEntity {
          final double foo;
        
          AnotherAbstractEntity(int id, this.foo) : super(id);
        }
        
        abstract class AbstractEntity {
          @primaryKey
          final int id;
        
          AbstractEntity(this.id);
        }                 
    ''');

      final actual = TestProcessor(classElement).process();
      final fieldNames = actual.fields.map((field) => field.name).toList();

      final expectedFieldNames = ['id', 'foo', 'name'];
      const expectedConstructor =
          "TestEntity(row['id'] as int, row['foo'] as double, row['name'] as String)";
      expect(fieldNames, containsAll(expectedFieldNames));
      expect(actual.constructor, equals(expectedConstructor));
    });

    test('Inherits fields from superclass', () async {
      final classElement = await createClassElement('''
        class TestEntity extends SuperClassEntity {
          final String name;
        
          TestEntity(int id, this.name) : super(id);
        }
        
        class SuperClassEntity {
          @primaryKey
          final int id;
        
          SuperClassEntity(this.id);
        }                 
    ''');

      final actual = TestProcessor(classElement).process();
      final fieldNames = actual.fields.map((field) => field.name).toList();

      final expectedFieldNames = ['id', 'name'];
      const expectedConstructor =
          "TestEntity(row['id'] as int, row['name'] as String)";
      expect(fieldNames, containsAll(expectedFieldNames));
      expect(actual.constructor, equals(expectedConstructor));
    });

    test('Inherits fields from superclass', () async {
      final classElement = await createClassElement('''
        class TestEntity implements InterfaceEntity {
          @primaryKey
          @override
          final int id;
          final String name;
        
          TestEntity(this.id, this.name);
        }
        
        class InterfaceEntity {
          final int id;
        
          InterfaceEntity(this.id);
        }                 
    ''');

      final actual = TestProcessor(classElement).process();
      final fieldNames = actual.fields.map((field) => field.name).toList();

      final expectedFieldNames = ['id', 'name'];
      const expectedConstructor =
          "TestEntity(row['id'] as int, row['name'] as String)";
      expect(fieldNames, containsAll(expectedFieldNames));
      expect(actual.constructor, equals(expectedConstructor));
    });

    test('Throws when queryable inherits from mixin', () async {
      final classElement = await createClassElement('''
        class TestEntity with TestMixin {
          final int id;
        
          TestEntity(this.id);
        }
        
        class TestMixin {
          String name;
        }      
    ''');

      final actual = () => TestProcessor(classElement).process();

      final error = QueryableProcessorError(classElement).prohibitedMixinUsage;
      expect(actual, throwsInvalidGenerationSourceError(error));
    });
  });

  group('Ignore special fields', () {
    test('Ignore static field', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
        
        static String foo = 'foo';
      }
    ''');

      final actual = TestProcessor(classElement).process();

      expect(actual.fields.length, equals(2));
    });

    test('Ignore hashCode field', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
        
        @override
        int get hashCode => id.hashCode ^ name.hashCode;
      }
    ''');

      final actual = TestProcessor(classElement).process();

      expect(actual.fields.length, equals(2));
    });

    test('Ignore getter', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
      
        String get label => '\$id: \$name'
      
        Person(this.id, this.name);
      }
    ''');

      final actual = TestProcessor(classElement)
          .process()
          .fields
          .map((field) => field.name)
          .toList();

      expect(actual, equals(['id', 'name']));
    });

    test('Ignore setter', () async {
      final classElement = await createClassElement('''
      class Person {
        @primaryKey
        final int id;
      
        final String name;
      
        set printwith(String prefix) => print(prefix+name);

        Person(this.id, this.name);
        
        static String foo = 'foo';
      }
    ''');

      final actual = TestProcessor(classElement)
          .process()
          .fields
          .map((field) => field.name)
          .toList();

      expect(actual, equals(['id', 'name']));
    });
  });

  group('Constructors', () {
    test('generate simple constructor', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

      final actual = TestProcessor(classElement).process().constructor;

      const expected = "Person(row['id'] as int, row['name'] as String)";
      expect(actual, equals(expected));
    });

    test('generate constructor with named argument', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
        
        final String bar;
      
        Person(this.id, this.name, {required this.bar});
      }
    ''');

      final actual = TestProcessor(classElement).process().constructor;

      const expected =
          "Person(row['id'] as int, row['name'] as String, bar: row['bar'] as String)";
      expect(actual, equals(expected));
    });

    test('generate constructor with boolean arguments', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
      
        final bool bar;
      
        final bool? foo;
      
        Person(this.id, this.name, {required this.bar, this.foo});
      }
    ''');

      final actual = TestProcessor(classElement).process().constructor;

      const expected =
          "Person(row['id'] as int, row['name'] as String, bar: (row['bar'] as int) != 0, foo: row['foo'] == null ? null : (row['foo'] as int) != 0)";
      expect(actual, equals(expected));
    });

    test('generate constructor with enum arguments', () async {
      final classElement = await createClassElement('''
      
      $characterType
      
      class Person {
        final int id;
      
        final String name;
      
        final CharacterType bar;
      
        final CharacterType? foo;
      
        Person(this.id, this.name, {required this.bar, this.foo});
      }
    ''');

      final actual = TestProcessor(classElement).process().constructor;

      const expected = 'Person('
          "row['id'] as int, "
          "row['name'] as String, "
          "bar: CharacterType.values[row['bar'] as int], "
          "foo: row['foo'] == null ? null : CharacterType.values[row['foo'] as int]"
          ')';
      expect(actual, equals(expected));
    });

    test('generate constructor with named arguments', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
        
        final String bar;
      
        Person({required this.id, required this.name, required this.bar});
      }
    ''');

      final actual = TestProcessor(classElement).process().constructor;

      const expected =
          "Person(id: row['id'] as int, name: row['name'] as String, bar: row['bar'] as String)";
      expect(actual, equals(expected));
    });

    test('generate constructor with optional argument', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
        
        final String? bar;
      
        Person(this.id, this.name, [this.bar]);
      }
    ''');

      final actual = TestProcessor(classElement).process().constructor;

      const expected =
          "Person(row['id'] as int, row['name'] as String, row['bar'] as String?)";
      expect(actual, equals(expected));
    });

    test('generate constructor with optional arguments', () async {
      final classElement = await createClassElement('''
      class Person {
        final int? id;
      
        final String? name;
        
        final String? bar;
      
        Person([this.id, this.name, this.bar]);
      }
    ''');

      final actual = TestProcessor(classElement).process().constructor;

      const expected =
          "Person(row['id'] as int?, row['name'] as String?, row['bar'] as String?)";
      expect(actual, equals(expected));
    });

    group('nullability', () {
      test('generates constructor with only nullable types', () async {
        final classElement = await createClassElement('''
          
          $characterType
          
          class Person {
            final int? id;
            
            final double? doubleId; 
          
            final String? name;
            
            final bool? bar;
            
            final Uint8List? blob;
            
            final CharacterType? character;
          
            Person(this.id, this.doubleId, this.name, this.bar, this.blob, this.character);
          }
        ''');

        final actual = TestProcessor(classElement).process().constructor;

        const expected = 'Person('
            "row['id'] as int?, "
            "row['doubleId'] as double?, "
            "row['name'] as String?, "
            "row['bar'] == null ? null : (row['bar'] as int) != 0, "
            "row['blob'] as Uint8List?, "
            "row['character'] == null ? null : CharacterType.values[row['character'] as int]"
            ')';
        expect(actual, equals(expected));
      });

      test('generates constructor with only non-nullable types', () async {
        final classElement = await createClassElement('''
          
          $characterType
        
          class Person {
            final int id;
            
            final double doubleId; 
          
            final String name;
            
            final bool bar;
            
            final Uint8List blob;
            
            final CharacterType character;
          
            Person(this.id, this.doubleId, this.name, this.bar, this.blob, this.character);
          }
        ''');

        final actual = TestProcessor(classElement).process().constructor;

        const expected = 'Person('
            "row['id'] as int, "
            "row['doubleId'] as double, "
            "row['name'] as String, "
            "(row['bar'] as int) != 0, "
            "row['blob'] as Uint8List, "
            "CharacterType.values[row['character'] as int]"
            ')';
        expect(actual, equals(expected));
      });
    });
  });

  group('@Ignore', () {
    test('ignore field not present in constructor', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
        
        @ignore
        String? foo;
      
        Person(this.id, this.name);
      }
    ''');

      final actual = TestProcessor(classElement)
          .process()
          .fields
          .map((field) => field.name);

      const expected = 'foo';
      expect(actual, isNot(contains(expected)));
    });

    test('ignore field present in constructor', () async {
      final classElement = await createClassElement('''
      class Person {
        final int id;
      
        final String name;
        
        @ignore
        String? foo;
      
        Person(this.id, this.name, [this.foo = 'foo']);
      }
    ''');

      final actual = TestProcessor(classElement).process().constructor;

      const expected = "Person(row['id'] as int, row['name'] as String)";
      expect(actual, equals(expected));
    });
  });
}

class TestQueryable extends Queryable {
  TestQueryable(
    ClassElement classElement,
    List<Field> fields,
    String constructor,
  ) : super(classElement, '', fields, constructor);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestQueryable &&
          runtimeType == other.runtimeType &&
          classElement == other.classElement &&
          const ListEquality<Field>().equals(fields, other.fields) &&
          constructor == other.constructor;

  @override
  int get hashCode =>
      classElement.hashCode ^ fields.hashCode ^ constructor.hashCode;

  @override
  String toString() {
    return 'TestQueryable{classElement: $classElement, name: $name, fields: $fields, constructor: $constructor}';
  }
}

class TestProcessor extends QueryableProcessor<TestQueryable> {
  TestProcessor(
    ClassElement classElement, [
    Set<TypeConverter>? typeConverters,
  ]) : super(classElement, typeConverters ?? {});

  @override
  TestQueryable process() {
    final fields = getFields();
    return TestQueryable(
      classElement,
      fields,
      getConstructor(fields),
    );
  }
}
