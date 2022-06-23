import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Pomos/pomo.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Tasks/task_list.dart';

class PomoPage extends StatelessWidget {
  const PomoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Pomo(),
        ),
        Divider(),
        Expanded(child: Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: TaskList(),
        )),
      ],
    );
  }
}
