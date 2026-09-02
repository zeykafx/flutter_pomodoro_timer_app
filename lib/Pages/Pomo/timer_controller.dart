import 'package:flutter/foundation.dart';

class TimerController extends ChangeNotifier {
  TimerController._();

  static final TimerController instance = TimerController._();

  bool _timerFinished = false;

  bool get timerFinished => _timerFinished;

  void changeTimerFinished(bool boolean) {
    if (_timerFinished == boolean) return;
    _timerFinished = boolean;
    notifyListeners();
  }
}
