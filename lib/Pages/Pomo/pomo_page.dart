import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/pomo.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Tasks/task_list.dart';

class PomoPage extends StatelessWidget {
  const PomoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Pomo(),
        TaskList(),
      ],
    );
  }
}
