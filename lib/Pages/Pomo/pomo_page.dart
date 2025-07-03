import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Pomos/pomo_widget.dart';

import 'Tasks/task_list.dart';

class PomoPage extends StatelessWidget {
  const PomoPage({super.key, required this.pageChanged});

  final bool pageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 700),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            // the Material widget is just here to provide a background to the Pomo widget, since there is a bug with colored list tiles that make the color appear over all widgets that sit above the list view.
            elevation: 10,
            shadowColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Pomo(pageChanged: pageChanged),
            ),
          ),
          // const Divider(),
          Expanded(
              child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(maxWidth: 700),
            child: TaskList(),
          )),
        ],
      ),
    );
  }
}
