import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  GetStorage box = GetStorage();

  RxBool blockSite = false.obs;
  RxList sitesToBlock = [].obs;

  RxInt defaultMinutes = 25.obs;
  RxInt shortBreakLength = 5.obs;
  RxInt longBreakLength = 10.obs;

  SettingsController() {
    defaultMinutes.value = box.read("defaultMinutes") ?? 25;
    shortBreakLength.value = box.read("shortBreakLength") ?? 5;
    longBreakLength.value = box.read("longBreakLength") ?? 10;

    defaultMinutes.listen((int val) {
      box.write("defaultMinutes", val);
    });

    shortBreakLength.listen((int val) {
      box.write("shortBreakLength", val);
    });

    longBreakLength.listen((int val) {
      box.write("longBreakLength", val);
    });

    blockSite.value = box.read("BlockSite") ?? false;
    blockSite.listen((bool val) {
      box.write("BlockSite", val);
    });

    List boxVal = box.read("sitesToBlock") ?? [];
    sitesToBlock.value = boxVal;
    sitesToBlock.listen((var newVal) {
      box.write("sitesToBlock", newVal);
    });
  }
}