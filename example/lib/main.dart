import 'package:example/database.dart';
import 'package:example/task.dart';
import 'package:example/task_dao.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await $FloorFlutterDatabase
      .databaseBuilder('flutter_database.db')
      .build();
  final dao = database.taskDao;

  runApp(FloorApp(dao));
}

class FloorApp extends StatelessWidget {
  final TaskDao dao;

  const FloorApp(this.dao);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floor Demo',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: TasksWidget(
        title: 'Floor Demo',
        dao: dao,
      ),
    );
  }
}

class TasksWidget extends StatelessWidget {
  final String title;
  final TaskDao dao;

  const TasksWidget({
    Key key,
    @required this.title,
    @required this.dao,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TasksListView(dao: dao),
            TasksTextField(dao: dao),
          ],
        ),
      ),
    );
  }
}

class TasksListView extends StatelessWidget {
  final TaskDao dao;

  const TasksListView({
    Key key,
    @required this.dao,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<List<Task>>(
        stream: dao.findAllTasksAsStream(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return Container();

          final tasks = snapshot.data;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (_, index) {
              return TaskListCell(
                task: tasks[index],
                dao: dao,
              );
            },
          );
        },
      ),
    );
  }
}

class TaskListCell extends StatelessWidget {
  final Task task;
  final TaskDao dao;

  const TaskListCell({
    Key key,
    @required this.task,
    @required this.dao,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('${task.hashCode}'),
      background: Container(color: Colors.red),
      direction: DismissDirection.endToStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        child: Text(task.message),
      ),
      onDismissed: (_) async {
        await dao.deleteTask(task);

        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(
          const SnackBar(content: Text('Removed task')),
        );
      },
    );
  }
}

class TasksTextField extends StatelessWidget {
  final TextEditingController _textEditingController;
  final TaskDao dao;

  TasksTextField({
    Key key,
    @required this.dao,
  })  : _textEditingController = TextEditingController(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textEditingController,
              decoration: const InputDecoration(
                fillColor: Colors.transparent,
                filled: true,
                contentPadding: EdgeInsets.all(16),
                border: InputBorder.none,
                hintText: 'Type task here',
              ),
              onSubmitted: (_) async {
                await _persistMessage();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: OutlineButton(
              textColor: Colors.blueGrey,
              child: const Text('Save'),
              onPressed: () async {
                await _persistMessage();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _persistMessage() async {
    final message = _textEditingController.text;
    if (message.trim().isEmpty) {
      _textEditingController.clear();
    } else {
      final task = Task(null, message);
      await dao.insertTask(task);
      _textEditingController.clear();
    }
  }
}
