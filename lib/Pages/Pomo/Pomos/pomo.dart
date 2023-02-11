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

  PomoSession(
      {required this.remainingSessions,
      required this.workLengthSeconds,
      required this.shortBreakLengthSeconds,
      required this.longBreakLengthSeconds,
      required this.shortBreaksLeftBeforeLong,
      required this.endTimestamp,
      required this.pomoLengthSeconds,
      required this.timeLeftString,
      required this.currentPhase,
      required this.shortBreaksDone}) {
    pomoLengthSeconds = settingsController.defaultMinutes.value * 60;
    shortBreakLengthSeconds = settingsController.shortBreakLength.value * 60;
    longBreakLengthSeconds = settingsController.longBreakLength.value * 60;
  }

  SettingsController settingsController = Get.put(SettingsController());
  TimerController timerController = Get.put(TimerController());

  void start() {
    if (currentPhase == PomoSessionPhase.stopped || currentPhase == PomoSessionPhase.working) {
      endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: pomoLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;
      currentPhase = PomoSessionPhase.working;
    } else if (currentPhase == PomoSessionPhase.shortBreak) {
      endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: shortBreakLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;
    } else if (currentPhase == PomoSessionPhase.longBreak) {
      endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: longBreakLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;
    }

    timerController.changeTimerFinished(false);
  }

  void endTimer() {
    // if (remainingSessions == 0) {
    //   remainingSessions = 3; // for now just reset it to 3 TODO: add setting for this
    // }

    // prepping for the next session
    switch (currentPhase) {
      case PomoSessionPhase.stopped:
        break;

      case PomoSessionPhase.longBreak:
        currentPhase = PomoSessionPhase.working;
        endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: pomoLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;
        break;

      case PomoSessionPhase.shortBreak:
        shortBreaksDone++;
        currentPhase = PomoSessionPhase.working;
        endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: pomoLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;

        break;

      case PomoSessionPhase.working:
        remainingSessions--;
        if (shortBreaksDone == shortBreaksLeftBeforeLong) {
          currentPhase = PomoSessionPhase.longBreak;
          endTimestamp =
              getDateTime().add(DateTime.now().add(Duration(seconds: longBreakLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;

          shortBreaksDone = 0;
        } else {
          currentPhase = PomoSessionPhase.shortBreak;
          endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: shortBreakLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;
        }
        break;
    }
  }

  void resetTimer(int minutes) {
    start();
    endTimestamp = DateTime.now().add(Duration(minutes: minutes)).millisecondsSinceEpoch;
    if (currentPhase == PomoSessionPhase.working) {
      pomoLengthSeconds = Duration(minutes: minutes).inSeconds;
    } else if (currentPhase == PomoSessionPhase.shortBreak) {
      shortBreakLengthSeconds = Duration(minutes: minutes).inSeconds;
    } else if (currentPhase == PomoSessionPhase.longBreak) {
      longBreakLengthSeconds = Duration(minutes: minutes).inSeconds;
    }
    timerController.changeTimerFinished(false);
  }

  void incrementTimeStamp(int minutes, Timer timer) {
    if (currentPhase == PomoSessionPhase.working) {
      pomoLengthSeconds += Duration(minutes: minutes).inSeconds;
      endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: pomoLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;
    } else if (currentPhase == PomoSessionPhase.shortBreak) {
      shortBreakLengthSeconds += Duration(minutes: minutes).inSeconds;
      endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: shortBreakLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;
    } else if (currentPhase == PomoSessionPhase.longBreak) {
      longBreakLengthSeconds += Duration(minutes: minutes).inSeconds;
      endTimestamp = getDateTime().add(DateTime.now().add(Duration(seconds: longBreakLengthSeconds)).difference(getDateTime())).millisecondsSinceEpoch;
    }
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

    if (timeLeft.inSeconds.abs() >= 0) {
      timeLeftString = timeLeft.toString().substring(0, 7);
    } else {
      // 0:00:00
      timeLeftString = DateTime.now().difference(DateTime.now()).toString().substring(0, 7);
      // timer.cancel(); // cancel the timer since the pomo is done
    }
    return timeLeftString;
  }
}
