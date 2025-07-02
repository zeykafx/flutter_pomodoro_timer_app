import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/settings_controller.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';

class PomoLengthSettings extends StatefulWidget {
  const PomoLengthSettings({super.key});

  @override
  State<PomoLengthSettings> createState() => _PomoLengthSettingsState();
}

class _PomoLengthSettingsState extends State<PomoLengthSettings> {
  SettingsController settingsController = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          // work time length
          Card(
            elevation: 0,
            key: const ValueKey("WorkLengthCard"),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                  child: Text(
                    "Work time length",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // const Divider(),
                [
                  Slider(
                    value: settingsController.defaultMinutes.value.toDouble(),
                    min: 5,
                    max: 60,
                    divisions: 11,
                    label: settingsController.defaultMinutes.value
                        .round()
                        .toString(),
                    onChanged: (double nValue) {
                      // setState(() {
                      settingsController.defaultMinutes.value = nValue.toInt();
                      // });
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

          const SizedBox(height: 10),

          // short break
          Card(
            elevation: 0,
            key: const ValueKey("ShortBreakLengthCard"),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                  child: Text(
                    "Short break length",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // const Divider(),
                [
                  Slider(
                    value: settingsController.shortBreakLength.value.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 21,
                    label: settingsController.shortBreakLength.value
                        .round()
                        .toString(),
                    onChanged: (double nValue) {
                      // setState(() {
                      settingsController.shortBreakLength.value =
                          nValue.toInt();
                      // });
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

          const SizedBox(height: 10),

          // long break
          Card(
            elevation: 0,
            key: const ValueKey("LongBreakLengthCard"),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                  child: Text(
                    "Long break length",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // const Divider(),
                [
                  Slider(
                    value: settingsController.longBreakLength.value.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 31,
                    label: settingsController.longBreakLength.value
                        .round()
                        .toString(),
                    onChanged: (double nValue) {
                      // setState(() {
                      settingsController.longBreakLength.value = nValue.toInt();
                      // });
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

          const SizedBox(height: 10),

          // EnableNotifications
          Card(
            elevation: 0,
            key: const ValueKey("EnableNotificationsCard"),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                  child: Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  title: Text("Ongoing Timer Notification"),
                  trailing: Switch(
                    value: settingsController.enableNotifications.value,
                    onChanged: (val) {},
                  ),
                  onTap: () {
                    settingsController.enableNotifications.toggle();
                  },
                ),
              ],
            ),
          ),

          // AutoContinue
          Card(
            elevation: 0,
            key: const ValueKey("AutoContinueCard"),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                  child: Text(
                    "Auto-Continue",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  title: Text("Auto-Continue Timers"),
                  trailing: Switch(
                    value: settingsController.autoContinue.value,
                    onChanged: (val) {},
                  ),
                  onTap: () {
                    settingsController.autoContinue.toggle();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
