import 'package:example/database.dart';
import 'package:example/task.dart';
import 'package:example/task_dao.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  final database = await FlutterDatabase.openDatabase();
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
  final TextEditingController textEditingController;

  TasksWidget({
    Key key,
    @required this.title,
    @required this.dao,
  })  : textEditingController = TextEditingController(),
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
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final tasks = snapshot.data;

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (_, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Text(tasks[index].message),
                      );
                    },
                  );
                }
              },
            ),
          ),
          TextField(
            controller: textEditingController,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: InputBorder.none,
              hintText: 'Type task here',
            ),
            onSubmitted: (input) async {
              final message = textEditingController.text;
              final task = Task(null, message);
              await dao.insertTask(task);

              textEditingController.clear();
            },
          )
        ],
      ),
    );
  }
}
