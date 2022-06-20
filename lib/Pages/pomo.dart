import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';

class PomoController extends GetxController {
  RxInt endTimestamp = 0.obs;
  RxString timeLeftString = "".obs;

  void changeTimestamp(int newTimeStamp) {
    endTimestamp.value = newTimeStamp;
  }

  void incrementTimeStamp(int minutes) {
    changeTimestamp(getDateTime().add(Duration(minutes: minutes)).millisecondsSinceEpoch);
  }

  void decrementTimeStamp(int minutes) {
    incrementTimeStamp(-minutes);
  }

  DateTime getDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(endTimestamp.value);
  }

  bool isTimerDone() {
    DateTime timestampDate = getDateTime();
    if (DateTime.now().compareTo(timestampDate) >= 0) {
      // its time
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
    timeLeftString.value = timeLeft.toString().substring(0, 7);
    return timeLeftString.value;
  }
}

class Pomo extends StatelessWidget {
  const Pomo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PomoController pomoController = Get.put(PomoController());

    Timer timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      pomoController.updateFormattedTimeLeftString();
    });

    return Obx(
      () => Center(
        child: [
          [
            Text(
              "${pomoController.timeLeftString}",
              style: const TextStyle(fontSize: 40),
            ),
            [
              IconButton(onPressed: () => pomoController.incrementTimeStamp(1), icon: const Icon(FontAwesome5.plus, size: 10)),
              IconButton(
                  onPressed: () => pomoController.decrementTimeStamp(1),
                  icon: const Icon(
                    FontAwesome5.minus,
                    size: 10,
                  )),
            ].toColumn(mainAxisAlignment: MainAxisAlignment.center, separator: const Padding(padding: EdgeInsets.all(0))),
          ].toRow(mainAxisAlignment: MainAxisAlignment.center).padding(all: 10),
          ElevatedButton(
              onPressed: () {
                pomoController.changeTimestamp(DateTime.now().add(const Duration(minutes: 40)).millisecondsSinceEpoch);
              },
              child: const Text("Reset")).paddingAll(5),
          ElevatedButton(
              onPressed: () {
                timer.cancel();
              },
              child: const Text("Stop")).paddingAll(5),
        ].toColumn(),
      ),
    );
  }
}
