import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Pomos/site_blocker.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/settings_controller.dart';
import 'package:get/get.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class StartStopButton extends StatefulWidget {
  const StartStopButton(
      {Key? key,
      required this.timer,
      required this.startTimer,
      required this.updateFormattedTimeLeftString,
      required this.resetTimer,
      required this.getTimeLeft})
      : super(key: key);

  final Timer timer;
  final Function startTimer;
  final void Function(int) resetTimer;
  final Duration Function() getTimeLeft;
  final Function updateFormattedTimeLeftString;

  @override
  _StartStopButtonState createState() => _StartStopButtonState();
}

class _StartStopButtonState extends State<StartStopButton> {
  SiteBlocker siteBlocker = SiteBlocker();
  SettingsController settingsController = Get.put(SettingsController());

  void stopTimer() {
    widget.timer.cancel();
    if (!kIsWeb && !Platform.isWindows) {
      flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colors = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: widget.timer.isActive ? "Stop Timer" : "Start Timer",
      onPressed: () {
        setState(() {
          // if the timer is currently running and the button is pressed, then stop the timer and unblock the sites (if enabled by the user on windows)
          if (widget.timer.isActive) {
            stopTimer();
            if (!kIsWeb) {
              if (Platform.isWindows && settingsController.blockSite.isTrue) {
                siteBlocker.unblockSites();
              }
            }
          } else {
            if (widget.getTimeLeft().inMinutes == 0) {
              widget.resetTimer(settingsController.defaultMinutes.value);
            }

            // else start the timer and block the sites in the list
            widget.startTimer();
            if (!kIsWeb) {
              if (Platform.isWindows && settingsController.blockSite.isTrue) {
                siteBlocker.blockSites(settingsController.sitesToBlock);
              }
            }
          }
          widget.updateFormattedTimeLeftString();
        });
      },
      icon: widget.timer.isActive ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
      // label: widget.timer.isActive ? const Text("Stop") : const Text("Start")
    );
  }
}
