import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/settings_controller.dart';
import 'package:flutter_pomodoro_timer_app/main.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SettingsController settingsController = Get.put(SettingsController());
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    textEditingController.text = settingsController.defaultMinutes.value.toString();
    settingsController.defaultMinutes.listen((int newData) {
      textEditingController.text = settingsController.defaultMinutes.value.toString();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Settings",
            style: TextStyle(fontSize: 20),
          ),
        ),

        // default minutes length
        Card(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(2.0),
                child: Text(
                  "Default Pomodoro session length",
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Divider(),
              [
                InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: const Icon(Icons.arrow_drop_down, size: 40),
                  onTap: () => settingsController.defaultMinutes--,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: Get.width / 3.5,
                    child: TextField(
                      controller: textEditingController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      onSubmitted: (String value) {
                        if (value.isNotEmpty) {
                          settingsController.defaultMinutes.value = int.parse(value);
                          FocusScope.of(context).unfocus();
                        }
                      },
                      onEditingComplete: () {
                        if (textEditingController.text.isNotEmpty) {
                          settingsController.defaultMinutes.value = int.parse(textEditingController.text);
                          FocusScope.of(context).unfocus();
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Default minutes",
                        labelText: "Default minutes",
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: const Icon(Icons.arrow_drop_up, size: 40),
                  onTap: () => settingsController.defaultMinutes++,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    settingsController.defaultMinutes.value = int.parse(textEditingController.text);
                    Get.snackbar("Saved!", "Saved default pomodoro length to ${settingsController.defaultMinutes} minutes",
                        padding: const EdgeInsets.all(8.0));
                  },
                  label: const Text("Save"),
                  icon: const Icon(FontAwesome5.save, size: 15),
                )
              ].toRow(mainAxisAlignment: MainAxisAlignment.center, separator: const Padding(padding: EdgeInsets.all(0))),
            ],
          ),
        ),

        if (Platform.isWindows)
          Card(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Text(
                    "Block sites during pomodoro session",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                const Text(
                  "You must run the app in administrator.",
                  style: TextStyle(fontSize: 10),
                ),
                const Divider(),
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: settingsController.blockSite.value,
                      onChanged: (bool? boolean) {
                        if (boolean != null) {
                          settingsController.blockSite.value = boolean;
                        }
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    Text(settingsController.blockSite.value ? "On" : "Off"),

                  ],
                )),
              ],
            ),
          ),
      ],
    );
  }
}
