import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  int pomoLengthSeconds = 0;

  int endTimestamp = 0;
  String timeLeftString = "";
  late Timer timer;
  bool isTimerFinished = false;

  TimerController timerController = Get.put(TimerController());

  final AudioPlayer player = AudioPlayer();
  GetStorage box = GetStorage();

  @override
  void initState() {
    super.initState();

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
      endTimestamp = DateTime.now().add(Duration(seconds: boxLength)).millisecondsSinceEpoch;
      pomoLengthSeconds = boxLength;
      box.write("pomoLengthSeconds", boxLength);
    } else {
      endTimestamp = DateTime.now().millisecondsSinceEpoch;
      pomoLengthSeconds = 0;
      box.write("pomoLengthSeconds", 0);
      isTimerFinished = true;
    }
  }

  void startTimer() {
    if (!kIsWeb && !Platform.isWindows) {
      flutterLocalNotificationsPlugin.cancelAll();
    }
    setState(() {
      endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: pomoLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;
      timerController.changeTimerFinished(false);
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
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'pomo focus',
      'main',
      channelDescription: 'Pomo focus',
      importance: Importance.min,
      priority: Priority.min,
      when: endTimestamp,
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
      endTimestamp = DateTime.now().add(Duration(minutes: minutes)).millisecondsSinceEpoch;
      pomoLengthSeconds = Duration(minutes: minutes).inSeconds;
      box.write("pomoLengthSeconds", pomoLengthSeconds);
      isTimerFinished = false;
      timerController.changeTimerFinished(false);
      if (!kIsWeb && !Platform.isWindows) {
        flutterLocalNotificationsPlugin.cancelAll();
        _showNotificationWithChronometer();
      }

    });
  }

  void incrementTimeStamp(int minutes) {
    setState(() {
      pomoLengthSeconds += Duration(minutes: minutes).inSeconds;
      box.write("pomoLengthSeconds", pomoLengthSeconds);
      endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: pomoLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;
    });
    updateFormattedTimeLeftString();
    if (!kIsWeb && !Platform.isWindows) {
      flutterLocalNotificationsPlugin.cancelAll();
      _showNotificationWithChronometer();
    }

  }

  void decrementTimeStamp(int minutes) {
    if (pomoLengthSeconds > 0) {
      incrementTimeStamp(-minutes);
    }
  }

  DateTime getDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(endTimestamp);
  }

  bool isTimerDone() {
    DateTime timestampDate = getDateTime();
    if (DateTime.now().compareTo(timestampDate) >= 0) {
      player.play(AssetSource("audio/notification_sound.mp3"));
      timer.cancel();
      if (!kIsWeb && !Platform.isWindows) {
        flutterLocalNotificationsPlugin.cancelAll();
        showTimerFinishedNotification();
      }
      pomoLengthSeconds = 0;
      box.write("pomoLengthSeconds", 0);
      timerController.changeTimerFinished(true);

      return true;
    } else {
      pomoLengthSeconds = getDateTime().difference(DateTime.now()).inSeconds;
      box.write("pomoLengthSeconds", pomoLengthSeconds);
      return false;
    }
  }

  Duration getTimeLeft() {
    return getDateTime().difference(DateTime.now());
  }

  String updateFormattedTimeLeftString() {
    Duration timeLeft = getTimeLeft();
    if (timeLeft.inSeconds >= 0) {
      setState(() {
        timeLeftString = timeLeft.toString().substring(0, 7);
      });
    } else {
      setState(() {
        timer.cancel();
        // timerController.changeTimerFinished(true);
        // isTimerDone();
      });
    }
    return timeLeftString;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: [
        [
          Text(
            timeLeftString,
            style: const TextStyle(fontSize: 45),
          ),
          [
            IconButton(
                onPressed: () => incrementTimeStamp(1),
                icon: const Icon(
                    FontAwesome5.plus,
                    size: 10
                )),
            IconButton(
                onPressed: () => decrementTimeStamp(1),
                icon: const Icon(
                  FontAwesome5.minus,
                  size: 10,
                )),
          ].toColumn(
              mainAxisAlignment: MainAxisAlignment.center,
              separator: const Padding(padding: EdgeInsets.all(0))
          ),
        ].toRow(
            mainAxisAlignment: MainAxisAlignment.center
        ).padding(all: 10, left: 25),
        [
          StartStopButton(
              timer: timer,
              startTimer: startTimer,
              updateFormattedTimeLeftString: updateFormattedTimeLeftString,
              resetTimer: resetTimer,
              getTimeLeft: getTimeLeft
          ).paddingAll(5),
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
