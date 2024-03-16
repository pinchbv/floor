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

  const FloorApp(this.dao, {super.key});

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
    super.key,
    required this.title,
    required this.dao,
  });

  @override
  State<StatefulWidget> createState() => TasksWidgetState();
}

class TasksWidgetState extends State<TasksWidget> {
  TaskStatus? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: Align(
          alignment: Alignment.center,
          child: StreamBuilder(
              stream: widget.dao.findUniqueMessagesCountAsStream(),
              builder: (_, snapshot) => Text('count: ${snapshot.data ?? 0}')),
        ),
        actions: <Widget>[
          PopupMenuButton<int>(
            itemBuilder: (context) {
              return List.generate(
                TaskStatus.values.length +
                    1, //Uses increment to handle All types
                (index) {
                  return PopupMenuItem<int>(
                    value: index,
                    child: Text(
                      index == 0 ? 'All' : _getMenuType(index).title,
                    ),
                  );
                },
              );
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

  TaskStatus _getMenuType(int index) => TaskStatus.values[index - 1];
}

class TasksListView extends StatelessWidget {
  final TaskDao dao;
  final TaskStatus? selectedType;

  const TasksListView({
    super.key,
    required this.dao,
    required this.selectedType,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<List<Task>>(
        stream: selectedType == null
            ? dao.findAllTasksAsStream()
            : dao.findAllTasksByStatusAsStream(selectedType!),
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
    super.key,
    required this.task,
    required this.dao,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('${task.hashCode}'),
      background: Container(
        padding: const EdgeInsets.only(left: 16),
        color: Colors.green,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Change status',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      secondaryBackground: Container(
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      direction: DismissDirection.horizontal,
      child: ListTile(
        title: Text(task.message),
        subtitle: Text('Status: ${task.statusTitle}'),
        trailing: Text(task.timestamp.toIso8601String()),
      ),
      confirmDismiss: (direction) async {
        String? statusMessage;
        switch (direction) {
          case DismissDirection.endToStart:
            await dao.deleteTask(task);
            statusMessage = 'Removed task';
            break;
          case DismissDirection.startToEnd:
            final tasksLength = TaskStatus.values.length;
            final nextIndex =
                (tasksLength + task.statusIndex + 1) % tasksLength;
            final taskCopy =
                task.copyWith(status: TaskStatus.values[nextIndex]);
            await dao.updateTask(taskCopy);
            statusMessage = 'Updated task status by: ${taskCopy.statusTitle}';
            break;
          default:
            break;
        }

        if (statusMessage != null && context.mounted) {
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
    super.key,
    required this.dao,
  }) : _textEditingController = TextEditingController();

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
      final task = Task.optional(message: message, type: TaskType.task);
      await dao.insertTask(task);
      _textEditingController.clear();
    }
  }
}
