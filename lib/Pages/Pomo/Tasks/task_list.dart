import 'package:flutter/material.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // things to do here:
        // text field to enter tasks
        // listview builder to create the task list
        // with each task being a card with the id, content, and a check box.
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: textEditingController,
            onSubmitted: (String value) {
              // todo, create a task from this
              print(value);
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Study discrete math...",
              labelText: "Enter a task"
            ),
          ),
        ),
      ],
    );
  }
}
