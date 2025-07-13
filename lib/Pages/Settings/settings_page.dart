import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/pomo_length.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/about_section.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/site_blocker_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PomoLengthSettings(key: ValueKey("LengthSettings")),
                AboutSection(),
                if (!kIsWeb)
                  if (Platform.isWindows)
                    SiteBlockerSettings(
                      key: ValueKey("SiteBlockerSettings"),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
