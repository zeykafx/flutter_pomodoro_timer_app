import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/settings_controller.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';

class PomoLengthSettings extends StatefulWidget {
  const PomoLengthSettings({Key? key}) : super(key: key);

  @override
  _PomoLengthSettingsState createState() => _PomoLengthSettingsState();
}

class _PomoLengthSettingsState extends State<PomoLengthSettings> {
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
    return Card(
      key: const ValueKey("LengthCard"),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(2.0),
            child: Text(
              "Default Pomodoro session length",
              style: TextStyle(fontSize: 15),
            ),
          ),
          const Divider(),
          [
            InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: const Icon(Icons.arrow_drop_down, size: 40),
              onTap: () => settingsController.defaultMinutes--,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 50,
                child: TextField(
                  controller: textEditingController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'\d')),
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
                    // labelText: "Default minutes",
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
          ].toRow(mainAxisAlignment: MainAxisAlignment.center),
        ],
      ),
    );
  }
}
