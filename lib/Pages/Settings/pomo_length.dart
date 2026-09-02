import 'package:material_ui/material_ui.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/settings_controller.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/settings_section.dart';

class PomoLengthSettings extends StatefulWidget {
  const PomoLengthSettings({super.key});

  @override
  State<PomoLengthSettings> createState() => _PomoLengthSettingsState();
}

class _PomoLengthSettingsState extends State<PomoLengthSettings> {
  SettingsController settingsController = SettingsController.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (context, _) => SettingsSection(
        title: "Pomodoro settings",
        children: [
          // work time length
          ListTile(
            title: const Text("Work time length"),
            subtitle: SizedBox(
              width: 150,
              child: Row(
                children: [
                  Text("${settingsController.defaultMinutes} min"),
                  Expanded(
                    child: Slider(
                      year2023: false, // todo: to fix (somehow)
                      label: settingsController.defaultMinutes.toString(),
                      value: settingsController.defaultMinutes.toDouble(),
                      min: 5,
                      max: 60,
                      divisions: 11,
                      onChanged: (newVal) {
                        settingsController.defaultMinutes = newVal.toInt();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Card(
          //   elevation: 0,
          //   key: const ValueKey("WorkLengthCard"),
          //   child: Column(
          //     children: [
          //       const Padding(
          //         padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          //         child: Text(
          //           "Work time length",
          //           style: TextStyle(
          //             fontSize: 15,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ),
          //       // const Divider(),
          //       [
          //         Slider(
          //           value: settingsController.defaultMinutes.toDouble(),
          //           min: 5,
          //           max: 60,
          //           divisions: 11,
          //           label: settingsController.defaultMinutes.round().toString(),
          //           onChanged: (double nValue) {
          //             // setState(() {
          //             settingsController.defaultMinutes = nValue.toInt();
          //             // });
          //           },
          //         ).expanded()
          //       ].toRow(mainAxisAlignment: MainAxisAlignment.center),
          //       Text(
          //         "Work time lasts ${settingsController.defaultMinutes} minutes.",
          //         style: const TextStyle(
          //           fontSize: 15,
          //         ),
          //       ).paddingAll(10),
          //     ],
          //   ),
          // ),

          // const SizedBox(height: 10),
          // short break
          ListTile(
            title: const Text("Short break length"),
            subtitle: SizedBox(
              width: 150,
              child: Row(
                children: [
                  Text("${settingsController.shortBreakLength} min"),
                  Expanded(
                    child: Slider(
                      year2023: false, // todo: to fix (somehow)
                      label: settingsController.shortBreakLength.toString(),
                      value: settingsController.shortBreakLength.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 21,
                      onChanged: (newVal) {
                        settingsController.shortBreakLength = newVal.toInt();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Card(
          //   elevation: 0,
          //   key: const ValueKey("ShortBreakLengthCard"),
          //   child: Column(
          //     children: [
          //       const Padding(
          //         padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          //         child: Text(
          //           "Short break length",
          //           style: TextStyle(
          //             fontSize: 15,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ),
          //       // const Divider(),
          //       [
          //         Slider(
          //           value: settingsController.shortBreakLength.toDouble(),
          //           min: 1,
          //           max: 20,
          //           divisions: 21,
          //           label: settingsController.shortBreakLength.round().toString(),
          //           onChanged: (double nValue) {
          //             // setState(() {
          //             settingsController.shortBreakLength = nValue.toInt();
          //             // });
          //           },
          //         ).expanded()
          //       ].toRow(mainAxisAlignment: MainAxisAlignment.center),
          //       Text(
          //         "Short break lasts ${settingsController.shortBreakLength} minutes.",
          //         style: const TextStyle(
          //           fontSize: 15,
          //         ),
          //       ).paddingAll(10),
          //     ],
          //   ),
          // ),

          // const SizedBox(height: 10),

          // long break
          ListTile(
            title: const Text("Long break length"),
            subtitle: SizedBox(
              width: 150,
              child: Row(
                children: [
                  Text("${settingsController.longBreakLength} min"),
                  Expanded(
                    child: Slider(
                      year2023: false, // todo: to fix (somehow)
                      label: settingsController.longBreakLength.toString(),
                      value: settingsController.longBreakLength.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 31,
                      onChanged: (newVal) {
                        settingsController.longBreakLength = newVal.toInt();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Card(
          //   elevation: 0,
          //   key: const ValueKey("LongBreakLengthCard"),
          //   child: Column(
          //     children: [
          //       const Padding(
          //         padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          //         child: Text(
          //           "Long break length",
          //           style: TextStyle(
          //             fontSize: 15,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ),
          //       // const Divider(),
          //       [
          //         Slider(
          //           value: settingsController.longBreakLength.toDouble(),
          //           min: 1,
          //           max: 30,
          //           divisions: 31,
          //           label: settingsController.longBreakLength.round().toString(),
          //           onChanged: (double nValue) {
          //             // setState(() {
          //             settingsController.longBreakLength = nValue.toInt();
          //             // });
          //           },
          //         ).expanded()
          //       ].toRow(mainAxisAlignment: MainAxisAlignment.center),
          //       Text(
          //         "Long break lasts ${settingsController.longBreakLength} minutes.",
          //         style: const TextStyle(
          //           fontSize: 15,
          //         ),
          //       ).paddingAll(10),
          //     ],
          //   ),
          // ),

          // const SizedBox(height: 10),

          // EnableNotifications
          ListTile(
            title: const Text("Enable Ongoing Timer Notification"),
            onTap: () {
              settingsController.enableNotifications = !settingsController.enableNotifications;
            },
            trailing: Switch(
              value: settingsController.enableNotifications,
              onChanged: (value) {
                settingsController.enableNotifications = !settingsController.enableNotifications;
              },
            ),
          ),
          // Card(
          //   elevation: 0,
          //   key: const ValueKey("EnableNotificationsCard"),
          //   child: Column(
          //     children: [
          //       const Padding(
          //         padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          //         child: Text(
          //           "Notifications",
          //           style: TextStyle(
          //             fontSize: 15,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ),
          //       ListTile(
          //         title: Text("Ongoing Timer Notification"),
          //         trailing: Switch(
          //           value: settingsController.enableNotifications,
          //           onChanged: (val) {
          //             settingsController.enableNotifications = !settingsController.enableNotifications;
          //           },
          //         ),
          //         onTap: () {
          //           settingsController.enableNotifications = !settingsController.enableNotifications;
          //         },
          //       ),
          //     ],
          //   ),
          // ),

          // AutoContinue
          ListTile(
            title: const Text("Auto-Continue Timers"),
            onTap: () {
              settingsController.autoContinue = !settingsController.autoContinue;
            },
            trailing: Switch(
              value: settingsController.autoContinue,
              onChanged: (value) {
                settingsController.autoContinue = !settingsController.autoContinue;
              },
            ),
          ),
          // Card(
          //   elevation: 0,
          //   key: const ValueKey("AutoContinueCard"),
          //   child: Column(
          //     children: [
          //       const Padding(
          //         padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          //         child: Text(
          //           "Auto-Continue",
          //           style: TextStyle(
          //             fontSize: 15,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ),
          //       ListTile(
          //         title: Text("Auto-Continue Timers"),
          //         trailing: Switch(
          //           value: settingsController.autoContinue,
          //           onChanged: (val) {
          //             settingsController.autoContinue = !settingsController.autoContinue;
          //           },
          //         ),
          //         onTap: () {
          //           settingsController.autoContinue = !settingsController.autoContinue;
          //         },
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
