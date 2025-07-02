import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResetButton extends StatelessWidget {
  const ResetButton(
      {super.key,
      required this.resetTimer,
      required this.defaultMinutes,
      required this.updateFormattedTimeLeftString});

  final Function resetTimer;
  final int defaultMinutes;
  final Function updateFormattedTimeLeftString;

  @override
  Widget build(BuildContext context) {
    ColorScheme colors = Theme.of(context).colorScheme;

    return IconButton.filledTonal(
      tooltip: "Reset Timer",
      icon: const Icon(Icons.restart_alt_rounded, size: 30),
      onPressed: () {
        HapticFeedback.mediumImpact();
        resetTimer(defaultMinutes);
        updateFormattedTimeLeftString();
      },
    );
  }
}
