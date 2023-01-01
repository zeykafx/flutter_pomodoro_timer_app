import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Pomos/pomo_widget.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Tasks/task_list.dart';

class PomoPage extends StatelessWidget {
  const PomoPage({Key? key, required this.pageChanged}) : super(key: key);

  final bool pageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 10,
          shadowColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Pomo(pageChanged: pageChanged),
          ),
        ),
        // const Divider(),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(0),
          child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), constraints: const BoxConstraints(maxWidth: 700), child: TaskList()),
        )),
      ],
    );
  }
}
