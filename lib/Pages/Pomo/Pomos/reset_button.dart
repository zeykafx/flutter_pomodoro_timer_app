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
      // style: IconButton.styleFrom(
      //   foregroundColor: colors.onPrimary,
      //   backgroundColor: colors.primary,
      //   disabledBackgroundColor: colors.onSurface.withOpacity(0.12),
      //   hoverColor: colors.onPrimary.withOpacity(0.08),
      //   focusColor: colors.onPrimary.withOpacity(0.12),
      //   highlightColor: colors.onPrimary.withOpacity(0.12),
      // ),
      tooltip: "Reset Timer",
      icon: const Icon(Icons.restart_alt),
      onPressed: () {
        resetTimer(defaultMinutes);
        updateFormattedTimeLeftString();
      },
      // child: const Text("Reset")
    );
  }
}
