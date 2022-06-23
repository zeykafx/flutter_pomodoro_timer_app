import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Pomos/site_blocker.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/settings_controller.dart';
import 'package:get/get.dart';

class StartStopButton extends StatefulWidget {
  const StartStopButton({Key? key, required this.timer, required this.startTimer, required this.updateFormattedTimeLeftString}) : super(key: key);

  final Timer timer;
  final Function startTimer;
  final Function updateFormattedTimeLeftString;

  @override
  _StartStopButtonState createState() => _StartStopButtonState();
}

class _StartStopButtonState extends State<StartStopButton> {
  SiteBlocker siteBlocker = SiteBlocker();
  SettingsController settingsController = Get.put(SettingsController());

  void stopTimer() {
    widget.timer.cancel();
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
            // if the timer is currently running and the button is pressed, then stop the timer and unblock the sites (if enabled by the user on windows)
            if (widget.timer.isActive) {
              stopTimer();
              if (Platform.isWindows && settingsController.blockSite.isTrue) {
                siteBlocker.unblockSites();
              }
            } else {
              // else start the timer and block the sites in the list
              widget.startTimer();
              if (Platform.isWindows && settingsController.blockSite.isTrue) {
                siteBlocker.blockSites(settingsController.sitesToBlock);
              }
            }
            // widget.timer.isActive ? stopTimer() : widget.startTimer();
            widget.updateFormattedTimeLeftString();

          });
        },
        child: widget.timer.isActive ? const Text("Stop") : const Text("Start"));
  }
}
