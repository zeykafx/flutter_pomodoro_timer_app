import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/pomo_length.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Settings/site_blocker_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        children: [
          Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Settings",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const PomoLengthSettings(key: ValueKey("LengthSettings")),
                  if (!kIsWeb)
                    if (Platform.isWindows) const SiteBlockerSettings(key: ValueKey("SiteBlockerSettings")),
                ],
              )),
        ],
      ),
    );
  }
}
