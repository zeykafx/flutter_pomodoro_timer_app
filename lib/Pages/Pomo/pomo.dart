import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/reset_button.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/start_stop_button.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:styled_widget/styled_widget.dart';

class Pomo extends StatefulWidget {
  const Pomo({Key? key}) : super(key: key);

  @override
  State<Pomo> createState() => _PomoState();
}

class _PomoState extends State<Pomo> {
  int defaultMinutes = 45;

  int pomoLengthSeconds = 0;

  int endTimestamp = 0;
  String timeLeftString = "";
  late Timer timer;
  bool isTimerFinished = false;

  final AudioPlayer player = AudioPlayer();
  GetStorage box = GetStorage();

  @override
  void initState() {
    super.initState();

    getPreviousPomoLength();
    startTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void getPreviousPomoLength() {
    int boxLength = box.read("pomoLengthSeconds") ?? Duration(minutes: defaultMinutes).inSeconds;
    if (kDebugMode) {
      print(boxLength);
    }
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
    setState(() {
      endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: pomoLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;
      timer = Timer.periodic(const Duration(milliseconds: 300), (Timer t) {
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
      pomoLengthSeconds = Duration(minutes: minutes).inSeconds;
      box.write("pomoLengthSeconds", pomoLengthSeconds);
      isTimerFinished = false;
    });
  }

  void incrementTimeStamp(int minutes) {
    setState(() {
      pomoLengthSeconds += Duration(minutes: minutes).inSeconds;
      box.write("pomoLengthSeconds", pomoLengthSeconds);
      endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: pomoLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;
    });
    updateFormattedTimeLeftString();
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
      pomoLengthSeconds = 0;
      box.write("pomoLengthSeconds", 0);
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
            style: const TextStyle(fontSize: 40),
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
        ).padding(all: 10),
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
        ].toRow(mainAxisAlignment: MainAxisAlignment.center),
      ].toColumn(),
    );
  }
}
