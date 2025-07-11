import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/timer_controller.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:styled_widget/styled_widget.dart';

import 'task.dart';
import 'task_input.dart';

enum ButtonBarOptions { Add, Clear }

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  // GetStorage box = GetStorage();
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
  Future<void> loadTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    taskList.clear();

    List<dynamic> tasksJson = prefs.getStringList("Tasks") ?? [];
    for (String singleTaskJson in tasksJson) {
      var singleTask = jsonDecode(singleTaskJson);
      Task task = Task(
        id: int.tryParse(singleTask["id"]!) ?? 99,
        content: singleTask["content"]!,
        taskType:
            EnumToString.fromString(TaskType.values, singleTask["taskType"]!)!,
        pomosDone: int.tryParse(singleTask["pomosDone"]!) ?? 0,
        plannedPomos: int.tryParse(singleTask["plannedPomos"]!) ?? 0,
      );
      taskList.add(task);
    }
  }

  /// used as a callback for the text field
  void taskListCallback(Task task) {
    setState(() {
      taskList.add(task);
    });
    Navigator.pop(context);
  }

  Future<void> updateTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> tasksJson = tasksToJson();
    prefs.setStringList("Tasks", tasksJson);
  }

  List<String> tasksToJson() {
    List<String> taskJson = [];
    for (Task task in taskList) {
      taskJson.add(jsonEncode(task.toJson()));
    }
    return taskJson;
  }

  Future<void> clearTaskList(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

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
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // Foreground color
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    // Background color
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                  onPressed: () {
                    setState(() {
                      taskList.clear();
                    });
                    Navigator.of(context).pop();
                    prefs.setStringList("Tasks", []);
                  },
                  child: const Text("OK")),
            ],
          );
        });
  }

  void openModalSheetAddTask(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SizedBox(
            height: 190,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Add a Task',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // ElevatedButton(
                    //   child: const Text('Close BottomSheet'),
                    //   onPressed: () => Navigator.pop(context),
                    // ),
                    TaskInput(taskListFunction: taskListCallback),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void deleteTask(Task task) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete task N°${task.id + 1}?"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
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

    void incrementNumberOfPomos(
        int number, void Function(void Function()) setState) {
      setState(() {
        task.plannedPomos += number;
      });
    }

    void decrementNumberOfPomos(
        int number, void Function(void Function()) setState) {
      if (task.plannedPomos > 0) {
        incrementNumberOfPomos(-number, setState);
      }
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Edit task N°${task.id + 1}"),
            content: StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text("Change N° of sessions:"),
                      [
                        InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          child: const Icon(Icons.arrow_drop_down, size: 40),
                          onTap: () => decrementNumberOfPomos(1, setState),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text("${task.plannedPomos}"),
                        ),
                        InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          child: const Icon(Icons.arrow_drop_up, size: 40),
                          onTap: () => incrementNumberOfPomos(1, setState),
                        ),
                      ].toRow(
                          mainAxisAlignment: MainAxisAlignment.center,
                          separator: const Padding(padding: EdgeInsets.all(1))),
                    ],
                  ),

                  // text field for new content
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                    child: TextField(
                      controller: textEditingController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter new task content",
                        labelText: "Enter new task content",
                      ),
                    ),
                  ),
                ],
              );
            }),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel")),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // Foreground color
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    // Background color
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
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
    // ColorScheme colors = Theme.of(context).colorScheme;

    ButtonBarOptions btn = ButtonBarOptions.Add;

    return Card(
      margin: EdgeInsets.all(8),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(
          8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // TaskInput(taskListFunction: taskListCallback),

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
                            key: UniqueKey(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            contentPadding: EdgeInsets.zero,
                            tileColor: task.taskType == TaskType.inProgress
                                ? Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                : task.taskType == TaskType.done
                                    ? Theme.of(context)
                                        .colorScheme
                                        .secondaryFixedDim
                                        .withValues(alpha: 0.4)
                                    : null,
                            // dense: true,
                            onLongPress: () => deleteTask(task),
                            onTap: () => editTask(task),
                            title: Text(
                              task.content,
                              style: TextStyle(
                                  decoration: task.taskType == TaskType.done
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationThickness: 3,
                                  decorationColor:
                                      Theme.of(context).colorScheme.primary),
                            ),
                            leading:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  if (task.taskType == TaskType.notStarted) {
                                    setState(() {
                                      task.changeType(TaskType.inProgress);
                                    });
                                  } else if (task.taskType ==
                                      TaskType.inProgress) {
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
                                icon: Icon(
                                    task.taskType == TaskType.notStarted
                                        ? FontAwesome5.hourglass_start
                                        : task.taskType == TaskType.inProgress
                                            ? Icons.check
                                            : Icons.restart_alt,
                                    size: 18),
                              ),
                              if (task.plannedPomos > 0)
                                Text("${task.pomosDone}/${task.plannedPomos}"),
                            ]),
                            trailing: PopupMenuButton(
                              elevation: 20,
                              icon: const Icon(Icons.more_vert),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      width: 0.3)),
                              onSelected: (index) {
                                if (index == 0) {
                                  editTask(task);
                                } else if (index == 1) {
                                  deleteTask(task);
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  const PopupMenuItem(
                                      value: 0,
                                      child: Wrap(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Icon(Icons.edit),
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 20),
                                              child: Text("Edit"))
                                        ],
                                      )),
                                  const PopupMenuItem(
                                      value: 1,
                                      child: Wrap(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Icon(Icons.delete),
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 20),
                                              child: Text("Delete"))
                                        ],
                                      )),
                                ];
                              },
                            ),
                          ),
                        );
                      })
                  : const Center(
                      child: Text(
                        "No Tasks",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),

            SegmentedButton<ButtonBarOptions>(
              style: SegmentedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondaryFixed,
                side: BorderSide(width: 0),
              ),
              segments: <ButtonSegment<ButtonBarOptions>>[
                ButtonSegment(
                  value: ButtonBarOptions.Add,
                  label: Text(
                    "Add",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryFixed,
                    ),
                  ),
                ),
                ButtonSegment(
                  value: ButtonBarOptions.Clear,
                  label: Text(
                    "Clear",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryFixed,
                    ),
                  ),
                ),
              ],
              selected: {},
              emptySelectionAllowed: true,
              onSelectionChanged: (Set<ButtonBarOptions> newSelection) {
                HapticFeedback.lightImpact();
                if (newSelection.contains(ButtonBarOptions.Add)) {
                  openModalSheetAddTask(context);
                } else {
                  clearTaskList(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
