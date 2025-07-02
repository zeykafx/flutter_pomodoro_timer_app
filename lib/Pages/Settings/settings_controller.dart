import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  // GetStorage box = GetStorage();

  RxBool blockSite = false.obs;
  RxList sitesToBlock = [].obs;

  RxBool enableNotifications = true.obs;
  RxBool autoContinue = false.obs;

  RxInt defaultMinutes = 25.obs;
  RxInt shortBreakLength = 5.obs;
  RxInt longBreakLength = 10.obs;

  SettingsController() {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      defaultMinutes.value = prefs.getInt("defaultMinutes") ?? 25;
      shortBreakLength.value = prefs.getInt("shortBreakLength") ?? 5;
      longBreakLength.value = prefs.getInt("longBreakLength") ?? 10;

      defaultMinutes.listen((int val) {
        prefs.setInt("defaultMinutes", val);
      });

      shortBreakLength.listen((int val) {
        prefs.setInt("shortBreakLength", val);
      });

      longBreakLength.listen((int val) {
        prefs.setInt("longBreakLength", val);
      });

      blockSite.value = prefs.getBool("BlockSite") ?? false;
      blockSite.listen((bool val) {
        prefs.setBool("BlockSite", val);
      });

      List boxVal = prefs.getStringList("sitesToBlock") ?? [];
      sitesToBlock.value = boxVal;
      sitesToBlock.listen((var newVal) {
        prefs.setStringList("sitesToBlock", newVal.cast());
      });

      enableNotifications.value = prefs.getBool("EnableNotifications") ?? true;
      enableNotifications.listen((bool val) {
        prefs.setBool("EnableNotifications", val);
      });

      autoContinue.value = prefs.getBool("AutoContinue") ?? false;
      autoContinue.listen((bool val) {
        prefs.setBool("AutoContinue", val);
      });
    });
  }
}
