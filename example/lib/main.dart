import 'package:example/database.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  final database = await MyDatabase.openDatabase();
  runApp(FloorApp(database));
}

class FloorApp extends StatelessWidget {
  final MyDatabase database;

  const FloorApp(this.database);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floor Demo',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: TasksWidget(
        title: 'Floor Demo',
        database: database,
      ),
    );
  }
}

class TasksWidget extends StatefulWidget {
  final String title;
  final MyDatabase database;
  final TextEditingController textEditingController;

  TasksWidget({
    Key key,
    @required this.title,
    @required this.database,
  })  : textEditingController = TextEditingController(),
        super(key: key);

  @override
  State<StatefulWidget> createState() => TasksWidgetState(database);
}

class TasksWidgetState extends State<TasksWidget> {
  final MyDatabase database;

  List<Task> _tasks = [];

  TasksWidgetState(this.database);

  Future<void> _storeTask() async {
    final message = widget.textEditingController.text;
    final task = Task(null, message);

    await database.insertTask(task);
    _tasks = await database.findAllTasks();

    setState(() {}); // trigger rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (_, index) {
                return Text(_tasks[index].message);
              },
            ),
          ),
          TextField(
            controller: widget.textEditingController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Type task here',
            ),
            onSubmitted: (input) async {
              await _storeTask();
              widget.textEditingController.clear();
            },
          )
        ],
      ),
    );
  }
}
