import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Pomos/pomo.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Pomos/reset_button.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/Pomos/start_stop_button.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/timer_controller.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/settings_controller.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:styled_widget/styled_widget.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class Pomo extends StatefulWidget {
  const Pomo({Key? key, required this.pageChanged}) : super(key: key);

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
  GetStorage box = GetStorage();

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

  void getPreviousPomoLength() {
    int boxLength = box.read("pomoLengthSeconds") ?? Duration(minutes: settingsController.defaultMinutes.value).inSeconds;

    if (boxLength > 0) {
      pomoSession.endTimestamp = DateTime.now().add(Duration(seconds: boxLength)).millisecondsSinceEpoch;
      pomoSession.pomoLengthSeconds = boxLength;
      box.write("pomoLengthSeconds", boxLength);
    } else {
      pomoSession.endTimestamp = DateTime.now().millisecondsSinceEpoch;
      pomoSession.pomoLengthSeconds = 0;
      box.write("pomoLengthSeconds", 0);
      isTimerFinished = true;
    }
  }

  void startTimer() {
    if (!kIsWeb && !Platform.isWindows) {
      flutterLocalNotificationsPlugin.cancelAll();
    }
    pomoSession.start();
    setState(() {
      timer = Timer.periodic(const Duration(milliseconds: 1000), (Timer t) {
        updateFormattedTimeLeftString();
        if (!isTimerFinished) {
          isTimerFinished = isTimerDone();
        }
      });
    });
    if (!kIsWeb && !Platform.isWindows) {
      _showNotificationWithChronometer();
    }
  }

  Future<void> _showNotificationWithChronometer() async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'pomo focus',
      'main',
      channelDescription: 'Pomo focus',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      when: pomoSession.endTimestamp,
      usesChronometer: true,
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Pomo Focus',
      'Timer currently running...',
      platformChannelSpecifics,
    );
  }

  Future<void> showTimerFinishedNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'pomo focus',
      'main',
      channelDescription: 'Pomo focus',
      importance: Importance.max,
      priority: Priority.max,
      usesChronometer: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Pomo Focus',
      'Timer Ended',
      platformChannelSpecifics,
    );
  }

  void resetTimer(int minutes) {
    setState(() {
      pomoSession.resetTimer(minutes);
      box.write("pomoLengthSeconds", pomoSession.pomoLengthSeconds);
      isTimerFinished = false;
      if (!kIsWeb && !Platform.isWindows && timer.isActive) {
        flutterLocalNotificationsPlugin.cancelAll();
        _showNotificationWithChronometer();
      }
    });
  }

  void incrementTimeStamp(int minutes) {
    setState(() {
      pomoSession.incrementTimeStamp(minutes, timer);
      box.write("pomoLengthSeconds", pomoSession.pomoLengthSeconds);
    });
    if (!kIsWeb && !Platform.isWindows) {
      flutterLocalNotificationsPlugin.cancelAll();
      _showNotificationWithChronometer();
    }
  }

  void decrementTimeStamp(int minutes) {
    if (pomoSession.pomoLengthSeconds > 0) {
      incrementTimeStamp(-minutes);
    }
  }

  bool isTimerDone() {
    DateTime timestampDate = pomoSession.getDateTime();
    if (DateTime.now().compareTo(timestampDate) >= 0) {
      player.play(AssetSource("audio/notification_sound.mp3"));
      timer.cancel();
      if (pomoSession.currentPhase == PomoSessionPhase.working) {
        timerController.changeTimerFinished(true);
      }
      
      pomoSession.endTimer();
      if (!kIsWeb && !Platform.isWindows) {
        flutterLocalNotificationsPlugin.cancelAll();
        showTimerFinishedNotification();
      }
      pomoSession.pomoLengthSeconds = 0;
      box.write("pomoLengthSeconds", 0);


      return true;
    } else {
      pomoSession.pomoLengthSeconds = pomoSession.getDateTime().difference(DateTime.now()).inSeconds;
      box.write("pomoLengthSeconds", pomoSession.pomoLengthSeconds);
      return false;
    }
  }

  String updateFormattedTimeLeftString() {
    String timeLeftString = pomoSession.updateFormattedTimeLeftString(timer);
    setState(() {});
    return timeLeftString;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: [
        [
          Text(
            pomoSession.timeLeftString,
            style: const TextStyle(fontSize: 45),
          ),
          [
            IconButton(onPressed: () => incrementTimeStamp(1), icon: const Icon(FontAwesome5.plus, size: 10)),
            IconButton(
                onPressed: () => decrementTimeStamp(1),
                icon: const Icon(
                  FontAwesome5.minus,
                  size: 10,
                )),
          ].toColumn(mainAxisAlignment: MainAxisAlignment.center, separator: const Padding(padding: EdgeInsets.all(0))),
        ].toRow(mainAxisAlignment: MainAxisAlignment.center).padding(left: 35),
        Text(
          phaseToString(pomoSession.currentPhase),
          style: const TextStyle(fontSize: 15),
        ).paddingDirectional(bottom: 10),
        [
          StartStopButton(
              timer: timer,
              startTimer: startTimer,
              updateFormattedTimeLeftString: updateFormattedTimeLeftString,
              resetTimer: resetTimer,
              getTimeLeft: pomoSession.getTimeLeft),
          // .paddingAll(5),
          ResetButton(
            defaultMinutes: settingsController.defaultMinutes.value,
            updateFormattedTimeLeftString: updateFormattedTimeLeftString,
            resetTimer: resetTimer,
          ).paddingAll(5),
        ].toRow(mainAxisAlignment: MainAxisAlignment.center),
      ].toColumn(),
    );
  }
}
