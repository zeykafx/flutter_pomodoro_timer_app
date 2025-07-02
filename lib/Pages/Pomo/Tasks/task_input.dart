import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Tasks/task.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:styled_widget/styled_widget.dart';

class TaskInput extends StatefulWidget {
  const TaskInput({super.key, required this.taskListFunction});
  final Function(Task) taskListFunction;

  @override
  _TaskInputState createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  TextEditingController textEditingController = TextEditingController();

  // the hint text in the text field is gonna be random on each reload, it adds a nice touch to it imo
  List<String> hintTexts = [
    "Study discrete math",
    "Clean the apartment",
    "Study history",
    "Meetings",
    "Walk the dog",
    "Finish presentation",
    "Do the dishes",
    "Do the laundry",
    "Go to the gym",
    "Go to the supermarket",
    "Daily meeting",
  ];
  Random random = Random();
  late int hintIdx;
  // GetStorage box = GetStorage();
  int numberOfPomos = 0;

  int columnWidth = 500;

  @override
  void initState() {
    hintIdx = random.nextInt(hintTexts.length);
    super.initState();
  }

  Future<Task> createTask(String textFieldValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasksString = prefs.getStringList("Tasks") ?? [];
    int lastId = 0;
    if (tasksString.isNotEmpty) {
      var lastTaskJson = jsonDecode(tasksString.last);
      lastId = int.tryParse(lastTaskJson["id"]) ?? 0 + 1;
    }

    Task newTask = Task(
      id: lastId,
      content: textFieldValue,
      taskType: TaskType.notStarted,
      plannedPomos: numberOfPomos,
      pomosDone: 0,
    );

    // add the new task to the list in the 'json' format and write that to the box
    tasksString.add(jsonEncode(newTask.toJson()));
    prefs.setStringList("Tasks", tasksString);

    setState(() {
      numberOfPomos = 0;
    });

    return newTask;
  }

  void incrementNumberOfPomos(int number) {
    setState(() {
      numberOfPomos += number;
    });
  }

  void decrementNumberOfPomos(int number) {
    if (numberOfPomos > 0) {
      incrementNumberOfPomos(-number);
    }
  }

  Widget wrapInExpanded(Widget widgetToWrap, double width) {
    if (width < columnWidth) {
      return widgetToWrap;
    } else {
      return Expanded(child: widgetToWrap);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Size mediaQuerySize = MediaQuery.of(context).size;
    ColorScheme colors = Theme.of(context).colorScheme;

    return Flex(
      direction: Axis.horizontal,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: TextField(
              controller: textEditingController,
              onTap: () {
                setState(() {
                  hintIdx = random.nextInt(hintTexts.length);
                });
              },
              onSubmitted: (String value) async {
                if (value.isNotEmpty) {
                  Task task = await createTask(value);
                  widget.taskListFunction(task);
                  textEditingController.clear();
                  FocusScope.of(context).unfocus();
                }
              },
              decoration: InputDecoration(
                // prefixIcon: const Icon(Icons.add),
                border: const OutlineInputBorder(),
                hintText: hintTexts[hintIdx],
                labelText: "Enter a task and the n° of sessions",
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Column(
                  children: [
                    // const Text("Sessions"),
                    [
                      InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        child: const Icon(Icons.arrow_drop_up, size: 35),
                        onTap: () => incrementNumberOfPomos(1),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: Text("$numberOfPomos"),
                      ),
                      InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        child: const Icon(Icons.arrow_drop_down, size: 35),
                        onTap: () => decrementNumberOfPomos(1),
                      ),
                    ].toColumn(
                        mainAxisAlignment: MainAxisAlignment.center,
                        separator: const Padding(padding: EdgeInsets.all(0))),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: "Add task",
                style: IconButton.styleFrom(
                  foregroundColor: colors.onSecondaryContainer,
                  backgroundColor: colors.secondaryContainer,
                  disabledBackgroundColor:
                      colors.onSurface.withValues(alpha: (0.12)),
                  hoverColor:
                      colors.onSecondaryContainer.withValues(alpha: (0.08)),
                  focusColor:
                      colors.onSecondaryContainer.withValues(alpha: (0.12)),
                  highlightColor:
                      colors.onSecondaryContainer.withValues(alpha: (0.12)),
                ),
                onPressed: () async {
                  if (textEditingController.text.isNotEmpty) {
                    Task task = await createTask(textEditingController.text);
                    widget.taskListFunction(task);
                    textEditingController.clear();
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
