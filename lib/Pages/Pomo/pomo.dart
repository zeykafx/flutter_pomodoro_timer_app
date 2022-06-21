import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/reset_button.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/start_stop_button.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';

class Pomo extends StatefulWidget {
  const Pomo({Key? key}) : super(key: key);

  @override
  State<Pomo> createState() => _PomoState();
}

class _PomoState extends State<Pomo> {
  int endTimestamp = 0;
  String timeLeftString = "";
  late Timer timer;
  bool isTimerFinished = false;

  int defaultMinutes = 45;

  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    startTimer(0);
    resetTimer(defaultMinutes);
  }

  void startTimer(int stoppedTimeStamp) {
    setState(() {
      if (stoppedTimeStamp != 0) {
        endTimestamp = getDateTime().add(DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(stoppedTimeStamp))).millisecondsSinceEpoch;
      }
      timer = Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
        updateFormattedTimeLeftString();
        if (!isTimerFinished) {
          isTimerFinished = isTimerDone();
        }
      });
    });
  }

  void resetTimer(int minutes) {
    setState(() {
      endTimestamp = DateTime.now().add(Duration(minutes: minutes)).millisecondsSinceEpoch;
    });
  }

  void incrementTimeStamp(int minutes) {
    setState(() {
      endTimestamp = getDateTime().add(Duration(minutes: minutes)).millisecondsSinceEpoch;
    });
    updateFormattedTimeLeftString();
  }

  void decrementTimeStamp(int minutes) {
    incrementTimeStamp(-minutes);
  }

  DateTime getDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(endTimestamp);
  }

  bool isTimerDone() {
    DateTime timestampDate = getDateTime();
    if (DateTime.now().compareTo(timestampDate) >= 0) {
      player.play(AssetSource("audio/notification_sound.mp3"));
      timer.cancel();
      return true;
    } else {
      return false;
    }
  }

  Duration getTimeLeft() {
    return getDateTime().difference(DateTime.now());
  }

  String updateFormattedTimeLeftString() {
    Duration timeLeft = getTimeLeft();
    setState(() {
      timeLeftString = timeLeft.toString().substring(0, 7);
    });
    return timeLeftString;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: [
        [
          Text(
            timeLeftString,
            style: const TextStyle(fontSize: 40),
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
        ].toRow(mainAxisAlignment: MainAxisAlignment.center).padding(all: 10),
        [
          StartStopButton(
              timer: timer,
              startTimer: startTimer,
              updateFormattedTimeLeftString: updateFormattedTimeLeftString
          ).paddingAll(5),

          ResetButton(
            defaultMinutes: defaultMinutes,
            updateFormattedTimeLeftString: updateFormattedTimeLeftString,
            resetTimer: resetTimer,
          ).paddingAll(5),

        ].toRow(
          mainAxisAlignment: MainAxisAlignment.center
        ),
      ].toColumn(),
    );
  }
}
