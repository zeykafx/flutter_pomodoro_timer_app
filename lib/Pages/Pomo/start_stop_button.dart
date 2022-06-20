import 'dart:async';

import 'package:flutter/material.dart';

class StartStopButton extends StatefulWidget {
  const StartStopButton({Key? key, required this.timer, required this.startTimer, required this.updateFormattedTimeLeftString}) : super(key: key);

  final Timer timer;
  final Function startTimer;
  final Function updateFormattedTimeLeftString;

  @override
  _StartStopButtonState createState() => _StartStopButtonState();
}

class _StartStopButtonState extends State<StartStopButton> {
  DateTime? stopTimeStamp;

  void stopTimer() {
    widget.timer.cancel();
    stopTimeStamp = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          // Foreground color
          onPrimary: Theme.of(context).colorScheme.onPrimary,
          // Background color
          primary: Theme.of(context).colorScheme.primary,
        ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
        onPressed: () {
          setState(() {
            widget.timer.isActive ? stopTimer() : widget.startTimer(stopTimeStamp?.millisecondsSinceEpoch);
            widget.updateFormattedTimeLeftString();
          });
        },
        child: widget.timer.isActive ? const Text("Stop") : const Text("Start"));
  }
}
