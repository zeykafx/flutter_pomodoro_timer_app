import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Pomos/site_blocker.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/settings_controller.dart';
import 'package:get/get.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class StartStopButton extends StatefulWidget {
  const StartStopButton(
      {super.key,
      required this.timer,
      required this.startTimer,
      required this.updateFormattedTimeLeftString,
      required this.resetTimer,
      required this.defaultMinutes,
      required this.getTimeLeft});

  final Timer timer;
  final Function startTimer;
  final void Function(int) resetTimer;
  final int defaultMinutes;
  final Duration Function() getTimeLeft;
  final Function updateFormattedTimeLeftString;

  @override
  _StartStopButtonState createState() => _StartStopButtonState();
}

class _StartStopButtonState extends State<StartStopButton> {
  SiteBlocker siteBlocker = SiteBlocker();
  SettingsController settingsController = Get.put(SettingsController());

  static const double iconSize = 40;

  void stopTimer() {
    widget.timer.cancel();
    if (!kIsWeb && !Platform.isWindows) {
      flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ColorScheme colors = Theme.of(context).colorScheme;
    return IconButton.filled(
      tooltip: widget.timer.isActive ? "Stop Timer" : "Start Timer",
      onPressed: () {
        HapticFeedback.mediumImpact();

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
            if (widget.getTimeLeft().inMinutes.abs() == 0) {
              widget.resetTimer(widget.defaultMinutes);
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
      icon: widget.timer.isActive
          ? const Icon(Icons.pause_rounded, size: iconSize)
          : const Icon(Icons.play_arrow_rounded, size: iconSize),
      // label: widget.timer.isActive ? const Text("Stop") : const Text("Start")
    );
  }
}
