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
    Key? key,
    required this.title,
    required this.dao,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TasksWidgetState();
}

class TasksWidgetState extends State<TasksWidget> {
  TaskStatusFilter _selectedFilter = TaskStatusFilter.all;

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
                TaskStatusFilter.values.length,
                (index) {
                  return PopupMenuItem<int>(
                    value: index,
                    child: Text(
                      index == 0 ? 'All' : _getMenuType(index).label,
                    ),
                  );
                },
              );
            },
            onSelected: (index) {
              setState(() {
                _selectedFilter = _getMenuType(index);
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
              selectedStatus: _selectedFilter,
            ),
            TasksTextField(dao: widget.dao),
          ],
        ),
      ),
    );
  }

  TaskStatusFilter _getMenuType(int index) => TaskStatusFilter.values[index];
}

class TasksListView extends StatelessWidget {
  final TaskDao dao;
  final TaskStatusFilter selectedStatus;

  const TasksListView({
    Key? key,
    required this.dao,
    required this.selectedStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<List<Task>>(
        stream: selectedStatus == TaskStatusFilter.all
            ? dao.findAllTasksAsStream()
            : selectedStatus == TaskStatusFilter.uncategorized
                ? dao.findAllTasksWithoutStatusAsStream()
                : dao.findAllTasksByStatusAsStream(
                    _getTaskStatusFromFilter(selectedStatus)),
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

  TaskStatus _getTaskStatusFromFilter(TaskStatusFilter filter) {
    switch (filter) {
      case TaskStatusFilter.open:
        return TaskStatus.open;
      case TaskStatusFilter.inProgress:
        return TaskStatus.inProgress;
      case TaskStatusFilter.done:
        return TaskStatus.done;
      default:
        return throw 'Invalid filter';
    }
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
            final nextIndex = task.statusIndex == null
                ? 0
                : (tasksLength + task.statusIndex! + 1) % tasksLength;
            final taskCopy =
                task.copyWith(status: TaskStatus.values[nextIndex]);
            await dao.updateTask(taskCopy);
            statusMessage = 'Updated task status by: ${taskCopy.statusTitle}';
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
      final task = Task.optional(
        message: message,
        type: TaskType.task,
        status: null,
      );
      await dao.insertTask(task);
      _textEditingController.clear();
    }
  }
}

enum TaskStatusFilter {
  all('All'),
  uncategorized('Uncategorized'),
  open('Open'),
  inProgress('In Progress'),
  done('Done');

  final String label;

  const TaskStatusFilter(this.label);
}
