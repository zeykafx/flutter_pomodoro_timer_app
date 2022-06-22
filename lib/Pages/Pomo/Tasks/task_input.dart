import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Tasks/task.dart';
import 'package:get_storage/get_storage.dart';

class TaskInput extends StatefulWidget {
  const TaskInput({Key? key, required this.taskListFunction}) : super(key: key);
  final Function(Task) taskListFunction;

  @override
  _TaskInputState createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  TextEditingController textEditingController = TextEditingController();

  // the hint text in the text field is gonna be random on each reload, it adds a nice touch to it imo
  List<String> hintTexts = [
    "Study discrete math",
    "Finish pomodoro app",
    "Clean the apartment",
    "Study history",
    "Meetings",
    "Walk the dog",
    "Finish presentation"
  ];
  Random random = Random();
  late int hintIdx;
  GetStorage box = GetStorage();

  @override
  void initState() {
    hintIdx = random.nextInt(hintTexts.length);
    super.initState();
  }

  Task createTask(String textFieldValue) {
    List<dynamic> tasksJson = box.read("Tasks") ?? [];
    if (kDebugMode) {
      print(tasksJson);
    }

    Task newTask = Task(
        id: tasksJson.isNotEmpty ? tasksJson.last["id"] : 0,
        content: textFieldValue,
        taskType: TaskType.notStarted
    );
    // add the new task to the list in the 'json' format and write that to the box
    tasksJson.add(newTask.toJson());
    box.write("Tasks", tasksJson);

    return newTask;
  }

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: textEditingController,
        onSubmitted: (String value) {
          if (kDebugMode) {
            print(value);
          }
          Task task = createTask(value);
          widget.taskListFunction(task);
        },
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hintTexts[hintIdx],
            labelText: "Enter a task"
        ),
      ),
    );
  }
}
