import 'package:flutter/material.dart';

class ResetButton extends StatelessWidget {
  const ResetButton(
      {Key? key,
      required this.resetTimer,
      required this.defaultMinutes,
      required this.updateFormattedTimeLeftString})
      : super(key: key);

  final Function resetTimer;
  final int defaultMinutes;
  final Function updateFormattedTimeLeftString;

  @override
  Widget build(BuildContext context) {
    ColorScheme colors = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: "Reset Timer",
      icon: const Icon(Icons.restart_alt, size: 20),
      onPressed: () {
        resetTimer(defaultMinutes);
        updateFormattedTimeLeftString();
      },
    );
  }
}
