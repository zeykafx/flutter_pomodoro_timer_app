import 'package:flutter/material.dart';

class ResetButton extends StatelessWidget {
  const ResetButton({Key? key, required this.resetTimer, required this.defaultMinutes, required this.updateFormattedTimeLeftString}) : super(key: key);

  final Function resetTimer;
  final int defaultMinutes;
  final Function updateFormattedTimeLeftString;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          resetTimer(defaultMinutes);
          updateFormattedTimeLeftString();
        },
        child: const Text("Reset"));
  }
}
