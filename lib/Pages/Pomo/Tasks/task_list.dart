import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'task.dart';
import 'task_input.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  GetStorage box = GetStorage();
  List<Task> taskList = [];

  @override
  void initState() {
    loadTasks();
    super.initState();
  }

  /// loads the saved tasks and parses them
  void loadTasks() {
    taskList.clear();

    List<dynamic> tasksJson = box.read("Tasks") ?? [];
    for (Map<String, dynamic> singleTask in tasksJson) {
      Task task = Task(
          id: singleTask["id"],
          content: singleTask["content"],
          taskType: EnumToString.fromString(TaskType.values, singleTask["taskType"])!
      );
      taskList.add(task);
    }
  }

  /// used as a callback for the text field
  void taskListCallback(Task task) {
    setState(() {
      taskList.add(task);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TaskInput(taskListFunction: taskListCallback),
        Expanded(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: taskList.length,
              itemBuilder: (BuildContext context, int index) {
                Task task = taskList[index];
            return ListTile(
              title: Text(
                  task.content,
                  style: TextStyle(
                      decoration: task.taskType == TaskType.done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none),
              ),
              trailing: Checkbox(
                value: task.taskType == TaskType.done,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (bool? value) {
                  if (value!) {
                    setState(() {
                      task.taskType = TaskType.done;
                    });
                  } else {
                    setState(() {
                      task.taskType = TaskType.inProgress;
                    });
                  }
                },
              ),
            );
          }),
        )
      ],
    );
  }
}
