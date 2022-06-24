import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/pomo_length.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/site_blocker_settings.dart';

class SettingsPage   extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

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

        const PomoLengthSettings(
          key: ValueKey("LengthSettings")
        ),

        if (Platform.isWindows)
          const SiteBlockerSettings(
            key: ValueKey("SiteBlockerSettings")
          ),
      ],
    );
  }
}
