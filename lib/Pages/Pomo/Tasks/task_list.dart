import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
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

  void updateTasks() {
    List tasksJson = tasksToJson();
    box.write("Tasks", tasksJson);
  }

  List<dynamic> tasksToJson() {
    List<dynamic> taskJson = [];
    for (Task task in taskList) {
      taskJson.add(task.toJson());
    }
    return taskJson;
  }

  void clearTaskList(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Clear task list?"),
            content: const Text("Do you really want to clear the task list?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () {
                    setState(() {
                      taskList.clear();
                    });
                    Navigator.of(context).pop();
                    box.write("Tasks", []);
                  },
                  child: const Text("OK")),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ROW: Clear tasks button and Input field
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton(
                  onPressed: () => clearTaskList(context),
                  icon: const Icon(
                    FontAwesome5.trash,
                    size: 20,
                  )),
            ),
            Expanded(child: TaskInput(taskListFunction: taskListCallback)),
          ],
        ),
        // list view
        Expanded(
          child: taskList.isNotEmpty ? ListView.builder(
              shrinkWrap: true,
              itemCount: taskList.length,
              itemBuilder: (BuildContext context, int index) {
                Task task = taskList[index];
                return ListTile(
                  title: Text(
                    task.content,
                    style: TextStyle(
                        decoration: task.taskType == TaskType.done ? TextDecoration.lineThrough : TextDecoration.none,
                        decorationThickness: 3,
                        decorationColor: Theme.of(context).colorScheme.primary
                    ),
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
                      updateTasks();
                    },
                  ),
                );
              }) : const Center(child: Text("No tasks"),),
        )
      ],
    );
  }
}
