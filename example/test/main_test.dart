import 'package:example/database.dart';
import 'package:example/main.dart';
import 'package:example/task_dao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FlutterDatabase database;
  TaskDao taskDao;

  setUp(() async {
    database = await $FloorFlutterDatabase.inMemoryDatabaseBuilder().build();
    taskDao = database.taskDao;
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('Tapping save stores task in database', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(FloorApp(taskDao));
      final textFieldFinder = find.byType(TextField);
      final raisedButtonFinder = find.byType(RaisedButton);

      await tester.enterText(textFieldFinder, 'Hello world!');
      await tester.tap(raisedButtonFinder);

      final tasks = await taskDao.findAllTasks();
      expect(tasks, isNotEmpty);
    });
  });

  testWidgets('Tapping save clears text input field', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(FloorApp(taskDao));
      final textFieldFinder = find.byType(TextField);
      final raisedButtonFinder = find.byType(RaisedButton);

      await tester.enterText(textFieldFinder, 'Hello world!');
      await tester.tap(raisedButtonFinder);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();

      final text = tester.widget<TextField>(textFieldFinder).controller.text;
      expect(text, isEmpty);
    });
  });

  testWidgets('Tapping save makes task appear in tasks list', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(FloorApp(taskDao));
      final textFieldFinder = find.byType(TextField);
      final raisedButtonFinder = find.byType(RaisedButton);
      final listViewFinder = find.byType(ListView);
      final textFinder = find.byType(Text);

      await tester.enterText(textFieldFinder, 'Hello world!');
      await tester.tap(raisedButtonFinder);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();

      final text = tester.firstWidget<Text>(
        find.descendant(of: listViewFinder, matching: textFinder),
      );
      expect(text.data, equals('Hello world!'));
    });
  });
}
