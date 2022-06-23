import 'package:get/get.dart';

class TimerController extends GetxController {
  RxBool timerFinished = false.obs;

  void changeTimerFinished(bool boolean) {
    timerFinished.value = boolean;
  }
}