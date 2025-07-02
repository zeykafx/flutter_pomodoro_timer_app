import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Pomos/pomo.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Pomos/reset_button.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Pomos/start_stop_button.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/timer_controller.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/settings_controller.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class Pomo extends StatefulWidget {
  const Pomo({super.key, required this.pageChanged});

  final bool pageChanged;

  @override
  State<Pomo> createState() => _PomoState();
}

class _PomoState extends State<Pomo> {
  SettingsController settingsController = Get.put(SettingsController());

  late Timer timer;
  bool isTimerFinished = false;

  TimerController timerController = Get.put(TimerController());

  final AudioPlayer player = AudioPlayer();

  late PomoSession pomoSession;

  @override
  void initState() {
    super.initState();

    pomoSession = PomoSession(
        remainingSessions: 0,
        workLengthSeconds: settingsController.defaultMinutes.value * 60,
        shortBreaksLeftBeforeLong: 3,
        endTimestamp: 0,
        timeLeftString: "",
        currentPhase: PomoSessionPhase.stopped,
        shortBreakLengthSeconds: settingsController.shortBreakLength.value * 60,
        longBreakLengthSeconds: settingsController.longBreakLength.value * 60,
        shortBreaksDone: 0,
        pomoLengthSeconds: 0);

    getPreviousPomoLength();

    isTimerFinished = false;
    startTimer();
    updateFormattedTimeLeftString();
    if (widget.pageChanged == false) {
      timer.cancel();
      if (!kIsWeb && !Platform.isWindows) {
        flutterLocalNotificationsPlugin.cancelAll();
      }
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> getPreviousPomoLength() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int boxLength = prefs.getInt("pomoLengthSeconds") ??
        Duration(minutes: settingsController.defaultMinutes.value).inSeconds;

    if (boxLength > 0) {
      pomoSession.endTimestamp = DateTime.now()
          .add(Duration(seconds: boxLength))
          .millisecondsSinceEpoch;
      pomoSession.pomoLengthSeconds = boxLength;
      prefs.setInt("pomoLengthSeconds", boxLength);
    } else {
      pomoSession.endTimestamp = DateTime.now().millisecondsSinceEpoch;
      pomoSession.pomoLengthSeconds = 0;
      prefs.setInt("pomoLengthSeconds", 0);
      isTimerFinished = true;
    }
  }

  void startTimer() {
    if (!kIsWeb && !Platform.isWindows) {
      flutterLocalNotificationsPlugin.cancelAll();
    }

    if (isTimerFinished && widget.pageChanged == true) {
      resetTimer(pomoSession.currentPhase == PomoSessionPhase.working
          ? settingsController.defaultMinutes.value
          : pomoSession.currentPhase == PomoSessionPhase.shortBreak
              ? settingsController.shortBreakLength.value
              : settingsController.longBreakLength.value);
    }

    setState(() {
      pomoSession.start();
      timer =
          Timer.periodic(const Duration(milliseconds: 1000), (Timer t) async {
        updateFormattedTimeLeftString();
        // print("Timer is running, isTimerFinished: $isTimerFinished, time left: ${pomoSession.getDateTime().difference(DateTime.now())}");
        // if (!isTimerFinished) {
        _showNotificationWithChronometer();
        isTimerFinished = await isTimerDone();
        // }
      });
    });

    if (!kIsWeb &&
        !Platform.isWindows &&
        settingsController.enableNotifications.value) {
      _showNotificationWithChronometer();
    }
  }

  Future<void> _showNotificationWithChronometer() async {
    if (!settingsController.enableNotifications.value) {
      return;
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pomo focus',
      'main',
      channelDescription: 'Pomo Focus',
      subText: "Session running: ${phaseToString(pomoSession.currentPhase)}",
      importance: Importance.max,
      priority: Priority.max,
      onlyAlertOnce: true,
      when: pomoSession.endTimestamp,
      usesChronometer: true,
      chronometerCountDown: true,
      enableVibration: false,
      playSound: false,
      showProgress: true,
      ongoing: true,
      progress: (pomoSession.sessionProgress * 100).toInt(),
      maxProgress: 100,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Pomo Focus',
      'Pomodoro Session running',
      platformChannelSpecifics,
    );
  }

  Future<void> showTimerFinishedNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pomo focus',
      'main',
      channelDescription: 'Pomo Focus',
      importance: Importance.max,
      priority: Priority.max,
      usesChronometer: false,
      onlyAlertOnce: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Pomo Focus',
      'Timer Ended',
      platformChannelSpecifics,
    );
  }

  Future<void> resetTimer(int minutes) async {
    pomoSession.resetTimer(minutes);
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setInt("pomoLengthSeconds", pomoSession.pomoLengthSeconds);
      isTimerFinished = false;
      if (!kIsWeb && !Platform.isWindows && timer.isActive) {
        flutterLocalNotificationsPlugin.cancelAll();
        _showNotificationWithChronometer();
      }
    });
  }

  Future<void> incrementTimeStamp(int minutes) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      pomoSession.incrementTimeStamp(minutes, timer);
      prefs.setInt("pomoLengthSeconds", pomoSession.pomoLengthSeconds);
    });
    if (!kIsWeb && !Platform.isWindows) {
      flutterLocalNotificationsPlugin.cancelAll();
      _showNotificationWithChronometer();
    }
  }

  void decrementTimeStamp(int minutes) {
    if (pomoSession.pomoLengthSeconds > 0 ||
        pomoSession.shortBreakLengthSeconds > 0 ||
        pomoSession.longBreakLengthSeconds > 0) {
      incrementTimeStamp(-minutes);
    }
  }

  Future<bool> isTimerDone() async {
    DateTime timestampDate = pomoSession.getDateTime();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // print(DateTime.now().compareTo(timestampDate));
    if (DateTime.now().compareTo(timestampDate) >= 0) {
      player.play(AssetSource("audio/notification_sound.mp3"));

      if (pomoSession.currentPhase == PomoSessionPhase.working) {
        timerController.changeTimerFinished(true);
      }

      pomoSession.endTimer();
      updateFormattedTimeLeftString();

      if (!settingsController.autoContinue.value) {
        timer.cancel();
      }
      if (!kIsWeb &&
          !Platform.isWindows &&
          settingsController.enableNotifications.value) {
        flutterLocalNotificationsPlugin.cancelAll();
        showTimerFinishedNotification();
      }
      // pomoSession.pomoLengthSeconds = 0;
      // box.write("pomoLengthSeconds", 0);
      // pomoSession.shortBreakLengthSeconds = 0;
      // pomoSession.longBreakLengthSeconds = 0;

      return true;
    } else {
      if (pomoSession.currentPhase == PomoSessionPhase.working) {
        pomoSession.pomoLengthSeconds =
            pomoSession.getDateTime().difference(DateTime.now()).inSeconds;
        prefs.setInt("pomoLengthSeconds", pomoSession.pomoLengthSeconds);
      } else if (pomoSession.currentPhase == PomoSessionPhase.shortBreak) {
        pomoSession.shortBreakLengthSeconds =
            pomoSession.getDateTime().difference(DateTime.now()).inSeconds;
      } else if (pomoSession.currentPhase == PomoSessionPhase.longBreak) {
        pomoSession.longBreakLengthSeconds =
            pomoSession.getDateTime().difference(DateTime.now()).inSeconds;
      }
      return false;
    }
  }

  String updateFormattedTimeLeftString() {
    String timeLeftString = pomoSession.updateFormattedTimeLeftString(timer);

    setState(() {});
    return timeLeftString;
  }

  int columnWidth = 500;

  @override
  Widget build(BuildContext context) {
    // Size mediaQuerySize = MediaQuery.of(context).size;

    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: pomoSession.sessionProgress,
                    strokeWidth: 16,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainer,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pomoSession.timeLeftString,
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      label: Text(
                        phaseToString(pomoSession.currentPhase),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      elevation: 0,
                      side:
                          const BorderSide(width: 0, color: Colors.transparent),
                      padding: const EdgeInsets.all(0),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                      // visualDensity: VisualDensity.compact,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(width: 0, color: Colors.transparent),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ResetButton(
                  defaultMinutes: pomoSession.currentPhase ==
                          PomoSessionPhase.working
                      ? settingsController.defaultMinutes.value
                      : pomoSession.currentPhase == PomoSessionPhase.shortBreak
                          ? settingsController.shortBreakLength.value
                          : settingsController.longBreakLength.value,
                  updateFormattedTimeLeftString: updateFormattedTimeLeftString,
                  resetTimer: resetTimer,
                ),
                StartStopButton(
                  timer: timer,
                  startTimer: startTimer,
                  updateFormattedTimeLeftString: updateFormattedTimeLeftString,
                  defaultMinutes: pomoSession.currentPhase ==
                          PomoSessionPhase.working
                      ? settingsController.defaultMinutes.value
                      : pomoSession.currentPhase == PomoSessionPhase.shortBreak
                          ? settingsController.shortBreakLength.value
                          : settingsController.longBreakLength.value,
                  resetTimer: resetTimer,
                  getTimeLeft: pomoSession.getTimeLeft,
                ),
                IconButton.filledTonal(
                  tooltip: "Skip to next phase",
                  icon: const Icon(Icons.skip_next_rounded, size: 30),
                  onPressed: () {
                    HapticFeedback.mediumImpact();

                    pomoSession.endTimer();
                    // resetTimer(defaultMinutes);
                    updateFormattedTimeLeftString();

                    if (timer.isActive &&
                        !settingsController.autoContinue.value) {
                      timer.cancel();
                      if (!kIsWeb && !Platform.isWindows) {
                        flutterLocalNotificationsPlugin.cancelAll();
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // return Center(
    //   child: [
    //     [
    //       Text(
    //         pomoSession.timeLeftString,
    //         style: TextStyle(
    //             fontSize: mediaQuerySize.width < columnWidth ? 35 : 45),
    //       ),
    //       [
    //         // reset and start/stop button
    //         [
    //           ResetButton(
    //             defaultMinutes: pomoSession.currentPhase ==
    //                     PomoSessionPhase.working
    //                 ? settingsController.defaultMinutes.value
    //                 : pomoSession.currentPhase == PomoSessionPhase.shortBreak
    //                     ? settingsController.shortBreakLength.value
    //                     : settingsController.longBreakLength.value,
    //             updateFormattedTimeLeftString: updateFormattedTimeLeftString,
    //             resetTimer: resetTimer,
    //           ).paddingDirectional(vertical: 5),
    //           StartStopButton(
    //             timer: timer,
    //             startTimer: startTimer,
    //             updateFormattedTimeLeftString: updateFormattedTimeLeftString,
    //             defaultMinutes: pomoSession.currentPhase ==
    //                     PomoSessionPhase.working
    //                 ? settingsController.defaultMinutes.value
    //                 : pomoSession.currentPhase == PomoSessionPhase.shortBreak
    //                     ? settingsController.shortBreakLength.value
    //                     : settingsController.longBreakLength.value,
    //             resetTimer: resetTimer,
    //             getTimeLeft: pomoSession.getTimeLeft,
    //           ).paddingSymmetric(vertical: 0),
    //         ].toColumn(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             crossAxisAlignment: CrossAxisAlignment.center),
    //
    //         // up and down buttons
    //         Visibility(
    //           visible: timer.isActive,
    //           maintainSize: true,
    //           maintainAnimation: true,
    //           maintainState: true,
    //           child: [
    //             IconButton(
    //                     onPressed: () => incrementTimeStamp(1),
    //                     icon: const Icon(FontAwesome5.plus, size: 15))
    //                 .paddingDirectional(vertical: 5),
    //             IconButton(
    //               onPressed: () => decrementTimeStamp(1),
    //               icon: const Icon(
    //                 FontAwesome5.minus,
    //                 size: 15,
    //               ),
    //             ),
    //           ].toColumn(),
    //         ),
    //       ].toRow(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           separator: const Padding(padding: EdgeInsets.all(0))),
    //     ].toRow(mainAxisAlignment: MainAxisAlignment.center).padding(left: 90),
    //     Text(
    //       phaseToString(pomoSession.currentPhase),
    //       style: const TextStyle(fontSize: 15),
    //     ).paddingDirectional(bottom: 10),
    //   ].toColumn(),
    // );
  }
}
