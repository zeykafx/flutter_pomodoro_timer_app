import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/timer_controller.dart';
import 'package:flutter_pomodoro_timer_app/main.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:styled_widget/styled_widget.dart';

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
  TimerController timerController = Get.put(TimerController());
  TextEditingController textEditingController = TextEditingController();


  @override
  void initState() {
    loadTasks();
    timerController.timerFinished.listen((bool newVal) {
      if (newVal) {
        for (Task task in taskList) {
          if (task.taskType == TaskType.inProgress) {

            if (mounted) {
              setState(() {
                task.pomosDone++;
              });
            }
            // if (task.pomosDone == task.plannedPomos) {
            //   task.changeType(TaskType.done);
            // }

          }
        }
        timerController.changeTimerFinished(false);
        updateTasks();
      }

    });
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
          taskType: EnumToString.fromString(TaskType.values, singleTask["taskType"])!,
          pomosDone: singleTask["pomosDone"],
          plannedPomos: singleTask["plannedPomos"]);
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

  void deleteTask(Task task) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete task N°${task.id}?"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Do you really want to delete this task?"),
                Text("\"${task.content}\"")
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () {
                    setState(() {
                      taskList.remove(task);
                    });
                    Navigator.of(context).pop();
                   updateTasks();
                  },
                  child: const Text("OK")),
            ],
          );
        });
  }

  void editTask(Task task) {
    textEditingController.text = task.content;

    void incrementNumberOfPomos(int number, void Function(void Function()) setState) {
      setState(() {
        task.plannedPomos += number;
      });
    }

    void decrementNumberOfPomos(int number, void Function(void Function()) setState) {
      if (task.plannedPomos > 0) {
        incrementNumberOfPomos(-number, setState);
      }
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Edit task N°${task.id}?"),
            content: StatefulBuilder(
              builder: (BuildContext context, void Function(void Function())setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text("New number of planned pomos:"),
                    [
                      InkWell(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        child: const Icon(Icons.arrow_drop_down),
                        onTap: () => decrementNumberOfPomos(1, setState),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text("${task.plannedPomos}"),
                      ),
                      InkWell(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        child: const Icon(Icons.arrow_drop_up),
                        onTap: () => incrementNumberOfPomos(1, setState),
                      ),
                    ].toRow(
                        mainAxisAlignment: MainAxisAlignment.center,
                        separator: const Padding(padding: EdgeInsets.all(0))
                    ),
                    // text field for new content
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: textEditingController,
                        // onSubmitted: (String value) {
                          // if (value.isNotEmpty) {
                          //   setState(() {
                          //     task.content = value;
                          //     taskList[taskList.indexOf(task)] = task;
                          //   });
                          //   // textEditingController.clear();
                          //   // FocusScope.of(context).unfocus();
                          //   // Navigator.of(context).pop();
                          //   updateTasks();
                          // }
                        // },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter new task content",
                          labelText: "Enter new task content",
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () {
                    setState(() {
                      task.content = textEditingController.text;
                      taskList[taskList.indexOf(task)] = task;
                    });
                    updateTasks();
                    Navigator.of(context).pop();
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
        TaskInput(taskListFunction: taskListCallback),

        // list view
        Expanded(
          child: taskList.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: taskList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Task task = taskList[index];
                    return GestureDetector(
                      onSecondaryTap: () => deleteTask(task),
                      child: ListTile(
                        tileColor: task.taskType == TaskType.inProgress ? Theme.of(context).colorScheme.onSecondary : null,
                        dense: true,
                        onLongPress: () => deleteTask(task),
                        onTap: () => editTask(task),
                        title: Text(
                          task.content,
                          style: TextStyle(
                              decoration: task.taskType == TaskType.done ? TextDecoration.lineThrough : TextDecoration.none,
                              decorationThickness: 3,
                              decorationColor: Theme.of(context).colorScheme.primary),
                        ),
                        leading: task.plannedPomos > 0 ? Text("${task.pomosDone}/${task.plannedPomos}") : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                                onPressed: () {
                                  if (task.taskType == TaskType.notStarted) {
                                    setState(() {
                                      task.changeType(TaskType.inProgress);
                                    });
                                  } else if (task.taskType == TaskType.inProgress) {
                                    setState(() {
                                      task.changeType(TaskType.done);
                                    });
                                  } else {
                                    setState(() {
                                      task.changeType(TaskType.notStarted);
                                    });
                                  }

                                  updateTasks();
                                },
                                icon: Icon(task.taskType == TaskType.notStarted ? FontAwesome5.hourglass_start : task.taskType == TaskType.inProgress ? Icons.check : Icons.restart_alt, size: 15),
                                label: Text(task.taskType == TaskType.notStarted ? "Start" : task.taskType == TaskType.inProgress ? "Done" : "Restart")),
                          ],
                        ),
                      ),
                    );
                  })
              : const Center(
                  child: Text("No tasks"),
                ),
        ),

        if (taskList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
                label: const Text("Clear"),
                onPressed: () => clearTaskList(context),
                icon: const Icon(
                  FontAwesome5.trash,
                  size: 20,
                )),
          ),
      ],
    );
  }
}
