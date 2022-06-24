import 'dart:io';

import 'package:get/get.dart';

class SiteBlocker {
  File file = File("c:/windows/system32/drivers/etc/hosts");


  bool blockSites(List sites) {
    try {
      for (String site in sites) {
        // adding a www. in front if the site didn't have it
        if (!site.contains(RegExp(r'www.'))) {
          site = "www.$site";
        }
        file.writeAsStringSync("0.0.0.0 $site # POMO FOCUS, DO NOT REMOVE\n", mode: FileMode.append);
      }
      return true;
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
      e.printError();
      return false;
    }
  }

  bool unblockSites() {
    try {
      file.readAsString().then((String content) {
        String cleaned = content.replaceAll(RegExp(r'0.0.0.0 [a-zA-Z.]+ # POMO FOCUS, DO NOT REMOVE\n'), "");
        file.writeAsStringSync(cleaned);
      });
      return true;
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
      e.printError();
      return false;
    }
  }
}