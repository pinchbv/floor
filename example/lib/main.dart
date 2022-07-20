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

class TasksWidget extends StatefulWidget {
  final String title;
  final TaskDao dao;

  const TasksWidget({
    Key? key,
    required this.title,
    required this.dao,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TasksWidgetState();
}

class TasksWidgetState extends State<TasksWidget> {
  TaskType? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<int>(
            itemBuilder: (context) {
              return List.generate(4, (index) {
                return PopupMenuItem<int>(
                  value: index,
                  child: Text(
                    index == 0 ? 'All' : _getMenuType(index).title,
                  ),
                );
              });
            },
            onSelected: (index) {
              setState(() {
                _selectedType = index == 0 ? null : _getMenuType(index);
              });
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TasksListView(
              dao: widget.dao,
              selectedType: _selectedType,
            ),
            TasksTextField(dao: widget.dao),
          ],
        ),
      ),
    );
  }

  TaskType _getMenuType(int index) => TaskType.values[index - 1];
}

class TasksListView extends StatelessWidget {
  final TaskDao dao;
  final TaskType? selectedType;

  const TasksListView({
    Key? key,
    required this.dao,
    required this.selectedType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<List<Task>>(
        stream: selectedType == null
            ? dao.findAllTasksAsStream()
            : dao.findAllTasksByTypeAsStream(selectedType!),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return Container();

          final tasks = snapshot.requireData;

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
    Key? key,
    required this.task,
    required this.dao,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('${task.hashCode}'),
      background: Container(
        padding: const EdgeInsets.only(left: 16),
        color: Colors.green,
        child: const Align(
          child: Text(
            'Change status',
            style: TextStyle(color: Colors.white),
          ),
          alignment: Alignment.centerLeft,
        ),
      ),
      secondaryBackground: Container(
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Align(
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.white),
          ),
          alignment: Alignment.centerRight,
        ),
      ),
      direction: DismissDirection.horizontal,
      child: ListTile(
        title: Text(task.message),
        trailing: Text(task.timestamp.toIso8601String()),
        subtitle: Text('Status: ${task.type.title}'),
      ),
      confirmDismiss: (direction) async {
        String? statusMessage;
        switch (direction) {
          case DismissDirection.endToStart:
            await dao.deleteTask(task);
            statusMessage = 'Removed task';
            break;
          case DismissDirection.startToEnd:
            final tasksLength = TaskType.values.length;
            final nextIndex = (tasksLength + task.type.index + 1) % tasksLength;
            final taskCopy = task.copy(type: TaskType.values[nextIndex]);
            await dao.updateTask(taskCopy);
            statusMessage = 'Updated task status by: ${taskCopy.type.title}';
            break;
          default:
            break;
        }

        if (statusMessage != null) {
          final scaffoldMessengerState = ScaffoldMessenger.of(context);
          scaffoldMessengerState.hideCurrentSnackBar();
          scaffoldMessengerState.showSnackBar(
            SnackBar(content: Text(statusMessage)),
          );
        }
        return statusMessage != null;
      },
    );
  }
}

class TasksTextField extends StatelessWidget {
  final TextEditingController _textEditingController;
  final TaskDao dao;

  TasksTextField({
    Key? key,
    required this.dao,
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
            child: OutlinedButton(
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
      final task = Task(null, false, message, DateTime.now(), TaskType.open);
      await dao.insertTask(task);
      _textEditingController.clear();
    }
  }
}
