import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/settings_section.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return const Text("Error loading package info");
          }
          return SettingsSection(
            title: "About Pomo Focus",
            children: [
              ListTile(
                  title: const Text(
                    "Pomo Focus",
                  ),
                  subtitle: Text("Version: ${snapshot.data?.version}\nBuild: ${snapshot.data?.buildNumber}"),
                  onTap: () {
                    showLicensePage(context: context);
                  },
                  trailing: const Text('View Licences'),),
              ListTile(
                title: const Text(
                  "Source Code",
                ),
                subtitle: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("You can find the source code at "),
                    Text("https://github.com/zeykafx/flutter_pomodoro_timer_app", style: TextStyle(color: Colors.blue)),
                  ],
                ),
                onTap: () {
                  // open the paypal link
                  launchUrlString("https://github.com/zeykafx/flutter_pomodoro_timer_app");
                },
                trailing: const Icon(Icons.open_in_new),
              ),
              ListTile(
                title: const Text(
                  "Made by Corentin Detry",
                ),
                subtitle: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("If you like this app, you can buy me a coffee at "),
                    Text("paypal.me/zeykafx", style: TextStyle(color: Colors.blue)),
                  ],
                ),
                onTap: () {
                  // open the paypal link
                  launchUrlString("https://paypal.me/zeykafx");
                },
                trailing: const Icon(Icons.open_in_new),
              ),
            ],
          );
        });
  }
}
