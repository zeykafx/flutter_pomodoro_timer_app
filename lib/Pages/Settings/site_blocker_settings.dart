import 'package:material_ui/material_ui.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/settings_controller.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class SiteBlockerSettings extends StatefulWidget {
  const SiteBlockerSettings({super.key});

  @override
  _SiteBlockerSettingsState createState() => _SiteBlockerSettingsState();
}

class _SiteBlockerSettingsState extends State<SiteBlockerSettings> {
  SettingsController settingsController = SettingsController.instance;
  TextEditingController siteToBlockController = TextEditingController();

  @override
  void initState() {
    siteToBlockController.text = settingsController.sitesToBlock.join(", ");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      key: const ValueKey("siteBlockerCard"),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(2.0),
            child: Text("Block sites during pomodoro session", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Text("You must run the app in administrator.", style: TextStyle(fontSize: 10)),
          const Divider(),
          ListenableBuilder(
            listenable: settingsController,
            builder: (context, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: settingsController.blockSite,
                  onChanged: (bool? boolean) {
                    if (boolean != null) {
                      settingsController.blockSite = boolean;
                    }
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                Text(settingsController.blockSite ? "On" : "Off"),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: siteToBlockController,
                    onSubmitted: (String value) {
                      if (value.isNotEmpty) {
                        List<String> sites = value.split(", ");
                        settingsController.sitesToBlock = sites;
                        FocusScope.of(context).unfocus();
                      }
                    },
                    onEditingComplete: () {
                      if (siteToBlockController.text.isNotEmpty) {
                        List<String> sites = siteToBlockController.text.split(", ");
                        settingsController.sitesToBlock = sites;
                        FocusScope.of(context).unfocus();
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter sites to block",
                      labelText: "Sites to block, e.g: \"youtube.com, discord.com\"",
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // settingsController.defaultMinutes = int.parse(textEditingController.text);
                  List<String> sites = siteToBlockController.text.split(", ");
                  settingsController.sitesToBlock = sites;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved sites to block!")));
                },
                label: const Text("Save"),
                icon: const Icon(FontAwesome5.save, size: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
