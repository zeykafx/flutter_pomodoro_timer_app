import 'dart:async';

import 'package:flutter_pomodoro_timer_app/Pages/Pomo/timer_controller.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/settings_controller.dart';
import 'package:get/get.dart';

enum PomoSessionPhase {
  /// The session ended.
  stopped,

  /// The session is currently in a work period.
  working,

  /// The session is currently in a short break.
  shortBreak,

  /// The session is currently in a long break.
  longBreak,
}

String phaseToString(PomoSessionPhase phase) {
  switch (phase) {
    case PomoSessionPhase.stopped:
      return "Timer stopped";
    case PomoSessionPhase.working:
      return "Work time";
    case PomoSessionPhase.shortBreak:
      return "Short Break";
    case PomoSessionPhase.longBreak:
      return "Long Break";
  }
}

class PomoSession {
  int remainingSessions = 0;
  int workLengthSeconds = 25 * 60;
  int shortBreakLengthSeconds = 5 * 60;
  int longBreakLengthSeconds = 10 * 60;
  int shortBreaksLeftBeforeLong = 3;

  PomoSessionPhase currentPhase = PomoSessionPhase.stopped;
  int endTimestamp;
  int pomoLengthSeconds;
  String timeLeftString = "";
  int shortBreaksDone = 0;

  PomoSession({
    required this.remainingSessions,
    required this.workLengthSeconds,
    required this.shortBreakLengthSeconds,
    required this.longBreakLengthSeconds,
    required this.shortBreaksLeftBeforeLong,
    required this.endTimestamp,
    required this.pomoLengthSeconds,
    required this.timeLeftString,
    required this.currentPhase,
    required this.shortBreaksDone
  });

  SettingsController settingsController = Get.put(SettingsController());
  TimerController timerController = Get.put(TimerController());

  void start() {
    if (currentPhase == PomoSessionPhase.stopped) {
      currentPhase = PomoSessionPhase.working;
    }
    if (currentPhase == PomoSessionPhase.working) {
      endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: pomoLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;
    } else if (currentPhase == PomoSessionPhase.shortBreak) {
      endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: shortBreakLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;
    } else if (currentPhase == PomoSessionPhase.longBreak) {
      endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: longBreakLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;
    }
    timerController.changeTimerFinished(false);

  }

  void endTimer() {
    // prepping for the next session
    switch (currentPhase) {
      case PomoSessionPhase.stopped:
        break;
      case PomoSessionPhase.longBreak:
        currentPhase = PomoSessionPhase.working;
        break;
      case PomoSessionPhase.shortBreak:
        shortBreaksDone++;
        currentPhase = PomoSessionPhase.working;
        break;
      case PomoSessionPhase.working:
        remainingSessions--;
        if (shortBreaksDone == shortBreaksLeftBeforeLong) {
          currentPhase = PomoSessionPhase.longBreak;
        } else {
          currentPhase = PomoSessionPhase.shortBreak;
        }
        break;
    }
  }

  void resetTimer(int minutes) {
      endTimestamp = DateTime.now().add(Duration(minutes: minutes)).millisecondsSinceEpoch;
      pomoLengthSeconds = Duration(minutes: minutes).inSeconds;
      timerController.changeTimerFinished(false);
  }

  void incrementTimeStamp(int minutes, Timer timer) {
    pomoLengthSeconds += Duration(minutes: minutes).inSeconds;
    endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: pomoLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;
    updateFormattedTimeLeftString(timer);
  }


  DateTime getDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(endTimestamp);
  }

  Duration getTimeLeft() {
    return getDateTime().difference(DateTime.now());
  }

  String updateFormattedTimeLeftString(Timer timer) {
    Duration timeLeft = getTimeLeft();
    if (timeLeft.inSeconds >= 0) {
        timeLeftString = timeLeft.toString().substring(0, 7);
    } else {
        // timer.cancel(); // cancel the timer since the pomo is done
    }
    return timeLeftString;
  }



}
