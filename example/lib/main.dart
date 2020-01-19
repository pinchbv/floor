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
  final TextEditingController _textEditingController;

  TasksWidget({
    Key key,
    @required this.title,
    @required this.dao,
  })  : _textEditingController = TextEditingController(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: dao.findAllTasksAsStream(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) return Container();

                final tasks = snapshot.data;

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (_, index) {
                    return ListCell(
                      task: tasks[index],
                      dao: dao,
                    );
                  },
                );
              },
            ),
          ),
          TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              filled: true,
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              hintText: 'Type task here',
            ),
            onSubmitted: (input) async {
              final message = _textEditingController.text;
              final task = Task(null, message);
              await dao.insertTask(task);

              _textEditingController.clear();
            },
          )
        ],
      ),
    );
  }
}

class ListCell extends StatelessWidget {
  const ListCell({
    Key key,
    @required this.task,
    @required this.dao,
  }) : super(key: key);

  final Task task;
  final TaskDao dao;

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
        Scaffold.of(context).showSnackBar(
          SnackBar(content: const Text('Removed task')),
        );
      },
    );
  }
}
