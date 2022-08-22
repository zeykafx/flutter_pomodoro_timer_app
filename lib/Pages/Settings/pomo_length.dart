import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/settings_controller.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';

class PomoLengthSettings extends StatefulWidget {
  const PomoLengthSettings({Key? key}) : super(key: key);

  @override
  _PomoLengthSettingsState createState() => _PomoLengthSettingsState();
}

class _PomoLengthSettingsState extends State<PomoLengthSettings> {
  SettingsController settingsController = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // work time length
        Card(
          key: const ValueKey("WorkLengthCard"),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(2.0),
                child: Text(
                  "Work time length",
                  style: TextStyle(fontSize: 15),
                ),
              ),
              const Divider(),
              [
                Slider(
                  value: settingsController.defaultMinutes.value.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  label: settingsController.defaultMinutes.value.round().toString(),
                  onChanged: (double nValue) {
                    setState(() {
                      settingsController.defaultMinutes.value = nValue.toInt();
                    });
                  },
                ).expanded()
              ].toRow(mainAxisAlignment: MainAxisAlignment.center),
              Text(
                "Work time lasts ${settingsController.defaultMinutes.value} minutes.",
                style: const TextStyle(
                  fontSize: 15,
                ),
              ).paddingAll(10),
            ],
          ),
        ),

        // short break
        Card(
          key: const ValueKey("ShortBreakLengthCard"),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(2.0),
                child: Text(
                  "Short break length",
                  style: TextStyle(fontSize: 15),
                ),
              ),
              const Divider(),
              [
                Slider(
                  value: settingsController.shortBreakLength.value.toDouble(),
                  min: 1,
                  max: 20,
                  // divisions: 5,
                  label: settingsController.shortBreakLength.value.round().toString(),
                  onChanged: (double nValue) {
                    setState(() {
                      settingsController.shortBreakLength.value = nValue.toInt();
                    });
                  },
                ).expanded()
              ].toRow(mainAxisAlignment: MainAxisAlignment.center),
              Text(
                "Short break lasts ${settingsController.shortBreakLength.value} minutes.",
                style: const TextStyle(
                  fontSize: 15,
                ),
              ).paddingAll(10),
            ],
          ),
        ),

        // long break
        Card(
          key: const ValueKey("LongBreakLengthCard"),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(2.0),
                child: Text(
                  "Long break length",
                  style: TextStyle(fontSize: 15),
                ),
              ),
              const Divider(),
              [
                Slider(
                  value: settingsController.longBreakLength.value.toDouble(),
                  min: 1,
                  max: 20,
                  // divisions: 5,
                  label: settingsController.longBreakLength.value.round().toString(),
                  onChanged: (double nValue) {
                    setState(() {
                      settingsController.longBreakLength.value = nValue.toInt();
                    });
                  },
                ).expanded()
              ].toRow(mainAxisAlignment: MainAxisAlignment.center),
              Text(
                "Long break lasts ${settingsController.longBreakLength.value} minutes.",
                style: const TextStyle(
                  fontSize: 15,
                ),
              ).paddingAll(10),
            ],
          ),
        ),
      ],
    );
  }
}
